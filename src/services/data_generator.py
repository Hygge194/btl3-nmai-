"""Random yet guaranteed-feasible dataset generator for Class Scheduling.

Creates and saves:
- data/courses.json
- data/sections.json
- data/professors.json
- data/rooms.json
"""

from __future__ import annotations

import json
from dataclasses import asdict
from pathlib import Path
from typing import List

import numpy as np

import config
from src.models import Course, Professor, Room, Section
from src.services.data_loader import ProblemData


def generate_data(
    seed: int = config.RANDOM_SEED,
    unavailable_ratio: float = config.ROOM_UNAVAILABLE_RATIO,
    save_dir: Path | str | None = config.DATA_DIR,
) -> ProblemData:
    """Generate a reproducible feasible ProblemData instance and optionally save to JSON files."""
    rng = np.random.default_rng(seed)

    # 1. Courses (c01..c60)
    courses: List[Course] = [
        Course(id=i, code=f"c{i + 1:02d}", name=f"Course {i + 1:02d}")
        for i in range(config.NUM_COURSES)
    ]

    # 2. Room sizes, Section sizes, and Room availability (with mathematical feasibility guard)
    while True:
        room_sizes = rng.choice([0, 1, 2], size=config.NUM_ROOMS, p=[0.30, 0.35, 0.35]).astype(np.int32)
        sec_sizes = rng.choice([0, 1, 2], size=config.NUM_SECTIONS, p=[0.34, 0.34, 0.32]).astype(np.int32)

        avail = np.ones((config.NUM_DAYS, config.NUM_TIMESLOTS, config.NUM_ROOMS), dtype=bool)
        num_unavail = int(round(avail.size * unavailable_ratio))
        unavail_per_day = [num_unavail // config.NUM_DAYS] * config.NUM_DAYS
        for i in range(num_unavail % config.NUM_DAYS):
            unavail_per_day[i] += 1

        for d, k in enumerate(unavail_per_day):
            coords = rng.choice(config.NUM_TIMESLOTS * config.NUM_ROOMS, size=k, replace=False)
            for idx in coords:
                avail[d, idx // config.NUM_ROOMS, idx % config.NUM_ROOMS] = False

        avail_s = [int(avail[:, :, room_sizes == s].sum()) for s in (0, 1, 2)]
        req_s = [int((sec_sizes == s).sum() * config.SESSIONS_PER_SECTION) for s in (0, 1, 2)]
        avail_day = [int(avail[d].sum()) for d in range(config.NUM_DAYS)]

        if (
            req_s[2] <= avail_s[2] - 20
            and (req_s[2] + req_s[1]) <= (avail_s[2] + avail_s[1]) - 30
            and config.NUM_SESSIONS <= sum(avail_s) - 40
            and min(avail_day) >= 202
            and int((room_sizes == 0).sum()) >= 10
        ):
            break

    # 3. Sections (480 sections: 8 per course)
    sections: List[Section] = []
    sec_id = 0
    for c in courses:
        for s_idx in range(1, config.SECTIONS_PER_COURSE + 1):
            sections.append(
                Section(
                    id=sec_id,
                    code=f"{c.code}-s{s_idx:02d}",
                    course_id=c.id,
                    registration_size=int(sec_sizes[sec_id]),
                )
            )
            sec_id += 1

    # 4. Rooms (rm01..rm35)
    rooms: List[Room] = []
    for r_id in range(config.NUM_ROOMS):
        matrix = [
            [bool(avail[d, t, r_id]) for t in range(config.NUM_TIMESLOTS)]
            for d in range(config.NUM_DAYS)
        ]
        rooms.append(
            Room(
                id=r_id,
                code=f"rm{r_id + 1:02d}",
                size=int(room_sizes[r_id]),
                availability=matrix,
            )
        )

    # 5. Professors (p01..p60) with top-3 favorite courses and 6 eligible courses each
    fav_sets: List[List[int]] = [[] for _ in range(config.NUM_PROFESSORS)]
    elig_sets: List[List[int]] = [[] for _ in range(config.NUM_PROFESSORS)]

    # 3 random matching layers -> top-3 favorites (ensuring every course has >= 2 favorite profs)
    for _ in range(3):
        perm = rng.permutation(config.NUM_COURSES)
        for p in range(config.NUM_PROFESSORS):
            c_id = int(perm[p])
            if c_id in fav_sets[p]:
                for q in range(config.NUM_PROFESSORS):
                    cand = int(perm[q])
                    if cand not in fav_sets[p] and int(perm[p]) not in fav_sets[q]:
                        perm[p], perm[q] = perm[q], perm[p]
                        c_id = int(perm[p])
                        break
            fav_sets[p].append(c_id)
            elig_sets[p].append(c_id)

    # 3 additional random matching layers -> eligible courses (total 6 per professor)
    for _ in range(3):
        perm = rng.permutation(config.NUM_COURSES)
        for p in range(config.NUM_PROFESSORS):
            c_id = int(perm[p])
            if c_id in elig_sets[p]:
                for q in range(config.NUM_PROFESSORS):
                    cand = int(perm[q])
                    if cand not in elig_sets[p] and int(perm[p]) not in elig_sets[q]:
                        perm[p], perm[q] = perm[q], perm[p]
                        c_id = int(perm[p])
                        break
            if c_id not in elig_sets[p]:
                elig_sets[p].append(c_id)

    professors: List[Professor] = [
        Professor(
            id=p,
            code=f"p{p + 1:02d}",
            name=f"Professor {p + 1:02d}",
            eligible_courses=elig_sets[p],
            favorite_courses=fav_sets[p],
            max_sessions=config.MAX_PROFESSOR_SESSIONS,
        )
        for p in range(config.NUM_PROFESSORS)
    ]

    data = ProblemData(
        courses=courses,
        sections=sections,
        professors=professors,
        rooms=rooms,
        seed=seed,
    )

    if save_dir is not None:
        save_data(data, Path(save_dir))

    return data


def save_data(data: ProblemData, data_dir: Path) -> None:
    """Persist ProblemData to data/courses.json, sections.json, professors.json, rooms.json."""
    data_dir.mkdir(parents=True, exist_ok=True)
    files = {
        "courses.json": [asdict(c) for c in data.courses],
        "sections.json": [asdict(s) for s in data.sections],
        "professors.json": [asdict(p) for p in data.professors],
        "rooms.json": [asdict(r) for r in data.rooms],
    }
    for fname, payload in files.items():
        with (data_dir / fname).open("w", encoding="utf-8") as f:
            json.dump(payload, f, indent=2, ensure_ascii=False)
