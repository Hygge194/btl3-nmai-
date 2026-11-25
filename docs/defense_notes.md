# Ghi chú phản biện mở rộng (Defense Notes) – Homework 3: Class Scheduling Using Genetic Algorithm

Tài liệu này lưu trữ các lập luận phản biện chuyên sâu, phân tích chi tiết và so sánh đối chứng mở rộng được tách ra từ báo cáo chính để giữ báo cáo PDF gọn trong 35–40 trang mà không mất cơ sở khoa học khi trả lời hội đồng.

---

## 1. Biểu diễn nghiệm: Tại sao dùng 480 gen (Section-based) thay vì 960 gen (Session-based)?

- **Lý do cấu trúc:** Hai buổi học của cùng một lớp học phần không độc lập mà phải dùng chung một giảng viên phụ trách $p_s$ và thỏa mãn ràng buộc khoảng cách ngày $|d_{s,1} - d_{s,2}| \ge 2$.
- **Hạn chế của Session-based (960 gen):** Nếu mỗi buổi học là một gen độc lập, toán tử lai ghép và đột biến dễ làm hai buổi của cùng một lớp bị gán hai giảng viên khác nhau hoặc rơi vào cùng ngày/liền ngày, buộc phải thêm cơ chế đồng bộ phức tạp.
- **Ưu điểm của Section-based (480 gen):** Mỗi gen đóng gói trọn vẹn $(s, p_s, u_{s,1}, u_{s,2})$. Khi lai ghép, việc trao đổi nguyên vẹn một gen bảo toàn tự động giảng viên chung và cấu trúc cặp ngày hợp lệ.
- **Lưu ý phản biện (không giảm một nửa không gian tìm kiếm):** Giảm số gen từ 960 xuống 480 *không* đồng nghĩa giảm một nửa kích thước không gian tìm kiếm, vì mỗi gen chứa 7 biến quyết định thay vì 4 biến. Tổng số biến quyết định vẫn là $480 \times 7 = 3360$, và kích thước không gian tìm kiếm theo cặp ngày hợp lệ vẫn là $|\Omega_{\text{pair}}| = (15\,876\,000)^{480} \approx 10^{3456.38}$. Lợi ích chính là bảo toàn tính toàn vẹn cấu trúc cho toán tử GA.

---

## 2. Phân tách ràng buộc: Tại sao 6 cứng thành 7 ($H_1$–$H_7$) và 4 mềm thành 5 ($S_1$–$S_5$)?

- **Tách $H_3$ và $H_4$:** Đề bài gộp quy định giảng viên thành một nhóm, nhưng về mặt toán học gồm hai ràng buộc khác bản chất: trùng lịch tại cùng một khung giờ ($H_3$, xung đột cục bộ theo $(d, t)$) và vượt định mức 20 buổi/tuần ($H_4$, giới hạn tổng tải toàn tuần). Tách riêng giúp Pha 1 của Repair xử lý trực tiếp $H_4$ bằng cách điều chuyển lớp sang giảng viên ít tải, còn Pha 2 xử lý $H_3$ bằng cách dời ca học.
- **Tách $S_1$ và $S_2$:** Sự phân tán lịch dạy của giảng viên diễn ra ở hai cấp độ thời gian khác nhau: ca trống giữa các tiết trong cùng một ngày ($S_1$) và ngày trống xen giữa các ngày dạy trong tuần ($S_2$). Tách riêng cho phép gán trọng số ưu tiên khác nhau ($w_1 = 5 > w_2 = 3$).
- **Tại sao giữ $H_6$ dù $H_2(x)=0 \Rightarrow H_6(x)=0$?**
  1. Đảm bảo ánh xạ 1–1 đầy đủ với đặc tả đề bài gốc.
  2. Hỗ trợ kiểm thử đơn vị (unit testing) cho các nghiệm chưa hợp lệ hoặc dữ liệu bất thường.
  3. Tách biệt lỗi khoảng cách ngày và lỗi trùng giờ khi chẩn đoán nghiệm. Việc giữ $H_6$ không làm sai lệch hàm mục tiêu đối với nghiệm khả thi vì $H_2(x)=0 \Rightarrow H_6(x)=0$.

---

## 3. Phân tách Bonus: Tập năng lực $E_p$ (6 môn) và tập yêu thích $F_p$ (3 môn)

- **Cơ sở dữ liệu:** Mỗi giảng viên có thể dạy tối đa 10 lớp/tuần (20 buổi), trong khi mỗi môn chỉ có 8 lớp và mỗi giảng viên chỉ có 3 môn Top-3 yêu thích ($F_p$). Nếu giới hạn cứng toàn bộ giảng viên chỉ được dạy trong $F_p$, không gian phân công bị thu hẹp quá mức và dễ gây bế tắc cục bộ ở các môn có ít giảng viên yêu thích.
- **Quan hệ phân cấp:** $\mathcal{C} \supseteq E_p \supseteq F_p$ với $|E_p| = 6$, $|F_p| = 3$. $E_p$ biểu diễn miền chuyên môn hợp lệ (Bonus 2: $B_2(x) = 0$), còn $F_p$ biểu diễn mức ưu tiên nguyện vọng (Bonus 1: $B_{1a}(x) = 0$ đảm bảo mỗi GV có ít nhất 1 lớp yêu thích; $B_{1b}(x)$ đếm số lớp ngoài Top-3).
- **Minh bạch khi đánh giá:** Nếu Bonus 2 của đề bài được diễn giải chặt theo nghĩa GV *chỉ* được dạy trong Top-3, điều kiện tương ứng phải là $B_{1b}(x) = 0$. Báo cáo thống kê tách biệt $B_2 = 0$ (0 lớp ngoài $E_p$) và $B_{1b} = 37$ (443/480 = 92,3% lớp thuộc $F_p$) để không đồng nhất hai khái niệm.

---

## 4. Tại sao cần Feasibility-first Ranking $R(x) = (H(x), P(x))$ bên cạnh $W_H = 100\,000$?

- **Rủi ro số học của hàm phạt cộng dồn:** Khi chỉ dùng $P(x) = W_H H(x) + P_{\text{soft}}(x) + P_{\text{bonus}}(x)$, nếu một nghiệm khả thi ($H=0$) có điểm phạt Bonus + mềm rất lớn (ví dụ tổng $> 100\,000$ khi vi phạm nhiều $B_2$ với trọng số $5\,000$), nó có thể bị xếp sau một nghiệm không khả thi ($H=1$) có ít vi phạm mềm/Bonus hơn.
- **Ví dụ minh họa:**
  - Nghiệm A: $H = 0$, $P_{\text{soft}} + P_{\text{bonus}} = 1\,500$ → **Ưu tiên** theo $R(x)$.
  - Nghiệm B: $H = 1$, $P_{\text{soft}} + P_{\text{bonus}} = 400$ → Nếu $W_H$ nhỏ hơn chênh lệch phạt mềm/Bonus thì $P(B)$ có thể nhỏ hơn $P(A)$, nhưng với $R(x) = (H(x), P(x))$, Nghiệm B luôn bị loại vì $H(B) = 1 > 0 = H(A)$.
- **Bản chất metaheuristic:** GA không chứng minh tối ưu toàn cục (global optimum) do không gian tìm kiếm $10^{3456.38}$ quá lớn và có sự đánh đổi đa tiêu chí; mục tiêu là tìm nghiệm khả thi ($H=0$) có chất lượng tốt nhất trong giới hạn tính toán.

---

## 5. Phân tích Day-Pair Bottleneck & Cận dưới hàm thích nghi

- **Nút thắt cặp ngày (Day-Pair Bottleneck):** Tập 6 cặp ngày không liền kề $\Pi_{\text{valid}} = \{(0,2),(0,3),(0,4),(1,3),(1,4),(2,4)\}$ khiến Thứ Hai (ngày 0) và Thứ Sáu (ngày 4) xuất hiện 3 lần, còn Thứ Ba, Tư, Năm chỉ xuất hiện 2 lần.
  - Nếu chọn đồng đều (16,67%/cặp): $E[L_0] = E[L_4] = 3 \times 80 = 240 > 210$ (vượt công suất lý thuyết $35 \times 6 = 210$ phòng–ca/ngày) → **Random Initialization chắc chắn quá tải Thứ 2 & Thứ 6**.
  - Giải hệ phương trình cân bằng $L_0 = \dots = L_4 = 192$ thu được họ nghiệm phụ thuộc tham số $a = n_{0,4} \in [0, 96]$ và chọn vector xác suất $q = (0.20, 0.18, 0.02, 0.22, 0.18, 0.20)$ giúp $E[L_d] = 480 \times 0.40 = 192 \le C_d$ cho mọi ngày.
- **Chứng minh Fitness không thể đạt 1:**
  - Cận dưới $S_3$: Nếu mọi GV chỉ dạy 1 buổi/ngày, công suất tối đa là $60 \times 5 \times 3 = 900 < 960$ buổi. Mỗi cặp GV–ngày dạy cả 2 buổi tăng thêm tối đa 3 buổi $\Rightarrow S_3(x) \ge \lceil (960-900)/3 \rceil = 20$.
  - Cận dưới $S_5$ (với `seed = 42`): Lớp cỡ trung bình (Size 1) có 174 lớp = 348 buổi, trong khi phòng Size 1 chỉ có 319 vị trí khả dụng. Do $H_1$ cấm dùng phòng Size 0, ít nhất $348 - 319 = 29$ buổi phải dùng phòng Size 2 $\Rightarrow S_5(x) \ge 29$.
  - Cận trên Fitness: $P_{\text{soft}}(x) \ge 5(20) + 1(29) = 129 \Rightarrow F(x) = \frac{1}{1+P(x)} \le \frac{1}{130} \approx 0.007692 < 1$. Vì vậy, tồn tại điểm phạt mềm dương là hệ quả toán học của dữ liệu, không phải lỗi hội tụ.

---

## 6. Tại sao GA thuần túy thất bại ở mật độ 93,75% và vai trò của Repair + Pairwise Swap?

- **Độ dư tài nguyên cực hẹp:** Với 960 buổi học trên 1.024 ô khả dụng (26 ô bảo trì, 2,48%), chỉ còn dư **64 vị trí trống (6,25%)** trên toàn tuần (~12–13 ô/ngày). Nhiều ca học đạt 100% công suất (Hình Heatmap).
- **Lý do GA thuần túy thất bại:** Uniform Crossover 50/50 và đột biến ngẫu nhiên dễ phá vỡ cấu trúc phòng và gây hàng trăm xung đột cứng (Baseline GA kết thúc với 393 vi phạm cứng). Ngay cả Improved GA (Greedy Init + Course-Block Crossover) vẫn kẹt ở 3 vi phạm cứng và 218 ca trống $S_1$ vì gần như không còn ô trống đơn lẻ để đột biến ngẫu nhiên dịch chuyển.
- **Khác biệt giữa Swap Mutation và Same-Day Pairwise Swap:**
  - *Swap Mutation (trong toán tử đột biến):* Hoán đổi ngẫu nhiên toàn bộ 2 buổi giữa hai lớp cùng cỡ để duy trì đa dạng quần thể; không kiểm tra trước xem chi phí có giảm hay không.
  - *Same-Day Pairwise Swap (Pha 4 của Repair):* Tìm kiếm cục bộ có định hướng (Memetic), tráo $(t_a, r_a) \leftrightarrow (t_b, r_b)$ của 2 buổi học *trong cùng một ngày* (không đổi khoảng cách ngày, không cần ô phòng trống) và chỉ chấp nhận khi giữ $H(x') = 0$ và giảm chi phí cục bộ $\Delta C_{\text{swap}} < 0$.

---

## 7. Quyết định kỹ thuật phần mềm (Chương 5)

- **Tại sao chọn Python & JSON/CSV/HTML thay vì C++/Microservices/DBMS?** Bài toán tối ưu tổ hợp độc lập quy mô hữu hạn (60 môn, 480 lớp), không có giao dịch đồng thời đa người dùng. Python + NumPy mảng chỉ số (`section_size_arr`, `room_avail_arr`, `is_eligible_arr`, `fav_rank_arr`) đủ nhanh để chạy 200 thế hệ trong ~136,9 giây, đồng thời tệp JSON/CSV giúp tái lập thực nghiệm dễ dàng.
- **Tại sao tách Data Seed (`42`) và GA Seed (`2026`)?** Cho phép giữ cố định hoàn toàn bộ dữ liệu bài toán trong khi thay đổi quá trình tìm kiếm ngẫu nhiên của GA.
- **Tại sao dùng Bitmask 6-bit kết hợp bộ đếm?** Mỗi ngày có 6 ca nên lịch dạy của GV biểu diễn bằng số nguyên 6-bit giúp tính $S_1$ (ca trống) và $S_3$ (AND với `0b000111` và `0b111000`) trong $O(1)$. Tuy nhiên bitmask chỉ ghi nhận trạng thái nhị phân (có/không) nên các ràng buộc xung đột ($H_3, H_7$) vẫn dùng bộ đếm để phát hiện chính xác số buổi trùng lặp $\ge 2$.
- **Điều kiện trong `data_generator.py` là điều kiện cần, không phải điều kiện đủ:** Kiểm tra tích lũy kích thước ($\text{req}_2 \le \text{avail}_2 - 20$, $\text{req}_2 + \text{req}_1 \le \text{avail}_2 + \text{avail}_1 - 30$, tải ngày $\ge 202$) chỉ loại bỏ các bộ dữ liệu chắc chắn vô nghiệm về mặt tổng tài nguyên; tính khả thi thực tế chỉ được xác nhận khi tìm được nghiệm cụ thể thỏa $H(x) = 0$.
- **Tại sao `@dataclass` cần hàm `copy()` riêng?** `@dataclass` và Type Hints không tự kiểm tra miền giá trị lúc chạy và không tự sao chép sâu khi nhân bản đối tượng chứa danh sách `Gene`/`Session`. Nếu chia sẻ tham chiếu, đột biến trên cá thể con sẽ làm hỏng cá thể ưu tú trong Elitism.

---

## 8. Giải thích các điểm nhạy cảm trong kết quả thực nghiệm (Chương 6)

- **Tại sao Proposed GA có độ khớp cỡ phòng (93,1%) thấp hơn Improved GA (95,6%) và phạt Bonus (55,5) cao hơn Improved GA (42,0)?**
  Đây là **sự đánh đổi đa tiêu chí (multi-objective trade-off)** tự nhiên. Improved GA còn 3 vi phạm cứng ($H_3 = 3$) và 218 ca trống ($S_1 = 218$). Để xóa sạch 3 xung đột cứng ($H = 0$) và giảm 76,6% ca trống ($218 \to 51$, trọng số $w_1 = 5$) cùng 29,7% ngày dạy 2 buổi ($192 \to 135$, trọng số $w_3 = 5$), Proposed GA chấp nhận nhượng bộ nhẹ ở $S_5$ (trọng số $w_5 = 1$) và $B_{1b}$ (trọng số $1.5$), qua đó giảm tổng phạt mềm tới 38,4% ($2459 \to 1515$).
- **Tại sao cấu hình khảo sát `Mutation Rate = 0.005` (Pop=40, 60 gen) đạt Soft Penalty = 1473, tốt hơn mốc 1515 của thí nghiệm chính?**
  1. Giá trị `0.005` thấp hơn cận dưới mặc định (`0.015`) của chế độ đột biến thích nghi nên ít phá vỡ cấu trúc tốt khi kết hợp với Repair ở mật độ 93,75%.
  2. Thí nghiệm chính và các khảo sát nhạy tham số dùng điều kiện cấu hình khác nhau (Pop=40/60 gen vs Pop=80/200 gen) trên một seed đơn lẻ nên kết quả chịu ảnh hưởng của yếu tố ngẫu nhiên. Không thể suy diễn gộp cơ học các tham số tốt nhất đơn lẻ thành cấu hình tối ưu toàn cục mà cần khảo sát tổ hợp đa seed.
- **Giới hạn của thí nghiệm đơn seed & Ablation Study:** Kết quả hiện tại xác nhận tính khả thi và hiệu quả tổng hợp của các nhóm cải tiến trên bộ dữ liệu `seed = 42`, `ga-seed = 2026`. Để kết luận ý nghĩa thống kê (trung bình, độ lệch chuẩn, tỷ lệ thành công) và tách biệt đóng góp riêng của từng toán tử, cần chạy đa seed và thực hiện *Ablation Study* ở bước phát triển tiếp theo.
- **Chi phí thời gian (+24,9% so với Improved GA; gấp 2,44 lần Baseline GA):** 136,9 giây (~2,3 phút) là hoàn toàn chấp nhận được cho bài toán lập thời khóa biểu theo tuần/học kỳ vốn chạy ngoại tuyến (offline), đổi lại loại bỏ toàn bộ 393 vi phạm cứng của Baseline GA và giảm mạnh công sức chỉnh sửa thủ công.
