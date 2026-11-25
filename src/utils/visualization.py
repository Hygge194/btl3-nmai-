"""Publication-quality Matplotlib charts for Fitness Plot, Comparison, Heatmap, and Timetables."""

from __future__ import annotations

from pathlib import Path
from typing import Dict

import matplotlib
matplotlib.use("Agg")
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

import config
from src.genetic.engine import GARunResult
from src.services.data_loader import ProblemData
from src.services.scheduler import ExperimentBundle

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["axes.edgecolor"] = "#cccccc"
plt.rcParams["axes.linewidth"] = 0.8

COLORS = {
    "baseline": "#dc2626",  # Red
    "improved": "#d97706",  # Amber
    "proposed": "#1d4ed8",  # Blue
}

LABELS_VI = {
    "baseline": "Baseline GA (Khởi tạo ngẫu nhiên)",
    "improved": "Improved GA (Khởi tạo Greedy)",
    "proposed": "Proposed GA (Greedy + Repair + Elitism)",
}


def generate_all_plots(
    bundle: ExperimentBundle,
    sched_df: pd.DataFrame,
    prof_df: pd.DataFrame,
    output_dir: Path | str = config.OUTPUT_DIR,
) -> None:
    out_dir = Path(output_dir)
    fig_dir = out_dir / "figures"
    fig_dir.mkdir(parents=True, exist_ok=True)

    # Main required fitness_plot.png right inside outputs/ (and mirrored in outputs/figures/)
    plot_fitness_comparison(bundle.results, out_dir / "fitness_plot.png")
    plot_fitness_comparison(bundle.results, fig_dir / "fitness_comparison.png")
    plot_proposed_convergence(bundle.best_result, fig_dir / "penalty_breakdown.png")
    plot_constraint_comparison(bundle.results, fig_dir / "constraint_satisfaction.png")
    plot_room_utilization_heatmap(bundle.data, sched_df, fig_dir / "room_utilization_heatmap.png")
    plot_sample_timetables(bundle.data, sched_df, prof_df, fig_dir / "sample_timetables.png")


def plot_fitness_comparison(results: Dict[str, GARunResult], out_path: Path) -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12.6, 4.8), dpi=300)

    max_fit = 0.0
    for key in ("baseline", "improved", "proposed"):
        if key not in results:
            continue
        h = results[key].history
        gens = h["generation"]
        c = COLORS[key]
        lbl = LABELS_VI[key]
        max_fit = max(max_fit, max(h["best_fitness"]))
        ax1.plot(gens, h["best_fitness"], color=c, lw=2.3, label=f"{lbl} (Best)")
        ax1.plot(gens, h["avg_fitness"], color=c, lw=1.2, ls="--", alpha=0.55, label=f"{lbl} (Avg)")
        ax2.semilogy(gens, np.maximum(1.0, h["best_penalty"]), color=c, lw=2.3, label=lbl)

    ax1.set_title("Tiến hóa Độ thích nghi F(x) = 1 / (1 + P(x))", fontsize=11.5, fontweight="bold")
    ax1.set_xlabel("Thế hệ (Generation)", fontsize=10)
    ax1.set_ylabel("Fitness Score F(x)", fontsize=10)
    ax1.set_ylim(-max_fit * 0.04, max_fit * 1.25)
    ax1.grid(True, ls=":", alpha=0.6)
    ax1.legend(fontsize=7.8, loc="center right", framealpha=0.94)

    ax2.set_title("Tổng điểm phạt P(x) theo thang log", fontsize=11.5, fontweight="bold")
    ax2.set_xlabel("Thế hệ (Generation)", fontsize=10)
    ax2.set_ylabel("Total Penalty P(x) (log scale)", fontsize=10)
    ax2.grid(True, which="both", ls=":", alpha=0.55)
    ax2.legend(fontsize=8.2, loc="center right", framealpha=0.94)

    fig.tight_layout()
    plt.savefig(out_path, bbox_inches="tight")
    plt.close(fig)


def plot_proposed_convergence(res: GARunResult, out_path: Path) -> None:
    h = res.history
    gens = h["generation"]
    fig, axes = plt.subplots(1, 3, figsize=(13.8, 4.3), dpi=300)

    # Panel 1: Fitness Best vs Avg + Hard=0 badge
    ax0 = axes[0]
    ax0.plot(gens, h["best_fitness"], color="#1d4ed8", lw=2.3, label="Best Fitness")
    ax0.plot(gens, h["avg_fitness"], color="#60a5fa", lw=1.3, ls="--", label="Avg Fitness")
    ax0.fill_between(gens, h["avg_fitness"], h["best_fitness"], color="#dbeafe", alpha=0.35)
    ax0.set_title("Hội tụ Fitness — Proposed GA", fontsize=11, fontweight="bold")
    ax0.set_xlabel("Thế hệ")
    ax0.set_ylabel("Fitness F(x)")
    ax0.grid(True, ls=":", alpha=0.6)
    ax0.legend(fontsize=8.5, loc="lower right", framealpha=0.92)
    ax0.text(
        0.04,
        0.92,
        f"Hard (H1–H7) = {int(h['best_hard'][-1])}\nFitness cuối = {h['best_fitness'][-1]:.6f}",
        transform=ax0.transAxes,
        va="top",
        fontsize=8.5,
        fontweight="bold",
        color="#166534",
        bbox=dict(boxstyle="round,pad=0.35", facecolor="#dcfce7", edgecolor="#16a34a", alpha=0.95),
    )

    # Panel 2: Soft Penalty reduction
    ax1 = axes[1]
    soft_vals = h["best_soft_penalty"]
    ax1.plot(gens, soft_vals, color="#0284c7", lw=2.3)
    lo = min(soft_vals) * 0.94
    ax1.fill_between(gens, soft_vals, lo, color="#bae6fd", alpha=0.4)
    ax1.set_ylim(lo, max(soft_vals) * 1.05)
    ax1.set_title("Giảm điểm phạt Mềm (S1–S5)", fontsize=11, fontweight="bold")
    ax1.set_xlabel("Thế hệ")
    ax1.set_ylabel("Soft Penalty S(x)")
    ax1.grid(True, ls=":", alpha=0.6)
    drop_pct = 100.0 * (soft_vals[0] - soft_vals[-1]) / max(1.0, soft_vals[0])
    ax1.text(
        0.96,
        0.92,
        f"Gen 0: {soft_vals[0]:.0f}\nCuối: {soft_vals[-1]:.0f}\n(-{drop_pct:.1f}%)",
        transform=ax1.transAxes,
        ha="right",
        va="top",
        fontsize=8.5,
        fontweight="bold",
        color="#0c4a6e",
        bbox=dict(boxstyle="round,pad=0.35", facecolor="#e0f2fe", edgecolor="#0284c7", alpha=0.95),
    )

    # Panel 3: Adaptive Mutation Rate & Bonus Penalty
    ax2 = axes[2]
    ax2.plot(gens, h["mutation_rate"], color="#7c3aed", lw=2.0, label="Đột biến thích nghi (p_m)")
    ax2.fill_between(gens, h["mutation_rate"], min(h["mutation_rate"]) * 0.98, color="#ede9fe", alpha=0.5)
    ax2.set_title("Đột biến thích nghi & Bonus Penalty", fontsize=11, fontweight="bold")
    ax2.set_xlabel("Thế hệ")
    ax2.set_ylabel("Mutation Rate (p_m)", color="#7c3aed")
    ax2.tick_params(axis="y", labelcolor="#7c3aed")
    ax2.grid(True, ls=":", alpha=0.6)

    ax2_r = ax2.twinx()
    ax2_r.plot(gens, h["best_bonus_penalty"], color="#059669", lw=2.0, ls="--", label="Bonus Penalty B(x)")
    ax2_r.set_ylabel("Bonus Penalty B(x)", color="#059669")
    ax2_r.tick_params(axis="y", labelcolor="#059669")
    b_lo, b_hi = min(h["best_bonus_penalty"]), max(h["best_bonus_penalty"])
    ax2_r.set_ylim(max(0, b_lo - 10), b_hi + 10)

    l1, lb1 = ax2.get_legend_handles_labels()
    l2, lb2 = ax2_r.get_legend_handles_labels()
    ax2.legend(l1 + l2, lb1 + lb2, fontsize=8, loc="upper left", framealpha=0.92)

    fig.tight_layout(w_pad=2.0)
    plt.savefig(out_path, bbox_inches="tight")
    plt.close(fig)


def plot_constraint_comparison(results: Dict[str, GARunResult], out_path: Path) -> None:
    metrics = [
        ("Hard (H1–H7)", lambda r: r.best_chromosome.hard_violations),
        ("S1: Ca trống\nGV (ngày)", lambda r: r.best_chromosome.breakdown["S1_professor_idle_gap"]),
        ("S3: Ngày chia\nSáng+Chiều", lambda r: r.best_chromosome.breakdown["S3_professor_shift_conflict"]),
        ("S4: Môn lệch\nbuổi S/C", lambda r: r.best_chromosome.breakdown["S4_course_shift_conflict"]),
        ("S5: Dư kích\nthước phòng", lambda r: r.best_chromosome.breakdown["S5_room_size_mismatch"]),
        ("B2: Ngoài DS\ndạy của GV", lambda r: r.best_chromosome.breakdown["B2_out_of_list_sections"]),
    ]

    x = np.arange(len(metrics))
    width = 0.26
    algos = [k for k in ("baseline", "improved", "proposed") if k in results]

    fig, ax = plt.subplots(figsize=(12, 5.0), dpi=300)
    max_all = 1
    for i, key in enumerate(algos):
        vals = [fn(results[key]) for _, fn in metrics]
        max_all = max(max_all, max(vals))
        bars = ax.bar(
            x + (i - 1) * width,
            vals,
            width=width,
            color=COLORS[key],
            label=LABELS_VI[key],
            alpha=0.92,
        )
        for bar, v in zip(bars, vals):
            ax.text(
                bar.get_x() + bar.get_width() / 2.0,
                bar.get_height() + max_all * 0.015,
                f"{int(v)}",
                ha="center",
                va="bottom",
                fontsize=8,
                fontweight="bold",
            )

    ax.set_ylim(0, max_all * 1.16)
    ax.set_title("So sánh số lượng vi phạm cuối cùng giữa 3 phiên bản GA", fontsize=12, fontweight="bold")
    ax.set_xticks(x)
    ax.set_xticklabels([m[0] for m in metrics], fontsize=9.5)
    ax.set_ylabel("Số vi phạm / đơn vị phạt", fontsize=10)
    ax.grid(axis="y", ls=":", alpha=0.6)
    ax.legend(fontsize=8.8, loc="upper right")

    fig.tight_layout()
    plt.savefig(out_path, bbox_inches="tight")
    plt.close(fig)


def plot_room_utilization_heatmap(data: ProblemData, sched_df: pd.DataFrame, out_path: Path) -> None:
    occ_grid = np.zeros((data.num_timeslots, data.num_days), dtype=np.int32)
    avail_grid = np.zeros((data.num_timeslots, data.num_days), dtype=np.int32)

    for d in range(data.num_days):
        for t in range(data.num_timeslots):
            avail_grid[t, d] = int(data.room_avail_arr[d, t].sum())

    for _, row in sched_df.iterrows():
        occ_grid[int(row["timeslot"]) - 1, int(row["day_idx"])] += 1

    pct_grid = 100.0 * occ_grid / np.maximum(1, avail_grid)

    fig, ax = plt.subplots(figsize=(8.6, 5.0), dpi=300)
    im = ax.imshow(pct_grid, cmap="YlGnBu", vmin=70, vmax=100, aspect="auto")

    ax.set_xticks(np.arange(data.num_days))
    ax.set_xticklabels(config.DAY_NAMES_VI, fontsize=10.5, fontweight="bold")
    ax.set_yticks(np.arange(data.num_timeslots))
    ax.set_yticklabels([f"Ca {t} ({'Sáng' if t <= 3 else 'Chiều'})" for t in range(1, 7)], fontsize=10)
    ax.set_title("Tỷ lệ sử dụng phòng học theo Ngày và Ca học (Proposed GA)", fontsize=11.5, fontweight="bold")

    for t in range(data.num_timeslots):
        for d in range(data.num_days):
            val_txt = f"{occ_grid[t, d]}/{avail_grid[t, d]}\n({pct_grid[t, d]:.0f}%)"
            txt_color = "white" if pct_grid[t, d] > 88 else "#111827"
            ax.text(d, t, val_txt, ha="center", va="center", color=txt_color, fontsize=9, fontweight="bold")

    ax.axhline(2.5, color="#dc2626", lw=2.0, ls="--")
    cbar = fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cbar.set_label("Tỷ lệ lấp đầy phòng khả dụng (%)", fontsize=9.5)

    fig.tight_layout()
    plt.savefig(out_path, bbox_inches="tight")
    plt.close(fig)


def plot_sample_timetables(
    data: ProblemData, sched_df: pd.DataFrame, prof_df: pd.DataFrame, out_path: Path
) -> None:
    candidates = prof_df.sort_values(
        by=["intra_day_gaps", "mixed_shift_days", "favorite_sections"],
        ascending=[True, True, False],
    )
    selected = candidates["professor"].head(2).tolist()

    fig, axes = plt.subplots(1, 2, figsize=(13.2, 5.2), dpi=300)
    for ax, pname in zip(axes, selected):
        sub = sched_df[sched_df["professor"] == pname]
        prow = prof_df[prof_df["professor"] == pname].iloc[0]

        ax.set_xlim(0, 5)
        ax.set_ylim(0, 6)
        ax.invert_yaxis()
        ax.set_xticks(np.arange(5) + 0.5)
        ax.set_xticklabels(config.DAY_NAMES_VI, fontsize=10, fontweight="bold")
        ax.set_yticks(np.arange(6) + 0.5)
        ax.set_yticklabels([f"Ca {t}" for t in range(1, 7)], fontsize=10)

        for d in range(5):
            for t in range(6):
                bg = "#f8fafc" if t < 3 else "#f1f5f9"
                ax.add_patch(mpatches.Rectangle((d, t), 1, 1, facecolor=bg, edgecolor="#cbd5e1", lw=0.9))

        ax.axhline(3, color="#dc2626", lw=1.8, ls="--")

        for _, row in sub.iterrows():
            d = int(row["day_idx"])
            t = int(row["timeslot"]) - 1
            is_fav = bool(row["is_favorite_course"])
            face = "#dbeafe" if is_fav else "#e2e8f0"
            edge = "#1d4ed8" if is_fav else "#475569"
            ax.add_patch(
                mpatches.FancyBboxPatch(
                    (d + 0.06, t + 0.08),
                    0.88,
                    0.84,
                    boxstyle="round,pad=0.02,rounding_size=0.08",
                    facecolor=face,
                    edgecolor=edge,
                    lw=1.4,
                )
            )
            star = " ★" if is_fav else ""
            ax.text(
                d + 0.5,
                t + 0.5,
                f"{row['section']}{star}\n{row['room']} (Sz {row['room_size']})",
                ha="center",
                va="center",
                fontsize=8.2,
                fontweight="bold",
                color="#0f172a",
            )

        ax.set_title(
            f"Lịch giảng dạy mẫu: {pname} ({prow['sessions']} buổi | "
            f"Gap={prow['intra_day_gaps']} | Mixed={prow['mixed_shift_days']})\n"
            f"Top-3 yêu thích: {prow['top3_favorites']}",
            fontsize=10,
            fontweight="bold",
        )

    fav_patch = mpatches.Patch(facecolor="#dbeafe", edgecolor="#1d4ed8", label="Môn trong Top-3 yêu thích (★)")
    elig_patch = mpatches.Patch(facecolor="#e2e8f0", edgecolor="#475569", label="Môn thuộc danh sách giảng dạy")
    fig.legend(handles=[fav_patch, elig_patch], loc="lower center", ncol=2, fontsize=9.5, frameon=True)
    fig.tight_layout(rect=[0, 0.07, 1, 1])
    plt.savefig(out_path, bbox_inches="tight")
    plt.close(fig)
