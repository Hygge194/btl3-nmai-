# Class Scheduling using Genetic Algorithm (CO3061 — Homework 3)

Hệ thống tự động xếp thời khóa biểu đại học quy mô lớn (**60 môn học, 480 lớp, 960 buổi học, 60 giảng viên, 35 phòng học**) bằng **Giải thuật Di truyền (Genetic Algorithm)**, được xây dựng theo **Kiến trúc Module phân lớp (Layered Modular Architecture)**.

## Cấu trúc thư mục dự án

```text
btl3/
├── config.py                    # Cấu hình bài toán, hyperparameter GA & trọng số Fitness
├── main.py                      # Điểm khởi chạy chương trình (so sánh 3 phiên bản GA)
├── app.py                       # Giao diện người dùng Streamlit (tùy chọn)
├── requirements.txt             # Danh sách thư viện Python
├── README.md
├── data/                        # Dữ liệu đầu vào sinh ngẫu nhiên (JSON)
│   ├── courses.json
│   ├── professors.json
│   ├── rooms.json
│   └── sections.json
├── src/
│   ├── models/                  # Domain Layer (Dataclasses)
│   │   ├── course.py
│   │   ├── section.py
│   │   ├── session.py
│   │   ├── professor.py
│   │   ├── room.py
│   │   └── chromosome.py        # Gene (1 section) & Chromosome (480 genes)
│   ├── constraints/             # Constraint Module
│   │   ├── hard_constraints.py  # H1-H7 (capacity, spacing, conflicts, workload, availability)
│   │   ├── soft_constraints.py  # S1-S5 (idle gap, day scatter, prof/course shift, size match)
│   │   └── bonus_constraints.py # Bonus 1 (Top-3 favorites) & Bonus 2 (Eligible course list)
│   ├── genetic/                 # GA Engine
│   │   ├── population.py
│   │   ├── initialization.py    # Random Init & Capacity-Balanced Greedy Randomized Init
│   │   ├── fitness.py           # Weighted Penalty Function: F(x) = 1 / (1 + P(x))
│   │   ├── selection.py         # Tournament Selection (lexicographic hard/penalty rank)
│   │   ├── crossover.py         # Uniform Crossover & Asymmetric Course-Block Crossover
│   │   ├── mutation.py          # Random Reassignment & Smart Swap Mutation
│   │   ├── repair.py            # Constraint-based Repair + Same-Day Pairwise Swap Polish
│   │   └── engine.py            # GeneticAlgorithm (Baseline / Improved / Proposed)
│   ├── services/                # Application & Data Services
│   │   ├── data_generator.py
│   │   ├── data_loader.py
│   │   └── scheduler.py
│   └── utils/                   # Output, Statistics, Visualization & PDF Report
│       ├── statistics.py
│       ├── exporter.py
│       ├── visualization.py
│       └── pdf_report.py
├── tests/                       # Bộ kiểm thử Pytest (8/8 PASSED)
│   ├── test_constraints.py
│   ├── test_fitness.py
│   ├── test_genetic.py
│   └── test_scheduler.py
├── outputs/                     # Kết quả xuất ra
│   ├── best_schedule.csv        # Thời khóa biểu tối ưu 960 buổi học
│   ├── fitness_history.csv      # Lịch sử tiến hóa qua các thế hệ
│   ├── fitness_plot.png         # Biểu đồ Fitness so sánh 3 phiên bản GA
│   ├── conflict_report.json     # Báo cáo đối chứng chi tiết toàn bộ ràng buộc
│   ├── professor_summary.csv    # Tổng hợp lịch của 60 giảng viên
│   ├── final_schedule.html      # Trình xem thời khóa biểu tương tác trên trình duyệt
│   ├── schedule_report.txt      # Tóm tắt văn bản & lịch mẫu
│   └── figures/                 # Bộ biểu đồ 300 DPI
└── docs/
    └── report.pdf               # Báo cáo học thuật tiếng Việt hoàn chỉnh (6 trang A4)
```

## Hướng dẫn cài đặt và chạy

```bash
# 1. Cài đặt thư viện (nếu chưa có)
pip install -r requirements.txt

# 2. Chạy bộ kiểm thử đơn vị & tích hợp
python -m pytest -v

# 3. Chạy thực nghiệm đối chứng 3 phiên bản GA và xuất kết quả
python main.py --pop-size 80 --generations 200 --seed 42 --ga-seed 2026


# 5. (Tùy chọn) Mở giao diện Streamlit
streamlit run app.py
```

## Kết quả thực nghiệm (200 thế hệ, seed=42)

| Phiên bản GA | Fitness $F(x)$ | Tổng Penalty | Hard (H1–H7) | Soft Penalty | Bonus Penalty | Khớp cỡ phòng | GV có Top-3 |
|---|---:|---:|---:|---:|---:|---:|---:|
| **Baseline GA** (Random Init) | 0.00000002 | 41,485,175.5 | 393 | 4,493.0 | 2,180,682.5 | 45.2% | 20/60 |
| **Improved GA** (Greedy Init) | 0.00000331 | 302,501.0 | 3 | 2,459.0 | 42.0 | 95.6% | 60/60 |
| **Proposed GA** (Greedy + Repair + Elitism) | **0.00063633** | **1,570.5** | **0** | **1,515.0** | **55.5** | **93.1% (894/960)** | **60/60 (100%)** |
"# btl3-nmai-" 
