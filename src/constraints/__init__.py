"""Constraint Module: Hard (H1-H7), Soft (S1-S5), and Bonus (B1-B2) checks."""

from .hard_constraints import (
    check_professor_conflict,
    check_professor_workload,
    check_room_availability,
    check_room_capacity,
    check_room_conflict,
    check_section_conflict,
    check_session_spacing,
    evaluate_hard_constraints,
)
from .soft_constraints import (
    course_shift_conflict,
    evaluate_soft_constraints,
    professor_day_scatter,
    professor_idle_gap,
    professor_shift_conflict,
    room_size_mismatch,
)
from .bonus_constraints import (
    check_professor_favorite_coverage,
    check_professor_out_of_list,
    count_non_favorite_sections,
    evaluate_bonus_constraints,
)

__all__ = [
    "check_room_capacity",
    "check_session_spacing",
    "check_professor_conflict",
    "check_professor_workload",
    "check_room_availability",
    "check_section_conflict",
    "check_room_conflict",
    "evaluate_hard_constraints",
    "professor_idle_gap",
    "professor_day_scatter",
    "professor_shift_conflict",
    "course_shift_conflict",
    "room_size_mismatch",
    "evaluate_soft_constraints",
    "check_professor_favorite_coverage",
    "count_non_favorite_sections",
    "check_professor_out_of_list",
    "evaluate_bonus_constraints",
]
