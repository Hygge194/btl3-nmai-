"""Integration tests for Data Persistence (JSON) and SchedulerService."""

from pathlib import Path

from src.services.data_generator import generate_data
from src.services.data_loader import load_data
from src.services.scheduler import SchedulerService


def test_data_save_and_load_roundtrip(tmp_path: Path):
    original = generate_data(seed=42, save_dir=tmp_path)
    loaded = load_data(tmp_path)

    assert loaded.num_courses == original.num_courses == 60
    assert loaded.num_sections == original.num_sections == 480
    assert loaded.num_professors == original.num_professors == 60
    assert loaded.num_rooms == original.num_rooms == 35
    assert loaded.feasibility_summary() == original.feasibility_summary()


def test_scheduler_proposed_reaches_zero_hard_conflicts():
    data = generate_data(seed=42, save_dir=None)
    svc = SchedulerService(data)
    res = svc.run_single(
        mode="proposed",
        population_size=12,
        max_generations=5,
        seed=123,
        verbose=False,
    )
    best = res.best_chromosome
    assert best.hard_violations == 0
    assert best.breakdown["B2_out_of_list_sections"] == 0
    assert best.breakdown["B1a_profs_without_favorite"] == 0
    assert len(res.history["generation"]) == 6
