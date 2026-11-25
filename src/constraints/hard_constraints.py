"""Hard Constraints (H1 - H7) for Class Scheduling.

H1: check_room_capacity()      - Room size >= section registration size
H2: check_session_spacing()    - 2 sessions not on same or adjacent days (|d1 - d2| >= 2)
H3: check_professor_conflict() - Professor cannot teach 2 classes at the same time
H4: check_professor_workload() - No professor teaches more than 20 sessions
H5: check_room_availability()  - Classes scheduled only in available classrooms
H6: check_section_conflict()   - A section cannot be in 2 rooms simultaneously
H7: check_room_conflict()      - A room cannot host 2 sections at the same time
"""

from __future__ import annotations

from collections import Counter
from typing import TYPE_CHECKING, Dict, Union

from src.models import Chromosome, Gene

if TYPE_CHECKING:
    from src.services.data_loader import ProblemData


def check_room_capacity(chromosome: Chromosome, data: ProblemData) -> int:
    """H1: Count sessions where room_size < section_registration_size."""
    room_sz = data.room_size_arr
    sec_sz = data.section_size_arr
    violations = 0
    for g in chromosome.genes:
        req = sec_sz[g.section_id]
        if room_sz[g.session_1.room_id] < req:
            violations += 1
        if room_sz[g.session_2.room_id] < req:
            violations += 1
    return violations


def check_session_spacing(target: Union[Gene, Chromosome]) -> int:
    """H2: Check |day1 - day2| >= 2. Accepts a single Gene (0/1) or full Chromosome."""
    if isinstance(target, Gene):
        return int(abs(target.session_1.day - target.session_2.day) < 2)
    violations = 0
    for g in target.genes:
        if abs(g.session_1.day - g.session_2.day) < 2:
            violations += 1
    return violations


def check_professor_conflict(chromosome: Chromosome, data: ProblemData) -> int:
    """H3: Count excess sessions when a professor is double-booked in the same (day, timeslot)."""
    counts = Counter()
    for g in chromosome.genes:
        counts[(g.professor_id, g.session_1.day, g.session_1.timeslot)] += 1
        counts[(g.professor_id, g.session_2.day, g.session_2.timeslot)] += 1
    return sum(c - 1 for c in counts.values() if c > 1)


def check_professor_workload(chromosome: Chromosome, data: ProblemData) -> int:
    """H4: Count excess sessions beyond max_sessions (20) per professor."""
    max_sess = data.prof_max_sessions_arr
    counts = Counter()
    for g in chromosome.genes:
        counts[g.professor_id] += 2
    return sum(c - int(max_sess[p]) for p, c in counts.items() if c > int(max_sess[p]))


def check_room_availability(chromosome: Chromosome, data: ProblemData) -> int:
    """H5: Count sessions placed in unavailable (day, timeslot, room) slots."""
    avail = data.room_avail_arr
    violations = 0
    for g in chromosome.genes:
        s1, s2 = g.session_1, g.session_2
        if not avail[s1.day, s1.timeslot, s1.room_id]:
            violations += 1
        if not avail[s2.day, s2.timeslot, s2.room_id]:
            violations += 1
    return violations


def check_section_conflict(chromosome: Chromosome) -> int:
    """H6: Count sections scheduled in two rooms at the exact same (day, timeslot)."""
    violations = 0
    for g in chromosome.genes:
        if g.session_1.day == g.session_2.day and g.session_1.timeslot == g.session_2.timeslot:
            violations += 1
    return violations


def check_room_conflict(chromosome: Chromosome, data: ProblemData) -> int:
    """H7: Count excess sessions when a room is double-booked in the same (day, timeslot)."""
    counts = Counter()
    for g in chromosome.genes:
        s1, s2 = g.session_1, g.session_2
        counts[(s1.day, s1.timeslot, s1.room_id)] += 1
        counts[(s2.day, s2.timeslot, s2.room_id)] += 1
    return sum(c - 1 for c in counts.values() if c > 1)


def evaluate_hard_constraints(chromosome: Chromosome, data: ProblemData) -> Dict[str, int]:
    """Evaluate all 7 hard constraints in a single high-speed pass (exact match with H1..H7)."""
    room_sz = data.room_size_arr
    sec_sz = data.section_size_arr
    avail = data.room_avail_arr
    max_sess = data.prof_max_sessions_arr

    n_profs = data.num_professors
    n_days = data.num_days
    n_ts = data.num_timeslots
    n_rooms = data.num_rooms

    prof_slot = [0] * (n_profs * n_days * n_ts)
    room_slot = [0] * (n_days * n_ts * n_rooms)
    prof_load = [0] * n_profs

    h1 = 0
    h2 = 0
    h3 = 0
    h5 = 0
    h6 = 0
    h7 = 0

    day_ts_stride = n_days * n_ts
    ts_room_stride = n_ts * n_rooms

    for g in chromosome.genes:
        p = g.professor_id
        req = sec_sz[g.section_id]
        s1 = g.session_1
        s2 = g.session_2
        d1, t1, r1 = s1.day, s1.timeslot, s1.room_id
        d2, t2, r2 = s2.day, s2.timeslot, s2.room_id

        if room_sz[r1] < req:
            h1 += 1
        if room_sz[r2] < req:
            h1 += 1

        if abs(d1 - d2) < 2:
            h2 += 1
        if d1 == d2 and t1 == t2:
            h6 += 1

        if not avail[d1, t1, r1]:
            h5 += 1
        if not avail[d2, t2, r2]:
            h5 += 1

        prof_load[p] += 2

        ps1 = p * day_ts_stride + d1 * n_ts + t1
        c_ps1 = prof_slot[ps1]
        if c_ps1:
            h3 += 1
        prof_slot[ps1] = c_ps1 + 1

        ps2 = p * day_ts_stride + d2 * n_ts + t2
        c_ps2 = prof_slot[ps2]
        if c_ps2:
            h3 += 1
        prof_slot[ps2] = c_ps2 + 1

        rs1 = d1 * ts_room_stride + t1 * n_rooms + r1
        c_rs1 = room_slot[rs1]
        if c_rs1:
            h7 += 1
        room_slot[rs1] = c_rs1 + 1

        rs2 = d2 * ts_room_stride + t2 * n_rooms + r2
        c_rs2 = room_slot[rs2]
        if c_rs2:
            h7 += 1
        room_slot[rs2] = c_rs2 + 1

    h4 = 0
    for p in range(n_profs):
        excess = prof_load[p] - int(max_sess[p])
        if excess > 0:
            h4 += excess

    return {
        "H1_room_capacity": h1,
        "H2_session_spacing": h2,
        "H3_professor_conflict": h3,
        "H4_professor_workload": h4,
        "H5_room_availability": h5,
        "H6_section_conflict": h6,
        "H7_room_conflict": h7,
        "hard_total": h1 + h2 + h3 + h4 + h5 + h6 + h7,
    }
