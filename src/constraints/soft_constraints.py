"""Soft Constraints (S1 - S5) for Class Scheduling.

S1: professor_idle_gap()       - Minimize idle timeslot gaps within a day for each professor
S2: professor_day_scatter()    - Minimize idle day gaps across the week for each professor
S3: professor_shift_conflict() - Professor prefers morning-only (0-2) or afternoon-only (3-5) per day
S4: course_shift_conflict()    - All sessions of a course prefer morning-only or afternoon-only
S5: room_size_mismatch()       - Minimize room_size - section_registration_size waste
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Dict, List, Set

import config
from src.models import Chromosome

if TYPE_CHECKING:
    from src.services.data_loader import ProblemData


def _build_prof_day_slots(chromosome: Chromosome, num_profs: int, num_days: int) -> List[List[Set[int]]]:
    grid: List[List[Set[int]]] = [[set() for _ in range(num_days)] for _ in range(num_profs)]
    for g in chromosome.genes:
        p = g.professor_id
        grid[p][g.session_1.day].add(g.session_1.timeslot)
        grid[p][g.session_2.day].add(g.session_2.timeslot)
    return grid


def professor_idle_gap(chromosome: Chromosome, data: ProblemData) -> int:
    """S1: Sum of idle timeslots between first and last class per (professor, day)."""
    grid = _build_prof_day_slots(chromosome, data.num_professors, data.num_days)
    gaps = 0
    for p_days in grid:
        for slots in p_days:
            if len(slots) >= 2:
                gaps += (max(slots) - min(slots) + 1) - len(slots)
    return gaps


def professor_day_scatter(chromosome: Chromosome, data: ProblemData) -> int:
    """S2: Sum of idle gap days between first and last teaching day in the week per professor."""
    grid = _build_prof_day_slots(chromosome, data.num_professors, data.num_days)
    scatter = 0
    for p_days in grid:
        active = [d for d, slots in enumerate(p_days) if slots]
        if len(active) >= 2:
            scatter += (active[-1] - active[0] + 1) - len(active)
    return scatter


def professor_shift_conflict(chromosome: Chromosome, data: ProblemData) -> int:
    """S3: Count (professor, day) pairs having classes in BOTH morning (0-2) and afternoon (3-5)."""
    grid = _build_prof_day_slots(chromosome, data.num_professors, data.num_days)
    conflicts = 0
    for p_days in grid:
        for slots in p_days:
            if len(slots) >= 2:
                if min(slots) < 3 and max(slots) >= 3:
                    conflicts += 1
    return conflicts


def course_shift_conflict(chromosome: Chromosome, data: ProblemData) -> int:
    """S4: Count sessions disagreeing with their course's dominant shift (morning vs afternoon)."""
    sec_course = data.section_course_arr
    morn = [0] * data.num_courses
    total_per_course = config.SECTIONS_PER_COURSE * config.SESSIONS_PER_SECTION
    for g in chromosome.genes:
        c = int(sec_course[g.section_id])
        if g.session_1.timeslot < 3:
            morn[c] += 1
        if g.session_2.timeslot < 3:
            morn[c] += 1
    return sum(min(m, total_per_course - m) for m in morn)


def room_size_mismatch(chromosome: Chromosome, data: ProblemData) -> int:
    """S5: Total excess room size units (room_size - section_size) across compatible sessions."""
    room_sz = data.room_size_arr
    sec_sz = data.section_size_arr
    waste = 0
    for g in chromosome.genes:
        req = int(sec_sz[g.section_id])
        d1 = int(room_sz[g.session_1.room_id]) - req
        d2 = int(room_sz[g.session_2.room_id]) - req
        if d1 > 0:
            waste += d1
        if d2 > 0:
            waste += d2
    return waste


def evaluate_soft_constraints(chromosome: Chromosome, data: ProblemData) -> Dict[str, int]:
    """Evaluate all 5 soft constraints in a single ultra-fast bitmask pass."""
    n_profs = data.num_professors
    n_days = data.num_days
    n_courses = data.num_courses
    room_sz = data.room_size_arr
    sec_sz = data.section_size_arr
    sec_course = data.section_course_arr

    # Bitmask per (professor, day): bits 0..5 represent timeslots 0..5
    pd_mask = [0] * (n_profs * n_days)
    course_morn = [0] * n_courses
    s5_waste = 0
    exact_matches = 0

    for g in chromosome.genes:
        p_off = g.professor_id * n_days
        c = int(sec_course[g.section_id])
        req = int(sec_sz[g.section_id])

        s1 = g.session_1
        pd_mask[p_off + s1.day] |= 1 << s1.timeslot
        if s1.timeslot < 3:
            course_morn[c] += 1
        d1 = int(room_sz[s1.room_id]) - req
        if d1 == 0:
            exact_matches += 1
        elif d1 > 0:
            s5_waste += d1

        s2 = g.session_2
        pd_mask[p_off + s2.day] |= 1 << s2.timeslot
        if s2.timeslot < 3:
            course_morn[c] += 1
        d2 = int(room_sz[s2.room_id]) - req
        if d2 == 0:
            exact_matches += 1
        elif d2 > 0:
            s5_waste += d2

    s1_gaps = 0
    s2_scatter = 0
    s3_prof_shift = 0

    for p in range(n_profs):
        p_off = p * n_days
        first_d = -1
        last_d = -1
        day_cnt = 0
        for d in range(n_days):
            m = pd_mask[p_off + d]
            if m:
                if first_d == -1:
                    first_d = d
                last_d = d
                day_cnt += 1
                cnt = m.bit_count()
                if cnt >= 2:
                    hi = m.bit_length() - 1
                    lo = (m & -m).bit_length() - 1
                    s1_gaps += (hi - lo + 1) - cnt
                    if (m & 0b000111) and (m & 0b111000):
                        s3_prof_shift += 1
        if day_cnt >= 2:
            s2_scatter += (last_d - first_d + 1) - day_cnt

    total_per_course = config.SECTIONS_PER_COURSE * config.SESSIONS_PER_SECTION
    s4_course_shift = 0
    for m in course_morn:
        other = total_per_course - m
        s4_course_shift += m if m < other else other

    return {
        "S1_professor_idle_gap": s1_gaps,
        "S2_professor_day_scatter": s2_scatter,
        "S3_professor_shift_conflict": s3_prof_shift,
        "S4_course_shift_conflict": s4_course_shift,
        "S5_room_size_mismatch": s5_waste,
        "exact_size_matches": exact_matches,
    }
