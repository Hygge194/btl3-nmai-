"""Weighted Penalty Fitness Function for Class Scheduling.

Formula (matching architecture specification):
    H(x) = sum_{i=1..7} h_i(x)
    S(x) = sum_{j=1..5} w_j * s_j(x)
    B(x) = w_b2 * B2(x) + w_b1a * B1a(x) + w_b1b * B1b(x)
    P(x) = W_H * H(x) + S(x) + B(x)
    F(x) = 1 / (1 + P(x))  in (0, 1]
"""

from __future__ import annotations

import config
from src.constraints import (
    evaluate_bonus_constraints,
    evaluate_hard_constraints,
    evaluate_soft_constraints,
)
from src.genetic.population import Population
from src.models import Chromosome
from src.services.data_loader import ProblemData


def evaluate_chromosome(
    chromosome: Chromosome,
    data: ProblemData,
    include_bonus: bool = True,
) -> float:
    """Evaluate all constraints, populate metrics on chromosome, and return fitness F(x)."""
    hard = evaluate_hard_constraints(chromosome, data)
    soft = evaluate_soft_constraints(chromosome, data)
    bonus = evaluate_bonus_constraints(chromosome, data)

    hard_violations = hard["hard_total"]
    hard_pen = config.HARD_PENALTY * hard_violations

    soft_pen = (
        config.SOFT_WEIGHTS["idle_gap"] * soft["S1_professor_idle_gap"]
        + config.SOFT_WEIGHTS["day_scatter"] * soft["S2_professor_day_scatter"]
        + config.SOFT_WEIGHTS["prof_shift"] * soft["S3_professor_shift_conflict"]
        + config.SOFT_WEIGHTS["course_shift"] * soft["S4_course_shift_conflict"]
        + config.SOFT_WEIGHTS["room_mismatch"] * soft["S5_room_size_mismatch"]
    )

    if include_bonus:
        bonus_pen = (
            config.BONUS_WEIGHTS["not_in_list"] * bonus["B2_out_of_list_sections"]
            + config.BONUS_WEIGHTS["no_favorite"] * bonus["B1a_profs_without_favorite"]
            + config.BONUS_WEIGHTS["non_favorite_section"] * bonus["B1b_non_favorite_sections"]
        )
    else:
        bonus_pen = 0.0

    total_pen = hard_pen + soft_pen + bonus_pen
    fitness = 1.0 / (1.0 + total_pen)

    chromosome.hard_violations = int(hard_violations)
    chromosome.soft_penalty = float(soft_pen)
    chromosome.bonus_penalty = float(bonus_pen)
    chromosome.total_penalty = float(total_pen)
    chromosome.fitness = float(fitness)
    chromosome.breakdown = {**hard, **soft, **bonus}
    return fitness


def evaluate_population(
    population: Population,
    data: ProblemData,
    include_bonus: bool = True,
) -> None:
    for chrom in population.chromosomes:
        evaluate_chromosome(chrom, data, include_bonus=include_bonus)
