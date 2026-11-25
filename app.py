"""Optional Streamlit UI for Class Scheduling using Genetic Algorithm (CO3061).

Run with:
    streamlit run app.py
"""

from __future__ import annotations

import json
import pandas as pd
import streamlit as st

import config
from src.services.data_generator import generate_data
from src.services.data_loader import load_data
from src.services.scheduler import SchedulerService
from src.utils.exporter import export_all
from src.utils.visualization import generate_all_plots

st.set_page_config(page_title="GA Class Scheduler (CO3061)", layout="wide")
st.title("GA Class Scheduler — Intelligent Timetable Optimization")
st.caption("CO3061 - Nhập môn Trí Tuệ Nhân Tạo | Modular Layered Architecture")

tab_dash, tab_sched, tab_analysis = st.tabs(["Dashboard & Cấu hình", "Thời khóa biểu", "Phân tích Kết quả"])

with tab_dash:
    c1, c2, c3, c4 = st.columns(4)
    c1.metric("Courses", config.NUM_COURSES)
    c2.metric("Sections", config.NUM_SECTIONS)
    c3.metric("Professors", config.NUM_PROFESSORS)
    c4.metric("Rooms", config.NUM_ROOMS)

    st.subheader("Cấu hình Giải thuật Di truyền")
    col_a, col_b, col_c = st.columns(3)
    pop_size = col_a.slider("Population size", 20, 150, config.POPULATION_SIZE, step=10)
    max_gens = col_b.slider("Max generations", 20, 500, config.MAX_GENERATIONS, step=20)
    mode = col_c.selectbox("Phiên bản GA", ["proposed", "improved", "baseline"])

    if st.button("Chạy tối ưu Thời khóa biểu", type="primary"):
        with st.spinner("Đang chạy Giải thuật Di truyền..."):
            data = generate_data(seed=config.RANDOM_SEED, save_dir=config.DATA_DIR)
            svc = SchedulerService(data)
            bundle = svc.run_comparison(
                modes=(mode,),
                population_size=pop_size,
                max_generations=max_gens,
                seed=config.GA_SEED,
                verbose=False,
            )
            dfs = export_all(bundle, config.OUTPUT_DIR)
            generate_all_plots(bundle, dfs["schedule"], dfs["professors"], config.OUTPUT_DIR)
        st.success("Hoàn tất tối ưu và xuất kết quả vào thư mục outputs/!")

with tab_sched:
    sched_path = config.OUTPUT_DIR / "best_schedule.csv"
    if sched_path.exists():
        df = pd.read_csv(sched_path)
        f1, f2, f3 = st.columns(3)
        prof_sel = f1.selectbox("Lọc theo Giảng viên", ["Tất cả"] + sorted(df["professor"].unique().tolist()))
        room_sel = f2.selectbox("Lọc theo Phòng học", ["Tất cả"] + sorted(df["room"].unique().tolist()))
        course_sel = f3.selectbox("Lọc theo Môn học", ["Tất cả"] + sorted(df["course"].unique().tolist()))

        view = df.copy()
        if prof_sel != "Tất cả":
            view = view[view["professor"] == prof_sel]
        if room_sel != "Tất cả":
            view = view[view["room"] == room_sel]
        if course_sel != "Tất cả":
            view = view[view["course"] == course_sel]
        st.dataframe(view, use_container_width=True, height=520)
    else:
        st.info("Chưa có dữ liệu outputs/best_schedule.csv. Hãy chạy `python main.py` trước.")

with tab_analysis:
    report_path = config.OUTPUT_DIR / "conflict_report.json"
    if report_path.exists():
        report = json.loads(report_path.read_text(encoding="utf-8"))
        st.json(report["algorithms"])
        for fname in ("fitness_plot.png", "figures/penalty_breakdown.png", "figures/room_utilization_heatmap.png"):
            p = config.OUTPUT_DIR / fname
            if p.exists():
                st.image(str(p), use_container_width=True)
    else:
        st.info("Chưa có báo cáo phân tích. Hãy chạy `python main.py` trước.")
