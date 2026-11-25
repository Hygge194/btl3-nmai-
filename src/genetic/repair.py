"""Constraint-based Repair Mechanism & Same-Day Pairwise Swap Local Search.

Eliminates hard conflicts (H1-H7) and strict bonus violations (B2, B1a),
then refines soft constraints (S1-S5) via single-session relocation and
same-day pairwise session swaps (breaking 93.75% room-utilization gridlock).
"""

from __future__ import annotations

from typing import List, Tuple

import numpy as np

import config
from src.models import Chromosome
from src.services.data_loader import ProblemData


def repair_chromosome(
    chromosome: Chromosome,
    data: ProblemData,
    rng: np.random.Generator,
    max_hard_steps: int = 80,
    max_soft_steps: int = 40,
) -> Chromosome:
    """In-place constraint-based repair + lightweight memetic soft polishing."""
    n_sec = data.num_sections
    n_profs = data.num_professors
    n_days = data.num_days
    n_ts = data.num_timeslots
    n_rooms = data.num_rooms
    genes = chromosome.genes

    room_cnt = np.zeros((n_days, n_ts, n_rooms), dtype=np.int32)
    prof_cnt = np.zeros((n_profs, n_days, n_ts), dtype=np.int32)
    prof_load = np.zeros(n_profs, dtype=np.int32)  # sections (<= 10)
    prof_fav = np.zeros(n_profs, dtype=np.int32)

    for g in genes:
        p = g.professor_id
        c = int(data.section_course_arr[g.section_id])
        s1, s2 = g.session_1, g.session_2
        room_cnt[s1.day, s1.timeslot, s1.room_id] += 1
        room_cnt[s2.day, s2.timeslot, s2.room_id] += 1
        prof_cnt[p, s1.day, s1.timeslot] += 1
        prof_cnt[p, s2.day, s2.timeslot] += 1
        prof_load[p] += 1
        if data.fav_rank_arr[p, c] > 0:
            prof_fav[p] += 1

    # --- Phase 1: Repair B2 (out-of-list), H4 (prof workload > 10 sections), B1a (missing fav) ---
    for sec_id in rng.permutation(n_sec):
        g = genes[int(sec_id)]
        p = g.professor_id
        c = int(data.section_course_arr[g.section_id])
        if data.is_eligible_arr[p, c] and prof_load[p] <= 10:
            continue

        s1, s2 = g.session_1, g.session_2
        best_p = -1
        best_sc = 1e9
        for cand in data.course_eligible_profs[c]:
            if prof_load[cand] >= 10:
                continue
            clash = (1 if prof_cnt[cand, s1.day, s1.timeslot] > 0 else 0) + (
                1 if prof_cnt[cand, s2.day, s2.timeslot] > 0 else 0
            )
            fav_bonus = (
                -50.0
                if (data.fav_rank_arr[cand, c] > 0 and prof_fav[cand] == 0)
                else (-5.0 if data.fav_rank_arr[cand, c] > 0 else 0.0)
            )
            sc = clash * 100.0 + prof_load[cand] * 0.5 + fav_bonus
            if sc < best_sc:
                best_sc = sc
                best_p = cand

        if best_p != -1 and best_p != p:
            prof_cnt[p, s1.day, s1.timeslot] -= 1
            prof_cnt[p, s2.day, s2.timeslot] -= 1
            prof_load[p] -= 1
            if data.fav_rank_arr[p, c] > 0:
                prof_fav[p] -= 1

            g.professor_id = best_p
            prof_cnt[best_p, s1.day, s1.timeslot] += 1
            prof_cnt[best_p, s2.day, s2.timeslot] += 1
            prof_load[best_p] += 1
            if data.fav_rank_arr[best_p, c] > 0:
                prof_fav[best_p] += 1

    # Guarantee every professor has >= 1 favorite class (Bonus 1)
    for p in np.where(prof_fav == 0)[0]:
        p = int(p)
        if prof_load[p] >= 10:
            continue
        assigned = False
        for fav_c in data.professors[p].favorite_courses:
            start = fav_c * config.SECTIONS_PER_COURSE
            for sec_id in range(start, start + config.SECTIONS_PER_COURSE):
                g = genes[sec_id]
                old_p = g.professor_id
                if old_p == p:
                    assigned = True
                    break
                if data.fav_rank_arr[old_p, fav_c] > 0 and prof_fav[old_p] <= 1:
                    continue
                s1, s2 = g.session_1, g.session_2
                if prof_cnt[p, s1.day, s1.timeslot] == 0 and prof_cnt[p, s2.day, s2.timeslot] == 0:
                    prof_cnt[old_p, s1.day, s1.timeslot] -= 1
                    prof_cnt[old_p, s2.day, s2.timeslot] -= 1
                    prof_load[old_p] -= 1
                    if data.fav_rank_arr[old_p, fav_c] > 0:
                        prof_fav[old_p] -= 1

                    g.professor_id = p
                    prof_cnt[p, s1.day, s1.timeslot] += 1
                    prof_cnt[p, s2.day, s2.timeslot] += 1
                    prof_load[p] += 1
                    prof_fav[p] += 1
                    assigned = True
                    break
            if assigned:
                break

    # Majority-vote preferred shift (Morning vs Afternoon) per course for S4
    course_morn = np.zeros(data.num_courses, dtype=np.int32)
    for g in genes:
        c = int(data.section_course_arr[g.section_id])
        if g.session_1.timeslot < 3:
            course_morn[c] += 1
        if g.session_2.timeslot < 3:
            course_morn[c] += 1
    course_pref_shift = (course_morn < 8).astype(np.int32)  # 0=Morning, 1=Afternoon

    # --- Phase 2: Repair Hard Conflicts (H1, H2, H3, H5, H6, H7) ---
    bad_secs: List[Tuple[int, bool, bool]] = []
    for g in genes:
        p = g.professor_id
        sz = int(data.section_size_arr[g.section_id])
        s1, s2 = g.session_1, g.session_2
        spacing_bad = abs(s1.day - s2.day) < 2
        b1 = (
            spacing_bad
            or room_cnt[s1.day, s1.timeslot, s1.room_id] > 1
            or prof_cnt[p, s1.day, s1.timeslot] > 1
            or data.room_size_arr[s1.room_id] < sz
            or not data.room_avail_arr[s1.day, s1.timeslot, s1.room_id]
        )
        b2 = (
            spacing_bad
            or room_cnt[s2.day, s2.timeslot, s2.room_id] > 1
            or prof_cnt[p, s2.day, s2.timeslot] > 1
            or data.room_size_arr[s2.room_id] < sz
            or not data.room_avail_arr[s2.day, s2.timeslot, s2.room_id]
        )
        if b1 or b2:
            bad_secs.append((g.section_id, b1, b2))

    rng.shuffle(bad_secs)
    for step, (sec_id, b1, b2) in enumerate(bad_secs):
        if step >= max_hard_steps:
            break
        g = genes[sec_id]
        p = g.professor_id
        c = int(data.section_course_arr[sec_id])
        sz = int(data.section_size_arr[sec_id])
        pref_slots = (0, 1, 2) if course_pref_shift[c] == 0 else (3, 4, 5)
        s1, s2 = g.session_1, g.session_2

        fixed_all = abs(s1.day - s2.day) >= 2
        if fixed_all:
            for sess, is_bad in ((s1, b1), (s2, b2)):
                if not is_bad:
                    continue
                still_bad = (
                    room_cnt[sess.day, sess.timeslot, sess.room_id] > 1
                    or prof_cnt[p, sess.day, sess.timeslot] > 1
                    or data.room_size_arr[sess.room_id] < sz
                    or not data.room_avail_arr[sess.day, sess.timeslot, sess.room_id]
                )
                if not still_bad:
                    continue
                move = _find_best_slot_room(data, room_cnt, prof_cnt, p, sess.day, sz, pref_slots)
                if move is not None:
                    nt, nr = move
                    room_cnt[sess.day, sess.timeslot, sess.room_id] -= 1
                    prof_cnt[p, sess.day, sess.timeslot] -= 1
                    sess.timeslot, sess.room_id = nt, nr
                    room_cnt[sess.day, nt, nr] += 1
                    prof_cnt[p, sess.day, nt] += 1
                else:
                    fixed_all = False

        if not fixed_all:
            room_cnt[s1.day, s1.timeslot, s1.room_id] -= 1
            room_cnt[s2.day, s2.timeslot, s2.room_id] -= 1
            prof_cnt[p, s1.day, s1.timeslot] -= 1
            prof_cnt[p, s2.day, s2.timeslot] -= 1

            placed = False
            for dp_idx in rng.permutation(len(config.VALID_DAY_PAIRS)):
                nd1, nd2 = config.VALID_DAY_PAIRS[int(dp_idx)]
                m1 = _find_best_slot_room(data, room_cnt, prof_cnt, p, nd1, sz, pref_slots)
                m2 = _find_best_slot_room(data, room_cnt, prof_cnt, p, nd2, sz, pref_slots)
                if m1 is not None and m2 is not None:
                    s1.day, s1.timeslot, s1.room_id = nd1, m1[0], m1[1]
                    s2.day, s2.timeslot, s2.room_id = nd2, m2[0], m2[1]
                    room_cnt[nd1, m1[0], m1[1]] += 1
                    room_cnt[nd2, m2[0], m2[1]] += 1
                    prof_cnt[p, nd1, m1[0]] += 1
                    prof_cnt[p, nd2, m2[0]] += 1
                    placed = True
                    break

            if not placed:
                room_cnt[s1.day, s1.timeslot, s1.room_id] += 1
                room_cnt[s2.day, s2.timeslot, s2.room_id] += 1
                prof_cnt[p, s1.day, s1.timeslot] += 1
                prof_cnt[p, s2.day, s2.timeslot] += 1

    # --- Phase 3: Single-Session Soft Polishing (S1, S3, S4, S5) ---
    sample_secs = rng.choice(n_sec, size=min(max_soft_steps, n_sec), replace=False)
    for sec_id in sample_secs:
        g = genes[int(sec_id)]
        p = g.professor_id
        c = int(data.section_course_arr[g.section_id])
        sz = int(data.section_size_arr[g.section_id])
        pref_slots = (0, 1, 2) if course_pref_shift[c] == 0 else (3, 4, 5)

        for sess in (g.session_1, g.session_2):
            d, cur_t, cur_r = sess.day, sess.timeslot, sess.room_id
            if room_cnt[d, cur_t, cur_r] != 1 or prof_cnt[p, d, cur_t] != 1:
                continue

            room_cnt[d, cur_t, cur_r] -= 1
            prof_cnt[p, d, cur_t] -= 1
            best_t, best_r = cur_t, cur_r
            best_sc = _local_soft_cost(data, prof_cnt[p, d], cur_t, cur_r, sz, pref_slots)

            for cand_t in range(n_ts):
                if prof_cnt[p, d, cand_t] > 0:
                    continue
                rooms = data.feasible_rooms_compat[(d, cand_t, sz)]
                free = [r for r in rooms if room_cnt[d, cand_t, r] == 0]
                if not free:
                    continue
                cand_r = min(free, key=lambda r: int(data.room_size_arr[r]) - sz)
                sc = _local_soft_cost(data, prof_cnt[p, d], cand_t, cand_r, sz, pref_slots)
                if sc < best_sc:
                    best_sc = sc
                    best_t, best_r = cand_t, cand_r

            sess.timeslot, sess.room_id = best_t, best_r
            room_cnt[d, best_t, best_r] += 1
            prof_cnt[p, d, best_t] += 1

    # --- Phase 4: Same-Day Pairwise Session Swaps (breaks 93.75% utilization gridlock) ---
    day_sessions: List[List[Tuple[int, bool]]] = [[] for _ in range(n_days)]
    for g in genes:
        day_sessions[g.session_1.day].append((g.section_id, False))
        day_sessions[g.session_2.day].append((g.section_id, True))

    for _ in range(max_soft_steps * 2):
        d = int(rng.integers(0, n_days))
        slist = day_sessions[d]
        if len(slist) < 2:
            continue
        ia = int(rng.integers(0, len(slist)))
        ib = int(rng.integers(0, len(slist)))
        if ia == ib:
            continue
        sec_a, is2_a = slist[ia]
        sec_b, is2_b = slist[ib]
        if sec_a == sec_b:
            continue

        ga, gb = genes[sec_a], genes[sec_b]
        sa_obj = ga.session_2 if is2_a else ga.session_1
        sb_obj = gb.session_2 if is2_b else gb.session_1
        ta, ra = sa_obj.timeslot, sa_obj.room_id
        tb, rb = sb_obj.timeslot, sb_obj.room_id
        pa, pb = ga.professor_id, gb.professor_id
        sza, szb = int(data.section_size_arr[sec_a]), int(data.section_size_arr[sec_b])

        if data.room_size_arr[rb] < sza or data.room_size_arr[ra] < szb:
            continue
        if not data.room_avail_arr[d, tb, rb] or not data.room_avail_arr[d, ta, ra]:
            continue
        if room_cnt[d, ta, ra] != 1 or room_cnt[d, tb, rb] != 1:
            continue
        if prof_cnt[pa, d, ta] != 1 or prof_cnt[pb, d, tb] != 1:
            continue
        if pa != pb and ta != tb:
            if prof_cnt[pa, d, tb] > 0 or prof_cnt[pb, d, ta] > 0:
                continue

        ca, cb = int(data.section_course_arr[sec_a]), int(data.section_course_arr[sec_b])
        pref_a = (0, 1, 2) if course_pref_shift[ca] == 0 else (3, 4, 5)
        pref_b = (0, 1, 2) if course_pref_shift[cb] == 0 else (3, 4, 5)

        prof_cnt[pa, d, ta] -= 1
        prof_cnt[pb, d, tb] -= 1

        before = _local_soft_cost(data, prof_cnt[pa, d], ta, ra, sza, pref_a)
        if pa == pb:
            prof_cnt[pa, d, ta] += 1
            before += _local_soft_cost(data, prof_cnt[pb, d], tb, rb, szb, pref_b)
            prof_cnt[pa, d, ta] -= 1
        else:
            before += _local_soft_cost(data, prof_cnt[pb, d], tb, rb, szb, pref_b)

        after = _local_soft_cost(data, prof_cnt[pa, d], tb, rb, sza, pref_a)
        if pa == pb:
            prof_cnt[pa, d, tb] += 1
            after += _local_soft_cost(data, prof_cnt[pb, d], ta, ra, szb, pref_b)
            prof_cnt[pa, d, tb] -= 1
        else:
            after += _local_soft_cost(data, prof_cnt[pb, d], ta, ra, szb, pref_b)

        if after < before:
            sa_obj.timeslot, sa_obj.room_id = tb, rb
            sb_obj.timeslot, sb_obj.room_id = ta, ra
            prof_cnt[pa, d, tb] += 1
            prof_cnt[pb, d, ta] += 1
        else:
            prof_cnt[pa, d, ta] += 1
            prof_cnt[pb, d, tb] += 1

    return chromosome


def _local_soft_cost(
    data: ProblemData,
    prof_day_occ: np.ndarray,
    t: int,
    r: int,
    sec_size: int,
    pref_slots: Tuple[int, int, int],
) -> float:
    w = config.SOFT_WEIGHTS
    cost = w["room_mismatch"] * max(0, int(data.room_size_arr[r]) - sec_size)
    if t not in pref_slots:
        cost += w["course_shift"]

    occupied = [slot for slot in range(6) if prof_day_occ[slot] > 0]
    occupied.append(t)
    if len(occupied) >= 2:
        lo, hi = min(occupied), max(occupied)
        gaps = (hi - lo + 1) - len(occupied)
        cost += w["idle_gap"] * gaps
        if lo < 3 and hi >= 3:
            cost += w["prof_shift"]
    return cost


def _find_best_slot_room(
    data: ProblemData,
    room_cnt: np.ndarray,
    prof_cnt: np.ndarray,
    p: int,
    d: int,
    sec_size: int,
    pref_slots: Tuple[int, int, int],
) -> Tuple[int, int] | None:
    best = None
    best_sc = 1e9
    for t in range(data.num_timeslots):
        if prof_cnt[p, d, t] > 0:
            continue
        rooms = data.feasible_rooms_compat[(d, t, sec_size)]
        free = [r for r in rooms if room_cnt[d, t, r] == 0]
        if not free:
            continue
        r = min(free, key=lambda rm: int(data.room_size_arr[rm]) - sec_size)
        sc = _local_soft_cost(data, prof_cnt[p, d], t, r, sec_size, pref_slots)
        if sc < best_sc:
            best_sc = sc
            best = (t, r)
    return best
