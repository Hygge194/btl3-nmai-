"""Statistics and schedule DataFrame builders."""

from __future__ import annotations

from typing import Dict

import numpy as np
import pandas as pd

import config
from src.models import Chromosome
from src.services.data_loader import ProblemData
from src.services.scheduler import ExperimentBundle


def build_schedule_dataframe(chromosome: Chromosome, data: ProblemData) -> pd.DataFrame:
    """Convert a Chromosome (480 genes) into a tidy 960-row schedule DataFrame."""
    rows = []
    for g in chromosome.genes:
        sec = data.sections[g.section_id]
        course = data.courses[sec.course_id]
        prof = data.professors[g.professor_id]
        is_elig = bool(data.is_eligible_arr[prof.id, course.id])
        fav_rank = int(data.fav_rank_arr[prof.id, course.id])

        for sess_no, sess in enumerate((g.session_1, g.session_2), start=1):
            room = data.rooms[sess.room_id]
            rows.append(
                {
                    "section_id": sec.id,
                    "course": course.code,
                    "section": sec.code,
                    "section_size": sec.registration_size,
                    "section_size_label": config.SIZE_LABELS_EN[sec.registration_size],
                    "professor": prof.code,
                    "is_eligible_course": is_elig,
                    "is_favorite_course": fav_rank > 0,
                    "favorite_rank": fav_rank,
                    "session_no": sess_no,
                    "day_idx": sess.day,
                    "day": config.DAY_NAMES_EN[sess.day],
                    "day_vi": config.DAY_NAMES_VI[sess.day],
                    "timeslot": sess.timeslot + 1,
                    "period": "Morning" if sess.timeslot < 3 else "Afternoon",
                    "room": room.code,
                    "room_size": room.size,
                    "room_size_label": config.SIZE_LABELS_EN[room.size],
                    "room_available": bool(room.is_available(sess.day, sess.timeslot)),
                    "size_waste": room.size - sec.registration_size,
                }
            )

    df = pd.DataFrame(rows)
    df.sort_values(by=["day_idx", "timeslot", "room", "section"], inplace=True)
    df.reset_index(drop=True, inplace=True)
    return df


def build_professor_summary(chromosome: Chromosome, data: ProblemData) -> pd.DataFrame:
    """Build per-professor workload, compactness, shift, and favorite statistics."""
    occ = np.zeros((data.num_professors, data.num_days, data.num_timeslots), dtype=np.int32)
    prof_genes = [[] for _ in range(data.num_professors)]

    for g in chromosome.genes:
        prof_genes[g.professor_id].append(g)
        occ[g.professor_id, g.session_1.day, g.session_1.timeslot] += 1
        occ[g.professor_id, g.session_2.day, g.session_2.timeslot] += 1

    rows = []
    for prof in data.professors:
        p = prof.id
        genes = prof_genes[p]
        courses = [data.sections[g.section_id].course_id for g in genes]
        fav_secs = sum(1 for c in courses if data.fav_rank_arr[p, c] > 0)
        out_secs = sum(1 for c in courses if not data.is_eligible_arr[p, c])

        day_gaps = 0
        mixed_days = 0
        active_days = []
        for d in range(data.num_days):
            slots = np.where(occ[p, d] > 0)[0]
            if slots.size > 0:
                active_days.append(d)
                if slots.size >= 2:
                    day_gaps += int((slots[-1] - slots[0] + 1) - slots.size)
                    if slots[0] < 3 and slots[-1] >= 3:
                        mixed_days += 1

        week_gaps = (
            (active_days[-1] - active_days[0] + 1) - len(active_days)
            if len(active_days) >= 2
            else 0
        )

        rows.append(
            {
                "professor": prof.code,
                "sections": len(genes),
                "sessions": len(genes) * 2,
                "active_days": len(active_days),
                "intra_day_gaps": day_gaps,
                "intra_week_gaps": week_gaps,
                "mixed_shift_days": mixed_days,
                "favorite_sections": fav_secs,
                "out_of_list_sections": out_secs,
                "top3_favorites": ", ".join(data.courses[c].code for c in prof.favorite_courses),
                "courses_taught": ", ".join(sorted({data.courses[c].code for c in courses})),
            }
        )

    return pd.DataFrame(rows)


def build_conflict_report(bundle: ExperimentBundle) -> Dict[str, object]:
    """Assemble full structured conflict & comparison report JSON payload."""
    comparisons = {}
    for mode, res in bundle.results.items():
        b = res.best_chromosome
        comparisons[mode] = {
            "label": res.label,
            "elapsed_seconds": round(res.elapsed_seconds, 3),
            "converged_feasible_gen": res.converged_feasible_gen,
            "fitness": round(b.fitness, 8),
            "total_penalty": round(b.total_penalty, 2),
            "hard_violations": b.hard_violations,
            "soft_penalty": round(b.soft_penalty, 2),
            "bonus_penalty": round(b.bonus_penalty, 2),
            "breakdown": b.breakdown,
        }

    return {
        "best_mode": bundle.best_mode,
        "problem_feasibility": bundle.data.feasibility_summary(),
        "weights": {
            "hard_penalty": config.HARD_PENALTY,
            "soft_weights": config.SOFT_WEIGHTS,
            "bonus_weights": config.BONUS_WEIGHTS,
        },
        "algorithms": comparisons,
    }
