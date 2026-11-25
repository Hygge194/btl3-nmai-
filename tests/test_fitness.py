"""Unit tests for Weighted Penalty Fitness Function."""

import math
import numpy as np

import config
from src.genetic.fitness import evaluate_chromosome
from src.genetic.initialization import greedy_randomized_initialize
from src.genetic.repair import repair_chromosome
from src.services.data_generator import generate_data


def test_fitness_formula_and_ordering():
    data = generate_data(seed=42, save_dir=None)
    rng = np.random.default_rng(7)

    ch = greedy_randomized_initialize(data, rng)
    repair_chromosome(ch, data, rng, max_hard_steps=120, max_soft_steps=30)
    fit = evaluate_chromosome(ch, data, include_bonus=True)

    expected_pen = (
        config.HARD_PENALTY * ch.hard_violations
        + ch.soft_penalty
        + ch.bonus_penalty
    )
    assert math.isclose(ch.total_penalty, expected_pen, rel_tol=1e-9)
    assert math.isclose(fit, 1.0 / (1.0 + expected_pen), rel_tol=1e-9)
    assert 0.0 < fit <= 1.0
    assert ch.hard_violations == 0
    assert ch.breakdown["B2_out_of_list_sections"] == 0
    assert ch.breakdown["B1a_profs_without_favorite"] == 0
