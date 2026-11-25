"""Genetic Algorithm Engine orchestrating evolution across 3 comparable modes:

1. 'baseline': Random Initialization + Uniform Crossover + Random Mutation
2. 'improved': Greedy Randomized Initialization + Course-Block Crossover + Smart/Swap Mutation
3. 'proposed': Greedy Randomized Initialization + Course-Block Crossover + Adaptive Smart/Swap
               Mutation + Constraint-based Repair & Pairwise Swap Local Search + Elitism
"""

from __future__ import annotations

import time
from dataclasses import dataclass, field
from typing import Dict, List, Literal

import numpy as np

import config
from src.genetic.crossover import course_block_crossover, uniform_crossover
from src.genetic.fitness import evaluate_chromosome, evaluate_population
from src.genetic.initialization import greedy_randomized_initialize, random_initialize
from src.genetic.mutation import random_reassignment_mutation, smart_swap_mutation
from src.genetic.population import Population
from src.genetic.repair import repair_chromosome
from src.genetic.selection import tournament_selection
from src.models import Chromosome
from src.services.data_loader import ProblemData

GAMode = Literal["baseline", "improved", "proposed"]


@dataclass
class GAConfig:
    mode: GAMode = "proposed"
    population_size: int = config.POPULATION_SIZE
    max_generations: int = config.MAX_GENERATIONS
    crossover_rate: float = config.CROSSOVER_RATE
    mutation_rate: float = config.MUTATION_RATE
    max_mutation_rate: float = config.MAX_MUTATION_RATE
    tournament_size: int = config.TOURNAMENT_SIZE
    elite_size: int = config.ELITE_SIZE
    repair_rate: float = config.REPAIR_RATE
    include_bonus: bool = True
    seed: int = config.GA_SEED


@dataclass
class GARunResult:
    mode: str
    label: str
    best_chromosome: Chromosome
    elapsed_seconds: float
    converged_feasible_gen: int | None
    history: Dict[str, List[float]] = field(default_factory=dict)


MODE_LABELS = {
    "baseline": "Baseline GA (Random Init)",
    "improved": "Improved GA (Greedy Init)",
    "proposed": "Proposed GA (Greedy + Repair + Elitism)",
}


class GeneticAlgorithm:
    def __init__(self, data: ProblemData, ga_config: GAConfig | None = None) -> None:
        self.data = data
        self.cfg = ga_config or GAConfig()
        self.rng = np.random.default_rng(self.cfg.seed)

    def _initialize_population(self) -> Population:
        chroms: List[Chromosome] = []
        for i in range(self.cfg.population_size):
            if self.cfg.mode == "baseline":
                ch = random_initialize(self.data, self.rng)
            else:
                ch = greedy_randomized_initialize(self.data, self.rng)
                if self.cfg.mode == "proposed" and i < self.cfg.population_size // 2:
                    repair_chromosome(ch, self.data, self.rng, max_hard_steps=40, max_soft_steps=15)
            chroms.append(ch)
        return Population(chromosomes=chroms, generation=0)

    def run(self, verbose: bool = True) -> GARunResult:
        t0 = time.perf_counter()
        pop = self._initialize_population()
        evaluate_population(pop, self.data, include_bonus=self.cfg.include_bonus)
        best = pop.best().copy()

        history: Dict[str, List[float]] = {
            "generation": [],
            "best_fitness": [],
            "avg_fitness": [],
            "best_penalty": [],
            "best_hard": [],
            "best_soft_penalty": [],
            "best_bonus_penalty": [],
            "mutation_rate": [],
        }

        mut_rate = self.cfg.mutation_rate
        stagnation = 0
        feasible_gen: int | None = 0 if best.hard_violations == 0 else None

        def log_gen(gen: int) -> None:
            history["generation"].append(gen)
            history["best_fitness"].append(best.fitness)
            history["avg_fitness"].append(pop.average_fitness())
            history["best_penalty"].append(best.total_penalty)
            history["best_hard"].append(best.hard_violations)
            history["best_soft_penalty"].append(best.soft_penalty)
            history["best_bonus_penalty"].append(best.bonus_penalty)
            history["mutation_rate"].append(mut_rate)

        log_gen(0)

        for gen in range(1, self.cfg.max_generations + 1):
            new_chroms = pop.get_elites(self.cfg.elite_size)

            while len(new_chroms) < self.cfg.population_size:
                p1 = tournament_selection(pop, self.cfg.tournament_size, self.rng)
                p2 = tournament_selection(pop, self.cfg.tournament_size, self.rng)

                if self.rng.random() < self.cfg.crossover_rate:
                    if self.cfg.mode == "baseline":
                        c1, c2 = uniform_crossover(p1, p2, self.rng)
                    else:
                        c1, c2 = course_block_crossover(p1, p2, self.data, self.rng)
                else:
                    c1, c2 = p1.copy(), p2.copy()

                if self.cfg.mode == "baseline":
                    random_reassignment_mutation(c1, self.data, mut_rate, self.rng)
                    random_reassignment_mutation(c2, self.data, mut_rate, self.rng)
                else:
                    smart_swap_mutation(c1, self.data, mut_rate, self.rng)
                    smart_swap_mutation(c2, self.data, mut_rate, self.rng)

                if self.cfg.mode == "proposed":
                    if self.rng.random() < self.cfg.repair_rate:
                        repair_chromosome(c1, self.data, self.rng, max_hard_steps=50, max_soft_steps=25)
                    if self.rng.random() < self.cfg.repair_rate:
                        repair_chromosome(c2, self.data, self.rng, max_hard_steps=50, max_soft_steps=25)

                new_chroms.append(c1)
                if len(new_chroms) < self.cfg.population_size:
                    new_chroms.append(c2)

            # Periodic intensive polish on top elite in Proposed mode
            if self.cfg.mode == "proposed" and gen % 5 == 0:
                cand = new_chroms[0].copy()
                repair_chromosome(cand, self.data, self.rng, max_hard_steps=80, max_soft_steps=120)
                evaluate_chromosome(cand, self.data, include_bonus=self.cfg.include_bonus)
                evaluate_chromosome(new_chroms[0], self.data, include_bonus=self.cfg.include_bonus)
                if cand.is_better_than(new_chroms[0]):
                    new_chroms[0] = cand

            pop = Population(chromosomes=new_chroms, generation=gen)
            evaluate_population(pop, self.data, include_bonus=self.cfg.include_bonus)

            gen_best = pop.best()
            if gen_best.is_better_than(best):
                best = gen_best.copy()
                stagnation = 0
                if self.cfg.mode != "baseline":
                    mut_rate = max(self.cfg.mutation_rate, mut_rate * 0.85)
            else:
                stagnation += 1
                if self.cfg.mode != "baseline" and stagnation >= 10:
                    mut_rate = min(self.cfg.max_mutation_rate, mut_rate * 1.15)
                    stagnation = 0

            if feasible_gen is None and best.hard_violations == 0:
                feasible_gen = gen

            log_gen(gen)

            if verbose and (gen % 50 == 0 or gen == self.cfg.max_generations):
                print(
                    f"[{self.cfg.mode.upper():8s}] Gen {gen:3d}/{self.cfg.max_generations} | "
                    f"Fitness={best.fitness:.6f} | Hard={best.hard_violations:3d} | "
                    f"Soft={best.soft_penalty:6.1f} | Bonus={best.bonus_penalty:7.1f} | "
                    f"Pen={best.total_penalty:10.1f}"
                )

        # Final polishing pass for Proposed GA
        if self.cfg.mode == "proposed":
            for _ in range(8):
                cand = best.copy()
                repair_chromosome(cand, self.data, self.rng, max_hard_steps=120, max_soft_steps=480)
                evaluate_chromosome(cand, self.data, include_bonus=self.cfg.include_bonus)
                if cand.is_better_than(best):
                    best = cand
            history["best_fitness"][-1] = best.fitness
            history["best_penalty"][-1] = best.total_penalty
            history["best_hard"][-1] = best.hard_violations
            history["best_soft_penalty"][-1] = best.soft_penalty
            history["best_bonus_penalty"][-1] = best.bonus_penalty

        elapsed = time.perf_counter() - t0
        return GARunResult(
            mode=self.cfg.mode,
            label=MODE_LABELS[self.cfg.mode],
            best_chromosome=best,
            elapsed_seconds=elapsed,
            converged_feasible_gen=feasible_gen,
            history=history,
        )
