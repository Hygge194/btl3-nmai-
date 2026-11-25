"""Population management for Genetic Algorithm."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import List

from src.models import Chromosome


@dataclass
class Population:
    chromosomes: List[Chromosome] = field(default_factory=list)
    generation: int = 0

    def __len__(self) -> int:
        return len(self.chromosomes)

    def sort_by_quality(self) -> None:
        """Sort chromosomes in-place using lexicographic (hard_violations, total_penalty)."""
        self.chromosomes.sort(key=lambda c: c.rank_key())

    def best(self) -> Chromosome:
        return min(self.chromosomes, key=lambda c: c.rank_key())

    def get_elites(self, elite_size: int) -> List[Chromosome]:
        self.sort_by_quality()
        return [c.copy() for c in self.chromosomes[:elite_size]]

    def average_fitness(self) -> float:
        if not self.chromosomes:
            return 0.0
        return sum(c.fitness for c in self.chromosomes) / len(self.chromosomes)
