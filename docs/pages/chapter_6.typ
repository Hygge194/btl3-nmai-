= THỰC NGHIỆM VÀ ĐÁNH GIÁ (EXPERIMENTS AND EVALUATION)

== Thiết lập thực nghiệm và kiểm thử tự động

*1. Môi trường thực thi và đặc trưng bộ dữ liệu:*
Toàn bộ các thực nghiệm được thực thi tuần tự (đơn luồng) trên hệ điều hành Windows với Python 3.12.1. Bộ dữ liệu chuẩn hóa được sinh bằng `data_generator.py` với `seed = 42`, bao gồm 60 môn học, 480 lớp học phần (960 buổi học), 60 giảng viên (tổng công suất 1.200 buổi/tuần, mức sử dụng 80,0%; mỗi môn có tối thiểu 5 giảng viên đủ năng lực $E_p$ và 2 giảng viên chọn Top-3 $F_p$) và 35 phòng học. Với 26/1050 vị trí phòng–ca không khả dụng do bảo trì (`2,48%`), tổng công suất khả dụng còn `1024` vị trí (`93,75%` mật độ sử dụng, chỉ dư 64 vị trí), phân bố đồng đều theo năm ngày `[204, 205, 205, 205, 205]` (dư 12–13 vị trí/ngày so với tải mục tiêu 192) và theo buổi (`515` sáng, `509` chiều). Cơ cấu cung–cầu theo kích thước phòng học được tổng hợp tại @tab_dataset_stats, làm rõ nguyên nhân xuất hiện cận dưới $S_5 >= 29$ do nhóm lớp cỡ trung bình (Size 1) vượt công suất phòng cùng cỡ 29 buổi.

#block(breakable: false)[
  #figure(
    table(
      columns: (1.55fr, 0.9fr, 1.0fr, 1.1fr, 1.25fr, 1.0fr),
      align: (left, center, center, center, center, center),
      inset: 4.5pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if y == 4 { rgb("#e2e8f0") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Nhóm kích thước*]), text(fill: white, [*Số phòng*]), text(fill: white, [*Số lớp*]),
        text(fill: white, [*Nhu cầu buổi*]), text(fill: white, [*Ô khả dụng*]), text(fill: white, [*Chênh lệch*]),
      ),
      [Size 0 (Nhỏ)], [11], [158], [316], [324], [$+8$],
      [Size 1 (Trung bình)], [11], [174], [348], [319], [$-29$ (đẩy Size 2)],
      [Size 2 (Lớn)], [13], [148], [296], [381], [$+85$],
      [*Tổng toàn trường*], [*35*], [*480*], [*960*], [*1.024*], [*$+64$ (6,25%)*],
    ),
    caption: [Thống kê cung–cầu phòng học theo kích thước (`seed = 42`).]
  ) <tab_dataset_stats>
]

*2. Cấu hình tham số mặc định và tiêu chí đánh giá:*
Ba phiên bản thuật toán (*Baseline GA*, *Improved GA* và *Proposed GA*) được đối chứng công bằng trên cùng bộ siêu tham số mặc định (@tab_exp_config). Chất lượng nghiệm được đánh giá theo sáu tiêu chí định lượng: (1) tổng số vi phạm ràng buộc cứng $H(x)$ (tiêu chí quyết định tính khả thi qua $R(x) = (H(x), P(x))$), (2) tổng điểm phạt mềm $P_"soft"(x)$ và từng thành phần $S_1$–$S_5$, (3) các chỉ tiêu mở rộng $B_(1a), B_(1b), B_2$, (4) độ thích nghi chuẩn hóa $F(x)$, (5) tiến trình hội tụ theo thế hệ và (6) thời gian thực thi (giây).

#block(breakable: false)[
  #figure(
    table(
      columns: (1.8fr, 1.1fr, 1.8fr, 1.1fr),
      align: (left, center, left, center),
      inset: 4.5pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Siêu tham số*]), text(fill: white, [*Giá trị*]),
        text(fill: white, [*Siêu tham số*]), text(fill: white, [*Giá trị*]),
      ),
      [`POPULATION_SIZE` ($N_"pop"$)], [80], [`TOURNAMENT_SIZE` ($k$)], [5],
      [`MAX_GENERATIONS` ($G_"max"$)], [200], [`ELITE_SIZE` ($E$)], [5 (6,25%)],
      [`CROSSOVER_RATE` ($p_c$)], [0,85], [`REPAIR_RATE` ($p_"repair"$)], [0,40 (Proposed)],
      [`MUTATION_RATE` ($p_m$)], [0,015 (đến 0,060)], [`DATA_SEED` / `GA_SEED`], [42 / 2026],
    ),
    caption: [Bộ siêu tham số mặc định dùng cho thực nghiệm đối chứng ba phiên bản GA.]
  ) <tab_exp_config>
]

*3. Kết quả kiểm thử tự động (`pytest`):*
Trước khi tiến hành các đợt thực nghiệm chính, bộ 8 ca kiểm thử đơn vị và kiểm thử tích hợp trên bốn module cốt lõi (@tab_pytest_modules) được chạy qua lệnh `python -m pytest -v` và đạt *8/8 PASSED (100%)* trong *1,37 giây*. Các kiểm thử đơn vị xác nhận tính chính xác của từng hàm ràng buộc trên các mẫu lịch cố tình vi phạm (phòng nhỏ, trùng giờ, quá tải 20 buổi, phòng bảo trì) và đảm bảo phép `copy()` không chia sẻ tham chiếu. Vì kiểm thử chỉ xác nhận tính đúng đắn trên các kịch bản thiết kế sẵn, hệ thống vẫn chạy kiểm tra lại toàn bộ 15 chỉ tiêu ràng buộc trên nghiệm cuối trước khi xuất báo cáo.

#block(breakable: false)[
  #figure(
    table(
      columns: (1.5fr, 3.2fr, 0.9fr),
      align: (left, left, center),
      inset: 4.5pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Tệp kiểm thử*]), text(fill: white, [*Phạm vi kiểm chứng*]), text(fill: white, [*Kết quả*]),
      ),
      [`test_constraints.py`], [Độ chính xác các hàm đánh giá ràng buộc cứng (`H1–H7`), mềm (`S1–S5`) và Bonus], [PASS],
      [`test_fitness.py`], [Công thức tổng mức phạt $P(x)$, Fitness $F(x)$ và xếp hạng từ điển `rank_key()`], [PASS],
      [`test_genetic.py`], [Cấu trúc nhiễm sắc thể 480 gen, sao chép sâu `copy()` và các toán tử GA], [PASS],
      [`test_scheduler.py`], [Luồng tích hợp đầu-cuối từ nạp dữ liệu, tiến hóa đến xuất kết quả (`8/8` trong `1,37s`)], [PASS],
    ),
    caption: [Kết quả kiểm thử tự động bằng `pytest` trước khi chạy thực nghiệm đối chứng.]
  ) <tab_pytest_modules>
]

== Kết quả thời khóa biểu cuối cùng (Proposed GA)

Sau 200 thế hệ tiến hóa và 8 vòng quét tinh chỉnh cuối (*Final Polish*), *Proposed GA* xuất ra thời khóa biểu hoàn chỉnh cho toàn bộ 960 buổi học tại `outputs/best_schedule.csv` và giao diện tra cứu `outputs/final_schedule.html`, đạt *0 vi phạm ràng buộc cứng* trên cả bảy nhóm ($H_1$–$H_7 = 0$).

*1. Phân tích chất lượng lịch theo giảng viên:*
@fig_timetables minh họa lịch giảng dạy cả tuần của hai giảng viên tiêu biểu trong nghiệm tối ưu:
- Giảng viên `p23` đảm nhận 5 lớp (10 buổi/tuần): đạt *0 ca trống trong ngày* (`Gap = 0`), *0 ngày phải dạy cả sáng lẫn chiều* (`Mixed = 0`), 100% lớp thuộc danh sách Top-3 yêu thích (`c33, c47, c04`), mọi lớp có khoảng cách giữa hai buổi $>= 2$ ngày.
- Giảng viên `p02` đảm nhận khối lượng cao hơn với 8 lớp (16 buổi/tuần): vẫn duy trì `Gap = 0` trên toàn tuần, chỉ có 1 ngày dạy hai buổi (`Mixed = 1`), 7/8 lớp thuộc Top-3 (`c23, c11, c52`) và lớp còn lại nằm trong danh sách năng lực $E_p$.

Trên quy mô toàn trường gồm 60 giảng viên, không có bất kỳ giảng viên nào bị trùng lịch ($H_3 = 0$) hay vượt định mức 20 buổi/tuần ($H_4 = 0$). Về tiêu chí mở rộng, *60/60 (100%)* giảng viên đều được phân công ít nhất một lớp yêu thích ($B_(1a) = 0$), *0 lớp* bị gán ngoài danh sách đủ năng lực ($B_2 = 0$), và *443/480 (92,3%)* lớp thuộc đúng Top-3 môn yêu thích ($B_(1b) = 37$ lớp thuộc tập năng lực ngoài Top-3). Báo cáo trình bày tách bạch $B_2 = 0$ và $B_(1b) = 37$ đúng theo phạm vi giả định mở rộng $E_p supset.eq F_p$ đã nêu tại Chương 3.

#block(breakable: false)[
  #figure(
    image("../../outputs/figures/sample_timetables.png", width: 92%),
    caption: [Thời khóa biểu tuần của hai giảng viên tiêu biểu `p23` và `p02` trong nghiệm tốt nhất của Proposed GA.]
  ) <fig_timetables>
]

*2. Phân tích khai thác phòng học và trích xuất thời khóa biểu:*
Gọi $C_(d,t) = sum_(r in cal(R)) A_(d,t,r)$ là số phòng khả dụng và $O_(d,t) = sum_(r in cal(R)) II[M(d,t,r) > 0]$ là số phòng đang được sử dụng tại ngày $d$, ca $t$. Tỷ lệ khai thác phòng khả dụng $U_(d,t) = (O_(d,t) / C_(d,t)) times 100%$ được trực quan hóa tại @fig_heatmap.

#block(breakable: false)[
  #figure(
    image("../../outputs/figures/room_utilization_heatmap.png", width: 72%),
    caption: [Bản đồ nhiệt tỷ lệ sử dụng phòng học khả dụng theo ngày và ca học (Proposed GA).]
  ) <fig_heatmap>
]

Bản đồ nhiệt cho thấy tải phòng học phân bố rất cân bằng trên cả năm ngày từ Thứ Hai đến Thứ Sáu, hoàn toàn không còn hiện tượng dồn tải cực đoan ở hai ngày đầu và cuối tuần — minh chứng thực nghiệm rõ nét cho hiệu quả của vector cân bằng cặp ngày $q$. Tỷ lệ khai thác từng ca dao động từ `68%` (Thứ Năm – Ca 6) đến `100%` ở nhiều ca cao điểm (chẳng hạn Ca 2–Ca 4 của Thứ Hai, Thứ Ba, Thứ Tư). Việc có nhiều khung giờ đạt mức lấp đầy tuyệt đối `100%` cũng giải thích trực quan vì sao tìm kiếm cục bộ chỉ dựa vào di chuyển đơn lẻ sang ô trống nhanh chóng bão hòa và cần tới cơ chế *Same-Day Pairwise Swap*.

@tab_excerpt trích xuất 10 buổi học đầu tiên (Thứ Hai – Ca 1) từ tệp `outputs/best_schedule.csv`. Trên toàn bộ 960 buổi học, 100% buổi đều thỏa $"size"_"rm" >= "size"_"sec"$ ($H_1 = 0$), trong đó *894/960 buổi* khớp chính xác kích thước phòng với quy mô lớp ($R_"size" approx 93,13%$). Một số lớp cỡ trung bình (như lớp `c19-s03` tại phòng `rm07`) được xếp vào phòng cỡ lớn hơn 1 bậc là hệ quả tất yếu của cận dưới $S_5 >= 29$ do thiếu 29 ô phòng Size 1 đã chứng minh ở Chương 3.

#block(breakable: false)[
  #figure(
    table(
      columns: (auto, auto, auto, auto, auto, auto, auto, auto),
      align: center + horizon,
      inset: 4pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Ngày*]), text(fill: white, [*Ca*]), text(fill: white, [*Phòng*]), text(fill: white, [*Lớp*]),
        text(fill: white, [*Cỡ lớp*]), text(fill: white, [*GV*]), text(fill: white, [*Yêu thích*]), text(fill: white, [*Độ khớp*]),
      ),
      [Thứ 2], [Ca 1], [`rm01` (Sz 1)], [`c05-s05`], [Sz 1], [`p21`], [Hợp lệ], [Khớp chuẩn],
      [Thứ 2], [Ca 1], [`rm02` (Sz 1)], [`c29-s02`], [Sz 1], [`p31`], [Hợp lệ], [Khớp chuẩn],
      [Thứ 2], [Ca 1], [`rm03` (Sz 1)], [`c23-s01`], [Sz 1], [`p08`], [Top-3], [Khớp chuẩn],
      [Thứ 2], [Ca 1], [`rm04` (Sz 0)], [`c18-s04`], [Sz 0], [`p39`], [Top-3], [Khớp chuẩn],
      [Thứ 2], [Ca 1], [`rm05` (Sz 2)], [`c08-s01`], [Sz 2], [`p49`], [Top-3], [Khớp chuẩn],
      [Thứ 2], [Ca 1], [`rm06` (Sz 2)], [`c03-s06`], [Sz 2], [`p33`], [Hợp lệ], [Khớp chuẩn],
      [Thứ 2], [Ca 1], [`rm07` (Sz 2)], [`c19-s03`], [Sz 1], [`p27`], [Top-3], [Dư +1],
      [Thứ 2], [Ca 1], [`rm08` (Sz 2)], [`c03-s03`], [Sz 2], [`p28`], [Top-3], [Khớp chuẩn],
      [Thứ 2], [Ca 1], [`rm09` (Sz 2)], [`c28-s06`], [Sz 2], [`p18`], [Top-3], [Khớp chuẩn],
      [Thứ 2], [Ca 1], [`rm10` (Sz 2)], [`c11-s08`], [Sz 2], [`p02`], [Top-3], [Khớp chuẩn],
    ),
    caption: [Trích xuất 10 buổi học đầu tiên (Thứ Hai – Ca 1) từ thời khóa biểu tối ưu 960 buổi.]
  ) <tab_excerpt>
]

== Biểu đồ hội tụ Fitness (Fitness Plot)

@fig_fitness thể hiện diễn biến giá trị Fitness $F(x)$ (bên trái) và tổng điểm phạt $P(x)$ theo thang logarithm (bên phải) của ba phiên bản thuật toán qua 200 thế hệ. Việc hiển thị kèm đồ thị thang logarithm là cần thiết vì tổng phạt của nghiệm không khả thi (hàng chục triệu điểm ở *Baseline GA*, hàng trăm nghìn điểm ở *Improved GA*) chênh lệch nhiều bậc độ lớn so với nghiệm khả thi (hàng nghìn điểm ở *Proposed GA*), nên nếu chỉ quan sát thang tuyến tính sẽ khó thấy rõ quá trình giảm lỗi của hai phiên bản nền.

#block(breakable: false)[
  #figure(
    image("../../outputs/fitness_plot.png", width: 92%),
    caption: [Biểu đồ hội tụ Fitness (trái) và tổng điểm phạt theo thang logarithm (phải) giữa ba phiên bản GA.]
  ) <fig_fitness>
]

Để quan sát sâu hơn cơ chế tối ưu của *Proposed GA*, @fig_conv tách riêng ba đường cong: tiến hóa Fitness (Best và Average), xu hướng giảm tổng phạt mềm $S(x)$ và quỹ đạo điều chỉnh tỷ lệ đột biến thích nghi $p_m$ cùng phạt Bonus $B(x)$.

#block(breakable: false)[
  #figure(
    image("../../outputs/figures/penalty_breakdown.png", width: 92%),
    caption: [Diễn biến hội tụ chi tiết của Proposed GA: đạt Hard = 0 từ thế hệ 0, giảm 34,8% phạt mềm và đột biến thích nghi.]
  ) <fig_conv>
]

Phân tích tiến trình hội tụ của *Proposed GA* cho thấy ba giai đoạn rõ rệt:
- *Giai đoạn 1 – Khởi tạo và đạt khả thi tức thời (Thế hệ 0):* Nhờ kết hợp khởi tạo tham lam cân bằng cặp ngày và sửa chữa ban đầu, *Proposed GA* đạt ngay trạng thái khả thi tuyệt đối ($H = 0$) từ thế hệ 0 với điểm phạt mềm khởi điểm `2322` ($F(x) = 0,000420$).
- *Giai đoạn 2 – Tối ưu nhanh (Thế hệ 0 $arrow.r$ 50):* Tổng điểm phạt mềm giảm mạnh từ `2322` xuống `1736` (tương đương giảm `25,2%` chỉ trong 50 thế hệ đầu) nhờ sự cộng hưởng giữa lai ghép theo khối môn và Pha 3–4 của Repair nhanh chóng gom gọn các ca trống $S_1$ và tách giảm ngày dạy hai buổi $S_3$.
- *Giai đoạn 3 – Khai thác tinh và thoát cực trị cục bộ (Thế hệ 50 $arrow.r$ 200):* Đường cong cải thiện tiếp tục đi xuống ổn định qua các mốc `1666` (thế hệ 100), `1577` (thế hệ 150) và đạt `1515` sau thế hệ 200 kèm tinh chỉnh cuối (tổng mức giảm phạt mềm $R_"improve" = (2322 - 1515)/2322 approx 34,75%$, Fitness tăng lên `0,000636`). Ở các đoạn nghiệm tốt nhất chững 10 thế hệ liên tiếp (như quanh thế hệ 130–180), cơ chế đột biến thích nghi tự động nâng $p_m$ lên cao hơn mức nền `0,015` để tạo đột phá mới, rồi lập tức hạ trở lại `0,015` ngay khi ghi nhận kỷ lục mới.

== Khảo sát độ nhạy các siêu tham số

Nhằm đánh giá ảnh hưởng của các siêu tham số chính lên hiệu quả hội tụ và thời gian chạy của *Proposed GA*, nhóm tiến hành bốn nhóm khảo sát độ nhạy: thay đổi `Population Size`, `Crossover Rate` và `Mutation Rate` trong khung 60 thế hệ (để cân bằng chi phí chạy nhiều cấu hình), và theo dõi ảnh hưởng của `Max Generations` trên cấu hình chính 200 thế hệ. Toàn bộ kết quả được trực quan hóa tại @fig_sens và tổng hợp định lượng tại @tab_sensitivity_all.

#block(breakable: false)[
  #figure(
    image("../../outputs/figures/parameter_sensitivity.png", width: 66%),
    caption: [Phân tích độ nhạy bốn siêu tham số lên chất lượng nghiệm (Soft Penalty) của Proposed GA.]
  ) <fig_sens>
]

#block(breakable: false)[
  #figure(
    table(
      columns: (1.55fr, 1.3fr, 0.7fr, 1.4fr, 1.55fr, 1.3fr),
      align: (left, center, center, center, center, center),
      inset: 3.5pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Tham số khảo sát*]), text(fill: white, [*Giá trị*]), text(fill: white, [*Hard*]),
        text(fill: white, [*Soft Penalty*]), text(fill: white, [*Fitness $F(x)$*]), text(fill: white, [*Thời gian (s)*]),
      ),
      [Population Size (60 gen)], [20 / 40 / *80*], [0 / 0 / 0], [1596 / 1659 / *1521*], [0,000612 / 0,000582 / *0,000634*], [6,39 / 14,80 / 29,44],
      [Crossover Rate (Pop=40)], [*0,65* / 0,85 / 0,95], [0 / 0 / 0], [*1556* / 1659 / 1668], [*0,000620* / 0,000582 / 0,000580], [12,84 / 12,98 / 13,01],
      [Mutation Rate (Pop=40)], [*0,005* / 0,015 / 0,040], [0 / 0 / 0], [*1473* / 1659 / 1643], [*0,000654* / 0,000582 / 0,000588], [12,54 / 12,93 / 13,77],
      [Max Generations (Pop=80)], [0 / 50 / 100 / 150 / *200*], [0 (mọi mốc)], [2322 / 1736 / 1666 / 1577 / *1515*], [0,000420 $arrow.r$ *0,000636*], [0 $arrow.r$ 136,9],
    ),
    caption: [Tổng hợp khảo sát độ nhạy tham số của Proposed GA (đều đạt Hard = 0).]
  ) <tab_sensitivity_all>
]

Phân tích chi tiết từng siêu tham số cho thấy các quy luật quan trọng sau:
- *Tính bền vững về khả thi:* Toàn bộ các cấu hình khảo sát — ngay cả với quần thể rất nhỏ `Pop = 20` — đều đạt `Hard = 0`, chứng tỏ sự kết hợp giữa khởi tạo cân bằng cặp ngày và cơ chế Repair bốn pha tạo độ ổn định khả thi rất cao.
- *Ảnh hưởng của `Population Size`:* Khi tăng từ `20` lên `80` trong 60 thế hệ, tổng phạt mềm giảm `4,70%` (`1596` $arrow.r$ `1521`), trong khi thời gian chạy tăng gần tuyến tính (`6,39s` $arrow.r$ `29,44s`), khớp với phân tích độ phức tạp ở Chương 4. Mốc `Pop = 40` ghi nhận `1659` cao hơn `Pop = 20` là do dao động ngẫu nhiên khi chạy trên một seed đơn lẻ.
- *Ảnh hưởng của `Crossover Rate` ($p_c$):* Mức lai ghép vừa phải `0,65` đạt kết quả tốt nhất trong nhóm khảo sát (`1556`, so với `1659` ở `0,85` và `1668` ở `0,95`), trong khi thời gian chạy gần như không đổi (`12,84s`–`13,01s`). Điều này cho thấy ở mật độ phòng cao `93,75%`, lai ghép quá dày đặc làm tăng nhẹ mức xáo trộn cấu trúc phòng đã được tinh chỉnh.
- *Ảnh hưởng của `Mutation Rate` ($p_m$):* Tỷ lệ đột biến nhẹ `0,005` đạt mức phạt mềm thấp nhất `1473` (Fitness `0,000654`), tốt hơn cả mức `1659` (`0,015`) và `1643` (`0,040`), bởi đột biến quá mạnh dễ phá vỡ các cụm lịch gọn mà Repair đã xây dựng. Tuy nhiên, cần diễn giải thận trọng: giá trị `0,005` nằm ngoài khoảng mặc định của chế độ đột biến thích nghi (`0,015–0,060`), và các nhóm khảo sát dùng điều kiện khác nhau (`Pop = 40, 60 gen` so với `Pop = 80, 200 gen`) trên một seed đơn lẻ. Do đó không nên suy diễn gộp cơ học các mốc tốt nhất riêng lẻ thành cấu hình tối ưu toàn cục mà cần khảo sát tổ hợp đa seed.
- *Ảnh hưởng của `Max Generations`:* Chất lượng nghiệm cải thiện đơn điệu theo số thế hệ (`2322` $arrow.r$ `1736` $arrow.r$ `1666` $arrow.r$ `1577` $arrow.r$ `1515`), với biên lợi ích lớn nhất tập trung trong 100 thế hệ đầu và giảm dần ở giai đoạn 150–200 thế hệ, khẳng định mốc `200` thế hệ là điểm dừng hợp lý giữa chất lượng lịch và thời gian tính toán.

== So sánh ba phiên bản thuật toán và thảo luận

@tab_compare và @fig_bars tổng hợp kết quả đối chứng trực tiếp giữa *Baseline GA*, *Improved GA* và *Proposed GA* trên cùng bộ dữ liệu (`seed = 42`), cùng `ga-seed = 2026`, kích thước quần thể `80` và `200` thế hệ.

#block(breakable: false)[
  #figure(
    table(
      columns: (1.35fr, 1.4fr, 1.35fr, 0.55fr, 0.75fr, 1.25fr, 0.75fr),
      align: center + horizon,
      inset: 4.5pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if y == 3 { rgb("#dcfce7") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Thuật toán*]), text(fill: white, [*Fitness*]), text(fill: white, [*Total Penalty*]),
        text(fill: white, [*Hard*]), text(fill: white, [*Soft*]), text(fill: white, [*Bonus*]), text(fill: white, [*Time (s)*]),
      ),
      [Baseline GA], [$2.41 times 10^(-8)$], [41.485.175,5], [393], [4493], [2.180.682,5], [56,0],
      [Improved GA], [$3.31 times 10^(-6)$], [302.501,0], [3], [2459], [42,0], [109,6],
      [*Proposed GA*], [*$6.36 times 10^(-4)$*], [*1570,5*], [*0*], [*1515*], [55,5], [136,9],
    ),
    caption: [So sánh hiệu năng tổng hợp giữa ba phiên bản giải thuật di truyền (200 thế hệ, Pop = 80).]
  ) <tab_compare>
]

#block(breakable: false)[
  #figure(
    image("../../outputs/figures/constraint_satisfaction.png", width: 82%),
    caption: [So sánh số lượng vi phạm cuối cùng ở các nhóm ràng buộc chính giữa ba phiên bản GA.]
  ) <fig_bars>
]

Để nhìn rõ nguồn gốc của từng khác biệt, @tab_detail_constraints trích xuất đầy đủ đối chứng 15 thành phần ràng buộc (`H1–H7`, `S1–S5`, `B2`, `B1a`, `B1b`) từ `outputs/conflict_report.json`.

#block(breakable: false)[
  #figure(
    table(
      columns: (2.65fr, 1.0fr, 1.05fr, 1.3fr),
      align: (left, center, center, center),
      inset: 4pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Chỉ tiêu ràng buộc*]), text(fill: white, [*Baseline GA*]),
        text(fill: white, [*Improved GA*]), text(fill: white, [*Proposed GA*]),
      ),
      [$H_1$: Phòng nhỏ hơn quy mô lớp], [157], [0], [*0*],
      [$H_2, H_4, H_6$: Cách ngày / Tải GV / Trùng lớp], [0 / 0 / 0], [0 / 0 / 0], [*0 / 0 / 0*],
      [$H_3$: Trùng lịch giảng viên cùng ca], [43], [3], [*0*],
      [$H_5, H_7$: Phòng bảo trì / Trùng phòng], [10 / 183], [0 / 0], [*0 / 0*],
      [$S_1$: Tổng số ca trống trong ngày (GV)], [342], [218], [*51*],
      [$S_2$: Tổng số ngày trống trong tuần (GV)], [1], [5], [*3*],
      [$S_3$: Số ngày GV dạy cả Sáng & Chiều], [229], [192], [*135*],
      [$S_4$: Số buổi lệch buổi Sáng/Chiều của môn], [384], [113], [167],
      [$S_5$: Tổng độ dư cỡ phòng (tỷ lệ khớp)], [483 (45,2%)], [55 (95,6%)], [75 (93,1%)],
      [$B_2$: Số lớp ngoài danh sách năng lực $E_p$], [420], [0], [*0*],
      [$B_(1a)$: Số GV có $>= 1$ môn Top-3 yêu thích], [20/60], [60/60], [*60/60 (100%)*],
      [$B_(1b)$: Tổng số lớp thuộc Top-3 yêu thích], [25/480], [452/480], [*443/480 (92,3%)*],
    ),
    caption: [Đối chứng chi tiết các thành phần ràng buộc giữa ba phiên bản GA (`conflict_report.json`).]
  ) <tab_detail_constraints>
]

Từ kết quả đối chứng tại @tab_compare và @tab_detail_constraints, có thể rút ra năm nhận xét khoa học quan trọng:

- *Baseline GA hoàn toàn thất bại ở mật độ tài nguyên cao:* Khởi tạo ngẫu nhiên đồng đều làm quá tải Thứ Hai và Thứ Sáu, còn lai ghép đồng đều 50/50 liên tục phá vỡ các cấu trúc phòng hợp lệ. Sau 200 thế hệ, thuật toán vẫn tồn đọng *393 vi phạm cứng* (183 trùng phòng, 157 sai cỡ phòng, 43 trùng giờ giảng viên, 10 phòng bảo trì) cùng *420 lớp* phân công ngoài danh sách chuyên môn $E_p$. Dù thời gian chạy thấp nhất (`56,0s`), nghiệm hoàn toàn không thể đưa vào sử dụng thực tế.
- *Improved GA giải quyết 99,24% xung đột cứng nhưng bế tắc ở những lỗi cuối cùng:* Việc thay thế bằng khởi tạo tham lam cân bằng cặp ngày và lai ghép bất đối xứng theo khối môn tạo bước nhảy vọt: số vi phạm cứng giảm từ `393` xuống chỉ còn `3` ($-99,24%$), xóa sạch vi phạm phòng ($H_1=H_5=H_7=0$) và ngoài chuyên môn ($B_2=0$), đồng thời giảm `45,27%` điểm phạt mềm (`4493` $arrow.r$ `2459`) và đạt độ khớp cỡ phòng rất cao (`95,6%`, 918/960 buổi). Tuy nhiên, khi không có cơ chế sửa chữa cục bộ, các toán tử di truyền ngẫu nhiên vẫn mắc kẹt ở 3 xung đột trùng giờ giảng viên cuối cùng ($H_3 = 3$) và để lại tới `218` ca trống trong ngày ($S_1$).
- *Proposed GA đạt khả thi tuyệt đối và tối ưu sâu lịch giảng viên:* Sự bổ sung của cơ chế sửa chữa bốn pha và hoán đổi cặp cùng ngày (*Same-Day Pairwise Swap*) triệt tiêu triệt để 3 xung đột cứng cuối cùng ($H = 0$), đồng thời giảm tiếp *38,4%* tổng điểm phạt mềm so với *Improved GA* (`2459` $arrow.r$ `1515`, giảm *66,3%* so với *Baseline GA*). Cụ thể, số ca trống trong ngày của giảng viên giảm mạnh *76,6%* ($S_1$: `218` $arrow.r$ `51`), số ngày giảng viên dạy cả hai buổi giảm *29,7%* ($S_3$: `192` $arrow.r$ `135`) và số ngày trống tuần giảm từ `5` xuống `3`.
- *Đánh đổi đa mục tiêu và chi phí thời gian:* Để triệt tiêu $H_3 = 3$ và ưu tiên tối ưu mạnh hai tiêu chí có trọng số cao nhất là $S_1, S_3$ ($w_1 = w_3 = 5$), *Proposed GA* chấp nhận nhượng bộ nhẹ so với *Improved GA* ở các tiêu chí có trọng số nhỏ hơn như độ khớp cỡ phòng (`95,6%` $arrow.r$ `93,1%`, $S_5$: `55` $arrow.r$ `75`, trọng số 1), độ tập trung buổi môn ($S_4$: `113` $arrow.r$ `167`, trọng số 3) và phạt Bonus (`42,0` $arrow.r$ `55,5`, tương ứng `443/480 = 92,3%` lớp Top-3). Đây là sự đánh đổi đa tiêu chí hợp lý của hàm mục tiêu tuyến tính có trọng số. Về tốc độ, thời gian chạy `136,9` giây tăng `24,9%` so với *Improved GA* (`109,6s`) và gấp `2,44` lần *Baseline GA* (`56,0s`) — mức chi phí hoàn toàn chấp nhận được cho bài toán lập thời khóa biểu ngoại tuyến theo tuần.

*Giới hạn của thực nghiệm hiện tại:* Các kết quả đối chứng trên được đo trên một bộ dữ liệu cố định (`seed = 42`) với một hạt giống tiến hóa (`ga-seed = 2026`), do đó phản ánh hiệu quả tổng hợp của các nhóm cải tiến (khởi tạo + lai ghép khối ở *Improved GA*; toàn bộ bốn pha Repair + Elitism ở *Proposed GA*). Để khẳng định ý nghĩa thống kê (giá trị trung bình, độ lệch chuẩn, tỷ lệ đạt khả thi) và lượng hóa chính xác đóng góp riêng lẻ của từng toán tử (chẳng hạn tách riêng tác động của *Same-Day Pairwise Swap* với *Adaptive Mutation*), cần thực hiện mở rộng thực nghiệm đa seed và *Ablation Study* ở giai đoạn phát triển tiếp theo.
