"""High-level Scheduler Service orchestrating 3-version GA experiments."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable

import config
from src.genetic.engine import GAConfig, GAMode, GARunResult, GeneticAlgorithm
from src.services.data_loader import ProblemData


@dataclass
class ExperimentBundle:
    data: ProblemData
    results: Dict[str, GARunResult]
    best_mode: str

    @property
    def best_result(self) -> GARunResult:
        return self.results[self.best_mode]


class SchedulerService:
    def __init__(self, data: ProblemData) -> None:
        self.data = data

    def run_single(
        self,
        mode: GAMode = "proposed",
        population_size: int = config.POPULATION_SIZE,
        max_generations: int = config.MAX_GENERATIONS,
        crossover_rate: float = config.CROSSOVER_RATE,
        mutation_rate: float = config.MUTATION_RATE,
        tournament_size: int = config.TOURNAMENT_SIZE,
        elite_size: int = config.ELITE_SIZE,
        repair_rate: float = config.REPAIR_RATE,
        seed: int = config.GA_SEED,
        verbose: bool = True,
    ) -> GARunResult:
        ga_cfg = GAConfig(
            mode=mode,
            population_size=population_size,
            max_generations=max_generations,
            crossover_rate=crossover_rate,
            mutation_rate=mutation_rate,
            tournament_size=tournament_size,
            elite_size=elite_size,
            repair_rate=repair_rate,
            seed=seed,
        )
        engine = GeneticAlgorithm(self.data, ga_cfg)
        return engine.run(verbose=verbose)

    def run_comparison(
        self,
        modes: Iterable[GAMode] = ("baseline", "improved", "proposed"),
        population_size: int = config.POPULATION_SIZE,
        max_generations: int = config.MAX_GENERATIONS,
        seed: int = config.GA_SEED,
        verbose: bool = True,
    ) -> ExperimentBundle:
        results: Dict[str, GARunResult] = {}
        for mode in modes:
            if verbose:
                print(f"\n=== Running {mode.upper()} GA (pop={population_size}, gens={max_generations}) ===")
            res = self.run_single(
                mode=mode,
                population_size=population_size,
                max_generations=max_generations,
                seed=seed,
                verbose=verbose,
            )
            results[mode] = res
            if verbose:
                b = res.best_chromosome
                print(
                    f"--> {res.label} finished in {res.elapsed_seconds:.2f}s | "
                    f"Hard={b.hard_violations} | Soft={b.soft_penalty:.1f} | "
                    f"Bonus={b.bonus_penalty:.1f} | Fitness={b.fitness:.6f}"
                )

        best_mode = min(
            results.keys(),
            key=lambda m: results[m].best_chromosome.rank_key(),
        )
        return ExperimentBundle(data=self.data, results=results, best_mode=best_mode)
