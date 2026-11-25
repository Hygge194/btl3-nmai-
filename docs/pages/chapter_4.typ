= THIẾT KẾ THUẬT TOÁN (ALGORITHM DESIGN)

== Tổng quan phương pháp đề xuất

Từ kết quả phân tích toán học ở Chương 3 — cụ thể là tỷ lệ lấp đầy phòng đạt `93,75%` (chỉ còn 64 vị trí trống trên toàn tuần) và nút thắt cặp ngày khiến khởi tạo đồng đều chắc chắn gây quá tải Thứ Hai và Thứ Sáu — có thể thấy một giải thuật di truyền tiêu chuẩn với khởi tạo ngẫu nhiên và lai ghép đồng đều rất khó thoát khỏi vùng nghiệm chứa hàng trăm xung đột cứng. Để giải quyết đồng thời yêu cầu *khả thi tuyệt đối* ($H(x) = 0$) và *tối ưu sâu ràng buộc mềm*, nhóm đề xuất phương pháp *Proposed GA* theo kiến trúc *Giải thuật Memetic (Memetic Algorithm)* kết hợp bảy thành phần chuyên biệt:

+ *Biểu diễn theo lớp học phần (Section-based Representation)* gồm 480 gen bảo toàn giảng viên chung và cặp ngày hợp lệ.
+ *Khởi tạo tham lam cân bằng tải (Greedy Randomized Initialization)* sử dụng vector xác suất cặp ngày $q$ nhằm triệt tiêu nút thắt Thứ Hai/Thứ Sáu ngay từ thế hệ 0.
+ *Xếp hạng ưu tiên khả thi (Feasibility-first Ranking)* theo thứ tự từ điển $R(x) = (H(x), P(x))$.
+ *Lai ghép bất đối xứng theo khối môn học (Asymmetric Course-Block Crossover)* bảo toàn phân bố buổi sáng/chiều của môn học.
+ *Đột biến thông minh thích nghi (Adaptive Smart Swap Mutation)* tự điều chỉnh $p_m$ theo mức độ chững của quần thể.
+ *Cơ chế sửa chữa nghiệm bốn pha (Four-phase Repair & Local Search)* kết hợp tìm kiếm cục bộ hoán đổi cặp cùng ngày (_Same-Day Pairwise Swap_) hoạt động hiệu quả ngay cả khi không còn ô phòng trống.
+ *Bảo toàn ưu tú (Elitism)* kèm tinh chỉnh sâu định kỳ (_Deep Polish_) và tinh chỉnh cuối (_Final Polish_).

@fig_proposed_overview trình bày sơ đồ tổng quan mối liên kết giữa các thành phần trong *Proposed GA*.

#block(breakable: false)[
  #figure(
    image("../picture/Sơ đồ tổng quan phương pháp đề xuất – Mục 4.1.svg", width: 72%),
    caption: [Sơ đồ tổng quan các thành phần của phương pháp đề xuất (Proposed GA).]
  ) <fig_proposed_overview>
]

Nhằm lượng hóa đóng góp của từng nhóm cải tiến trên cùng bộ dữ liệu (`seed = 42`), kích thước quần thể (`Pop = 80`), số thế hệ (`200`) và hàm đánh giá, nhóm thiết kế ba phiên bản đối chứng tại @tab_ga_versions.

#block(breakable: false)[
  #figure(
    table(
      columns: (1.15fr, 1.75fr, 1.85fr, 1.05fr),
      align: (left, left, left, center),
      inset: 4pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Phiên bản*]),
        text(fill: white, [*Phương pháp khởi tạo*]),
        text(fill: white, [*Toán tử lai ghép*]),
        text(fill: white, [*Repair & Polish*]),
      ),
      [Baseline GA], [Random Initialization (chọn đều 6 cặp ngày)], [Uniform Crossover (tráo 50/50 theo lớp)], [Không],
      [Improved GA], [Greedy Randomized Init (cân bằng tải ngày)], [Asymmetric Course-Block (khối 8 lớp)], [Không],
      [*Proposed GA*], [Greedy Randomized Init (cân bằng tải ngày)], [Asymmetric Course-Block (khối 8 lớp)], [*Có (4 pha + Swap)*],
    ),
    caption: [So sánh cấu hình kỹ thuật giữa ba phiên bản GA đối chứng.]
  ) <tab_ga_versions>
]

== Biểu diễn nghiệm và Khởi tạo quần thể

*Biểu diễn nghiệm (Section-based Representation):* Mỗi gen mã hóa trọn vẹn lịch trình của một lớp học phần $s in {0, ..., 479}$ gồm định danh lớp (`section_id`), giảng viên phụ trách (`professor_id`) và hai đối tượng buổi học (`session_1`, `session_2`):
$ g_s = (s, p_s, u_(s,1), u_(s,2)), quad u_(s,k) = (d_(s,k), t_(s,k), r_(s,k)) $
Một nhiễm sắc thể (`Chromosome`) là danh sách có thứ tự gồm đúng 480 gen $x = (g_0, g_1, ..., g_479)$, lưu kèm các kết quả đánh giá (`fitness`, `hard_violations`, `soft_penalty`, `bonus_penalty`, `total_penalty`, `breakdown`) nhằm tái sử dụng trong bước chọn lọc mà không cần tính lại. Một quần thể (`Population`) quản lý $N_"pop" = 80$ nhiễm sắc thể và sắp xếp trực tiếp bằng khóa từ điển `rank_key() = (hard_violations, total_penalty)` tương ứng $R(x) = (H(x), P(x))$.

*Khởi tạo ngẫu nhiên (Random Initialization – Baseline GA):* Với mỗi lớp học phần $s$, thuật toán chọn ngẫu nhiên đồng đều giảng viên $p_s in cal(P)$, chọn đều một cặp ngày $(d_(s,1), d_(s,2)) in Pi_"valid"$ (xác suất $1/6 approx 16,67%$), sau đó chọn ngẫu nhiên ca $t_(s,k) in cal(T)$ và phòng $r_(s,k) in cal(R)$ cho từng buổi. Phương pháp này đơn giản nhưng bỏ qua hoàn toàn cấu trúc bài toán: Thứ Hai và Thứ Sáu có tải kỳ vọng 240 buổi ($> 210$ vị trí tối đa), nhiều lớp nhận phòng nhỏ hơn quy mô hoặc phòng bảo trì, và giảng viên thường bị phân công ngoài danh sách chuyên môn $E_p$.

*Khởi tạo tham lam có ngẫu nhiên (Greedy Randomized Initialization – Improved & Proposed GA):* Để tạo ra quần thể ban đầu nằm rất gần miền khả thi nhưng vẫn giữ được tính đa dạng giữa 80 cá thể, thuật toán thực hiện bốn bước tuần tự cho mỗi cá thể:

+ *Bước 1 – Phân chia buổi ưu tiên theo môn học:* Xáo trộn ngẫu nhiên 60 môn học và chia thành hai tập cân bằng gồm $|cal(C)_M| = 30$ môn ưu tiên buổi sáng và $|cal(C)_A| = 30$ môn ưu tiên buổi chiều. Phân chia này tạo nhu cầu kỳ vọng đúng 480 buổi sáng và 480 buổi chiều (khớp với công suất 515 sáng / 509 chiều), giúp giảm mạnh phạt $S_4$ ngay từ đầu. Vì tập $cal(C)_M, cal(C)_A$ được xáo trộn độc lập cho từng cá thể, mỗi cá thể mang một cấu trúc buổi khác nhau.
+ *Bước 2 – Lấy mẫu cặp ngày theo phân bố cân bằng tải:* Với mỗi lớp học phần, chọn cặp ngày trong $Pi_"valid"$ theo vector xác suất đã chứng minh ở Chương 3:
  $ q = (0.20, 0.18, 0.02, 0.22, 0.18, 0.20) $
  (Thứ 2–4: 20%, 2–5: 18%, 2–6: 2%, 3–5: 22%, 3–6: 18%, 4–6: 20%). Cách lấy mẫu này đưa tải kỳ vọng của cả năm ngày về đúng $192$ buổi/ngày, nhỏ hơn công suất khả dụng thực tế (204–205 vị trí/ngày).
+ *Bước 3 – Phân công giảng viên cân bằng tải và ưu tiên Top-3:* Xáo trộn ngẫu nhiên thứ tự duyệt 480 lớp. Với mỗi lớp thuộc môn $c(s)$, ưu tiên chọn giảng viên trong tập yêu thích $cal(P)_"fav"(s)$ (dành 12% xác suất mở rộng sang tập năng lực $cal(P)_"eligible"(s)$ nhằm tránh bế tắc tải và tăng đa dạng) thỏa điều kiện số lớp hiện tại $n_p < 10$ (đảm bảo $H_4 = 0$). Xác suất chọn mỗi ứng viên tỷ lệ nghịch với tải hiện tại ($1 / (1 + n_p)$), giúp san đều khối lượng giữa 60 giảng viên và giảm đồng thời $B_2, B_(1a), B_(1b)$.
+ *Bước 4 – Xếp phòng và ca học tham lam theo kích thước giảm dần:* Áp dụng tư tưởng *Most Constrained Variable First*, các lớp học phần được sắp xếp theo quy mô giảm dần: *Lớp cỡ Lớn (Size 2) $arrow.r$ Trung bình (Size 1) $arrow.r$ Nhỏ (Size 0)* (xáo trộn ngẫu nhiên trong cùng kích thước). Lý do là lớp Size 2 chỉ có thể xếp vào phòng Size 2, trong khi lớp Size 0 có thể xếp vào mọi phòng. Với từng buổi học, thuật toán tìm vị trí $(t, r)$ trong ngày đã chọn thỏa mãn: phòng khả dụng ($A_(d,t,r)=1$), chưa bị chiếm ($M(d,t,r)=0$), giảng viên rảnh ($N_p(d,t)=0$) và $"size"_"rm"(r) >= "size"_"sec"(s)$. Trong số các vị trí hợp lệ, thuật toán ưu tiên vị trí đúng buổi sáng/chiều của môn và khớp chính xác kích thước phòng trước khi nới sang phòng lớn hơn hoặc buổi còn lại; việc chọn ngẫu nhiên giữa các ứng viên đồng hạng đảm bảo 80 cá thể khởi tạo khác biệt nhau.

== Thiết kế hàm thích nghi và hệ thống trọng số

Hàm phạt tổng hợp $P(x)$ kết hợp tuyến tính ba thành phần cứng, mềm và mở rộng:
$ P_"hard"(x) = W_H H(x), quad P_"soft"(x) = 5 S_1(x) + 3 S_2(x) + 5 S_3(x) + 3 S_4(x) + S_5(x) $
$ P_"bonus"(x) = 5000 B_2(x) + 2000 B_(1a)(x) + 1.5 B_(1b)(x), quad P(x) = P_"hard"(x) + P_"soft"(x) + P_"bonus"(x) $
Hàm thích nghi chuẩn hóa được tính bằng $F(x) = frac(1, 1 + P(x)) in (0, 1]$, với bảng phân tầng trọng số tại @tab_weights.

#block(breakable: false)[
  #figure(
    table(
      columns: (0.75fr, 2.35fr, 0.85fr, 2.15fr),
      align: (center, left, right, left),
      inset: 4.5pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Ký hiệu*]),
        text(fill: white, [*Tiêu chí đánh giá*]),
        text(fill: white, [*Trọng số*]),
        text(fill: white, [*Tầng ưu tiên nghiệp vụ*]),
      ),
      [$H$], [Vi phạm ràng buộc cứng ($H_1$–$H_7$)], [100.000], [Tầng 1 – Bắt buộc tuyệt đối (kết hợp `rank_key`)],
      [$B_2$], [Lớp gán ngoài danh sách năng lực $E_p$], [5.000], [Tầng 2 – Ràng buộc chuyên môn giảng dạy],
      [$B_(1a)$], [Giảng viên chưa có lớp Top-3 yêu thích], [2.000], [Tầng 2 – Phủ nguyện vọng 100% giảng viên],
      [$S_1$], [Ca trống giữa các tiết trong ngày (GV)], [5], [Tầng 3 – Tránh thời gian chờ trực tiếp của GV],
      [$S_3$], [Ngày giảng viên dạy cả sáng lẫn chiều], [5], [Tầng 3 – Tập trung lịch dạy theo buổi của GV],
      [$S_2$], [Ngày trống xen giữa trong tuần (GV)], [3], [Tầng 4 – Giảm phân tán lịch dạy theo tuần],
      [$S_4$], [Buổi học lệch sáng/chiều của môn học], [3], [Tầng 4 – Đồng nhất buổi học theo từng môn],
      [$B_(1b)$], [Lớp thuộc $E_p$ nhưng ngoài Top-3 $F_p$], [1,5], [Tầng 5 – Khuyến khích tăng tỷ lệ Top-3],
      [$S_5$], [Độ dư kích thước phòng so với cỡ lớp], [1], [Tầng 5 – Tối ưu sức chứa phòng học],
    ),
    caption: [Hệ thống trọng số phạt phân tầng sử dụng trong hàm thích nghi.]
  ) <tab_weights>
]

Các trọng số trong @tab_weights được chọn theo cấu trúc phân tầng rõ rệt: vi phạm cứng có bậc lớn nhất ($100.000$) và được củng cố bằng khóa xếp hạng từ điển `rank_key() = (H(x), P(x))` nhằm đảm bảo tuyệt đối mọi nghiệm khả thi luôn thắng nghiệm không khả thi; tiếp đến là nhóm chuyên môn và phủ Top-3 ($5.000$ và $2.000$); trong nhóm ràng buộc mềm, độ gọn lịch trong ngày của giảng viên ($S_1, S_3$, trọng số $5$) được ưu tiên hơn phân tán tuần và buổi môn ($S_2, S_4$, trọng số $3$), còn độ dư cỡ phòng ($S_5$, trọng số $1$) có mức ưu tiên linh hoạt nhất vì một phần độ dư là bất khả kháng theo dữ liệu.

Thay hai cận dưới đã chứng minh ở Chương 3 ($S_3(x) >= 20$ và $S_5(x) >= 29$) vào hàm $P_"soft"(x)$, ta thu được cận dưới điểm phạt mềm đối với mọi nghiệm khả thi trên bộ dữ liệu thực nghiệm là:
$ P_"soft"(x) >= 5 times 20 + 1 times 29 = 129 $
Từ đó suy ra cận trên lý thuyết của hàm thích nghi trên bộ dữ liệu `seed = 42` là:
$ F(x) = frac(1, 1 + P(x)) <= frac(1, 1 + 129) = frac(1, 130) approx 0.007692 $

== Các toán tử di truyền

*1. Toán tử chọn lọc (Tournament Selection, $k = 5$):*
Mỗi lần cần chọn một cá thể cha mẹ, thuật toán rút ngẫu nhiên $k = 5$ cá thể từ quần thể hiện tại (tập $cal(T)_"tour"$) và chọn cá thể tốt nhất theo khóa xếp hạng ưu tiên khả thi:
$ x^* in arg min_(x in cal(T)_"tour") R(x) = arg min_(x in cal(T)_"tour") (H(x), P(x)) $
Kích thước $k = 5$ trên quần thể $N_"pop" = 80$ tạo áp lực chọn lọc vừa đủ mạnh để đẩy nhanh hội tụ trong 200 thế hệ, đồng thời tránh tình trạng một vài cá thể có Fitness vượt trội chiếm lĩnh hoàn toàn quần thể như ở *Roulette Wheel Selection*.

*2. Toán tử lai ghép (Crossover, $p_c = 0.85$):*
- *Uniform Crossover (Baseline GA):* Với mỗi lớp $s in {0, ..., 479}$, cá thể con lấy gen $g_s$ từ cha $A$ hoặc mẹ $B$ với xác suất $0.5$. Ở mật độ phòng `93,75%`, việc trộn lẫn 50/50 các khung phòng từ hai thời khóa biểu khác nhau khiến xác suất hai buổi học đè lên cùng một phòng rất cao, đồng thời xé lẻ 8 lớp của cùng một môn học làm tăng phạt $S_4$.
- *Asymmetric Course-Block Crossover (Improved & Proposed GA):* Thay vì trộn từng lớp đơn lẻ với tỷ lệ 50/50, thuật toán chọn ngẫu nhiên một tỷ lệ nhỏ $alpha in [0.08, 0.22]$ số môn học — tương ứng $N_"block" = round(alpha times 60) in [5, 13]$ môn (từ 40 đến 104 lớp trong tổng số 480 lớp), gọi là tập $cal(C)_"swap"$. Cá thể con $C$ kế thừa bộ khung nền từ cha mẹ nhận $A$ và sao chép nguyên khối toàn bộ 8 gen của mỗi môn thuộc $cal(C)_"swap"$ từ cha mẹ cho $B$:
  $ g_s^C = cases(g_s^B & "nếu" c(s) in cal(C)_"swap", g_s^A & "ngược lại") $
  (cá thể con thứ hai hoán đổi vai trò $A$ và $B$). Thiết kế *bất đối xứng theo khối môn* mang lại hai lợi ích trực tiếp: (i) bảo toàn nguyên vẹn cấu trúc buổi sáng/chiều của 8 lớp cùng môn ($S_4$) và (ii) giữ nguyên 78%–92% cấu trúc lấp đầy phòng học từ cá thể nền, giúp số xung đột phát sinh sau lai ghép rất nhỏ và dễ được Repair triệt tiêu.

*3. Toán tử đột biến thích nghi (Adaptive Smart Swap Mutation):*
Tỷ lệ đột biến $p_m$ khởi tạo ở mức $p_m^0 = 0.015$ và biến thiên trong đoạn $[0.015, 0.060]$ dựa trên bộ đếm thế hệ chững (`stagnation`). Nếu cá thể tốt nhất toàn cục không cải thiện sau mỗi 10 thế hệ liên tiếp, thuật toán tăng $p_m' = min(0.060, 1.15 p_m)$ để mở rộng khám phá thoát khỏi cực trị cục bộ; ngược lại, ngay khi tìm được nghiệm kỷ lục mới, bộ đếm được đặt về 0 và giảm $p_m' = max(0.015, 0.85 p_m)$ để tập trung khai thác tinh. Khi một gen được chọn đột biến, thuật toán thực hiện ngẫu nhiên một trong ba chế độ thông minh:
+ *Timeslot & Room Mutation:* Dời một buổi học sang cặp $(t, r)$ khả dụng thỏa $"size"_"rm"(r) >= "size"_"sec"(s)$, hoặc đổi sang cặp ngày hợp lệ mới trong $Pi_"valid"$ lấy mẫu theo vector cân bằng $q$.
+ *Professor Mutation:* Đổi giảng viên phụ trách cho cả hai buổi của lớp học phần bằng cách chọn từ tập Top-3 yêu thích (xác suất 70%) hoặc tập đủ năng lực $E_p$ (xác suất 30%), giúp duy trì $B_2 = 0$ ngay trong quá trình đột biến.
+ *Swap Mutation:* Chọn hai lớp học phần $s_a, s_b$ có cùng quy mô đăng ký ($"size"_"sec"(s_a) = "size"_"sec"(s_b)$) và hoán đổi toàn bộ cặp buổi học $(u_(a,1), u_(a,2)) arrow.l.r (u_(b,1), u_(b,2))$ trong khi giữ nguyên giảng viên phụ trách của từng lớp. Phép biến đổi này bảo toàn tập các vị trí phòng đang được sử dụng (không tạo thêm trùng phòng $H_7$) nhằm gia tăng đa dạng ngẫu nhiên, khác với phép *Same-Day Pairwise Swap* có định hướng tối ưu chi phí cục bộ trong bộ sửa chữa.

== Cơ chế sửa chữa nghiệm (Repair), Bảo toàn ưu tú và Điều kiện dừng

*Cơ chế sửa chữa bốn pha và tìm kiếm cục bộ (Four-phase Repair & Local Search):*
Trong *Proposed GA*, cơ chế sửa chữa được áp dụng lên cá thể con sau bước đột biến với xác suất $p_"repair" = 0.40$ (thay vì 100%) nhằm cân bằng giữa tốc độ cải thiện chất lượng nghiệm, duy trì đa dạng quần thể và kiểm soát thời gian chạy. Quy trình gồm bốn pha tuần tự, trong đó Pha 1–2 hướng tới tính khả thi và chuyên môn, còn Pha 3–4 tối ưu sâu ràng buộc mềm (@tab_repair_phases):

+ *Pha 1 – Hiệu chỉnh phân công giảng viên ($B_2, H_4, B_(1a)$):* Quét toàn bộ 480 lớp để phát hiện các lớp bị gán cho giảng viên ngoài tập năng lực $E_p$ ($B_2$) hoặc giảng viên đang vượt định mức 10 lớp ($H_4$), sau đó điều chuyển sang giảng viên hợp lệ đang có số lớp ít nhất. Tiếp theo, với mỗi giảng viên chưa có lớp nào thuộc Top-3 yêu thích ($B_(1a)$), thuật toán tìm một lớp thuộc Top-3 của giảng viên đó từ giảng viên khác đang có từ 2 lớp yêu thích trở lên để điều chuyển, đảm bảo đạt $B_(1a) = 0$ mà không làm giảng viên cũ mất lớp yêu thích duy nhất.
+ *Pha 2 – Triệt tiêu xung đột cứng ($H_1, H_3, H_5, H_7$):* Duyệt các buổi học gặp một trong bốn lỗi: phòng nhỏ hơn cỡ lớp ($H_1$), trùng giờ giảng viên ($H_3$), phòng bảo trì ($H_5$) hoặc trùng phòng ($H_7$). Với mỗi buổi lỗi, thuật toán ưu tiên tìm một vị trí $(t, r)$ trống, khả dụng, tương thích kích thước và không trùng giờ giảng viên *trong chính ngày hiện tại* nhằm bảo toàn cân bằng tải ngày. Chỉ khi ngày hiện tại không còn vị trí khả thi nào, thuật toán mới dời cả hai buổi của lớp sang một cặp ngày mới trong $Pi_"valid"$ có đủ hai vị trí hợp lệ.
+ *Pha 3 – Tinh chỉnh mềm bằng di chuyển đơn lẻ (Single-Session Move):* Khi nghiệm đã khả thi, thuật toán khảo sát việc dịch chuyển từng buổi học sang các vị trí $(t, r)$ trống khác trong cùng ngày và chấp nhận bước đi nếu duy trì $H(x') = 0$ đồng thời giảm chi phí mềm cục bộ ($Delta C = C_"local"(x') - C_"local"(x) < 0$ tính trên $S_1, S_3, S_4, S_5$).
+ *Pha 4 – Hoán đổi cặp buổi học cùng ngày (Same-Day Pairwise Swap):* Ở mật độ lấp đầy `93,75%`, nhiều ca học đã kín 100% phòng học nên Pha 3 rất nhanh rơi vào trạng thái không còn ô trống để dịch chuyển đơn lẻ. Pha 4 khắc phục triệt để hạn chế này bằng cách chọn hai buổi học $a, b$ thuộc hai lớp khác nhau nhưng diễn ra trong *cùng một ngày* ($d_a = d_b$) và hoán đổi đồng thời cặp (ca, phòng) của chúng:
  $ (t_a, r_a) arrow.l.r (t_b, r_b) quad arrow.r.double quad u_(a') = (d_a, t_b, r_b), quad u_(b') = (d_b, t_a, r_a) $
  Phép hoán đổi này *không đòi hỏi ô phòng trống*, không làm thay đổi tải của bất kỳ ngày nào và bảo toàn tuyệt đối khoảng cách ngày $H_2$. Một phép hoán đổi được chấp nhận ngay khi cả hai buổi mới đều khớp kích thước phòng ($"size"_"rm"(r_b) >= "size"_"sec"(s_a)$ và $"size"_"rm"(r_a) >= "size"_"sec"(s_b)$), không gây trùng lịch giảng viên tại khung giờ mới ($H(x') = 0$) và làm giảm tổng chi phí mềm cục bộ ($Delta C_"swap" < 0$).

  *Ví dụ minh họa hiệu quả của Same-Day Pairwise Swap:* Giả sử vào Thứ Ba khi toàn bộ 35 phòng ở Ca 2 đều đã kín, giảng viên `p10` đang dạy Ca 1 và Ca 3 (phát sinh 1 ca trống $S_1$, phạt 5 điểm), còn giảng viên `p22` dạy Ca 2 và Ca 4 (cũng có 1 ca trống $S_1$). Nếu hai lớp tại Ca 3 của `p10` và Ca 2 của `p22` tương thích kích thước phòng và giảng viên không trùng giờ ở ca mới, việc hoán đổi đồng thời hai buổi này đưa lịch `p10` thành Ca 1–Ca 2 (0 ca trống) và giữ gọn lịch `p22` tại Ca 3–Ca 4 (0 ca trống), giảm ngay 10 điểm phạt mềm mà không cần bất kỳ phòng trống nào.

#block(breakable: false)[
  #figure(
    table(
      columns: (0.55fr, 1.85fr, 1.35fr, 2.25fr),
      align: (center, left, center, left),
      inset: 4.5pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Pha*]), text(fill: white, [*Nhiệm vụ chính*]),
        text(fill: white, [*Mục tiêu*]), text(fill: white, [*Cơ chế xử lý cốt lõi*]),
      ),
      [1], [Sửa phân công giảng viên], [$B_2, H_4, B_(1a)$], [Chuyển lớp sang GV hợp lệ ít tải nhất và phủ Top-3 cho mọi GV],
      [2], [Triệt tiêu xung đột cứng], [$H_1, H_3, H_5, H_7$], [Dời sang ô $(t,r)$ trống cùng ngày; dự phòng đổi cặp ngày trong $Pi_"valid"$],
      [3], [Tinh chỉnh mềm đơn lẻ], [$S_1, S_3, S_4, S_5$], [Chuyển từng buổi sang ô trống cùng ngày nếu $Delta C < 0$ và $H=0$],
      [4], [Hoán đổi cặp cùng ngày], [$S_1, S_3, S_4, S_5$], [Tráo đồng thời $(t_a, r_a) arrow.l.r (t_b, r_b)$ không cần ô phòng trống],
    ),
    caption: [Tóm tắt cơ chế sửa chữa bốn pha của Proposed GA.]
  ) <tab_repair_phases>
]

*Bảo toàn ưu tú (Elitism), Tinh chỉnh định kỳ và Điều kiện dừng:*
Tại mỗi thế hệ, $E = 5$ cá thể tốt nhất ($6,25%$ quần thể) theo `rank_key()` được sao chép sâu trực tiếp sang thế hệ tiếp theo, đảm bảo tính đơn điệu không giảm của nghiệm tốt nhất:
$ R(x_"best"^(g+1)) <=_"lex" R(x_"best"^g) $
Ngoài ra, cứ mỗi 5 thế hệ, một bản sao của cá thể tốt nhất được đưa qua bước tinh chỉnh sâu định kỳ (_Deep Polish_) chạy lặp Pha 3 và Pha 4, và chỉ thay thế cá thể ưu tú nếu không làm xấu `rank_key()`. Thuật toán dừng khi hoàn thành $G_"max" = 200$ thế hệ, sau đó thực hiện bước tinh chỉnh cuối (_Final Polish_, 8 vòng quét trên toàn bộ 480 lớp) và kiểm tra độc lập lại toàn bộ 15 chỉ tiêu ràng buộc trước khi trả về nghiệm.

== Lưu đồ, mã giả và Phân tích độ phức tạp

@fig_proposed_flowchart và thuật toán mã giả bên dưới mô tả trọn vẹn quy trình thực thi từ khởi tạo đến tinh chỉnh cuối của *Proposed GA*.

#block(breakable: false)[
  #figure(
    image("../picture/Lưu đồ thuật toán tổng thể – Mục 4.11.svg", width: 50%),
    caption: [Lưu đồ thuật toán tổng thể của Proposed GA.]
  ) <fig_proposed_flowchart>
]

```text
Algorithm Proposed_Memetic_GA(Data, N_pop=80, G_max=200, E=5, k=5, p_c=0.85, p_m=0.015):
 1. P <- Greedy_Randomized_Init(Data, N_pop)         // 4 bước cân bằng tải & cỡ phòng
 2. Repair selected half of P; Evaluate_Population(P)
 3. best <- Copy(Best_By_Rank_Key(P)); stagnation <- 0
 4. FOR g = 1 TO G_max DO
 5.   P_next <- Copy(Top_Elites(P, E))               // Bảo toàn E=5 cá thể ưu tú
 6.   WHILE |P_next| < N_pop DO
 7.     p1, p2 <- Tournament_Select(P, k), Tournament_Select(P, k)
 8.     c1, c2 <- Course_Block_Crossover(p1, p2, p_c)
 9.     c1 <- Smart_Swap_Mutation(c1, p_m); c2 <- Smart_Swap_Mutation(c2, p_m)
10.     IF Random() < 0.40 THEN
11.       c1 <- Repair_4_Phase(c1); c2 <- Repair_4_Phase(c2)
12.     END IF
13.     Append c1 to P_next; IF |P_next| < N_pop THEN Append c2 to P_next
14.   END WHILE
15.   IF g mod 5 == 0 THEN                           // Deep Polish định kỳ
16.     cand <- Deep_Polish(Copy(P_next[0])); Evaluate(cand)
17.     IF Rank(cand) <= Rank(P_next[0]) THEN P_next[0] <- cand
18.   END IF
19.   Evaluate_Population(P_next); cur <- Best_By_Rank_Key(P_next)
20.   IF Rank(cur) < Rank(best) THEN
21.     best <- Copy(cur); stagnation <- 0; p_m <- max(0.015, 0.85 * p_m)
22.   ELSE
23.     stagnation <- stagnation + 1
24.     IF stagnation mod 10 == 0 THEN p_m <- min(0.060, 1.15 * p_m)
25.   END IF
26.   P <- P_next; Record_Statistics(P, best)
27. END FOR
28. cand <- Final_Polish(Copy(best), rounds=8); Evaluate(cand)
29. IF Rank(cand) <= Rank(best) THEN best <- cand
30. Validate_Constraints(best); RETURN best, history
```

*Phân tích độ phức tạp tính toán:* Đặt $N = |cal(S)| = 480$ (số lớp), $M = |cal(P)| = 60$ (số giảng viên), $R = |cal(R)| = 35$ (số phòng), $D = 5$ (số ngày), $T = 6$ (số ca/ngày), $K_"hard"$ và $K_"soft"$ lần lượt là số bước sửa cứng và bước tìm kiếm cục bộ thực hiện trên mỗi cá thể. Chi phí của từng thành phần được tổng hợp tại @tab_complexity.

#block(breakable: false)[
  #figure(
    table(
      columns: (1.55fr, 2.25fr, 2.1fr),
      align: (left, center, left),
      inset: 4.5pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Thành phần*]),
        text(fill: white, [*Độ phức tạp thời gian*]),
        text(fill: white, [*Giải thích*]),
      ),
      [Đánh giá Fitness], [$O(N + M D T + D T R + |cal(C)|)$], [Duyệt 1 lượt $N$ lớp kết hợp bảng đếm và bitmask 6-bit (tuyến tính khi $D, T$ cố định).],
      [Tournament Selection], [$O(k) = O(1)$], [So sánh $k=5$ khóa `rank_key()` đã lưu sẵn.],
      [Course-Block Crossover], [$O(N)$], [Sao chép có chọn lọc 480 gen theo tập môn $cal(C)_"swap"$.],
      [Adaptive Mutation], [$O(N + p_m N C_"mut")$], [Duyệt $N$ gen; chỉ biến đổi với xác suất nhỏ $p_m$.],
      [Four-phase Repair], [$O(N + K_"hard" C_"move" + K_"soft" C_"local")$], [Xây dựng trạng thái $O(N)$, khảo sát tối đa $T R$ ô cùng ngày và đánh giá cặp hoán đổi cục bộ.],
      [Sắp xếp Elitism], [$O(N_"pop" log N_"pop")$], [Sắp xếp $N_"pop" = 80$ cá thể theo `rank_key()`.],
    ),
    caption: [Phân tích độ phức tạp thời gian của các thành phần cốt lõi trong Proposed GA.]
  ) <tab_complexity>
]

Tổng hợp chi phí cho một thế hệ và toàn bộ quá trình tiến hóa gồm $G_"max"$ thế hệ:
$ C_"generation" = O(N_"pop" log N_"pop" + N_"pop" (k + N + p_m N C_"mut" + C_"eval" + p_"repair" C_"repair")) $
$ C_"total" = O(C_"init" + G_"max" C_"generation" + floor(G_"max" / 5) C_"polish" + C_"final") $
Về độ phức tạp không gian bộ nhớ, mỗi nhiễm sắc thể lưu 480 gen (kèm 2 buổi học), nên toàn bộ quần thể $N_"pop"$ cá thể và các mảng phụ trợ chỉ chiếm $O(N_"pop" N + D T R + M D T)$, tương đương vài megabyte RAM. Dù chi phí thời gian mỗi thế hệ của *Proposed GA* cao hơn do thành phần $p_"repair" C_"repair"$ và tinh chỉnh định kỳ, tổng thời gian thực nghiệm cho 200 thế hệ vẫn ở mức rất hợp lý (`136,9` giây trên CPU đơn luồng), hoàn toàn đáp ứng bài toán lập thời khóa biểu ngoại tuyến theo tuần.
