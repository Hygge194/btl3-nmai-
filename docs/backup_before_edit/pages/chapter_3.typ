= MÔ HÌNH HÓA BÀI TOÁN (PROBLEM FORMULATION)

== Phân tích yêu cầu bài toán

Theo đặc tả của Homework 3 thuộc môn Nhập môn Trí tuệ nhân tạo (CO3061), bài toán đặt ra là xây dựng thời khóa biểu giảng dạy trong một tuần cho 60 môn học, với mỗi môn học được chia thành 8 lớp học phần. Mỗi lớp học phần có đúng 2 buổi học mỗi tuần, được bố trí vào hai ngày khác nhau và không liền kề.

Hệ thống cần thực hiện đồng thời việc phân công giảng viên, lựa chọn phòng học và xác định khung thời gian phù hợp cho toàn bộ 480 lớp học phần, tương ứng với 960 buổi học trong tuần.

Bài toán bao gồm hai nhóm yêu cầu chính:

- *Yêu cầu về tính khả thi:* Đảm bảo thời khóa biểu thỏa mãn các điều kiện bắt buộc liên quan đến kích thước phòng học, khoảng cách giữa hai buổi học, định mức giảng dạy, trạng thái khả dụng của phòng và các xung đột tài nguyên.

- *Yêu cầu về chất lượng nghiệm:* Hạn chế khoảng trống trong lịch giảng viên, giảm mức độ phân tán lịch giảng dạy, ưu tiên bố trí các buổi học trong cùng một buổi sáng hoặc chiều và nâng cao mức độ phù hợp giữa kích thước phòng học với quy mô lớp.

Ngoài các yêu cầu chính, nhóm xem xét thêm các tiêu chí mở rộng liên quan đến sở thích môn học và khả năng đảm nhận môn học của giảng viên.

Do số lượng buổi học lớn so với tổng số vị trí phòng học khả dụng, bài toán có mức độ cạnh tranh tài nguyên cao. Vì vậy, quá trình mô hình hóa cần biểu diễn chính xác các biến quyết định, miền giá trị và hệ thống ràng buộc, đồng thời xác định hàm mục tiêu phù hợp để định hướng quá trình tối ưu hóa.


== Định nghĩa các tập dữ liệu và tham số

Để xây dựng mô hình toán học, các đối tượng của bài toán được biểu diễn dưới dạng những tập hợp hữu hạn. Các phần tử được đánh chỉ số bắt đầu từ 0 nhằm thống nhất với cách tổ chức dữ liệu trong chương trình.


=== Tập môn học (Courses)

Gọi $cal(C)$ là tập hợp toàn bộ các môn học cần được xếp lịch:

$ cal(C) = {c_0, c_1, dots, c_59} $

Trong đó:

- $|cal(C)| = 60$ là tổng số môn học.
- $c_i$ là môn học thứ $i$, với $i in {0, 1, dots, 59}$.

Trong hệ thống, các môn học được định danh từ `c01` đến `c60`.

Mỗi môn học có đúng 8 lớp học phần và tổng cộng 16 buổi học mỗi tuần.


=== Tập lớp học (Sections)

Gọi $cal(S)$ là tập hợp toàn bộ các lớp học phần:

$ cal(S) = {s_0, s_1, dots, s_479} $

Tổng số lớp học phần được xác định như sau:

$ |cal(S)| = 60 times 8 = 480 $

Mỗi lớp học phần $s in cal(S)$ được liên kết với một môn học thông qua ánh xạ:

$ c: cal(S) arrow.r cal(C) $

Trong đó, $c(s)$ là môn học tương ứng với lớp học phần $s$.

Mỗi lớp học phần có một tham số kích thước đăng ký:

$ "size"_"sec"(s) in {0, 1, 2} $

Các giá trị được quy ước như sau:

- 0: Lớp có quy mô nhỏ.
- 1: Lớp có quy mô trung bình.
- 2: Lớp có quy mô lớn.

Tham số này được sử dụng để xác định mức độ tương thích giữa lớp học phần và phòng học trong quá trình phân bổ tài nguyên.


=== Tập buổi học (Sessions)

Mỗi lớp học phần $s in cal(S)$ có đúng hai buổi học trong tuần.

Gọi $cal(K)$ là tập chỉ số buổi học của mỗi lớp:

$ cal(K) = {1, 2} $

Tập hợp toàn bộ các buổi học cần được phân bổ được biểu diễn như sau:

$ cal(U) = {(s,k) | s in cal(S), k in cal(K)} $

Tổng số buổi học là:

$ N_"sess" = |cal(U)| = |cal(S)| times |cal(K)| $

$ N_"sess" = 480 times 2 = 960 $

Mỗi buổi học chiếm đúng một ca học và cần được gán một ngày học, một ca học và một phòng học phù hợp.


=== Tập giảng viên (Professors)

Gọi $cal(P)$ là tập hợp các giảng viên tham gia giảng dạy:

$ cal(P) = {p_0, p_1, dots, p_59} $

Trong đó, $|cal(P)| = 60$.

Các giảng viên được định danh từ `p01` đến `p60`.

Theo yêu cầu đề bài, mỗi giảng viên được phân công tối đa:

$ L_"max" = 20 $

buổi học mỗi tuần.

Với giả định một giảng viên phụ trách cả hai buổi học của cùng một lớp học phần, số lớp tối đa mà một giảng viên có thể đảm nhận là:

$ L_"section"^"max" = L_"max" / 2 = 10 $

Để mô hình hóa các yêu cầu mở rộng, nhóm định nghĩa thêm hai tập môn học đối với mỗi giảng viên $p in cal(P)$:

- $E_p subset.eq cal(C)$: Tập các môn học mà giảng viên có khả năng đảm nhận (_Eligible Courses_).

- $F_p subset.eq E_p$: Tập ba môn học yêu thích nhất của giảng viên (_Favorite Courses_).

Trong bộ dữ liệu thực nghiệm, nhóm giả định:

$ |E_p| = 6, quad |F_p| = 3 $

Danh sách môn có thể đảm nhận và danh sách môn yêu thích được sử dụng để đánh giá mức độ phù hợp của việc phân công giảng viên.

Việc mở rộng thành hai danh sách riêng biệt là giả định mô hình hóa của nhóm, nhằm phân biệt khả năng chuyên môn và nguyện vọng giảng dạy của mỗi giảng viên.


=== Tập phòng học (Rooms)

Gọi $cal(R)$ là tập hợp các phòng học:

$ cal(R) = {r_0, r_1, dots, r_34} $

Trong đó:

$ |cal(R)| = 35 $

Các phòng học được định danh từ `rm01` đến `rm35`.

Mỗi phòng học $r in cal(R)$ có một tham số kích thước:

$ "size"_"rm"(r) in {0, 1, 2} $

Tương ứng với ba loại phòng học: nhỏ, trung bình và lớn.

Bên cạnh kích thước, trạng thái khả dụng của phòng học được biểu diễn bằng tham số nhị phân:

$ A_(d,t,r) in {0, 1} $

Trong đó:

- $A_(d,t,r) = 1$: Phòng $r$ khả dụng tại ngày $d$ và ca học $t$.
- $A_(d,t,r) = 0$: Phòng $r$ không khả dụng tại ngày $d$ và ca học $t$.

Trong bộ dữ liệu thực nghiệm, trạng thái không khả dụng có thể được sử dụng để mô phỏng các trường hợp phòng học đang được bảo trì hoặc không thể sử dụng vì những lý do khác.


=== Tập ngày học và khung giờ (Timeslots)

Thời khóa biểu được xây dựng trong phạm vi một tuần gồm 5 ngày học, từ thứ Hai đến thứ Sáu.

Tập ngày học được định nghĩa như sau:

$ cal(D) = {0, 1, 2, 3, 4} $

Mỗi ngày có 6 ca học:

$ cal(T) = {0, 1, 2, 3, 4, 5} $

Trong đó, các chỉ số từ 0 đến 5 tương ứng với ca 1 đến ca 6.

Để mô hình hóa các ràng buộc liên quan đến buổi học, nhóm quy ước mỗi ngày được chia thành hai buổi:

$ cal(T)_M = {0, 1, 2} $

$ cal(T)_A = {3, 4, 5} $

Trong đó:

- $cal(T)_M$: Tập các ca thuộc buổi sáng, từ ca 1 đến ca 3.
- $cal(T)_A$: Tập các ca thuộc buổi chiều, từ ca 4 đến ca 6.

Hai tập này thỏa mãn:

$ cal(T)_M inter cal(T)_A = emptyset $

$ cal(T)_M union cal(T)_A = cal(T) $

Tổng số khung thời gian trong một tuần là:

$ |cal(D)| times |cal(T)| = 5 times 6 = 30 $


== Biến quyết định và miền giá trị

Với mỗi lớp học phần $s in cal(S)$, nhóm định nghĩa một bộ gồm bảy biến quyết định biểu diễn thông tin phân bổ giảng viên, ngày học, ca học và phòng học:

$ x_s = (p_s, d_(s,1), t_(s,1), r_(s,1),
d_(s,2), t_(s,2), r_(s,2)) $

Trong đó:

- $p_s in cal(P)$: Giảng viên phụ trách lớp học phần $s$.
- $d_(s,k) in cal(D)$: Ngày học của buổi thứ $k$.
- $t_(s,k) in cal(T)$: Ca học của buổi thứ $k$.
- $r_(s,k) in cal(R)$: Phòng học của buổi thứ $k$.
- $k in cal(K)$: Chỉ số buổi học.

Một giảng viên được giả định phụ trách cả hai buổi học của cùng một lớp học phần.

Mỗi nghiệm ứng viên hoàn chỉnh của bài toán được biểu diễn dưới dạng:

$ x = (x_(s_0), x_(s_1), dots, x_(s_479)) $

Do mỗi lớp học phần được biểu diễn bằng bảy biến quyết định, tổng số thành phần quyết định của một thời khóa biểu là:

$ N_"var" = 480 times 7 = 3360 $

Gọi $Omega$ là không gian chứa toàn bộ các nghiệm ứng viên có thể được biểu diễn.

Tập nghiệm khả thi được xác định bởi:

$ cal(F) = {x in Omega | H_i(x) = 0,
forall i in {1, 2, dots, 7}} $

Trong đó, $H_i(x)$ là mức độ vi phạm ràng buộc cứng thứ $i$.

Mục tiêu của hệ thống là tìm kiếm một nghiệm thuộc $cal(F)$ có chất lượng tốt nhất có thể theo các tiêu chí đánh giá đã được xác định.

Việc lựa chọn lớp học phần làm đơn vị biểu diễn nghiệm xuất phát từ mối liên hệ chặt chẽ giữa hai buổi học thuộc cùng một lớp. Hai buổi học này không độc lập hoàn toàn mà phải sử dụng chung giảng viên phụ trách và thỏa mãn ràng buộc về khoảng cách ngày học.

Nếu sử dụng phương pháp biểu diễn theo từng buổi học (_Session-based Representation_), một nhiễm sắc thể sẽ bao gồm 960 gen. Khi thực hiện các toán tử lai ghép và đột biến, việc thay đổi độc lập từng buổi học có thể làm mất tính nhất quán trong phân công giảng viên hoặc tạo ra các vi phạm về khoảng cách ngày học giữa hai buổi của cùng một lớp.

Vì vậy, nhóm lựa chọn phương pháp biểu diễn theo lớp học phần (_Section-based Representation_), trong đó mỗi gen chứa đầy đủ thông tin của một lớp và hai buổi học tương ứng. Cách biểu diễn này giúp giảm số lượng gen trong nhiễm sắc thể từ 960 xuống còn 480, đồng thời duy trì tính toàn vẹn cấu trúc của từng lớp học phần. Khi thực hiện lai ghép, việc trao đổi nguyên vẹn một gen cho phép bảo toàn thông tin giảng viên và mối quan hệ giữa hai buổi học.

Tuy nhiên, việc giảm số lượng gen không đồng nghĩa với việc giảm một nửa kích thước không gian tìm kiếm, do mỗi gen chứa nhiều thành phần quyết định hơn. Lợi ích chính của phương pháp nằm ở khả năng đóng gói các biến có liên hệ chặt chẽ trong cùng một cấu trúc, từ đó hỗ trợ thiết kế toán tử di truyền và kiểm tra ràng buộc hiệu quả hơn.

#figure(
  table(
    columns: (1.2fr, 1.8fr, 1.8fr),
    align: (left, left, left),
    table.header([*Tiêu chí*], [*Session-based Representation*], [*Section-based Representation*]),
    [Đơn vị biểu diễn], [Từng buổi học riêng lẻ], [Từng lớp học phần (gồm 2 buổi học)],
    [Số lượng gen], [960 gen (Lớp 1 -- Buổi 1, Lớp 1 -- Buổi 2, ...)], [480 gen (mỗi gen chứa $p_s$ và cả hai bộ $(d, t, r)$)],
    [Tính nhất quán], [Dễ mất đồng bộ giảng viên và khoảng cách ngày khi lai ghép], [Bảo toàn giảng viên chung và cấu trúc cặp buổi học của lớp],
    [Tác động đến GA], [Cần thêm bước đồng bộ hoặc sửa lỗi phân công giảng viên], [Toán tử lai ghép/đột biến thao tác tự nhiên trên từng lớp học phần],
  ),
  caption: [So sánh phương pháp biểu diễn theo buổi học và theo lớp học phần]
) <tab:bieu-dien-gen>


== Mô hình hóa ràng buộc cứng (Hard Constraints)

Ràng buộc cứng là những điều kiện bắt buộc phải được thỏa mãn để thời khóa biểu có thể sử dụng trong thực tế.

Theo đặc tả Homework 3, bài toán gồm sáu yêu cầu bắt buộc. Trong đó, yêu cầu liên quan đến giảng viên bao hàm đồng thời hai khía cạnh khác nhau về mặt toán học: không được dạy hai lớp tại cùng một thời điểm và không được giảng dạy quá số lớp quy định trong một tuần.

Nếu gộp hai điều kiện này vào cùng một hàm phạt, việc theo dõi nguyên nhân vi phạm trong quá trình tối ưu hóa sẽ trở nên khó khăn. Do đó, nhóm tách yêu cầu này thành hai ràng buộc riêng biệt là $H_3$ (trùng lịch giảng viên theo khung giờ) và $H_4$ (giới hạn khối lượng giảng dạy tối đa trong tuần), dẫn đến mô hình gồm bảy hàm kiểm tra ràng buộc cứng từ $H_1$ đến $H_7$. Cách tách này giúp hàm đánh giá phản ánh chính xác bản chất từng lỗi và hỗ trợ thiết kế cơ chế sửa chữa nghiệm có định hướng ở Chương 4.

Đặt $II[Phi]$ là hàm chỉ thị (_Indicator Function_), được định nghĩa như sau:

$ II[Phi] = cases(
  1 & "nếu mệnh đề đúng",
  0 & "nếu mệnh đề sai"
) $

Tổng số vi phạm ràng buộc cứng của nghiệm $x$ được xác định bởi:

$ H(x) = sum_(i=1)^7 H_i(x) $

Một nghiệm được xem là khả thi khi và chỉ khi:

$ H(x) = 0 $

Do tất cả các thành phần $H_i(x)$ đều không âm, điều kiện trên tương đương với việc từng ràng buộc cứng đều được thỏa mãn.


=== Ràng buộc kích thước phòng học ($H_1$)

Mỗi buổi học phải được bố trí vào phòng có kích thước không nhỏ hơn quy mô đăng ký của lớp học phần.

Theo đề bài:

- Phòng kích thước 0 chỉ có thể phục vụ lớp kích thước 0.
- Phòng kích thước 1 có thể phục vụ lớp kích thước 0 hoặc 1.
- Phòng kích thước 2 có thể phục vụ lớp thuộc cả ba mức kích thước.

Điều kiện hợp lệ được biểu diễn như sau:

$ "size"_"rm"(r_(s,k)) >= "size"_"sec"(s) $

Mức độ vi phạm được xác định bởi:

$ H_1(x) =
sum_(s in cal(S)) sum_(k in cal(K))
II["size"_"rm"(r_(s,k)) < "size"_"sec"(s)] $

Mỗi buổi học được phân vào phòng có kích thước không phù hợp làm tăng giá trị $H_1$ thêm một đơn vị.

Ràng buộc được thỏa mãn khi:

$ H_1(x) = 0 $


=== Ràng buộc khoảng cách giữa hai buổi học ($H_2$)

Hai buổi học của cùng một lớp học phần không được diễn ra trong cùng một ngày hoặc trong hai ngày liền kề.

Điều kiện hợp lệ là:

$ |d_(s,1) - d_(s,2)| >= 2 $

Mức độ vi phạm được xác định bởi:

$ H_2(x) =
sum_(s in cal(S))
II[|d_(s,1) - d_(s,2)| < 2] $

Ràng buộc được thỏa mãn khi:

$ H_2(x) = 0 $

Nếu hai buổi học được sắp xếp theo thứ tự ngày tăng dần, tập các cặp ngày hợp lệ trong tuần gồm:

$ Pi_"valid" = {
(0,2), (0,3), (0,4),
(1,3), (1,4), (2,4)
} $

Như vậy, mỗi lớp học phần có sáu phương án lựa chọn cặp ngày hợp lệ.

Việc sử dụng tập cặp ngày hợp lệ ngay từ giai đoạn khởi tạo và đột biến giúp thu hẹp không gian tìm kiếm, đồng thời hạn chế khả năng phát sinh vi phạm $H_2$.


=== Ràng buộc trùng lịch giảng viên ($H_3$)

Một giảng viên không thể phụ trách nhiều hơn một buổi học tại cùng một thời điểm.

Đặt $N_p(d,t)$ là số buổi học được phân công cho giảng viên $p$ tại ngày $d$ và ca học $t$:

$ N_p(d,t) =
sum_(s in cal(S)) sum_(k in cal(K))
II[p_s = p and d_(s,k) = d and t_(s,k) = t] $

Điều kiện hợp lệ là:

$ N_p(d,t) <= 1 $

với mọi $p in cal(P)$, $d in cal(D)$ và $t in cal(T)$.

Mức độ vi phạm được xác định bởi:

$ H_3(x) =
sum_(p in cal(P))
sum_(d in cal(D))
sum_(t in cal(T))
max(0, N_p(d,t) - 1) $

Cách tính trên xác định số lượng buổi học vượt quá khả năng đảm nhận đồng thời của mỗi giảng viên.

Ràng buộc được thỏa mãn khi:

$ H_3(x) = 0 $


=== Ràng buộc khối lượng giảng dạy ($H_4$)

Theo yêu cầu đề bài, mỗi giảng viên được phân công tối đa 20 buổi học trong một tuần.

Tổng số buổi giảng dạy của giảng viên $p$ được xác định bởi:

$ L_p =
sum_(d in cal(D))
sum_(t in cal(T))
N_p(d,t) $

Điều kiện hợp lệ là:

$ L_p <= L_"max" = 20 $

Mức độ vi phạm được xác định bởi:

$ H_4(x) =
sum_(p in cal(P))
max(0, L_p - L_"max") $

Giá trị $H_4$ phản ánh tổng số buổi giảng dạy vượt quá định mức cho phép của các giảng viên.

Ràng buộc được thỏa mãn khi:

$ H_4(x) = 0 $


=== Ràng buộc phòng học khả dụng ($H_5$)

Mỗi buổi học chỉ được phân bổ vào phòng học đang khả dụng tại thời điểm tương ứng.

Điều kiện hợp lệ là:

$ A_(d_(s,k), t_(s,k), r_(s,k)) = 1 $

Mức độ vi phạm được xác định bởi:

$ H_5(x) =
sum_(s in cal(S))
sum_(k in cal(K))
II[A_(d_(s,k), t_(s,k), r_(s,k)) = 0] $

Mỗi buổi học được bố trí vào một vị trí phòng không khả dụng làm tăng giá trị $H_5$ thêm một đơn vị.

Ràng buộc được thỏa mãn khi:

$ H_5(x) = 0 $


=== Ràng buộc trùng lịch của lớp ($H_6$)

Một lớp học phần không thể tham gia đồng thời hai buổi học tại cùng một thời điểm.

Mức độ vi phạm được xác định bởi:

$ H_6(x) =
sum_(s in cal(S))
II[d_(s,1) = d_(s,2)
and t_(s,1) = t_(s,2)] $

Ràng buộc được thỏa mãn khi:

$ H_6(x) = 0 $

Về mặt toán học, khi ràng buộc khoảng cách ngày học $H_2(x) = 0$ được thỏa mãn, hai buổi học của cùng một lớp chắc chắn diễn ra vào hai ngày khác nhau, suy ra chúng không thể trùng nhau về mặt thời gian:

$ H_2(x) = 0 arrow.r.double H_6(x) = 0 $

Tuy nhiên, nhóm vẫn giữ thành phần $H_6$ trong mô hình vì ba lý do: (i) đảm bảo ánh xạ đầy đủ 1--1 với các yêu cầu của đề bài gốc, (ii) hỗ trợ kiểm thử đơn vị (unit testing) cho các nghiệm chưa hợp lệ hoặc dữ liệu đầu vào bất thường, và (iii) tách biệt rõ lỗi khoảng cách ngày học và lỗi trùng giờ học khi chẩn đoán chất lượng nghiệm. Về mặt tính toán, việc giữ $H_6$ không làm sai lệch hàm mục tiêu đối với nghiệm khả thi do $H_6(x) = 0$ khi $H_2(x) = 0$.


=== Ràng buộc trùng lịch phòng học ($H_7$)

Một phòng học chỉ có thể phục vụ tối đa một buổi học tại cùng một thời điểm.

Đặt $M(d,t,r)$ là số buổi học được phân bổ vào phòng $r$ tại ngày $d$ và ca học $t$:

$ M(d,t,r) =
sum_(s in cal(S))
sum_(k in cal(K))
II[d_(s,k) = d and t_(s,k) = t
and r_(s,k) = r] $

Điều kiện hợp lệ là:

$ M(d,t,r) <= 1 $

Mức độ vi phạm được xác định bởi:

$ H_7(x) =
sum_(d in cal(D))
sum_(t in cal(T))
sum_(r in cal(R))
max(0, M(d,t,r) - 1) $

Giá trị $H_7$ phản ánh tổng số buổi học được bố trí vượt quá khả năng sử dụng đồng thời của các phòng học.

Ràng buộc được thỏa mãn khi:

$ H_7(x) = 0 $


== Mô hình hóa ràng buộc mềm (Soft Constraints)

Ràng buộc mềm được sử dụng để đánh giá chất lượng của các phương án thời khóa biểu. Khác với ràng buộc cứng, việc vi phạm ràng buộc mềm không làm mất tính khả thi của nghiệm.

Theo đề bài, có bốn nhóm yêu cầu về chất lượng thời khóa biểu. Tuy nhiên, yêu cầu hạn chế lịch giảng dạy phân tán của giảng viên tác động ở hai cấp độ thời gian khác nhau: sự xuất hiện các khoảng trống giữa các ca dạy trong cùng một ngày và sự kéo dài số ngày có tiết dạy trong tuần.

Do đó, nhóm phân tách tiêu chí này thành hai thành phần độc lập là $S_1$ (khoảng trống trong ngày) và $S_2$ (số ngày giảng dạy trong tuần), tạo thành hệ năm thành phần đánh giá ràng buộc mềm ký hiệu từ $S_1$ đến $S_5$. Cách phân tách này cho phép gán trọng số riêng cho từng loại phân tán lịch và đo lường chính xác hơn mức độ thuận tiện cho giảng viên.

Tổng mức phạt ràng buộc mềm được xác định bởi:

$ S(x) = sum_(j=1)^5 w_j S_j(x) $

Trong đó, $w_j > 0$ là trọng số thể hiện mức độ ưu tiên của ràng buộc mềm thứ $j$.

Mục tiêu của quá trình tối ưu hóa là giảm giá trị $S(x)$ trong khi vẫn đảm bảo tính khả thi của thời khóa biểu.


=== Tối ưu khoảng trống trong lịch giảng viên ($S_1$)

Lịch giảng dạy của mỗi giảng viên nên được bố trí tập trung, hạn chế các ca trống giữa những ca có giờ dạy trong cùng một ngày.

Gọi $T_(p,d)$ là tập các ca học mà giảng viên $p$ được phân công giảng dạy trong ngày $d$:

$ T_(p,d) = {t in cal(T) | N_p(d,t) > 0} $

Đối với một ngày có ít nhất hai ca dạy, số ca trống nằm giữa ca đầu tiên và ca cuối cùng được xác định bởi:

$ G_(p,d) =
max(T_(p,d)) - min(T_(p,d)) + 1
- |T_(p,d)| $

Mức độ vi phạm của toàn bộ thời khóa biểu được xác định bởi:

$ S_1(x) =
sum_(p in cal(P))
sum_(d in cal(D): |T_(p,d)| >= 2)
G_(p,d) $

Ví dụ, nếu một giảng viên dạy ở ca 1 và ca 6 trong cùng một ngày, giữa hai ca dạy tồn tại bốn ca trống. Khi đó, mức phạt tương ứng bằng 4.

Việc tối thiểu hóa $S_1$ giúp giảm thời gian chờ và nâng cao mức độ tập trung của lịch giảng dạy trong ngày.


=== Hạn chế lịch giảng dạy rải rác trong tuần ($S_2$)

Bên cạnh khoảng trống giữa các ca học trong ngày, lịch giảng dạy cũng nên hạn chế những ngày trống xen kẽ giữa các ngày có giờ dạy.

Gọi $D_p$ là tập các ngày mà giảng viên $p$ có ít nhất một buổi giảng dạy:

$ D_p = {d in cal(D) | |T_(p,d)| > 0} $

Đối với giảng viên có lịch dạy trong ít nhất hai ngày, số ngày trống nằm giữa ngày dạy đầu tiên và ngày dạy cuối cùng được xác định bởi:

$ G_p = max(D_p) - min(D_p) + 1 - |D_p| $

Mức độ vi phạm được xác định bởi:

$ S_2(x) =
sum_(p in cal(P): |D_p| >= 2)
G_p $

Ví dụ, một giảng viên chỉ dạy vào thứ Hai và thứ Sáu sẽ có ba ngày trống xen giữa. Khi đó, mức phạt tương ứng bằng 3.

Ràng buộc này hướng đến việc giảm khoảng trống giữa các ngày giảng dạy, nhưng không trực tiếp tối thiểu hóa tổng số ngày làm việc của mỗi giảng viên.


=== Tối ưu buổi dạy của giảng viên ($S_3$)

Theo đề bài, lịch giảng dạy của mỗi giảng viên nên được tập trung vào buổi sáng hoặc buổi chiều trong cùng một ngày.

Một ngày được xem là vi phạm nếu giảng viên có ít nhất một ca dạy vào buổi sáng và ít nhất một ca dạy vào buổi chiều.

Mức độ vi phạm được xác định bởi:

$ S_3(x) =
sum_(p in cal(P))
sum_(d in cal(D))
II[(T_(p,d) inter cal(T)_M != emptyset)
and
(T_(p,d) inter cal(T)_A != emptyset)] $

Mỗi cặp giảng viên và ngày học có lịch dạy ở cả hai buổi làm tăng giá trị $S_3$ thêm một đơn vị.

Việc tối thiểu hóa $S_3$ giúp hạn chế các ngày giảng viên phải phân bố thời gian giảng dạy trên cả buổi sáng và buổi chiều.


=== Tối ưu buổi học của môn học ($S_4$)

Các buổi học thuộc cùng một môn nên được bố trí tập trung vào buổi sáng hoặc buổi chiều.

Mỗi môn học $c in cal(C)$ có 8 lớp học phần, tương ứng với 16 buổi học mỗi tuần.

Gọi $m_c$ là số buổi học của môn $c$ được bố trí vào buổi sáng:

$ m_c =
sum_(s in cal(S): c(s) = c)
sum_(k in cal(K))
II[t_(s,k) in cal(T)_M] $

Số buổi học vào buổi chiều của môn $c$ được xác định bởi:

$ a_c = 16 - m_c $

Mức độ phân tán giữa hai buổi được đánh giá thông qua số buổi học thuộc nhóm thiểu số:

$ S_4(x) =
sum_(c in cal(C))
min(m_c, 16 - m_c) $

Ví dụ, nếu một môn có 12 buổi học vào buổi sáng và 4 buổi học vào buổi chiều, mức phạt tương ứng của môn đó bằng 4.

Giá trị $S_4$ càng nhỏ thể hiện mức độ tập trung của các buổi học thuộc cùng một môn càng cao.


=== Tối ưu kích thước phòng học ($S_5$)

Bên cạnh việc đảm bảo phòng học có kích thước đủ lớn theo ràng buộc $H_1$, hệ thống cần hạn chế việc sử dụng phòng có kích thước lớn hơn mức cần thiết.

Mức độ lãng phí kích thước được xác định bằng chênh lệch không âm giữa kích thước phòng và quy mô lớp:

$ S_5(x) =
sum_(s in cal(S))
sum_(k in cal(K))
max(0,
"size"_"rm"(r_(s,k)) -
"size"_"sec"(s)) $

Trong đó:

- Lớp và phòng cùng kích thước: mức phạt bằng 0.
- Phòng lớn hơn lớp một mức: mức phạt bằng 1.
- Phòng lớn hơn lớp hai mức: mức phạt bằng 2.

Trường hợp phòng nhỏ hơn quy mô lớp được xử lý bởi ràng buộc cứng $H_1$.

Việc tối thiểu hóa $S_5$ giúp nâng cao mức độ phù hợp giữa nhu cầu sử dụng và kích thước phòng học.


== Ràng buộc mở rộng (Bonus Constraints)

Bên cạnh các yêu cầu chính, đề bài đưa ra các tiêu chí mở rộng liên quan đến việc phân công môn học theo sở thích của giảng viên.

Trong mô hình đề xuất, nhóm sử dụng ba thành phần đánh giá $B_(1a)$, $B_(1b)$ và $B_2$ nhằm phân biệt mức độ đáp ứng nguyện vọng giảng dạy và khả năng đảm nhận môn học.


=== Mức độ đáp ứng môn học yêu thích ($B_(1a)$)

Theo yêu cầu Bonus 1, mỗi giảng viên nên được phân công ít nhất một lớp học phần thuộc danh sách ba môn học yêu thích.

Gọi $Q_p$ là số lớp học phần thuộc danh sách môn yêu thích được phân công cho giảng viên $p$:

$ Q_p =
sum_(s in cal(S))
II[p_s = p and c(s) in F_p] $

Số giảng viên chưa được phân công bất kỳ lớp học phần yêu thích nào được xác định bởi:

$ B_(1a)(x) =
sum_(p in cal(P))
II[Q_p = 0] $

Mục tiêu của thành phần này là:

$ B_(1a)(x) = 0 $

Khi điều kiện trên được thỏa mãn, toàn bộ 60 giảng viên đều được phân công ít nhất một lớp thuộc danh sách môn học yêu thích.


=== Tối ưu số lớp thuộc môn học yêu thích ($B_(1b)$)

Ngoài việc đảm bảo mỗi giảng viên có ít nhất một lớp yêu thích, nhóm bổ sung tiêu chí tối thiểu hóa tổng số lớp được phân công ngoài danh sách Top-3.

Mức độ vi phạm được xác định bởi:

$ B_(1b)(x) =
sum_(s in cal(S))
II[c(s) in.not F_(p_s)] $

Tỷ lệ lớp học phần được phân công đúng môn yêu thích được xác định bởi:

$ R_"favorite"(x) =
(|cal(S)| - B_(1b)(x)) / |cal(S)| times 100% $

Giá trị $B_(1b)$ càng nhỏ thể hiện mức độ đáp ứng sở thích giảng dạy càng cao.

Thành phần này là tiêu chí tối ưu bổ sung do nhóm đề xuất, đồng thời có thể được sử dụng để đánh giá mức độ đáp ứng Bonus 2 nếu danh sách được đề cập trong yêu cầu đó được hiểu là danh sách Top-3 môn yêu thích.


=== Mức độ phù hợp về khả năng giảng dạy ($B_2$)

Trong mô hình mở rộng, mỗi giảng viên được giả định có một tập môn học có khả năng đảm nhận $E_p$, trong đó bao gồm ba môn học yêu thích nhất $F_p$.

Mức độ phân công không phù hợp với danh sách môn có thể đảm nhận được xác định bởi:

$ B_2(x) =
sum_(s in cal(S))
II[c(s) in.not E_(p_s)] $

Mục tiêu của thành phần này là:

$ B_2(x) = 0 $

Việc tách biệt tập môn có thể đảm nhận $E_p$ (6 môn) và tập môn yêu thích $F_p$ (3 môn) xuất phát từ tính chất cấu trúc của bài toán. Theo giả thiết dữ liệu, mỗi giảng viên có tối đa 8 lớp có thể phụ trách trong tuần, nhưng nếu chỉ giới hạn ở 3 môn yêu thích thì không gian phân công sẽ bị thu hẹp quá mức và dễ gây bế tắc về năng lực giảng dạy ở một số môn học. Vì vậy, $E_p$ đóng vai trò miền chuyên môn hợp lệ để đảm bảo tính khả thi của việc phân công, còn $F_p$ đại diện cho mức độ ưu tiên chuyên sâu cần tối đa hóa.

Đây là giả định mở rộng có chủ đích của nhóm, tạo nên quan hệ phân cấp $cal(C) supset.eq E_p supset.eq F_p$. Nếu yêu cầu Bonus 2 trong đề bài được hiểu theo nghĩa chặt hơn là giảng viên chỉ được dạy các môn thuộc danh sách Top-3, điều kiện tương ứng phải là $B_(1b)(x) = 0$. Do đó, hệ thống báo cáo riêng biệt hai chỉ số là số lớp ngoài danh sách $E_p$ ($B_2$) và số lớp ngoài danh sách $F_p$ ($B_(1b)$) nhằm tránh đồng nhất hai khái niệm này khi đánh giá nghiệm.

#figure(
  table(
    columns: (1.2fr, 1.3fr, 1.8fr, 1.5fr),
    align: (left, center, left, left),
    table.header([*Tập môn học*], [*Số lượng*], [*Ý nghĩa trong mô hình*], [*Ràng buộc tương ứng*]),
    [$F_p$ (Favorite)], [3 môn / GV], [Môn giảng viên ưu tiên nhất (Top-3)], [Bonus 1: $B_(1a), B_(1b)$],
    [$E_p$ (Eligible)], [6 môn / GV ($F_p subset.eq E_p$)], [Môn giảng viên đủ chuyên môn đảm nhận], [Bonus 2: $B_2(x) = 0$],
    [$cal(C) without E_p$], [54 môn còn lại], [Môn ngoài chuyên môn, cần loại bỏ hoàn toàn], [Phạt nặng qua $B_2(x)$],
  ),
  caption: [Phân cấp tập môn học yêu thích ($F_p$) và tập môn học có thể đảm nhận ($E_p$)]
) <tab:phan-cap-ep-fp>


== Hàm mục tiêu tối ưu hóa

Bài toán xếp thời khóa biểu được mô hình hóa dưới dạng bài toán tối ưu có ràng buộc, trong đó tính khả thi của nghiệm được ưu tiên trước chất lượng của các tiêu chí mềm và mở rộng.

Tổng số vi phạm ràng buộc cứng được xác định bởi:

$ H(x) = sum_(i=1)^7 H_i(x) $

Tổng mức phạt ràng buộc mềm được xác định bởi:

$ S(x) = sum_(j=1)^5 w_j S_j(x) $

Tổng mức phạt của các tiêu chí mở rộng được xác định bởi:

$ B(x) =
w_(B_(1a)) B_(1a)(x)
+ w_(B_(1b)) B_(1b)(x)
+ w_(B_2) B_2(x) $

Trong đó, các trọng số có giá trị dương và phản ánh mức độ ưu tiên của từng tiêu chí đánh giá.

Bài toán tối ưu có ràng buộc được biểu diễn như sau:

$ min_(x in Omega) [S(x) + B(x)] $

với điều kiện:

$ H(x) = 0 $

Để đánh giá các nghiệm ứng viên trong quá trình tiến hóa, nhóm sử dụng hàm phạt tổng hợp:

$ P(x) = W_H H(x) + S(x) + B(x) $

Trong đó, $W_H$ là trọng số phạt dành cho các vi phạm ràng buộc cứng.

Hàm thích nghi được xác định bởi:

$ F(x) = frac(1, 1 + P(x)) $

Do $P(x) >= 0$, hàm thích nghi có miền giá trị:

$ F(x) in (0, 1] $

Khi tổng mức phạt giảm, giá trị hàm thích nghi tăng. Do đó, việc tối đa hóa $F(x)$ tương đương với việc tối thiểu hóa $P(x)$.

Tuy nhiên, việc chỉ sử dụng một hàm tổng phạt cộng dồn $P(x)$ với trọng số lớn $W_H$ vẫn tồn tại rủi ro về mặt số học: một nghiệm không khả thi có một vi phạm cứng nhưng ít vi phạm mềm có thể đạt tổng mức phạt nhỏ hơn hoặc xấp xỉ một nghiệm khả thi có nhiều vi phạm mềm, dẫn đến sai lệch thứ tự ưu tiên trong chọn lọc. Để triệt tiêu hoàn toàn rủi ro này, nhóm kết hợp cơ chế xếp hạng theo thứ tự từ điển (_Feasibility-first Ranking_):

$ R(x) = (H(x), P(x)) $

Hai nghiệm được so sánh theo nguyên tắc:

+ Nghiệm có tổng số vi phạm ràng buộc cứng $H(x)$ thấp hơn luôn được ưu tiên, bất kể giá trị $P(x)$.

+ Chỉ khi hai nghiệm có cùng giá trị $H(x)$, nghiệm có tổng mức phạt $P(x)$ thấp hơn mới được ưu tiên.

@tab:so-sanh-ranking minh họa tình huống một nghiệm không khả thi có $P(x)$ thấp hơn nhưng vẫn bị xếp sau nghiệm khả thi nhờ cơ chế xếp hạng $R(x)$.

#figure(
  table(
    columns: (1.2fr, 1.0fr, 1.3fr, 1.4fr, 1.4fr),
    align: (left, center, center, center, left),
    table.header([*Nghiệm*], [*$H(x)$*], [*Phạt mềm + mở rộng*], [*Nếu chỉ xét $P(x)$*], [*Theo xếp hạng $R(x)$*]),
    [Nghiệm A], [0 (Khả thi)], [1.500], [1.500], [*Được ưu tiên* (vì $H = 0$)],
    [Nghiệm B], [1 (Không khả thi)], [400], [$W_H + 400$ (nhạy cảm với $W_H$)], [Bị loại (vì $H = 1 > 0$)],
  ),
  caption: [Minh họa ưu thế của cơ chế xếp hạng Feasibility-first $R(x)$]
) <tab:so-sanh-ranking>

Cần lưu ý rằng thuật toán di truyền là một phương pháp metaheuristic. Do không gian tìm kiếm rất lớn và sự tồn tại của các ngưỡng đánh đổi đa tiêu chí, thuật toán không nhằm chứng minh nghiệm tìm được là tối ưu toàn cục tuyệt đối (global optimum), mà hướng tới việc tìm ra nghiệm khả thi ($H(x) = 0$) có chất lượng tốt nhất có thể trong giới hạn tài nguyên tính toán cho phép.

Các trọng số cụ thể và phương pháp hiện thực hàm thích nghi được trình bày chi tiết tại Chương 4.


== Phân tích không gian tìm kiếm và tính khả thi

Trước khi thiết kế thuật toán tối ưu, việc phân tích không gian tìm kiếm và khả năng đáp ứng của các nguồn tài nguyên là cần thiết nhằm xác định những khó khăn đặc trưng của bài toán.

Các phân tích trong phần này cung cấp những điều kiện cần và cận dưới lý thuyết, đồng thời tạo cơ sở cho việc thiết kế các kỹ thuật cải tiến của giải thuật di truyền.


=== Phân tích kích thước không gian tìm kiếm

Đối với mỗi lớp học phần, xét phương pháp biểu diễn trong đó hai buổi học được sắp xếp theo thứ tự ngày tăng dần và lựa chọn từ tập sáu cặp ngày hợp lệ $Pi_"valid"$.

Số phương án phân bổ tối đa cho một lớp học phần được xác định dựa trên:

- 60 phương án lựa chọn giảng viên.
- 6 phương án lựa chọn cặp ngày học.
- 6 phương án lựa chọn ca học cho mỗi buổi.
- 35 phương án lựa chọn phòng học cho mỗi buổi.

Do đó:

$ N_"gene" =
60 times 6 times (6 times 35)^2 $

$ N_"gene" = 15 876 000 $

Với tổng cộng 480 lớp học phần, kích thước không gian tìm kiếm tương ứng là:

$ |Omega_"pair"| = (15 876 000)^480 $

Lấy logarithm cơ số 10:

$ log_10 |Omega_"pair"|
= 480 log_10(15 876 000)
approx 3456.38 $

Suy ra:

$ |Omega_"pair"| approx 10^(3456.38) $

Đây là kích thước không gian tìm kiếm khi đã giới hạn các cặp ngày hợp lệ và chưa xét đến những ràng buộc còn lại về giảng viên, kích thước phòng, trạng thái khả dụng và xung đột tài nguyên.

Kết quả trên cho thấy số lượng phương án phân bổ có thể rất lớn, tạo ra khó khăn đáng kể đối với các phương pháp tìm kiếm vét cạn.

Do đó, nhóm lựa chọn giải thuật di truyền kết hợp các kỹ thuật khởi tạo có định hướng và sửa chữa nghiệm nhằm tìm kiếm những phương án khả thi có chất lượng tốt trong giới hạn tài nguyên tính toán.


=== Phân tích khả năng đáp ứng tài nguyên phòng học

Tổng số vị trí phòng–ca tối đa về mặt lý thuyết trong một tuần là:

$ C_"room"^"max" =
|cal(R)| times |cal(D)| times |cal(T)| $

$ C_"room"^"max" = 35 times 5 times 6 = 1050 $

Trong khi đó, tổng số buổi học cần phân bổ là:

$ N_"sess" = 960 $

Nếu tất cả các phòng học đều khả dụng, tỷ lệ sử dụng tài nguyên tối thiểu là:

$ U_"room"^"ideal" =
960 / 1050 times 100%
approx 91.43% $

Trong bộ dữ liệu thực nghiệm của nhóm, có 26 vị trí phòng–ca không khả dụng, tương ứng với khoảng 2,48% tổng số vị trí lý thuyết.

Tổng số vị trí phòng–ca thực tế khả dụng là:

$ C_"room" =
sum_(d in cal(D))
sum_(t in cal(T))
sum_(r in cal(R))
A_(d,t,r) $

$ C_"room" = 1050 - 26 = 1024 $

Tỷ lệ sử dụng tài nguyên cần thiết là:

$ U_"room" = 960 / 1024 times 100% = 93.75% $

Số vị trí phòng–ca còn dư sau khi bố trí đầy đủ các buổi học chỉ là:

$ C_"remain" = 1024 - 960 = 64 $

Mức độ sử dụng tài nguyên cao làm giảm số lượng vị trí trống có thể sử dụng để di chuyển hoặc sửa chữa các buổi học bị xung đột.

Tuy nhiên, điều kiện tổng số vị trí phòng–ca lớn hơn hoặc bằng số buổi học chỉ là điều kiện cần, chưa đủ để đảm bảo tồn tại thời khóa biểu khả thi. Các yếu tố như kích thước phòng, phân bố tải theo ngày và xung đột giảng viên vẫn cần được xem xét đồng thời.


=== Phân tích nút thắt phân bố cặp ngày (Day-Pair Bottleneck)

Một đặc điểm quan trọng của bài toán là hai buổi học của mỗi lớp phải diễn ra vào hai ngày không liền kề.

Tập sáu cặp ngày hợp lệ được xác định như sau:

$ Pi_"valid" = {
(0,2), (0,3), (0,4),
(1,3), (1,4), (2,4)
} $

Trong tập này:

- Thứ Hai xuất hiện trong ba cặp ngày.
- Thứ Ba xuất hiện trong hai cặp ngày.
- Thứ Tư xuất hiện trong hai cặp ngày.
- Thứ Năm xuất hiện trong hai cặp ngày.
- Thứ Sáu xuất hiện trong ba cặp ngày.

Nếu phương pháp khởi tạo lựa chọn đồng đều sáu cặp ngày, số lớp kỳ vọng thuộc mỗi cặp là:

$ E[n_(i,j)] = 480 / 6 = 80 $

Do đó, tải kỳ vọng của các ngày được xác định như sau:

$ E[L_0] = E[L_4] = 3 times 80 = 240 $

$ E[L_1] = E[L_2] = E[L_3]
= 2 times 80 = 160 $

Trong khi đó, công suất phòng học tối đa về mặt lý thuyết của mỗi ngày chỉ là:

$ C_"day"^"max" = 35 times 6 = 210 $

Như vậy:

$ E[L_0] = E[L_4] = 240 > 210 $

Kết quả này cho thấy phương pháp lựa chọn đồng đều các cặp ngày tạo ra xu hướng quá tải vào thứ Hai và thứ Sáu, ngay cả khi tất cả các phòng học đều khả dụng.

Để phân bố tải cân bằng hơn, nhóm hướng đến mức tải kỳ vọng:

$ L_"target" = 960 / 5 = 192 $

buổi học mỗi ngày.

Gọi $n_(i,j)$ là số lớp học phần được phân bổ vào cặp ngày $(i,j)$.

Tổng tải trên từng ngày được xác định bởi hệ phương trình:

$ cases(
L_0 = n_(0,2) + n_(0,3) + n_(0,4),
L_1 = n_(1,3) + n_(1,4),
L_2 = n_(0,2) + n_(2,4),
L_3 = n_(0,3) + n_(1,3),
L_4 = n_(0,4) + n_(1,4) + n_(2,4)
) $

Để cân bằng tuyệt đối tải giữa năm ngày, hệ phương trình cần thỏa mãn:

$ L_0 = L_1 = L_2 = L_3 = L_4 = 192 $

Từ hệ phương trình trên, có thể suy ra:

$ n_(0,2) = n_(2,4) = 96 $

$ n_(0,3) = n_(1,4) $

$ n_(0,3) + n_(0,4) = 96 $

$ n_(1,3) - n_(0,4) = 96 $

Đặt:

$ a = n_(0,4), quad 0 <= a <= 96 $

Khi đó, một họ nghiệm cân bằng tải được biểu diễn bởi:

$ cases(
n_(0,2) = 96,
n_(0,3) = 96 - a,
n_(0,4) = a,
n_(1,3) = 96 + a,
n_(1,4) = 96 - a,
n_(2,4) = 96
) $

Với $a$ là số nguyên, họ nghiệm trên mô tả các phương án phân bố số lớp vào sáu cặp ngày sao cho mỗi ngày có đúng 192 buổi học.

Dựa trên cấu trúc này, nhóm thiết kế vector xác suất lựa chọn cặp ngày:

$ q = (0.20, 0.18, 0.02, 0.22, 0.18, 0.20) $

Các thành phần của vector tương ứng với thứ tự các cặp ngày trong $Pi_"valid"$.

Vector xác suất thỏa mãn:

$ sum_(i=1)^6 q_i = 1 $

Xác suất xuất hiện của mỗi ngày trong một cặp ngày được lựa chọn là:

$ cases(
q_1 + q_2 + q_3 = 0.40,
q_4 + q_5 = 0.40,
q_1 + q_6 = 0.40,
q_2 + q_4 = 0.40,
q_3 + q_5 + q_6 = 0.40
) $

Do đó, tải kỳ vọng của mỗi ngày bằng:

$ E[L_d] = 480 times 0.40 = 192 $

với mọi $d in cal(D)$.

Kết quả trên lý giải trực tiếp nguyên nhân phương pháp khởi tạo ngẫu nhiên đồng đều (Random Initialization) dễ thất bại: tải kỳ vọng vào Thứ Hai và Thứ Sáu lên tới 240 buổi/ngày, vượt quá sức chứa tối đa lý thuyết 210 vị trí/ngày của hệ thống phòng học. Việc sử dụng vector xác suất cân bằng $q = (0,20; 0,18; 0,02; 0,22; 0,18; 0,20)$ đưa tải kỳ vọng về mức đồng đều 192 buổi/ngày, giải tỏa nút thắt ở hai ngày đầu và cuối tuần.

#figure(
  table(
    columns: (1.5fr, 1.0fr, 1.0fr, 1.0fr, 1.0fr, 1.0fr),
    align: (left, center, center, center, center, center),
    table.header([*Phương pháp chọn cặp ngày*], [*Thứ 2*], [*Thứ 3*], [*Thứ 4*], [*Thứ 5*], [*Thứ 6*]),
    [Phân bố đồng đều], [240 (Quá tải)], [160], [160], [160], [240 (Quá tải)],
    [Vector cân bằng $q$], [192], [192], [192], [192], [192],
    [Sức chứa tối đa lý thuyết], [210], [210], [210], [210], [210],
  ),
  caption: [So sánh tải buổi học kỳ vọng theo ngày giữa chọn đồng đều và vector cân bằng]
) <tab:tai-ngay-cap-ngay>

Tuy nhiên, việc lấy mẫu ngẫu nhiên theo vector xác suất chỉ đảm bảo cân bằng về mặt kỳ vọng. Tải thực tế của mỗi ngày vẫn có thể dao động và cần được kiểm tra dựa trên số lượng vị trí phòng học khả dụng:

$ C_d =
sum_(t in cal(T))
sum_(r in cal(R))
A_(d,t,r) $

Điều kiện cần về khả năng đáp ứng phòng học tại mỗi ngày là:

$ L_d <= C_d, quad forall d in cal(D) $

Do đó, ở Chương 4, vector xác suất cân bằng $q$ được kết hợp cùng phương pháp khởi tạo tham lam có ngẫu nhiên (_Greedy Randomized Initialization_) nhằm kiểm soát tải thực tế theo ngày ngay từ thế hệ đầu tiên.


=== Phân tích cận dưới của ràng buộc mềm $S_3$

Ràng buộc mềm $S_3$ hướng đến việc hạn chế số ngày mà mỗi giảng viên phải dạy đồng thời cả buổi sáng và buổi chiều.

Giả sử mọi giảng viên chỉ giảng dạy trong một buổi của mỗi ngày. Khi đó, mỗi giảng viên có thể đảm nhận tối đa ba ca học mỗi ngày.

Tổng công suất giảng dạy trong trường hợp này là:

$ C_"single-shift" =
|cal(P)| times |cal(D)| times 3 $

$ C_"single-shift" =
60 times 5 times 3 = 900 $

Tuy nhiên, tổng số buổi học cần phân bổ là:

$ N_"sess" = 960 $

Số buổi học vượt quá công suất trong trường hợp mỗi giảng viên chỉ dạy một buổi mỗi ngày là:

$ Delta_"sess" = 960 - 900 = 60 $

Mỗi trường hợp giảng viên dạy cả buổi sáng và buổi chiều có thể bổ sung tối đa ba ca học so với trường hợp chỉ dạy một buổi.

Do đó, đối với mọi thời khóa biểu khả thi:

$ 960 <= 900 + 3 S_3(x) $

Suy ra:

$ S_3(x) >= ceil((960 - 900) / 3) $

$ S_3(x) >= 20 $

Kết quả trên cho thấy không thể đồng thời bố trí toàn bộ 960 buổi học và thỏa mãn tuyệt đối ràng buộc mềm $S_3$.

Ít nhất 20 cặp giảng viên–ngày phải có lịch giảng dạy ở cả buổi sáng và buổi chiều.

Đây là cận dưới lý thuyết của $S_3$ đối với mọi nghiệm khả thi. Giá trị thực tế có thể lớn hơn do ảnh hưởng của các ràng buộc khác.

Phân tích này cũng cho thấy mục tiêu tối ưu của bài toán không nhất thiết tương ứng với việc đưa toàn bộ các thành phần điểm phạt mềm về 0.


=== Phân tích cận dưới của ràng buộc mềm $S_5$

Ràng buộc mềm $S_5$ hướng đến việc giảm độ chênh lệch giữa kích thước phòng học và quy mô lớp học phần.

Trong bộ dữ liệu thực nghiệm được sinh với `seed = 42`, số lớp học phần có kích thước trung bình (Size 1) là:

$ N_"section"^(1) = 174 $

Do mỗi lớp có hai buổi học mỗi tuần, tổng nhu cầu sử dụng phòng của các lớp kích thước trung bình là:

$ N_"sess"^(1) =
2 times N_"section"^(1) $

$ N_"sess"^(1) = 2 times 174 = 348 $

Trong khi đó, tổng số vị trí phòng–ca khả dụng thuộc các phòng kích thước trung bình là:

$ C_"room"^(1) = 319 $

Do ràng buộc cứng $H_1$ không cho phép lớp kích thước trung bình sử dụng phòng kích thước nhỏ, ít nhất một phần số buổi học phải được bố trí vào phòng kích thước lớn.

Số buổi học tối thiểu cần sử dụng phòng lớn hơn quy mô lớp là:

$ N_"overflow"^(1) =
max(0, N_"sess"^(1) - C_"room"^(1)) $

$ N_"overflow"^(1) = 348 - 319 = 29 $

Mỗi buổi học kích thước trung bình được phân vào phòng kích thước lớn làm tăng giá trị $S_5$ thêm ít nhất một đơn vị.

Do đó, đối với mọi nghiệm khả thi trên bộ dữ liệu thực nghiệm:

$ S_5(x) >= 29 $

Đây là một cận dưới lý thuyết được xác định từ sự mất cân đối giữa nhu cầu sử dụng và nguồn cung phòng học theo kích thước. Giá trị thực tế của $S_5$ có thể lớn hơn do ảnh hưởng của sự phân bố thời gian và những ràng buộc liên quan.

Kết quả này cho thấy việc đưa toàn bộ điểm phạt kích thước phòng về 0 không khả thi đối với bộ dữ liệu đang xét.


=== Nhận xét về tính khả thi và mục tiêu tối ưu

Từ các phân tích trên, có thể rút ra một số nhận xét quan trọng:

- Không gian tìm kiếm của bài toán có kích thước rất lớn, gây khó khăn cho các phương pháp tìm kiếm vét cạn.

- Tỷ lệ sử dụng phòng học đạt 93,75% trên bộ dữ liệu thực nghiệm (960 buổi học trên tổng số 1.024 vị trí khả dụng, chỉ còn dư 64 vị trí trống hay 6,25% độ dư), làm giảm mạnh mức độ linh hoạt khi phân bổ và hoán đổi lịch.

- Việc lựa chọn đồng đều các cặp ngày hợp lệ tạo ra xu hướng quá tải vào Thứ Hai và Thứ Sáu. Vì vậy, cần sử dụng phương pháp khởi tạo có định hướng cân bằng tải.

- Một số ràng buộc mềm có cận dưới lý thuyết dương, cụ thể là $S_3(x) >= 20$ và $S_5(x) >= 29$ đối với mọi nghiệm khả thi trên bộ dữ liệu đang xét. Từ đây, tổng mức phạt $P(x)$ luôn có cận dưới dương:

$ P(x) >= w_3 S_3(x) + w_5 S_5(x) >= 20 w_3 + 29 w_5 > 0 $

Suy ra giá trị hàm thích nghi $F(x)$ của bất kỳ nghiệm khả thi nào cũng bị chặn trên nghiêm ngặt bởi một hằng số nhỏ hơn 1:

$ F(x) = frac(1, 1 + P(x)) <= frac(1, 1 + 20 w_3 + 29 w_5) < 1 $

Điều này chứng minh về mặt toán học rằng hàm thích nghi không thể đạt giá trị 1 và việc còn tồn tại một lượng vi phạm ràng buộc mềm là hệ quả tất yếu từ cấu trúc dữ liệu, chứ không phải lỗi hội tụ của thuật toán.

Do mật độ sử dụng tài nguyên lên tới 93,75% với chỉ 64 vị trí phòng học dự phòng trên toàn tuần, các toán tử lai ghép và đột biến ngẫu nhiên của GA thuần túy rất dễ tạo ra xung đột phòng học hoặc phá vỡ tính khả thi đã đạt được. Đồng thời, việc chỉ dùng hàm phạt với đột biến ngẫu nhiên khó tìm ra các chuỗi hoán đổi dây chuyền để vừa giữ $H(x) = 0$ vừa giảm sâu ràng buộc mềm. Đây là cơ sở lý thuyết để nhóm thiết kế cơ chế khởi tạo có định hướng, cơ chế sửa chữa nghiệm (_Repair Mechanism_) và tìm kiếm cục bộ hoán đổi cặp (_Pairwise Swap_) tại Chương 4.