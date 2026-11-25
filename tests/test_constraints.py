"""Unit tests for Hard (H1-H7), Soft (S1-S5), and Bonus (B1-B2) constraints."""

import pytest

from src.constraints import (
    check_professor_conflict,
    check_professor_favorite_coverage,
    check_professor_out_of_list,
    check_professor_workload,
    check_room_availability,
    check_room_capacity,
    check_room_conflict,
    check_section_conflict,
    check_session_spacing,
    course_shift_conflict,
    professor_day_scatter,
    professor_idle_gap,
    professor_shift_conflict,
    room_size_mismatch,
)
from src.models import Chromosome, Course, Gene, Professor, Room, Section, Session
from src.services.data_loader import ProblemData


def _mini_data() -> ProblemData:
    courses = [Course(0, "c01", "Course 01"), Course(1, "c02", "Course 02")]
    sections = [
        Section(0, "c01-s01", 0, 2),  # Large
        Section(1, "c01-s02", 0, 0),  # Small
        Section(2, "c02-s01", 1, 1),  # Average
    ]
    avail_ok = [[True] * 6 for _ in range(5)]
    avail_blocked = [[True] * 6 for _ in range(5)]
    avail_blocked[0][0] = False
    rooms = [
        Room(0, "rm01", 0, avail_ok),       # Small
        Room(1, "rm02", 1, avail_ok),       # Average
        Room(2, "rm03", 2, avail_blocked),  # Large, unavailable at (Mon, slot 0)
    ]
    professors = [
        Professor(0, "p01", "Prof 01", eligible_courses=[0, 1], favorite_courses=[0], max_sessions=4),
        Professor(1, "p02", "Prof 02", eligible_courses=[1], favorite_courses=[1], max_sessions=4),
    ]
    return ProblemData(courses=courses, sections=sections, professors=professors, rooms=rooms)


def test_session_spacing_single_gene_and_chromosome():
    g_ok = Gene(0, 0, Session(0, 0, 2), Session(2, 0, 2))
    g_same = Gene(0, 0, Session(1, 0, 2), Session(1, 4, 2))
    g_adj = Gene(0, 0, Session(0, 0, 2), Session(1, 0, 2))

    assert check_session_spacing(g_ok) == 0
    assert check_session_spacing(g_same) == 1
    assert check_session_spacing(g_adj) == 1
    assert check_session_spacing(Chromosome([g_ok, g_same, g_adj])) == 2


def test_hard_constraints_detect_all_violations():
    data = _mini_data()
    # Gene 0: Large section in Small room (H1), unavailable slot (0,0,2) on session_2 (H5), same slot (H6)
    # Gene 1 & 2: Prof 0 double booked at (2, 1) (H3), Room 1 double booked at (2, 1) (H7), Prof 0 overload 6>4 (H4)
    genes = [
        Gene(0, 0, Session(0, 0, 0), Session(0, 0, 2)),  # H1(s1), H2, H5(s2), H6
        Gene(1, 0, Session(2, 1, 1), Session(4, 1, 0)),  # Valid spacing
        Gene(2, 0, Session(2, 1, 1), Session(4, 2, 1)),  # H3(p0@2,1), H7(r1@2,1), H4(p0 has 6>4)
    ]
    ch = Chromosome(genes=genes)

    assert check_room_capacity(ch, data) == 1
    assert check_session_spacing(ch) == 1
    assert check_professor_conflict(ch, data) == 2  # (0,0) twice for gene 0 + (2,1) twice for genes 1&2
    assert check_professor_workload(ch, data) == 2  # 6 - 4 = 2 excess sessions
    assert check_room_availability(ch, data) == 1   # rm03 blocked at (0, 0)
    assert check_section_conflict(ch) == 1          # gene 0 both sessions at (0, 0)
    assert check_room_conflict(ch, data) == 1       # rm02 at (2, 1)


def test_soft_constraints_exact_values():
    data = _mini_data()
    # Prof 0 teaches Mon slot 0 and Mon slot 5 -> 4 idle gaps (S1), 1 shift conflict (S3)
    # Prof 0 teaches Mon (0) and Thu (3) -> 2 day scatter gaps (Tue, Wed) (S2)
    # Section 1 (size 0) in Room 2 (size 2) -> waste +2 per session -> 4 total (S5)
    genes = [
        Gene(0, 0, Session(0, 0, 2), Session(3, 0, 2)),  # size 2 in room 2 -> 0 waste
        Gene(1, 0, Session(0, 5, 2), Session(3, 1, 2)),  # size 0 in room 2 -> 2+2=4 waste
    ]
    ch = Chromosome(genes=genes)

    assert professor_idle_gap(ch, data) == 4          # Mon: (5-0+1)-2 = 4; Thu: (1-0+1)-2 = 0
    assert professor_day_scatter(ch, data) == 2       # Mon(0) & Thu(3) -> Tue, Wed missing
    assert professor_shift_conflict(ch, data) == 1    # Mon has slot 0 (M) & slot 5 (A)
    assert room_size_mismatch(ch, data) == 4


def test_bonus_constraints_favorite_and_out_of_list():
    data = _mini_data()
    # Prof 1 only eligible for course 1; assigned course 0 -> out_of_list = 1, missing fav = 1
    genes = [
        Gene(0, 0, Session(0, 1, 2), Session(2, 1, 2)),  # p0 teaches c0 (fav!)
        Gene(1, 1, Session(1, 1, 0), Session(3, 1, 0)),  # p1 teaches c0 (NOT eligible, NOT fav)
    ]
    ch = Chromosome(genes=genes)

    assert check_professor_out_of_list(ch, data) == 1
    assert check_professor_favorite_coverage(ch, data) == 1
