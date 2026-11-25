"""Gene and Chromosome domain models (Section-based representation: 480 genes)."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Dict, List

from .session import Session


@dataclass
class Gene:
    section_id: int
    professor_id: int
    session_1: Session
    session_2: Session

    def copy(self) -> "Gene":
        return Gene(
            section_id=self.section_id,
            professor_id=self.professor_id,
            session_1=self.session_1.copy(),
            session_2=self.session_2.copy(),
        )


@dataclass
class Chromosome:
    genes: List[Gene]
    fitness: float = 0.0
    hard_violations: int = 0
    soft_penalty: float = 0.0
    bonus_penalty: float = 0.0
    total_penalty: float = 0.0
    breakdown: Dict[str, int] = field(default_factory=dict)

    def copy(self) -> "Chromosome":
        return Chromosome(
            genes=[g.copy() for g in self.genes],
            fitness=self.fitness,
            hard_violations=self.hard_violations,
            soft_penalty=self.soft_penalty,
            bonus_penalty=self.bonus_penalty,
            total_penalty=self.total_penalty,
            breakdown=dict(self.breakdown),
        )

    def rank_key(self) -> tuple[int, float]:
        """Lexicographic comparison key: prioritize feasible schedules (hard=0) first."""
        return (self.hard_violations, self.total_penalty)

    def is_better_than(self, other: "Chromosome") -> bool:
        return self.rank_key() < other.rank_key()
