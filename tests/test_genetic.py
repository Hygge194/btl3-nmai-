"""Unit tests for Genetic Algorithm operators (init, selection, crossover, mutation, repair)."""

import numpy as np

from src.constraints import check_session_spacing
from src.genetic.crossover import course_block_crossover, uniform_crossover
from src.genetic.fitness import evaluate_chromosome, evaluate_population
from src.genetic.initialization import greedy_randomized_initialize, random_initialize
from src.genetic.mutation import random_reassignment_mutation, smart_swap_mutation
from src.genetic.population import Population
from src.genetic.repair import repair_chromosome
from src.genetic.selection import tournament_selection
from src.services.data_generator import generate_data


def test_operators_preserve_chromosome_integrity():
    data = generate_data(seed=42, save_dir=None)
    rng = np.random.default_rng(99)

    p1 = greedy_randomized_initialize(data, rng)
    p2 = random_initialize(data, rng)
    assert len(p1.genes) == data.num_sections
    assert len(p2.genes) == data.num_sections
    assert check_session_spacing(p1) == 0
    assert check_session_spacing(p2) == 0

    c1, c2 = uniform_crossover(p1, p2, rng)
    b1, b2 = course_block_crossover(p1, p2, data, rng)
    assert len(c1.genes) == data.num_sections and len(b1.genes) == data.num_sections

    random_reassignment_mutation(c1, data, 0.05, rng)
    smart_swap_mutation(b1, data, 0.05, rng)
    assert check_session_spacing(c1) == 0
    assert check_session_spacing(b1) == 0

    pop = Population(chromosomes=[p1, p2, c1, b1])
    evaluate_population(pop, data)
    winner = tournament_selection(pop, tournament_size=3, rng=rng)
    assert winner.fitness > 0.0

    repaired = b1.copy()
    repair_chromosome(repaired, data, rng, max_hard_steps=100, max_soft_steps=20)
    evaluate_chromosome(repaired, data)
    assert repaired.hard_violations <= b1.hard_violations
