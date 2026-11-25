"""Selection operators (Tournament Selection using lexicographic quality ranking)."""

from __future__ import annotations

import numpy as np

from src.genetic.population import Population
from src.models import Chromosome


def tournament_selection(
    population: Population,
    tournament_size: int,
    rng: np.random.Generator,
) -> Chromosome:
    """Pick `tournament_size` random candidates and return the best by (hard_violations, total_penalty)."""
    n = len(population)
    k = min(tournament_size, n)
    indices = rng.integers(0, n, size=k)
    best = population.chromosomes[int(indices[0])]
    for idx in indices[1:]:
        cand = population.chromosomes[int(idx)]
        if cand.is_better_than(best):
            best = cand
    return best
