= THIẾT KẾ VÀ HIỆN THỰC HỆ THỐNG (SYSTEM DESIGN AND IMPLEMENTATION)

== Công nghệ, kiến trúc tổng thể và cấu trúc mã nguồn

*Lựa chọn công nghệ và cơ sở kỹ thuật:* Bài toán xếp thời khóa biểu Homework 3 là bài toán tối ưu tổ hợp ngoại tuyến có quy mô dữ liệu hữu hạn (60 môn, 480 lớp, 60 giảng viên, 35 phòng) và không đòi hỏi xử lý giao dịch đồng thời đa người dùng. Vì vậy, nhóm lựa chọn *Python 3.12* kết hợp các thư viện khoa học chuẩn cùng cơ chế lưu trữ bằng tệp phẳng (`JSON`/`CSV`/`HTML`) thay vì hệ quản trị cơ sở dữ liệu hay kiến trúc vi dịch vụ, nhằm tối giản cài đặt, đảm bảo khả năng tái lập thực nghiệm tuyệt đối và dễ mở rộng thuật toán (@tab_tech_stack).

#block(breakable: false)[
  #figure(
    table(
      columns: (1.25fr, 1.0fr, 3.65fr),
      align: (left, center, left),
      inset: 4.5pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Công nghệ*]),
        text(fill: white, [*Phiên bản*]),
        text(fill: white, [*Vai trò và lý do lựa chọn trong hệ thống*]),
      ),
      [Python], [3.12], [Ngôn ngữ hiện thực chính; hỗ trợ `@dataclass`, Type Hints và tốc độ phát triển cao.],
      [`numpy`], [$>= 1.26$], [Sinh ngẫu nhiên có kiểm soát theo seed và lưu mảng chỉ số (`section_size_arr`, `room_avail_arr`, `is_eligible_arr`, `fav_rank_arr`) giúp truy cập $O(1)$ khi đánh giá Fitness.],
      [`pandas`], [$>= 2.1$], [Tổng hợp thống kê 960 buổi học, lịch sử hội tụ và xuất bảng `CSV` chuẩn hóa.],
      [`matplotlib`], [$>= 3.8$], [Tự động sinh 6 biểu đồ phân tích chất lượng cao 300 DPI phục vụ báo cáo.],
      [`pytest`], [$>= 8.0$], [Thực thi bộ kiểm thử đơn vị và tích hợp tự động trước khi chạy thực nghiệm.],
      [`streamlit`], [$>= 1.32$], [Cung cấp giao diện web tùy chọn cho cấu hình tham số, tra cứu lịch và xem biểu đồ.],
    ),
    caption: [Tổng hợp công nghệ và thư viện sử dụng trong hệ thống.]
  ) <tab_tech_stack>
]

*Kiến trúc hệ thống (Layered Modular Architecture):* Hệ thống được tổ chức theo *Kiến trúc Module phân lớp theo trách nhiệm* gồm sáu thành phần chính minh họa tại @fig_sys_arch và chi tiết hóa tại @tab_arch_layers. Nguyên tắc cốt lõi là phụ thuộc một chiều từ tầng trên xuống tầng dưới và cô lập hoàn toàn các mô hình nghiệp vụ (`src/models/`) cũng như quy tắc ràng buộc (`src/constraints/`) khỏi tầng giao diện và vòng lặp tiến hóa. Nhờ đó, nhóm có thể bổ sung ràng buộc mới hoặc thay đổi toán tử lai ghép/đột biến mà không làm ảnh hưởng các tầng còn lại.

#block(breakable: false)[
  #figure(
    image("../picture/System Architecture Diagram – Mục 5.2.svg", width: 100%),
    caption: [Kiến trúc module phân lớp của hệ thống xếp thời khóa biểu.]
  ) <fig_sys_arch>
]

#block(breakable: false)[
  #figure(
    table(
      columns: (1.45fr, 1.55fr, 2.9fr),
      align: (left, left, left),
      inset: 4.5pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Tầng / Module*]),
        text(fill: white, [*Tệp / Thư mục chính*]),
        text(fill: white, [*Trách nhiệm và quan hệ phụ thuộc*]),
      ),
      [Presentation Layer], [`main.py`, `app.py`], [Tiếp nhận tham số CLI / Web UI và hiển thị kết quả; chỉ gọi tới Application Layer.],
      [Application Layer], [`src/services/scheduler.py`], [`SchedulerService` điều phối chạy đơn lẻ hoặc đối chứng 3 phiên bản GA và đóng gói `ExperimentBundle`.],
      [Data Layer], [`data_generator.py`, `data_loader.py`], [Sinh dữ liệu kiểm soát, kiểm tra điều kiện cần tài nguyên và nạp `data/*.json` cùng mảng chỉ số NumPy.],
      [Constraint Module], [`src/constraints/*.py`], [Hiện thực tách biệt 7 ràng buộc cứng, 5 ràng buộc mềm và 3 chỉ tiêu Bonus; không phụ thuộc GA Engine.],
      [GA Engine], [`src/genetic/*.py`], [Hiện thực quần thể, khởi tạo, đánh giá Fitness, chọn lọc, lai ghép, đột biến, Repair 4 pha và vòng lặp tiến hóa.],
      [Domain & Output], [`src/models/`, `src/utils/`, `config.py`], [Định nghĩa thực thể, cấu trúc nghiệm, tập trung siêu tham số và xuất báo cáo `CSV`/`JSON`/`HTML`/PNG.],
    ),
    caption: [Trách nhiệm và quan hệ phụ thuộc giữa các tầng trong kiến trúc phần mềm.]
  ) <tab_arch_layers>
]

Cấu trúc cây thư mục mã nguồn phản ánh trực tiếp phân tầng kiến trúc nêu trên:

```text
btl3/
├── config.py, main.py, app.py, requirements.txt     # Tham số tập trung, CLI, Web UI
├── data/        (courses, sections, professors, rooms).json
├── src/
│   ├── models/      (course, section, session, professor, room, chromosome).py
│   ├── constraints/ (hard_constraints, soft_constraints, bonus_constraints).py
│   ├── genetic/     (population, initialization, fitness, selection, crossover, mutation, repair, engine).py
│   ├── services/    (data_generator, data_loader, scheduler).py
│   └── utils/       (statistics, exporter, visualization).py
├── tests/       (test_constraints, test_fitness, test_genetic, test_scheduler).py
└── outputs/     (best_schedule.csv, professor_summary.csv, fitness_history.csv, conflict_report.json, final_schedule.html, figures/)
```

== Thiết kế mô hình dữ liệu và cấu trúc vào/ra

*Sơ đồ lớp (Class Diagram):* Tầng Domain tách bạch hai nhóm lớp có vòng đời khác nhau (@fig_class_diagram): nhóm *mô hình dữ liệu bài toán* (`Course`, `Section`, `Professor`, `Room` — nạp một lần, bất biến và tham chiếu thông qua ID số nguyên) và nhóm *cấu trúc biểu diễn nghiệm* (`Population` $arrow.r$ `Chromosome` $arrow.r$ `Gene` $arrow.r$ `Session` — được nhân bản độc lập cho từng cá thể qua các thế hệ).

#block(breakable: false)[
  #figure(
    image("../picture/Class Diagram – Mục 5.4.1.svg", width: 72%),
    caption: [Sơ đồ lớp biểu diễn quan hệ giữa mô hình dữ liệu bài toán và cấu trúc nghiệm GA.]
  ) <fig_class_diagram>
]

Về bội số quan hệ đối tượng: một `Population` quản lý $N_"pop" = 80$ `Chromosome`; mỗi `Chromosome` sở hữu đúng 480 `Gene` tương ứng 1–1 với 480 `Section`; mỗi `Gene` liên kết với một `Professor` (`professor_id`) và chứa đúng hai đối tượng `Session` (`session_1`, `session_2`) theo quan hệ hợp thành (*Composition*); mỗi `Session` tham chiếu tới một `Room` (`room_id`); còn ở phía dữ liệu nền, mỗi `Course` gồm đúng 8 `Section` (tỷ lệ 1:8). Cách tham chiếu bằng chỉ số nguyên `0..N-1` thay vì lồng ghép đối tượng giúp thao tác sao chép nghiệm cực nhẹ và tra cứu trực tiếp trên mảng NumPy.

*Cấu trúc dữ liệu đầu vào (`data/*.json`) và đầu ra (`outputs/`):* Hệ thống tách biệt hoàn toàn hai hạt giống ngẫu nhiên là `--seed` (sinh dữ liệu đầu vào cố định) và `--ga-seed` (điều khiển quá trình tiến hóa GA), đảm bảo có thể khảo sát nhiều cấu hình thuật toán trên chính xác cùng một bộ dữ liệu. Danh mục tệp vào/ra chính được tổng hợp tại @tab_io_files.

#block(breakable: false)[
  #figure(
    table(
      columns: (1.9fr, 0.75fr, 3.25fr),
      align: (left, center, left),
      inset: 4pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Tệp tin*]),
        text(fill: white, [*Loại*]),
        text(fill: white, [*Nội dung và cấu trúc chính*]),
      ),
      [`data/courses.json`, `sections.json`], [Đầu vào], [60 môn học và 480 lớp học phần kèm `course_id`, `registration_size` ($0, 1, 2$).],
      [`data/professors.json`, `rooms.json`], [Đầu vào], [60 giảng viên (`eligible_courses` 6 môn, `favorite_courses` 3 môn, `max_sessions=20`) và 35 phòng (ma trận khả dụng $5 times 6$).],
      [`outputs/` `best_schedule.csv`], [Đầu ra], [960 dòng chi tiết từng buổi học kèm `period`, `is_favorite_course`, `size_waste`.],
      [`outputs/` `professor_summary.csv`], [Đầu ra], [Thống kê 60 giảng viên: tổng số lớp/buổi, số ca trống, số ngày chia buổi và tỷ lệ Top-3.],
      [`outputs/` `conflict_report.json`], [Đầu ra], [Báo cáo định lượng toàn bộ 15 chỉ tiêu ràng buộc và thống kê khả thi cho cả 3 phiên bản GA.],
      [`outputs/final_schedule.html`, `figures/*.png`], [Đầu ra], [Trang web tra cứu lịch độc lập và 6 biểu đồ phân tích 300 DPI (`fitness_plot.png`, heatmap, sensitivity, breakdown...).],
    ),
    caption: [Mô tả cấu trúc các tệp dữ liệu đầu vào và đầu ra.]
  ) <tab_io_files>
]

== Hiện thực các module cốt lõi và kỹ thuật tối ưu

- *Sinh dữ liệu và kiểm tra điều kiện cần (`src/services/data_generator.py`):* Sinh ngẫu nhiên có kiểm soát bộ dữ liệu (`seed = 42`, tạo 26/1050 vị trí phòng bảo trì) đồng thời áp dụng bộ kiểm tra tích lũy theo kích thước với khoảng dự phòng an toàn: $"req"_2 <= "avail"_2 - 20$, $"req"_2 + "req"_1 <= "avail"_2 + "avail"_1 - 30$, công suất mỗi ngày $>= 202$ vị trí, và mỗi môn có tối thiểu 5 giảng viên đủ năng lực cùng 2 giảng viên yêu thích. Cần nhấn mạnh rằng các phép kiểm tra này chỉ là *điều kiện cần* nhằm loại sớm các bộ dữ liệu vô nghiệm về mặt tổng tài nguyên, không phải điều kiện đủ đảm bảo tồn tại nghiệm; tính khả thi thực sự chỉ được xác nhận khi thuật toán tìm thấy nghiệm cụ thể đạt $H(x) = 0$.
- *Mô hình Domain và sao chép sâu (`src/models/`):* Các thực thể được định nghĩa bằng `@dataclass` và Type Hints giúp mã nguồn gọn, rõ ràng. Tuy nhiên, vì `@dataclass` không tự động kiểm tra miền giá trị lúc chạy và phép gán thông thường chỉ sao chép tham chiếu (*shallow copy*), các lớp `Session`, `Gene` và `Chromosome` đều cài đặt tường minh phương thức `copy()` để tạo bản sao độc lập. Quyết định này đảm bảo mọi phép lai ghép, đột biến hay thử nghiệm trong Repair tác động lên cá thể con không bao giờ làm biến đổi ngoài ý muốn các cá thể ưu tú đang được lưu giữ trong Elitism.
- *Tối ưu đánh giá ràng buộc bằng Bitmask 6-bit (`src/constraints/`):* Module cung cấp cả các hàm kiểm tra đơn lẻ phục vụ kiểm thử đơn vị (`pytest`) lẫn hàm đánh giá tổng hợp một lượt duyệt (`evaluate_hard_constraints()`, `evaluate_soft_constraints()`). Để tăng tốc đánh giá lịch dạy của giảng viên trên 6 ca mỗi ngày, trạng thái bận của giảng viên $p$ tại ngày $d$ được nén thành một số nguyên *bitmask 6-bit*:
  $ b_(p,d) = sum_(t in cal(T)) 2^t II[N_p(d,t) > 0] $
  *Ví dụ minh họa:* Nếu giảng viên dạy ca 0, ca 2 và ca 4 trong ngày, bitmask tương ứng là `0b010101` (giá trị thập phân 21). Chỉ bằng các phép toán bit $O(1)$, hệ thống xác định ngay vị trí bit thấp nhất (`0`), bit cao nhất (`4`), tổng số bit bật (`3`) để suy ra số ca trống $S_1 = 4 - 0 + 1 - 3 = 2$; đồng thời phép toán AND với mặt nạ buổi sáng `0b000111` (khác 0) và buổi chiều `0b111000` (khác 0) phát hiện tức thời việc dạy cả hai buổi ($S_3 = 1$). Riêng các ràng buộc phát hiện trùng lịch ($H_3, H_7$) vẫn sử dụng mảng đếm số lượng vì bitmask chỉ lưu trạng thái nhị phân có/không và không phân biệt được mức độ trùng lặp từ 2 buổi trở lên tại cùng một ca.
- *Hàm thích nghi, GA Engine và Repair (`fitness.py`, `engine.py`, `repair.py`):* `fitness.py` tính toán một lần và ghi trực tiếp các thuộc tính (`fitness`, `hard_violations`, `soft_penalty`, `bonus_penalty`, `total_penalty`, `breakdown`) vào đối tượng `Chromosome` để `selection.py` và Elitism tái sử dụng tức thời mà không tính lặp lại. `engine.py` vận hành cùng một bộ máy tiến hóa chung cho cả ba chế độ `baseline`, `improved` và `proposed` (chỉ bật/tắt đúng thành phần tương ứng), đảm bảo tuyệt đối tính công bằng khi đối chứng. Trong `repair.py`, thao tác *Same-Day Pairwise Swap* giải phóng đồng thời cả hai buổi khỏi bảng trạng thái tài nguyên cục bộ trước khi kiểm tra xung đột tại vị trí hoán đổi nhằm tránh xung đột giả, và sau khi hoàn tất sửa chữa luôn gọi lại `fitness.py` để đồng bộ hóa chính xác toàn bộ chỉ số đánh giá.

== Luồng hoạt động, giao diện web và hướng dẫn sử dụng

@fig_sys_activity mô tả luồng hoạt động tổng thể của phần mềm trong chế độ thực nghiệm đối chứng qua bốn giai đoạn: chuẩn bị cấu hình & dữ liệu $arrow.r$ điều phối chạy tuần tự ba phiên bản GA $arrow.r$ xếp hạng chọn nghiệm tốt nhất theo $R(x)$ $arrow.r$ thống kê, xuất tệp và vẽ biểu đồ. Khác với lưu đồ Chương 4 đi sâu vào vòng lặp tiến hóa bên trong thuật toán, sơ đồ này thể hiện cách toàn bộ hệ thống phần mềm kết nối từ đầu vào đến đầu ra.

#block(breakable: false)[
  #figure(
    image("../picture/System Activity Diagram – Mục 5.6.svg", width: 70%),
    caption: [Luồng thực thi tổng thể của hệ thống trong chế độ thực nghiệm đối chứng.]
  ) <fig_sys_activity>
]

*Giao diện web trực quan (`app.py` – Streamlit):* Bên cạnh chế độ dòng lệnh `main.py` phục vụ thực nghiệm tự động, hệ thống cung cấp giao diện web tùy chọn gồm ba phân khu chức năng: (1) *Dashboard & Cấu hình* cho phép tùy chỉnh `Population Size`, `Max Generations`, lựa chọn chế độ GA và chạy trực tiếp; (2) *Tra cứu thời khóa biểu* hỗ trợ lọc nhanh toàn bộ 960 buổi học theo giảng viên, phòng học, môn học hoặc ngày học; và (3) *Phân tích kết quả* hiển thị trực quan bảng vi phạm 15 chỉ tiêu và biểu đồ hội tụ. Tầng giao diện chỉ giao tiếp thông qua `SchedulerService`, tuyệt đối không chứa logic thuật toán.

*Hướng dẫn cài đặt và vận hành hệ thống (Python 3.12):*
```bash
python -m venv .venv && .venv\Scripts\activate   # Tạo và kích hoạt môi trường ảo
python -m pip install -r requirements.txt        # Cài đặt đầy đủ thư viện phụ thuộc
python -m pytest -v                              # Chạy bộ 8 ca kiểm thử tự động
python main.py --pop-size 80 --generations 200 --seed 42 --ga-seed 2026
streamlit run app.py                             # Khởi chạy giao diện web tra cứu
```
