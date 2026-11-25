"""Population initialization strategies: Random (Baseline) and Greedy Randomized."""

from __future__ import annotations

from typing import List, Tuple

import numpy as np

import config
from src.models import Chromosome, Gene, Session
from src.services.data_loader import ProblemData


def random_initialize(data: ProblemData, rng: np.random.Generator) -> Chromosome:
    """Uniform random initialization (used by Baseline GA)."""
    genes: List[Gene] = []
    for sec in data.sections:
        p = int(rng.integers(0, data.num_professors))
        dp_idx = int(rng.integers(0, len(config.VALID_DAY_PAIRS)))
        d1, d2 = config.VALID_DAY_PAIRS[dp_idx]
        t1 = int(rng.integers(0, data.num_timeslots))
        r1 = int(rng.integers(0, data.num_rooms))
        t2 = int(rng.integers(0, data.num_timeslots))
        r2 = int(rng.integers(0, data.num_rooms))
        genes.append(
            Gene(
                section_id=sec.id,
                professor_id=p,
                session_1=Session(day=d1, timeslot=t1, room_id=r1),
                session_2=Session(day=d2, timeslot=t2, room_id=r2),
            )
        )
    return Chromosome(genes=genes)


def greedy_randomized_initialize(data: ProblemData, rng: np.random.Generator) -> Chromosome:
    """Capacity-balanced, domain-aware Greedy Randomized Initialization.

    Key insights:
    - Samples valid day pairs with BALANCED_DAY_PAIR_PROBS so E[load] = 192 sessions/day
      (avoiding the 240 > 210 Mon/Fri bottleneck).
    - Splits courses 50/50 into Morning vs. Afternoon shifts for S4 alignment.
    - Assigns eligible/favorite professors within max 10 sections (20 sessions).
    - Places large sections first into unoccupied, available, exact-size rooms.
    """
    n_sec = data.num_sections
    n_courses = data.num_courses
    n_profs = data.num_professors

    # 50/50 split of courses into Morning (0..2) and Afternoon (3..5)
    course_shift = np.zeros(n_courses, dtype=np.int32)
    aft_courses = rng.choice(n_courses, size=n_courses // 2, replace=False)
    course_shift[aft_courses] = 1

    # Balanced day pairs per section
    dp_indices = rng.choice(
        len(config.VALID_DAY_PAIRS), size=n_sec, p=config.BALANCED_DAY_PAIR_PROBS
    )

    # Assign professors (favorite-biased within eligible list, respecting <= 10 sections)
    prof_assign = np.zeros(n_sec, dtype=np.int32)
    prof_sec_load = np.zeros(n_profs, dtype=np.int32)

    for sec_id in rng.permutation(n_sec):
        c_id = int(data.section_course_arr[sec_id])
        favs = data.course_favorite_profs[c_id]
        eligs = data.course_eligible_profs[c_id]

        cand = [p for p in favs if prof_sec_load[p] < 10]
        if not cand or rng.random() < 0.12:
            cand_e = [p for p in eligs if prof_sec_load[p] < 10]
            if cand_e:
                cand = cand_e
        if not cand:
            cand = eligs if eligs else list(range(n_profs))

        weights = np.array([1.0 / (1.0 + prof_sec_load[p]) for p in cand], dtype=np.float64)
        weights /= weights.sum()
        chosen_p = int(rng.choice(cand, p=weights))
        prof_assign[sec_id] = chosen_p
        prof_sec_load[chosen_p] += 1

    # Greedy-randomized room & timeslot placement (largest sections first)
    room_occ = np.zeros((data.num_days, data.num_timeslots, data.num_rooms), dtype=bool)
    prof_occ = np.zeros((n_profs, data.num_days, data.num_timeslots), dtype=bool)

    genes: List[Gene | None] = [None] * n_sec
    order_by_size = np.lexsort((rng.random(n_sec), -data.section_size_arr))

    for sec_id in order_by_size:
        sec_id = int(sec_id)
        c_id = int(data.section_course_arr[sec_id])
        p_id = int(prof_assign[sec_id])
        sz = int(data.section_size_arr[sec_id])
        d1, d2 = config.VALID_DAY_PAIRS[int(dp_indices[sec_id])]
        pref_slots = [0, 1, 2] if course_shift[c_id] == 0 else [3, 4, 5]

        t1, r1 = _pick_free_slot_room(data, rng, room_occ, prof_occ, p_id, d1, sz, pref_slots)
        room_occ[d1, t1, r1] = True
        prof_occ[p_id, d1, t1] = True

        t2, r2 = _pick_free_slot_room(data, rng, room_occ, prof_occ, p_id, d2, sz, pref_slots)
        room_occ[d2, t2, r2] = True
        prof_occ[p_id, d2, t2] = True

        genes[sec_id] = Gene(
            section_id=sec_id,
            professor_id=p_id,
            session_1=Session(day=d1, timeslot=t1, room_id=r1),
            session_2=Session(day=d2, timeslot=t2, room_id=r2),
        )

    return Chromosome(genes=[g for g in genes if g is not None])


def _pick_free_slot_room(
    data: ProblemData,
    rng: np.random.Generator,
    room_occ: np.ndarray,
    prof_occ: np.ndarray,
    p_id: int,
    day: int,
    sec_size: int,
    pref_slots: List[int],
) -> Tuple[int, int]:
    other_slots = [t for t in range(data.num_timeslots) if t not in pref_slots]
    slot_groups = [list(rng.permutation(pref_slots)), list(rng.permutation(other_slots))]

    for exact_only in (True, False):
        for slots in slot_groups:
            for t in slots:
                t = int(t)
                if prof_occ[p_id, day, t]:
                    continue
                rooms = (
                    data.feasible_rooms_exact[(day, t, sec_size)]
                    if exact_only
                    else data.feasible_rooms_compat[(day, t, sec_size)]
                )
                free = [r for r in rooms if not room_occ[day, t, r]]
                if free:
                    return t, int(rng.choice(free))

    # Fallback: ignore professor clash, find any free compatible room
    for slots in slot_groups:
        for t in slots:
            t = int(t)
            rooms = data.feasible_rooms_compat[(day, t, sec_size)]
            free = [r for r in rooms if not room_occ[day, t, r]]
            if free:
                return t, int(rng.choice(free))

    # Last fallback
    t = int(rng.choice(pref_slots))
    rooms = data.feasible_rooms_compat[(day, t, sec_size)]
    if rooms:
        return t, int(rng.choice(rooms))
    return t, int(rng.integers(0, data.num_rooms))
