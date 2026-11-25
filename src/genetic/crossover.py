"""Crossover operators (Section-level Uniform Crossover & Asymmetric Course-Block Crossover)."""

from __future__ import annotations

from typing import Tuple

import numpy as np

from src.models import Chromosome
from src.services.data_loader import ProblemData


def uniform_crossover(
    parent1: Chromosome,
    parent2: Chromosome,
    rng: np.random.Generator,
) -> Tuple[Chromosome, Chromosome]:
    """Uniform crossover exchanging whole section genes (preserving 2-session structure)."""
    n = len(parent1.genes)
    mask = rng.random(n) < 0.5
    c1_genes = [
        parent1.genes[i].copy() if mask[i] else parent2.genes[i].copy()
        for i in range(n)
    ]
    c2_genes = [
        parent2.genes[i].copy() if mask[i] else parent1.genes[i].copy()
        for i in range(n)
    ]
    return Chromosome(genes=c1_genes), Chromosome(genes=c2_genes)


def course_block_crossover(
    parent1: Chromosome,
    parent2: Chromosome,
    data: ProblemData,
    rng: np.random.Generator,
) -> Tuple[Chromosome, Chromosome]:
    """Asymmetric course-block crossover: grafts 8%-22% of courses (all 8 sections each)
    between parents to preserve course-shift consistency (S4) & high-utilization feasibility."""
    graft_ratio = float(rng.uniform(0.08, 0.22))
    keep_mask_course = rng.random(data.num_courses) >= graft_ratio
    sec_course = data.section_course_arr

    c1_genes = []
    c2_genes = []
    for i in range(len(parent1.genes)):
        if keep_mask_course[sec_course[i]]:
            c1_genes.append(parent1.genes[i].copy())
            c2_genes.append(parent2.genes[i].copy())
        else:
            c1_genes.append(parent2.genes[i].copy())
            c2_genes.append(parent1.genes[i].copy())
    return Chromosome(genes=c1_genes), Chromosome(genes=c2_genes)
