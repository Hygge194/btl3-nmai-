"""Main entry point for Class Scheduling using Genetic Algorithm (CO3061 - Homework 3)."""

from __future__ import annotations

import argparse

import config
from src.services.data_generator import generate_data
from src.services.scheduler import SchedulerService
from src.utils.exporter import export_all
from src.utils.pdf_report import generate_pdf_report
from src.utils.visualization import generate_all_plots


def main() -> None:
    parser = argparse.ArgumentParser(description="Class Scheduling using Genetic Algorithm (CO3061)")
    parser.add_argument("--seed", type=int, default=config.RANDOM_SEED, help="Dataset random seed")
    parser.add_argument("--ga-seed", type=int, default=config.GA_SEED, help="GA random seed")
    parser.add_argument("--pop-size", type=int, default=config.POPULATION_SIZE, help="Population size")
    parser.add_argument("--generations", type=int, default=config.MAX_GENERATIONS, help="Max generations")
    args = parser.parse_args()

    print("=== 1. Generating & Persisting Input Dataset (data/*.json) ===")
    data = generate_data(seed=args.seed, save_dir=config.DATA_DIR)
    feas = data.feasibility_summary()
    print(
        f"Courses={data.num_courses}, Sections={data.num_sections}, Sessions={data.num_sessions}, "
        f"Professors={data.num_professors}, Rooms={data.num_rooms}"
    )
    print(
        f"Available Room-Slots: {feas['available_room_slots']}/{feas['total_room_slots']} "
        f"({feas['utilization_pct']}% utilization)"
    )
    print(f"Rooms per size (0/1/2)   : {feas['rooms_per_size']}")
    print(f"Sections per size (0/1/2): {feas['sections_per_size']}")
    print(f"Available slots per day  : {feas['available_slots_per_day']}")

    print("\n=== 2. Running 3-Version GA Comparison (Baseline vs. Improved vs. Proposed) ===")
    scheduler = SchedulerService(data)
    bundle = scheduler.run_comparison(
        modes=("baseline", "improved", "proposed"),
        population_size=args.pop_size,
        max_generations=args.generations,
        seed=args.ga_seed,
        verbose=True,
    )

    best = bundle.best_result.best_chromosome
    print(f"\n=== 3. Best Solution Summary ({bundle.best_mode.upper()}) ===")
    print(
        f"Fitness={best.fitness:.8f} | TotalPenalty={best.total_penalty:.1f} | "
        f"Hard={best.hard_violations} | Soft={best.soft_penalty:.1f} | Bonus={best.bonus_penalty:.1f}"
    )
    for k, v in best.breakdown.items():
        print(f"  {k:<28}: {v}")

    print("\n=== 4. Exporting Schedules, Conflict Report, Plots & PDF Documentation ===")
    dfs = export_all(bundle, config.OUTPUT_DIR)
    generate_all_plots(bundle, dfs["schedule"], dfs["professors"], config.OUTPUT_DIR)
    pdf_path = generate_pdf_report(config.OUTPUT_DIR, config.DOCS_DIR)
    print(f"All outputs written to: {config.OUTPUT_DIR}")
    print(f"PDF documentation written to: {pdf_path}")


if __name__ == "__main__":
    main()
