"""Data loader and ProblemData container for Class Scheduling."""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Tuple

import numpy as np

import config
from src.models import Course, Professor, Room, Section


@dataclass
class ProblemData:
    courses: List[Course]
    sections: List[Section]
    professors: List[Professor]
    rooms: List[Room]
    num_days: int = config.NUM_DAYS
    num_timeslots: int = config.NUM_TIMESLOTS
    seed: int = config.RANDOM_SEED

    # Fast precomputed lookup arrays for high-speed GA evaluation & repair
    section_course_arr: np.ndarray = field(default_factory=lambda: np.array([], dtype=np.int32))
    section_size_arr: np.ndarray = field(default_factory=lambda: np.array([], dtype=np.int32))
    room_size_arr: np.ndarray = field(default_factory=lambda: np.array([], dtype=np.int32))
    room_avail_arr: np.ndarray = field(default_factory=lambda: np.array([], dtype=bool))
    prof_max_sessions_arr: np.ndarray = field(default_factory=lambda: np.array([], dtype=np.int32))
    is_eligible_arr: np.ndarray = field(default_factory=lambda: np.array([], dtype=bool))
    fav_rank_arr: np.ndarray = field(default_factory=lambda: np.array([], dtype=np.int32))

    course_eligible_profs: List[List[int]] = field(default_factory=list)
    course_favorite_profs: List[List[int]] = field(default_factory=list)
    feasible_rooms_exact: Dict[Tuple[int, int, int], List[int]] = field(default_factory=dict)
    feasible_rooms_compat: Dict[Tuple[int, int, int], List[int]] = field(default_factory=dict)

    def __post_init__(self) -> None:
        self.build_lookups()

    @property
    def num_courses(self) -> int:
        return len(self.courses)

    @property
    def num_sections(self) -> int:
        return len(self.sections)

    @property
    def num_sessions(self) -> int:
        return len(self.sections) * config.SESSIONS_PER_SECTION

    @property
    def num_professors(self) -> int:
        return len(self.professors)

    @property
    def num_rooms(self) -> int:
        return len(self.rooms)

    def build_lookups(self) -> None:
        n_c = len(self.courses)
        n_p = len(self.professors)
        n_r = len(self.rooms)

        self.section_course_arr = np.array([s.course_id for s in self.sections], dtype=np.int32)
        self.section_size_arr = np.array([s.registration_size for s in self.sections], dtype=np.int32)
        self.room_size_arr = np.array([r.size for r in self.rooms], dtype=np.int32)
        self.prof_max_sessions_arr = np.array([p.max_sessions for p in self.professors], dtype=np.int32)

        avail = np.zeros((self.num_days, self.num_timeslots, n_r), dtype=bool)
        for r in self.rooms:
            for d in range(self.num_days):
                for t in range(self.num_timeslots):
                    avail[d, t, r.id] = bool(r.availability[d][t])
        self.room_avail_arr = avail

        self.is_eligible_arr = np.zeros((n_p, n_c), dtype=bool)
        self.fav_rank_arr = np.zeros((n_p, n_c), dtype=np.int32)
        self.course_eligible_profs = [[] for _ in range(n_c)]
        self.course_favorite_profs = [[] for _ in range(n_c)]

        for p in self.professors:
            for c_id in p.eligible_courses:
                self.is_eligible_arr[p.id, c_id] = True
                self.course_eligible_profs[c_id].append(p.id)
            for rank_idx, c_id in enumerate(p.favorite_courses, start=1):
                self.fav_rank_arr[p.id, c_id] = rank_idx
                self.course_favorite_profs[c_id].append(p.id)

        self.feasible_rooms_exact = {}
        self.feasible_rooms_compat = {}
        for d in range(self.num_days):
            for t in range(self.num_timeslots):
                for sz in (0, 1, 2):
                    exact = [r.id for r in self.rooms if avail[d, t, r.id] and r.size == sz]
                    compat = [r.id for r in self.rooms if avail[d, t, r.id] and r.size >= sz]
                    self.feasible_rooms_exact[(d, t, sz)] = exact
                    self.feasible_rooms_compat[(d, t, sz)] = compat

    def feasibility_summary(self) -> Dict[str, object]:
        total_slots = int(self.room_avail_arr.size)
        avail_slots = int(self.room_avail_arr.sum())
        avail_by_size = {
            s: int(self.room_avail_arr[:, :, self.room_size_arr == s].sum()) for s in (0, 1, 2)
        }
        req_by_size = {
            s: int((self.section_size_arr == s).sum() * config.SESSIONS_PER_SECTION) for s in (0, 1, 2)
        }
        return {
            "total_room_slots": total_slots,
            "available_room_slots": avail_slots,
            "unavailable_room_slots": total_slots - avail_slots,
            "required_sessions": self.num_sessions,
            "utilization_pct": round(100.0 * self.num_sessions / avail_slots, 2),
            "rooms_per_size": {s: int((self.room_size_arr == s).sum()) for s in (0, 1, 2)},
            "sections_per_size": {s: int((self.section_size_arr == s).sum()) for s in (0, 1, 2)},
            "available_slots_per_size": avail_by_size,
            "required_sessions_per_size": req_by_size,
            "available_slots_per_day": [int(self.room_avail_arr[d].sum()) for d in range(self.num_days)],
            "available_morning_slots": int(self.room_avail_arr[:, :3, :].sum()),
            "available_afternoon_slots": int(self.room_avail_arr[:, 3:, :].sum()),
            "min_eligible_profs_per_course": min(len(x) for x in self.course_eligible_profs),
            "min_favorite_profs_per_course": min(len(x) for x in self.course_favorite_profs),
            "total_prof_session_capacity": int(self.prof_max_sessions_arr.sum()),
        }


def load_data(data_dir: Path | str = config.DATA_DIR) -> ProblemData:
    """Load courses.json, sections.json, professors.json, and rooms.json into ProblemData."""
    base = Path(data_dir)
    with (base / "courses.json").open("r", encoding="utf-8") as f:
        courses = [Course(**item) for item in json.load(f)]
    with (base / "sections.json").open("r", encoding="utf-8") as f:
        sections = [Section(**item) for item in json.load(f)]
    with (base / "professors.json").open("r", encoding="utf-8") as f:
        professors = [Professor(**item) for item in json.load(f)]
    with (base / "rooms.json").open("r", encoding="utf-8") as f:
        rooms = [Room(**item) for item in json.load(f)]

    return ProblemData(courses=courses, sections=sections, professors=professors, rooms=rooms)
