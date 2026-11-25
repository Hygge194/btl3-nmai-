"""Exporters for schedule CSV, fitness history CSV, conflict report JSON, TXT, and HTML."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Dict

import pandas as pd

import config
from src.services.scheduler import ExperimentBundle
from src.utils.statistics import (
    build_conflict_report,
    build_professor_summary,
    build_schedule_dataframe,
)


def export_all(
    bundle: ExperimentBundle,
    output_dir: Path | str = config.OUTPUT_DIR,
) -> Dict[str, pd.DataFrame]:
    out_dir = Path(output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    best_chrom = bundle.best_result.best_chromosome
    sched_df = build_schedule_dataframe(best_chrom, bundle.data)
    prof_df = build_professor_summary(best_chrom, bundle.data)
    conflict_report = build_conflict_report(bundle)

    # 1. outputs/best_schedule.csv
    sched_df.to_csv(out_dir / "best_schedule.csv", index=False, encoding="utf-8-sig")

    # 2. outputs/professor_summary.csv
    prof_df.to_csv(out_dir / "professor_summary.csv", index=False, encoding="utf-8-sig")

    # 3. outputs/fitness_history.csv (combined across all executed GA modes)
    hist_rows = []
    for mode, res in bundle.results.items():
        h = res.history
        for i in range(len(h["generation"])):
            hist_rows.append(
                {
                    "mode": mode,
                    "generation": int(h["generation"][i]),
                    "best_fitness": h["best_fitness"][i],
                    "avg_fitness": h["avg_fitness"][i],
                    "best_penalty": h["best_penalty"][i],
                    "best_hard": int(h["best_hard"][i]),
                    "best_soft_penalty": h["best_soft_penalty"][i],
                    "best_bonus_penalty": h["best_bonus_penalty"][i],
                    "mutation_rate": h["mutation_rate"][i],
                }
            )
    hist_df = pd.DataFrame(hist_rows)
    hist_df.to_csv(out_dir / "fitness_history.csv", index=False, encoding="utf-8-sig")

    # 4. outputs/conflict_report.json
    with (out_dir / "conflict_report.json").open("w", encoding="utf-8") as f:
        json.dump(conflict_report, f, indent=2, ensure_ascii=False)

    # 5. outputs/schedule_report.txt
    _write_text_report(bundle, sched_df, prof_df, out_dir / "schedule_report.txt")

    # 6. outputs/final_schedule.html
    _write_html_schedule(bundle, sched_df, out_dir / "final_schedule.html")

    return {"schedule": sched_df, "professors": prof_df, "history": hist_df}


def _write_text_report(
    bundle: ExperimentBundle,
    sched_df: pd.DataFrame,
    prof_df: pd.DataFrame,
    path: Path,
) -> None:
    data = bundle.data
    best = bundle.best_result
    b = best.best_chromosome
    bd = b.breakdown
    feas = data.feasibility_summary()

    lines = [
        "=" * 90,
        "CLASS SCHEDULING USING GENETIC ALGORITHM (CO3061 - HOMEWORK 3)",
        "=" * 90,
        f"Scale    : {data.num_courses} courses | {data.num_sections} sections | {data.num_sessions} sessions | "
        f"{data.num_professors} professors | {data.num_rooms} rooms",
        f"Capacity : {feas['available_room_slots']}/{feas['total_room_slots']} available room-slots "
        f"({feas['utilization_pct']}% utilization)",
        "",
        "--- ALGORITHM COMPARISON ---",
        f"{'Mode':<10} {'Fitness':>12} {'TotalPen':>12} {'Hard':>6} {'SoftPen':>9} {'BonusPen':>10} {'Time(s)':>8}",
        "-" * 75,
    ]
    for mode, res in bundle.results.items():
        ch = res.best_chromosome
        lines.append(
            f"{mode:<10} {ch.fitness:12.8f} {ch.total_penalty:12.1f} {ch.hard_violations:6d} "
            f"{ch.soft_penalty:9.1f} {ch.bonus_penalty:10.1f} {res.elapsed_seconds:8.2f}"
        )

    lines.append("")
    lines.append(f"--- BEST SOLUTION ({bundle.best_mode.upper()}) CONSTRAINT VERIFICATION ---")
    lines.append(f"Hard Violations Total: {b.hard_violations}")
    for key in (
        "H1_room_capacity",
        "H2_session_spacing",
        "H3_professor_conflict",
        "H4_professor_workload",
        "H5_room_availability",
        "H6_section_conflict",
        "H7_room_conflict",
    ):
        lines.append(f"  {key:<28}: {bd[key]}")

    lines.append("Soft Constraints:")
    for key in (
        "S1_professor_idle_gap",
        "S2_professor_day_scatter",
        "S3_professor_shift_conflict",
        "S4_course_shift_conflict",
        "S5_room_size_mismatch",
    ):
        lines.append(f"  {key:<28}: {bd[key]}")
    lines.append(
        f"  Exact room-size matches     : {bd['exact_size_matches']}/{data.num_sessions} "
        f"({100.0 * bd['exact_size_matches'] / data.num_sessions:.2f}%)"
    )

    lines.append("Bonus Constraints (Bonus 1 & 2):")
    lines.append(f"  B2_out_of_list_sections     : {bd['B2_out_of_list_sections']}")
    lines.append(f"  B1a_profs_without_favorite  : {bd['B1a_profs_without_favorite']}")
    lines.append(f"  Profs with >=1 favorite     : {bd['profs_with_favorite']}/{data.num_professors}")
    lines.append(
        f"  Favorite sections           : {bd['favorite_sections']}/{data.num_sections} "
        f"({100.0 * bd['favorite_sections'] / data.num_sections:.2f}%)"
    )

    lines.append("")
    lines.append("--- SAMPLE PROFESSOR TIMETABLES (p01, p02, p03) ---")
    for pname in ("p01", "p02", "p03"):
        sub = sched_df[sched_df["professor"] == pname]
        prow = prof_df[prof_df["professor"] == pname].iloc[0]
        lines.append(
            f"\nProfessor {pname} | Sessions: {prow['sessions']} | DayGaps: {prow['intra_day_gaps']} | "
            f"MixedDays: {prow['mixed_shift_days']} | FavSecs: {prow['favorite_sections']}/{prow['sections']} | "
            f"Top3: [{prow['top3_favorites']}]"
        )
        lines.append(f"{'Slot':<6} " + " ".join(f"{d:<16}" for d in config.DAY_NAMES_EN))
        for ts in range(1, 7):
            cells = []
            for d_idx in range(5):
                hit = sub[(sub["day_idx"] == d_idx) & (sub["timeslot"] == ts)]
                if len(hit) == 1:
                    r = hit.iloc[0]
                    star = "*" if r["is_favorite_course"] else " "
                    cells.append(f"{r['section']}@{r['room']}{star}"[:16].ljust(16))
                else:
                    cells.append(".".ljust(16))
            lines.append(f"T{ts:<5} " + " ".join(cells))

    path.write_text("\n".join(lines), encoding="utf-8")


def _write_html_schedule(bundle: ExperimentBundle, sched_df: pd.DataFrame, path: Path) -> None:
    b = bundle.best_result.best_chromosome
    bd = b.breakdown
    records = sched_df[
        [
            "course",
            "section",
            "section_size",
            "professor",
            "day_vi",
            "timeslot",
            "period",
            "room",
            "room_size",
            "is_favorite_course",
            "size_waste",
        ]
    ].to_dict(orient="records")
    data_json = json.dumps(records, ensure_ascii=False)

    html = f"""<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Thời Khóa Biểu Tối Ưu — Genetic Algorithm (CO3061)</title>
<style>
  body {{ font-family: 'Segoe UI', Arial, sans-serif; margin: 24px; background: #f5f7fb; color: #1f2937; }}
  h1 {{ color: #0f3d7a; margin-bottom: 6px; }}
  .subtitle {{ color: #4b5563; margin-bottom: 20px; }}
  .cards {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(170px, 1fr)); gap: 12px; margin-bottom: 20px; }}
  .card {{ background: #fff; padding: 14px 16px; border-radius: 10px; box-shadow: 0 2px 6px rgba(0,0,0,0.06); border-left: 4px solid #1d4ed8; }}
  .card.ok {{ border-left-color: #16a34a; }}
  .card .label {{ font-size: 12px; color: #6b7280; text-transform: uppercase; }}
  .card .val {{ font-size: 21px; font-weight: 700; margin-top: 4px; color: #111827; }}
  .controls {{ background: #fff; padding: 14px 16px; border-radius: 10px; box-shadow: 0 2px 6px rgba(0,0,0,0.06); margin-bottom: 16px; display: flex; flex-wrap: wrap; gap: 12px; align-items: center; }}
  .controls input, .controls select {{ padding: 8px 10px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 14px; }}
  table {{ width: 100%; border-collapse: collapse; background: #fff; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 6px rgba(0,0,0,0.06); }}
  th, td {{ padding: 9px 11px; text-align: left; border-bottom: 1px solid #e5e7eb; font-size: 13px; }}
  th {{ background: #0f3d7a; color: #fff; position: sticky; top: 0; }}
  tr:hover {{ background: #eff6ff; }}
  .badge {{ padding: 2px 7px; border-radius: 999px; font-size: 11px; font-weight: 600; }}
  .fav {{ background: #fef3c7; color: #92400e; }}
  .exact {{ background: #dcfce7; color: #166534; }}
  .waste {{ background: #e0e7ff; color: #3730a3; }}
</style>
</head>
<body>
  <h1>Thời Khóa Biểu Tối Ưu — Proposed Genetic Algorithm (CO3061)</h1>
  <div class="subtitle">{bundle.data.num_courses} môn học · {bundle.data.num_sections} lớp · {bundle.data.num_sessions} buổi · {bundle.data.num_professors} giảng viên · {bundle.data.num_rooms} phòng</div>
  <div class="cards">
    <div class="card ok"><div class="label">Hard Violations</div><div class="val">{b.hard_violations}</div></div>
    <div class="card"><div class="label">Fitness F(x)</div><div class="val">{b.fitness:.6f}</div></div>
    <div class="card"><div class="label">Tổng Penalty</div><div class="val">{b.total_penalty:.1f}</div></div>
    <div class="card ok"><div class="label">GV có Top-3 yêu thích</div><div class="val">{bd['profs_with_favorite']}/{bundle.data.num_professors}</div></div>
    <div class="card ok"><div class="label">Lớp ngoài danh sách</div><div class="val">{bd['B2_out_of_list_sections']}</div></div>
    <div class="card"><div class="label">Khớp kích thước phòng</div><div class="val">{bd['exact_size_matches']}/{bundle.data.num_sessions}</div></div>
  </div>
  <div class="controls">
    <input id="q" type="text" placeholder="Tìm nhanh (c01, p05, rm12...)" oninput="render()" />
    <select id="dayFilter" onchange="render()">
      <option value="">Tất cả các ngày</option>
      <option value="Thứ 2">Thứ 2</option>
      <option value="Thứ 3">Thứ 3</option>
      <option value="Thứ 4">Thứ 4</option>
      <option value="Thứ 5">Thứ 5</option>
      <option value="Thứ 6">Thứ 6</option>
    </select>
    <select id="periodFilter" onchange="render()">
      <option value="">Cả Sáng & Chiều</option>
      <option value="Morning">Sáng (Ca 1-3)</option>
      <option value="Afternoon">Chiều (Ca 4-6)</option>
    </select>
    <span id="count" style="margin-left:auto; font-weight:600; color:#374151;"></span>
  </div>
  <table>
    <thead>
      <tr>
        <th>Ngày</th><th>Ca</th><th>Buổi</th><th>Phòng (Size)</th><th>Môn</th>
        <th>Lớp (Size)</th><th>Giảng viên</th><th>Môn yêu thích</th><th>Độ khớp phòng</th>
      </tr>
    </thead>
    <tbody id="tbody"></tbody>
  </table>
<script>
const DATA = {data_json};
function render() {{
  const q = document.getElementById('q').value.trim().toLowerCase();
  const d = document.getElementById('dayFilter').value;
  const p = document.getElementById('periodFilter').value;
  const rows = DATA.filter(r => {{
    if (d && r.day_vi !== d) return false;
    if (p && r.period !== p) return false;
    if (q) {{
      const hay = (r.course + ' ' + r.section + ' ' + r.professor + ' ' + r.room).toLowerCase();
      if (!hay.includes(q)) return false;
    }}
    return true;
  }});
  document.getElementById('count').textContent = `Hiển thị ${{rows.length}} / ${{DATA.length}} buổi học`;
  document.getElementById('tbody').innerHTML = rows.map(r => `<tr>
    <td>${{r.day_vi}}</td>
    <td>Ca ${{r.timeslot}}</td>
    <td>${{r.period === 'Morning' ? 'Sáng' : 'Chiều'}}</td>
    <td><b>${{r.room}}</b> (${{r.room_size}})</td>
    <td>${{r.course}}</td>
    <td><b>${{r.section}}</b> (${{r.section_size}})</td>
    <td>${{r.professor}}</td>
    <td>${{r.is_favorite_course ? '<span class="badge fav">Top-3 ★</span>' : 'Danh sách dạy'}}</td>
    <td>${{r.size_waste === 0 ? '<span class="badge exact">Khớp chuẩn</span>' : '<span class="badge waste">Dư +' + r.size_waste + '</span>'}}</td>
  </tr>`).join('');
}}
render();
</script>
</body>
</html>
"""
    path.write_text(html, encoding="utf-8")
