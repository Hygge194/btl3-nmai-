"""Bonus Constraints (Bonus 1 & Bonus 2) for Class Scheduling.

Bonus 1:
- Each professor lists their top-3 favorite courses.
- Ensure every professor gets at least 1 favorite class (B1a = 0).
- Maximize the total number of sections taught as a favorite course (minimize B1b).

Bonus 2:
- A professor should NOT teach courses that are NOT in their eligible course list (B2 = 0).
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Dict

from src.models import Chromosome

if TYPE_CHECKING:
    from src.services.data_loader import ProblemData


def check_professor_favorite_coverage(chromosome: Chromosome, data: ProblemData) -> int:
    """B1a: Count professors who have 0 sections from their top-3 favorite courses."""
    fav_rank = data.fav_rank_arr
    sec_course = data.section_course_arr
    fav_counts = [0] * data.num_professors
    for g in chromosome.genes:
        c = int(sec_course[g.section_id])
        if fav_rank[g.professor_id, c] > 0:
            fav_counts[g.professor_id] += 1
    return sum(1 for cnt in fav_counts if cnt == 0)


def count_non_favorite_sections(chromosome: Chromosome, data: ProblemData) -> int:
    """B1b: Count sections whose course is not in the assigned professor's top-3 favorites."""
    fav_rank = data.fav_rank_arr
    sec_course = data.section_course_arr
    non_fav = 0
    for g in chromosome.genes:
        if fav_rank[g.professor_id, int(sec_course[g.section_id])] == 0:
            non_fav += 1
    return non_fav


def check_professor_out_of_list(chromosome: Chromosome, data: ProblemData) -> int:
    """B2: Count sections assigned to a professor who does NOT have that course in eligible list."""
    elig = data.is_eligible_arr
    sec_course = data.section_course_arr
    violations = 0
    for g in chromosome.genes:
        if not elig[g.professor_id, int(sec_course[g.section_id])]:
            violations += 1
    return violations


def evaluate_bonus_constraints(chromosome: Chromosome, data: ProblemData) -> Dict[str, int]:
    """Evaluate Bonus 1 and Bonus 2 metrics in one pass."""
    elig = data.is_eligible_arr
    fav_rank = data.fav_rank_arr
    sec_course = data.section_course_arr

    fav_counts = [0] * data.num_professors
    out_of_list = 0
    fav_sections = 0

    for g in chromosome.genes:
        p = g.professor_id
        c = int(sec_course[g.section_id])
        if not elig[p, c]:
            out_of_list += 1
        if fav_rank[p, c] > 0:
            fav_counts[p] += 1
            fav_sections += 1

    no_fav_profs = sum(1 for cnt in fav_counts if cnt == 0)
    non_fav_sections = len(chromosome.genes) - fav_sections

    return {
        "B1a_profs_without_favorite": no_fav_profs,
        "B1b_non_favorite_sections": non_fav_sections,
        "B2_out_of_list_sections": out_of_list,
        "profs_with_favorite": data.num_professors - no_fav_profs,
        "favorite_sections": fav_sections,
    }
