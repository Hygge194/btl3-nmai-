= MÔ HÌNH HÓA BÀI TOÁN (PROBLEM FORMULATION)

== Phân tích bài toán, tập dữ liệu và biến quyết định

Bài toán xếp thời khóa biểu Homework 3 đặt ra nhiệm vụ phân bổ đồng thời giảng viên, ngày học, ca học và phòng học cho 480 lớp học phần (tương ứng 960 buổi học) trong phạm vi một tuần học gồm 5 ngày (Thứ Hai đến Thứ Sáu) và 6 ca học mỗi ngày. Toàn bộ các tập đối tượng và tham số đầu vào được chuẩn hóa theo quy ước đánh chỉ số bắt đầu từ 0 nhằm đảm bảo ánh xạ nhất quán 1–1 giữa mô hình toán học và mã nguồn cài đặt (@tab_math_sets).

#block(breakable: false)[
  #figure(
    table(
      columns: (1.2fr, 1.8fr, 2.7fr),
      align: (left, left, left),
      inset: 4.5pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Tập / Tham số*]),
        text(fill: white, [*Định nghĩa toán học*]),
        text(fill: white, [*Ý nghĩa và quy ước cài đặt*]),
      ),
      [$cal(C)$], [${c_0, ..., c_59}$, $|cal(C)| = 60$], [Tập môn học (`c01`–`c60`); mỗi môn có đúng 8 lớp học phần (16 buổi/tuần).],
      [$cal(S)$], [${s_0, ..., s_479}$, $|cal(S)| = 480$], [Tập lớp học phần; ánh xạ môn $c: cal(S) arrow.r cal(C)$; cỡ lớp $"size"_"sec"(s) in {0,1,2}$ (nhỏ, trung bình, lớn).],
      [$cal(U)$], [${(s,k) | s in cal(S), k in {1,2}}$], [Tập toàn bộ 960 buổi học cần phân bổ trong tuần ($N_"sess" = 480 times 2 = 960$).],
      [$cal(P)$], [${p_0, ..., p_59}$, $|cal(P)| = 60$], [Tập giảng viên (`p01`–`p60`); định mức tối đa $L_"max" = 20$ buổi (10 lớp)/tuần.],
      [$E_p, F_p$], [$F_p subset.eq E_p subset.eq cal(C)$], [Tập môn đủ năng lực dạy ($|E_p|=6$) và tập Top-3 môn yêu thích ($|F_p|=3$) của giảng viên $p$.],
      [$cal(R)$], [${r_0, ..., r_34}$, $|cal(R)| = 35$], [Tập phòng học (`rm01`–`rm35`); cỡ phòng $"size"_"rm"(r) in {0,1,2}$.],
      [$A_(d,t,r)$], [$A_(d,t,r) in {0,1}$], [Trạng thái khả dụng của phòng $r$ tại ngày $d$, ca $t$ (1: mở khả dụng, 0: không khả dụng/bảo trì).],
      [$cal(D), cal(T)$], [$cal(D)={0..4}, cal(T)={0..5}$], [5 ngày học (Thứ 2–6), 6 ca/ngày gồm buổi sáng $cal(T)_M={0,1,2}$ và buổi chiều $cal(T)_A={3,4,5}$.],
    ),
    caption: [Tổng hợp các tập dữ liệu và tham số toán học của bài toán.]
  ) <tab_math_sets>
]

*Biến quyết định và không gian nghiệm:* Theo giả định nghiệp vụ của bài toán, mỗi lớp học phần $s in cal(S)$ do đúng một giảng viên $p_s in cal(P)$ phụ trách cả hai buổi học $k in cal(K) = {1, 2}$ trong tuần. Do đó, quyết định lập lịch cho mỗi lớp học phần $s$ được biểu diễn trọn vẹn bởi bộ bảy biến:
$ x_s = (p_s, d_(s,1), t_(s,1), r_(s,1), d_(s,2), t_(s,2), r_(s,2)) $
trong đó $p_s in cal(P)$ là giảng viên phụ trách, $d_(s,k) in cal(D)$ là ngày học, $t_(s,k) in cal(T)$ là ca học và $r_(s,k) in cal(R)$ là phòng học của buổi thứ $k$. Một nghiệm ứng viên hoàn chỉnh cho toàn trường là vector gồm 480 bộ biến $x = (x_(s_0), x_(s_1), ..., x_(s_479))$, chứa tổng cộng $N_"var" = 480 times 7 = 3360$ thành phần quyết định. Gọi $Omega$ là toàn bộ không gian tìm kiếm, tập nghiệm khả thi được định nghĩa là:
$ cal(F) = {x in Omega | H_i(x) = 0, forall i in {1, 2, ..., 7}} $

*Cơ sở lựa chọn biểu diễn theo lớp học phần (Section-based Representation):* Một câu hỏi thiết kế quan trọng là nên mã hóa nghiệm thành 480 gen (mỗi gen là một lớp học phần) hay 960 gen (mỗi gen là một buổi học độc lập, _Session-based Representation_). Nếu dùng 960 gen độc lập, các phép lai ghép và đột biến tác động riêng rẽ lên từng buổi sẽ dễ phá vỡ tính thống nhất giảng viên giữa hai buổi của cùng một lớp hoặc đẩy hai buổi về cùng ngày/liền ngày, buộc phải bổ sung cơ chế đồng bộ hóa phức tạp. Ngược lại, khi đóng gói cả giảng viên chung và hai buổi học vào cùng một gen, mỗi lần trao đổi gen đều tự động bảo toàn tính toàn vẹn của từng lớp. Cần lưu ý rằng việc giảm số gen từ 960 xuống 480 *không* làm giảm một nửa kích thước không gian tìm kiếm (vì mỗi gen chứa nhiều biến quyết định hơn), mà giá trị cốt lõi nằm ở khả năng bảo toàn cấu trúc nghiệp vụ cho các toán tử tiến hóa.

== Mô hình hóa ràng buộc cứng (Hard Constraints)

Theo đặc tả Homework 3 có sáu nhóm điều kiện bắt buộc; nhóm tách yêu cầu về giảng viên thành hai hàm độc lập là trùng lịch theo khung giờ ($H_3$) và vượt định mức tải tuần ($H_4$). Lý do tách riêng là hai lỗi này có bản chất hoàn toàn khác nhau: $H_3$ là xung đột cục bộ tại một thời điểm $(d, t)$ cần giải quyết bằng cách dời ca học, còn $H_4$ là xung đột tích lũy trên toàn tuần cần giải quyết bằng cách điều chuyển lớp sang giảng viên khác. Tách biệt hai hàm giúp cơ chế sửa chữa ở Chương 4 định hướng xử lý chính xác từng nguyên nhân lỗi.

Đặt hàm chỉ thị $II[Phi] = 1$ nếu mệnh đề logic $Phi$ đúng và $II[Phi] = 0$ nếu sai. Tổng số vi phạm ràng buộc cứng của một nghiệm $x$ là $H(x) = sum_(i=1)^7 H_i(x)$, với điều kiện khả thi $H(x) = 0$.

+ *Ràng buộc kích thước phòng học ($H_1$):* Mọi buổi học phải được xếp vào phòng có sức chứa không nhỏ hơn quy mô đăng ký của lớp ($"size"_"rm"(r_(s,k)) >= "size"_"sec"(s)$). Số buổi xếp vào phòng quá nhỏ là:
  $ H_1(x) = sum_(s in cal(S)) sum_(k in cal(K)) II["size"_"rm"(r_(s,k)) < "size"_"sec"(s)] $
  Ràng buộc này đảm bảo sinh viên của lớp cỡ trung bình (Size 1) hoặc cỡ lớn (Size 2) không bị xếp vào phòng nhỏ hơn sức chứa.

+ *Ràng buộc khoảng cách giữa hai buổi học ($H_2$):* Hai buổi học của cùng một lớp không được diễn ra trong cùng một ngày hoặc hai ngày liên tiếp ($|d_(s,1) - d_(s,2)| >= 2$) nhằm tạo thời gian ôn tập giữa hai buổi:
  $ H_2(x) = sum_(s in cal(S)) II[|d_(s,1) - d_(s,2)| < 2] $
  Với quy ước sắp thứ tự ngày tăng dần $d_(s,1) < d_(s,2)$, tập hợp tất cả các cặp ngày hợp lệ trên 5 ngày làm việc chỉ gồm đúng sáu cặp:
  $ Pi_"valid" = {(0,2), (0,3), (0,4), (1,3), (1,4), (2,4)} $
  (tương ứng Thứ 2–4, 2–5, 2–6, 3–5, 3–6 và 4–6). Khi thuật toán chỉ lấy mẫu cặp ngày từ $Pi_"valid"$, ràng buộc $H_2$ được đảm bảo ngay ở mức biểu diễn.

+ *Ràng buộc không trùng lịch giảng viên ($H_3$):* Tại bất kỳ khung giờ $(d, t)$ nào, mỗi giảng viên chỉ được giảng dạy tối đa một lớp. Đặt $N_p(d,t) = sum_(s in cal(S)) sum_(k in cal(K)) II[p_s = p and d_(s,k) = d and t_(s,k) = t]$ là số buổi dạy của giảng viên $p$ tại $(d,t)$:
  $ H_3(x) = sum_(p in cal(P)) sum_(d in cal(D)) sum_(t in cal(T)) max(0, N_p(d,t) - 1) $

+ *Ràng buộc định mức khối lượng giảng dạy ($H_4$):* Tổng số buổi dạy trong tuần của mỗi giảng viên $L_p = sum_(d in cal(D)) sum_(t in cal(T)) N_p(d,t)$ không vượt quá $L_"max" = 20$ buổi (tương đương 10 lớp học phần):
  $ H_4(x) = sum_(p in cal(P)) max(0, L_p - L_"max") $
  Với 60 giảng viên, tổng công suất giảng dạy toàn trường là $60 times 20 = 1200$ buổi/tuần, tương ứng tỷ lệ sử dụng tải giảng viên trung bình là $960 / 1200 = 80%$.

+ *Ràng buộc phòng học khả dụng ($H_5$):* Buổi học chỉ được phân bổ vào vị trí $(d, t, r)$ có trạng thái mở ($A_(d,t,r) = 1$), tránh các khung giờ phòng đang bảo trì hoặc phục vụ hoạt động khác:
  $ H_5(x) = sum_(s in cal(S)) sum_(k in cal(K)) II[A_(d_(s,k), t_(s,k), r_(s,k)) = 0] $

+ *Ràng buộc không trùng lịch của lớp học phần ($H_6$):* Hai buổi của cùng một lớp không thể diễn ra tại cùng một thời điểm $(d, t)$:
  $ H_6(x) = sum_(s in cal(S)) II[d_(s,1) = d_(s,2) and t_(s,1) = t_(s,2)] $
  Về mặt logic, khi $H_2(x) = 0$ thì chắc chắn $d_(s,1) != d_(s,2)$, kéo theo $H_6(x) = 0$. Tuy nhiên, nhóm vẫn giữ tường minh $H_6$ trong mô hình và mã nguồn nhằm ánh xạ đầy đủ 1–1 với đặc tả đề bài, đồng thời hỗ trợ kiểm thử đơn vị độc lập trên các dữ liệu lịch bất hợp lệ mà không làm sai lệch đánh giá nghiệm khả thi.

+ *Ràng buộc không trùng lịch phòng học ($H_7$):* Tại mỗi khung giờ $(d, t)$, mỗi phòng học $r$ chỉ phục vụ tối đa một buổi học. Đặt $M(d,t,r) = sum_(s in cal(S)) sum_(k in cal(K)) II[d_(s,k) = d and t_(s,k) = t and r_(s,k) = r]$:
  $ H_7(x) = sum_(d in cal(D)) sum_(t in cal(T)) sum_(r in cal(R)) max(0, M(d,t,r) - 1) $

== Mô hình hóa ràng buộc mềm (Soft Constraints)

Từ bốn nhóm tiêu chí chất lượng của đề bài, nhóm tách yêu cầu hạn chế phân tán lịch giảng viên thành hai cấp độ độc lập là *khoảng trống giữa các ca trong cùng ngày* ($S_1$) và *ngày trống xen giữa trong tuần* ($S_2$). Sự tách biệt này cho phép gán mức ưu tiên khác nhau vì việc giảng viên phải chờ giữa các ca trong cùng một ngày gây bất tiện trực tiếp hơn so với việc nghỉ một ngày giữa tuần. Tổng điểm phạt mềm được định nghĩa dạng tổ hợp tuyến tính có trọng số:
$ S(x) = sum_(j=1)^5 w_j S_j(x) quad (w_j > 0) $

+ *Khoảng trống giữa các ca dạy trong ngày ($S_1$):* Gọi $T_(p,d) = {t in cal(T) | N_p(d,t) > 0}$ là tập các ca dạy trong ngày $d$ của giảng viên $p$. Với mỗi ngày giảng viên dạy từ 2 ca trở lên ($|T_(p,d)| >= 2$), số ca trống nằm xen giữa ca đầu và ca cuối là $G_(p,d) = max(T_(p,d)) - min(T_(p,d)) + 1 - |T_(p,d)|$:
  $ S_1(x) = sum_(p in cal(P)) sum_(d in cal(D): |T_(p,d)| >= 2) G_(p,d) $
  *Ví dụ minh họa:* Nếu giảng viên $p$ dạy các ca ${0, 2, 4}$ trong Thứ Hai, thì $max = 4, min = 0, |T_(p,0)| = 3$, suy ra số ca trống là $G_(p,0) = 4 - 0 + 1 - 3 = 2$ (bỏ trống ca 1 và ca 3). Nếu giảng viên dạy liên tiếp ${0, 1, 2}$, thì $G_(p,0) = 2 - 0 + 1 - 3 = 0$.

+ *Lịch giảng dạy rải rác trong tuần ($S_2$):* Gọi $D_p = {d in cal(D) | |T_(p,d)| > 0}$ là tập các ngày có lịch dạy của giảng viên $p$. Nếu giảng viên dạy ít nhất 2 ngày ($|D_p| >= 2$), số ngày trống xen giữa ngày đầu và ngày cuối trong tuần là $G_p = max(D_p) - min(D_p) + 1 - |D_p|$:
  $ S_2(x) = sum_(p in cal(P): |D_p| >= 2) G_p $
  *Ví dụ minh họa:* Giảng viên dạy vào Thứ 2, Thứ 4 và Thứ 6 ($D_p = {0, 2, 4}$) có $G_p = 4 - 0 + 1 - 3 = 2$ ngày trống (Thứ 3 và Thứ 5), trong khi dạy liền Thứ 2–Thứ 4 ($D_p = {0, 1, 2}$) có $G_p = 0$.

+ *Tập trung buổi dạy của giảng viên ($S_3$):* Hạn chế tình trạng giảng viên phải lên trường dạy cả buổi sáng ($cal(T)_M = {0, 1, 2}$) lẫn buổi chiều ($cal(T)_A = {3, 4, 5}$) trong cùng một ngày. Hàm $S_3$ đếm tổng số cặp (giảng viên, ngày) bị chia buổi:
  $ S_3(x) = sum_(p in cal(P)) sum_(d in cal(D)) II[(T_(p,d) inter cal(T)_M != emptyset) and (T_(p,d) inter cal(T)_A != emptyset)] $

+ *Tập trung buổi học của môn học ($S_4$):* Khuyến khích toàn bộ 16 buổi học của 8 lớp thuộc cùng một môn $c in cal(C)$ tập trung về cùng một buổi (toàn bộ sáng hoặc toàn bộ chiều). Gọi $m_c = sum_(s in cal(S): c(s)=c) sum_(k in cal(K)) II[t_(s,k) in cal(T)_M]$ là số buổi sáng của môn $c$, số buổi bị lệch khỏi buổi đa số là:
  $ S_4(x) = sum_(c in cal(C)) min(m_c, 16 - m_c) $
  Giá trị $min(m_c, 16 - m_c)$ bằng 0 khi cả 16 buổi đều ở sáng ($m_c = 16$) hoặc đều ở chiều ($m_c = 0$), và đạt cực đại bằng 8 khi chia đều 8 sáng – 8 chiều.

+ *Tối ưu kích thước phòng học ($S_5$):* Đo tổng độ chênh lệch dư kích thước phòng so với quy mô lớp học nhằm tránh lãng phí phòng lớn cho lớp nhỏ (trường hợp phòng nhỏ hơn quy mô lớp đã bị chặn bởi ràng buộc cứng $H_1$):
  $ S_5(x) = sum_(s in cal(S)) sum_(k in cal(K)) max(0, "size"_"rm"(r_(s,k)) - "size"_"sec"(s)) $
  Ví dụ, xếp lớp Size 0 vào phòng Size 0 có độ dư 0 (khớp chuẩn), vào phòng Size 1 bị phạt $+1$, vào phòng Size 2 bị phạt $+2$.

== Ràng buộc mở rộng (Bonus Constraints) và Hàm mục tiêu

*Mô hình hóa ràng buộc mở rộng:* Bài toán đề xuất hai yêu cầu mở rộng gắn với sở thích môn học của giảng viên: (Bonus 1) mỗi giảng viên có ít nhất một lớp thuộc danh sách yêu thích và (Bonus 2) giảng viên chỉ dạy các môn thuộc danh sách giảng dạy phù hợp. Tuy nhiên, nếu mỗi giảng viên chỉ có đúng 3 môn Top-3 yêu thích ($|F_p| = 3$) trong khi có thể dạy tối đa 10 lớp/tuần và mỗi môn chỉ có 8 lớp, việc giới hạn cứng toàn bộ 480 lớp chỉ được phân công trong $F_p$ sẽ thu hẹp mạnh không gian gán giảng viên và dễ gây bế tắc ở những môn có ít giảng viên chọn Top-3. Do đó, nhóm xây dựng mô hình phân cấp chuyên môn $cal(C) supset.eq E_p supset.eq F_p$, trong đó mỗi giảng viên có $|E_p| = 6$ môn *đủ năng lực giảng dạy* và $|F_p| = 3$ môn *Top-3 yêu thích*.

Gọi $Q_p = sum_(s in cal(S)) II[p_s = p and c(s) in F_p]$ là số lớp thuộc Top-3 yêu thích của giảng viên $p$. Ba chỉ tiêu mở rộng được định nghĩa tách bạch như sau:
$ B_(1a)(x) = sum_(p in cal(P)) II[Q_p = 0], quad B_(1b)(x) = sum_(s in cal(S)) II[c(s) in.not F_(p_s)], quad B_2(x) = sum_(s in cal(S)) II[c(s) in.not E_(p_s)] $
trong đó:
- $B_(1a)(x) = 0$ đảm bảo 100% giảng viên đều có ít nhất một lớp thuộc Top-3 yêu thích (đáp ứng trực tiếp Bonus 1);
- $B_2(x) = 0$ đảm bảo không có lớp nào bị gán cho giảng viên ngoài danh sách năng lực $E_p$ (Bonus 2 theo giả định mở rộng);
- $B_(1b)(x)$ đếm số lớp thuộc $E_p without F_p$, từ đó tính tỷ lệ lớp khớp Top-3 yêu thích $R_"favorite"(x) = frac(|cal(S)| - B_(1b)(x), |cal(S)|) times 100%$. Nếu Bonus 2 được diễn giải theo nghĩa chặt là chỉ dạy trong Top-3 thì điều kiện tương ứng là $B_(1b)(x) = 0$; việc báo cáo đồng thời $B_2$ và $B_(1b)$ đảm bảo tính minh bạch hoàn toàn khi đánh giá.

*Hàm mục tiêu và Cơ chế Xếp hạng ưu tiên khả thi (Feasibility-first Ranking):* Tổng mức phạt Bonus là $B(x) = w_(B_(1a)) B_(1a)(x) + w_(B_(1b)) B_(1b)(x) + w_(B_2) B_2(x)$. Bài toán tối ưu tổng quát hướng tới:
$ min_(x in Omega) [S(x) + B(x)] quad "với điều kiện" quad H(x) = 0 $
Để phục vụ việc theo dõi hội tụ và so sánh định lượng, tổng mức phạt $P(x)$ và độ thích nghi chuẩn hóa $F(x)$ được định nghĩa là:
$ P(x) = W_H H(x) + S(x) + B(x), quad F(x) = frac(1, 1 + P(x)) in (0, 1] $
Tuy nhiên, chỉ dựa vào tổng phạt vô hướng $P(x)$ có thể phát sinh rủi ro số học nếu một nghiệm khả thi ($H = 0$) mang nhiều vi phạm mềm hoặc Bonus vượt ngưỡng $W_H$, khiến nó bị xếp sau một nghiệm không khả thi ($H = 1$). Để loại bỏ tuyệt đối khả năng này, mọi thao tác chọn lọc và bảo toàn ưu tú đều sử dụng thứ tự từ điển *Feasibility-first Ranking*:
$ R(x) = (H(x), P(x)) $
Nghiệm $x_1$ được xếp hạng tốt hơn $x_2$ ($R(x_1) <_"lex" R(x_2)$) khi và chỉ khi $H(x_1) < H(x_2)$, hoặc $H(x_1) = H(x_2)$ và $P(x_1) < P(x_2)$ (@tab_ranking_demo). Do GA là phương pháp metaheuristic trên không gian rời rạc khổng lồ, mục tiêu thực tế là tìm nghiệm khả thi có chất lượng tốt nhất trong giới hạn tài nguyên tính toán thay vì chứng minh tối ưu toàn cục.

#block(breakable: false)[
  #figure(
    table(
      columns: (1.05fr, 1.15fr, 1.3fr, 1.4fr, 1.55fr),
      align: (left, center, center, center, left),
      inset: 4.5pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Nghiệm*]), text(fill: white, [*$H(x)$*]), text(fill: white, [*Phạt mềm + Bonus*]),
        text(fill: white, [*Nếu chỉ xét $P(x)$*]), text(fill: white, [*Theo xếp hạng $R(x)$*]),
      ),
      [Nghiệm A], [0 (Khả thi)], [1.500], [1.500], [*Ưu tiên* (vì $H = 0$)],
      [Nghiệm B], [1 (Không KT)], [400], [$W_H + 400$ (phụ thuộc $W_H$)], [Bị loại (vì $H = 1 > 0$)],
    ),
    caption: [Minh họa ưu thế của cơ chế xếp hạng Feasibility-first $R(x) = (H(x), P(x))$.]
  ) <tab_ranking_demo>
]

== Phân tích không gian tìm kiếm, nút thắt cặp ngày và cận dưới

*1. Kích thước không gian tìm kiếm và độ chặt tài nguyên phòng học:*
Ngay cả khi thu hẹp miền ngày học về đúng 6 cặp ngày hợp lệ trong $Pi_"valid"$, mỗi lớp học phần vẫn có 60 lựa chọn giảng viên, 6 lựa chọn cặp ngày và $6 times 35 = 210$ phương án (ca, phòng) cho từng buổi học. Số cấu hình khả dĩ của một gen là:
$ N_"gene" = 60 times 6 times (6 times 35)^2 = 15\,876\,000 $
Trên toàn bộ 480 lớp học phần, kích thước không gian tìm kiếm theo cặp ngày hợp lệ đạt:
$ |Omega_"pair"| = (15\,876\,000)^480 approx 10^(3456.38) $
Con số này vượt xa khả năng duyệt vét cạn của bất kỳ máy tính nào. Đồng thời, trên bộ dữ liệu thực nghiệm (`seed = 42`), có 26 vị trí phòng–ca bảo trì (`2,48%`), làm giảm tổng công suất khả dụng xuống $C_"room" = 1050 - 26 = 1024$ vị trí. Để xếp đủ 960 buổi học, tỷ lệ khai thác phòng đạt $U_"room" = 960 / 1024 = 93,75%$, chỉ còn lại đúng $C_"remain" = 64$ vị trí trống (`6,25%` độ dư) cho toàn bộ 5 ngày học — tức trung bình chỉ khoảng 12–13 vị trí trống mỗi ngày trên 35 phòng học.

*2. Phân tích nút thắt phân bố cặp ngày (Day-Pair Bottleneck):*
Một phát hiện toán học quan trọng của bài toán nằm ở cấu trúc bất đối xứng của tập sáu cặp ngày hợp lệ $Pi_"valid" = {(0,2), (0,3), (0,4), (1,3), (1,4), (2,4)}$. Quan sát tần suất xuất hiện của từng ngày trong $Pi_"valid"$ cho thấy:
- Thứ Hai (ngày 0) xuất hiện trong *3 cặp*: $(0,2), (0,3), (0,4)$.
- Thứ Sáu (ngày 4) xuất hiện trong *3 cặp*: $(0,4), (1,4), (2,4)$.
- Thứ Ba (ngày 1), Thứ Tư (ngày 2) và Thứ Năm (ngày 3) mỗi ngày chỉ xuất hiện trong *2 cặp*.

Nếu thuật toán khởi tạo chọn ngẫu nhiên đồng đều 6 cặp ngày ($p_(i,j) = 1/6 approx 16,67%$, tức trung bình $E[n_(i,j)] = 480 / 6 = 80$ lớp mỗi cặp), tải buổi học kỳ vọng theo từng ngày sẽ là:
$ E[L_0] = E[L_4] = 3 times 80 = 240 "buổi", quad E[L_1] = E[L_2] = E[L_3] = 2 times 80 = 160 "buổi" $
Trong khi đó, công suất tối đa lý thuyết của một ngày ngay cả khi không có phòng bảo trì chỉ là $C_"day"^"max" = 35 times 6 = 210$ vị trí. Như vậy, cách lấy mẫu đồng đều *chắc chắn gây quá tải trung bình 30 buổi học tại cả Thứ Hai và Thứ Sáu* ($240 > 210$), tạo ra ít nhất 60 xung đột trùng phòng ngay từ bản chất xác suất trước khi tính tới xung đột giảng viên và kích thước phòng.

Để phân bổ đều tải về đúng mức mục tiêu $L_"target" = 960 / 5 = 192$ buổi/ngày, gọi $n_(i,j)$ là số lớp chọn cặp ngày $(i,j) in Pi_"valid"$. Giải hệ năm phương trình cân bằng theo ngày:
$ cases(
  L_0 = n_(0,2) + n_(0,3) + n_(0,4) = 192,
  L_1 = n_(1,3) + n_(1,4) = 192,
  L_2 = n_(0,2) + n_(2,4) = 192,
  L_3 = n_(0,3) + n_(1,3) = 192,
  L_4 = n_(0,4) + n_(1,4) + n_(2,4) = 192
) $
Theo tham số tự do $a = n_(0,4) in [0, 96]$, ta thu được họ nghiệm tổng quát:
$ n_(0,2) = n_(2,4) = 96, quad n_(0,3) = n_(1,4) = 96 - a, quad n_(0,4) = a, quad n_(1,3) = 96 + a $
Chọn tham số $a approx 9,6$ (giữ cặp Thứ 2–Thứ 6 ở mức nhỏ 2% để tránh bỏ trống giữa tuần cho $S_2$ nhưng vẫn giữ đa dạng), chia cho 480 ta thu được vector xác suất cân bằng tải:
$ q = (q_(0,2), q_(0,3), q_(0,4), q_(1,3), q_(1,4), q_(2,4)) = (0.20, 0.18, 0.02, 0.22, 0.18, 0.20) $
Kiểm tra lại tổng xác suất xuất hiện của từng ngày: $P(d=0) = 0.20 + 0.18 + 0.02 = 0.40$, $P(d=1) = 0.22 + 0.18 = 0.40$, $P(d=2) = 0.20 + 0.20 = 0.40$, $P(d=3) = 0.18 + 0.22 = 0.40$ và $P(d=4) = 0.02 + 0.18 + 0.20 = 0.40$. Nhờ đó, tải kỳ vọng mọi ngày đều đưa về đúng $E[L_d] = 480 times 0.40 = 192 <= C_d$ (@tab_day_load), giải quyết triệt để nút thắt cổ chai ở hai ngày đầu và cuối tuần.

#block(breakable: false)[
  #figure(
    table(
      columns: (1.9fr, 1.0fr, 0.85fr, 0.85fr, 0.85fr, 1.0fr),
      align: (left, center, center, center, center, center),
      inset: 4.5pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Phương pháp chọn cặp ngày*]),
        text(fill: white, [*Thứ 2*]),
        text(fill: white, [*Thứ 3*]),
        text(fill: white, [*Thứ 4*]),
        text(fill: white, [*Thứ 5*]),
        text(fill: white, [*Thứ 6*]),
      ),
      [Phân bố đồng đều (Random)], [240 (Quá tải)], [160], [160], [160], [240 (Quá tải)],
      [Vector xác suất cân bằng $q$], [*192*], [*192*], [*192*], [*192*], [*192*],
      [Công suất khả dụng (`seed=42`)], [204], [205], [205], [205], [205],
      [Công suất tối đa lý thuyết], [210], [210], [210], [210], [210],
    ),
    caption: [So sánh tải buổi học kỳ vọng theo ngày giữa chọn đồng đều và vector cân bằng $q$.]
  ) <tab_day_load>
]

*3. Chứng minh cận dưới lý thuyết của $S_3$, $S_5$ và cận trên hàm thích nghi:*
Một câu hỏi quan trọng khi đánh giá GA là liệu hàm thích nghi $F(x) = 1/(1+P(x))$ có thể hội tụ về 1 ($P(x)=0$) hay không. Phân tích đếm trên cấu trúc bài toán và bộ dữ liệu thực nghiệm chứng minh hai cận dưới chặt mang tính bắt buộc:

- *Cận dưới của $S_3$ (Giảng viên dạy cả sáng và chiều):* Nếu không có bất kỳ giảng viên nào phải dạy cả hai buổi trong cùng một ngày ($S_3(x) = 0$), thì mỗi ngày mỗi giảng viên chỉ dạy tối đa 1 buổi (tức tối đa 3 ca học). Khi đó, tổng công suất giảng dạy tối đa toàn trường trong 5 ngày là $C_"single-shift" = 60 times 5 times 3 = 900$ buổi, thiếu $960 - 900 = 60$ buổi so với tổng nhu cầu. Mỗi cặp giảng viên–ngày dạy cả sáng lẫn chiều bổ sung thêm tối đa 3 ca, do đó mọi nghiệm khả thi đều phải thỏa:
  $ 960 <= 900 + 3 S_3(x) arrow.r.double S_3(x) >= ceil(frac(960 - 900, 3)) = 20 $

- *Cận dưới của $S_5$ (Độ dư kích thước phòng học):* Trên bộ dữ liệu thực nghiệm (`seed = 42`), có 174 lớp cỡ trung bình (Size 1), tạo nhu cầu $N_"sess"^1 = 174 times 2 = 348$ buổi học, trong khi tổng số vị trí khả dụng của 11 phòng Size 1 chỉ là $C_"room"^1 = 319$ vị trí. Do ràng buộc cứng $H_1$ cấm xếp lớp Size 1 vào phòng Size 0, tối thiểu $348 - 319 = 29$ buổi học cỡ trung bình bắt buộc phải đẩy lên phòng cỡ lớn (Size 2), mỗi buổi chịu độ dư $+1$. Do đó, mọi nghiệm khả thi trên bộ dữ liệu này đều thỏa:
  $ S_5(x) >= 29 $

- *Hệ quả đối với cận trên hàm thích nghi:* Với mọi nghiệm khả thi $x in cal(F)$ trên dữ liệu thực nghiệm, tổng mức phạt luôn bị chặn dưới chặt bởi $P(x) >= w_3 S_3(x) + w_5 S_5(x) >= 20 w_3 + 29 w_5 > 0$, suy ra:
  $ F(x) = frac(1, 1 + P(x)) <= frac(1, 1 + 20 w_3 + 29 w_5) < 1 $

Chứng minh trên khẳng định rằng việc hàm thích nghi không đạt giá trị 1 là hệ quả toán học tất yếu của quy mô và cấu trúc dữ liệu chứ không phải lỗi cài đặt hay lỗi hội tụ của thuật toán. Đồng thời, sự kết hợp giữa mật độ sử dụng phòng `93,75%` (chỉ còn 64 ô trống) và nút thắt cặp ngày giải thích lý do GA thuần túy khó tìm được nghiệm khả thi, tạo cơ sở khoa học trực tiếp cho thiết kế khởi tạo tham lam cân bằng tải, lai ghép theo khối và cơ chế sửa chữa hoán đổi cặp tại Chương 4.
