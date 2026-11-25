= THIẾT KẾ THUẬT TOÁN (ALGORITHM DESIGN)

== Tổng quan phương pháp đề xuất

Dựa trên mô hình toán học được xây dựng tại Chương 3, bài toán xếp thời khóa biểu trong đề tài có hai thách thức chính: mật độ sử dụng tài nguyên phòng học cao và sự tồn tại đồng thời của nhiều ràng buộc có mức độ ưu tiên khác nhau.

Với 960 buổi học cần phân bổ vào 1024 vị trí phòng–ca khả dụng, tỷ lệ sử dụng tài nguyên đạt 93,75%. Điều này làm giảm số lượng vị trí trống có thể sử dụng trong quá trình điều chỉnh lịch học. Bên cạnh đó, việc cải thiện một tiêu chí mềm có thể ảnh hưởng đến các tiêu chí khác, khiến quá trình tìm kiếm nghiệm trở nên phức tạp.

Giải thuật di truyền cơ bản có khả năng khám phá không gian nghiệm thông qua quá trình chọn lọc, lai ghép và đột biến. Tuy nhiên, các toán tử di truyền ngẫu nhiên có thể tạo ra nhiều cá thể không khả thi, đặc biệt khi bài toán có mật độ sử dụng tài nguyên cao.

Để giải quyết những hạn chế trên, nhóm đề xuất phương pháp giải thuật di truyền kết hợp khởi tạo có định hướng, toán tử di truyền thích nghi, cơ chế sửa chữa nghiệm và tìm kiếm cục bộ. Phương pháp này được gọi là _Proposed GA_ và được xây dựng theo hướng tiếp cận của giải thuật Memetic (_Memetic Algorithm_).

Trong đó, giải thuật di truyền đảm nhiệm quá trình khám phá không gian tìm kiếm, còn cơ chế sửa chữa và tìm kiếm cục bộ hỗ trợ giảm số lượng vi phạm ràng buộc và cải thiện chất lượng của từng cá thể.

Phương pháp đề xuất bao gồm các thành phần chính:

- Khởi tạo quần thể tham lam ngẫu nhiên kết hợp cân bằng tải theo ngày (_Greedy Randomized Initialization_).

- Biểu diễn nhiễm sắc thể theo lớp học phần (_Section-based Chromosome Representation_).

- Hàm thích nghi có trọng số kết hợp cơ chế xếp hạng ưu tiên tính khả thi (_Feasibility-first Ranking_).

- Lai ghép bất đối xứng theo khối môn học (_Asymmetric Course-Block Crossover_).

- Đột biến thông minh với tỷ lệ thích nghi (_Adaptive Smart Swap Mutation_).

- Cơ chế sửa chữa nghiệm và tìm kiếm cục bộ gồm bốn pha (_Four-phase Repair and Local Search_).

- Cơ chế bảo toàn cá thể ưu tú (_Elitism_).

#figure(
  image("../picture/Sơ đồ tổng quan phương pháp đề xuất – Mục 4.1.svg", width: 95%),
  caption: [Sơ đồ tổng quan phương pháp đề xuất (Proposed GA).]
) <fig_proposed_overview>

Để đánh giá hiệu quả của các kỹ thuật cải tiến, nhóm xây dựng ba phiên bản thuật toán:

#table(
  columns: (1.1fr, 1.5fr, 1.5fr, 1.3fr),
  align: (left, left, left, center),
  table.header(
    [*Phiên bản*],
    [*Khởi tạo*],
    [*Lai ghép*],
    [*Repair*],
  ),
  [Baseline GA],
  [Random Initialization],
  [Uniform Crossover],
  [Không],

  [Improved GA],
  [Greedy Randomized Initialization],
  [Course-Block Crossover],
  [Không],

  [Proposed GA],
  [Greedy Randomized Initialization],
  [Course-Block Crossover],
  [Có],
)

Baseline GA được sử dụng làm phương pháp đối chứng. Improved GA bổ sung các kỹ thuật khởi tạo và lai ghép phù hợp với cấu trúc bài toán. Proposed GA tiếp tục tích hợp cơ chế sửa chữa nghiệm và tìm kiếm cục bộ nhằm nâng cao khả năng tìm kiếm nghiệm khả thi.

Việc so sánh ba phiên bản cho phép đánh giá hiệu quả của các nhóm kỹ thuật cải tiến. Tuy nhiên, do một số phiên bản khác nhau đồng thời ở nhiều thành phần, kết quả so sánh phản ánh hiệu quả tổng hợp của các kỹ thuật thay vì xác định riêng đóng góp của từng toán tử.


== Biểu diễn nghiệm

Phương pháp biểu diễn nghiệm có ảnh hưởng trực tiếp đến cấu trúc nhiễm sắc thể, hiệu quả của các toán tử di truyền và khả năng duy trì tính nhất quán của thời khóa biểu.

Trong đề tài, nhóm lựa chọn biểu diễn nghiệm theo lớp học phần thay vì biểu diễn độc lập từng buổi học.


=== Cấu trúc Gene

Mỗi gen (_Gene_) biểu diễn toàn bộ thông tin phân bổ của một lớp học phần, bao gồm giảng viên phụ trách và hai buổi học trong tuần.

Với lớp học phần $s$, cấu trúc gen được biểu diễn như sau:

$ g_s = (s, p_s, u_(s,1), u_(s,2)) $

Trong đó:

$ u_(s,1) = (d_(s,1), t_(s,1), r_(s,1)) $

$ u_(s,2) = (d_(s,2), t_(s,2), r_(s,2)) $

Các thành phần có ý nghĩa như sau:

- $s$: Chỉ số định danh của lớp học phần.
- $p_s$: Giảng viên phụ trách lớp học phần.
- $d_(s,k)$: Ngày học của buổi thứ $k$.
- $t_(s,k)$: Ca học của buổi thứ $k$.
- $r_(s,k)$: Phòng học của buổi thứ $k$.

Cấu trúc tương ứng trong chương trình bao gồm:

- `section_id`: Định danh lớp học phần.
- `professor_id`: Định danh giảng viên phụ trách.
- `session_1`: Thông tin phân bổ buổi học thứ nhất.
- `session_2`: Thông tin phân bổ buổi học thứ hai.

Ví dụ, một gen có thể biểu diễn lớp học phần được phân công cho giảng viên `p03`, học vào thứ Hai tại ca 2, phòng `rm05` và thứ Năm tại ca 3, phòng `rm12`.

Việc lựa chọn một gen tương ứng với một lớp học phần xuất phát từ mối liên hệ giữa hai buổi học của cùng một lớp. Hai buổi học phải sử dụng chung giảng viên phụ trách và thỏa mãn điều kiện về khoảng cách ngày học.

Nếu biểu diễn từng buổi học thành một gen riêng biệt, nhiễm sắc thể sẽ gồm 960 gen. Khi thực hiện lai ghép hoặc đột biến độc lập trên từng gen, thuật toán có thể làm mất tính nhất quán trong phân công giảng viên hoặc phá vỡ mối liên hệ giữa hai buổi học.

Với phương pháp biểu diễn theo lớp học phần, nhiễm sắc thể chỉ gồm 480 gen. Việc trao đổi nguyên vẹn một gen trong quá trình lai ghép giúp duy trì thông tin phân công giảng viên và cấu trúc hai buổi học của lớp.

Tuy nhiên, phương pháp này không loại bỏ hoàn toàn các xung đột giữa những lớp học phần khác nhau. Các ràng buộc liên quan đến giảng viên, phòng học và tài nguyên dùng chung vẫn cần được kiểm tra sau khi thực hiện các toán tử di truyền.


=== Cấu trúc Chromosome

Một nhiễm sắc thể (_Chromosome_) biểu diễn một phương án thời khóa biểu hoàn chỉnh của toàn bộ 480 lớp học phần.

Cấu trúc nhiễm sắc thể được biểu diễn như sau:

$ x = (g_0, g_1, dots, g_479) $

Các gen được lưu theo thứ tự chỉ số lớp học phần, trong đó gen tại vị trí $i$ tương ứng với lớp học phần thứ $i$.

Cách tổ chức này giúp xác định trực tiếp vị trí của một lớp học phần mà không cần tìm kiếm trên toàn bộ nhiễm sắc thể. Đồng thời, khi thực hiện lai ghép giữa hai cá thể, các gen tại cùng một vị trí luôn biểu diễn cùng một lớp học phần.

Ngoài danh sách gen, mỗi nhiễm sắc thể lưu trữ các thuộc tính đánh giá chất lượng nghiệm:

#table(
  columns: (1.3fr, 2.7fr),
  align: left,
  table.header(
    [*Thuộc tính*],
    [*Ý nghĩa*],
  ),
  [`fitness`],
  [Giá trị hàm thích nghi.],

  [`hard_violations`],
  [Tổng số vi phạm ràng buộc cứng.],

  [`soft_penalty`],
  [Tổng mức phạt ràng buộc mềm.],

  [`bonus_penalty`],
  [Tổng mức phạt của các tiêu chí mở rộng.],

  [`total_penalty`],
  [Tổng mức phạt của nhiễm sắc thể.],

  [`breakdown`],
  [Kết quả đánh giá chi tiết của từng thành phần ràng buộc.],
)

Việc lưu trữ riêng các thành phần đánh giá giúp hệ thống không chỉ xác định cá thể tốt nhất mà còn phân tích được nguyên nhân làm giảm chất lượng của từng nghiệm.

Các thuộc tính đánh giá cần được cập nhật sau khi nhiễm sắc thể bị thay đổi bởi các toán tử di truyền hoặc cơ chế sửa chữa nghiệm.


=== Cấu trúc Population

Quần thể (_Population_) tại thế hệ thứ $g$ bao gồm tập hợp các nhiễm sắc thể:

$ cal(P)_g = (x_1^g, x_2^g, dots, x_(N_"pop")^g) $

Trong đề tài, kích thước quần thể mặc định được lựa chọn là:

$ N_"pop" = 80 $

Mỗi cá thể biểu diễn một phương án phân bổ thời khóa biểu khác nhau. Việc duy trì nhiều cá thể giúp thuật toán khảo sát nhiều vùng của không gian tìm kiếm và giảm sự phụ thuộc vào một nghiệm khởi tạo duy nhất.

Để ưu tiên tính khả thi, các cá thể trong quần thể được so sánh thông qua khóa xếp hạng:

$ R(x) = (H(x), P(x)) $

Trong chương trình, khóa xếp hạng được biểu diễn bởi phương thức `rank_key()`:

`rank_key = (hard_violations, total_penalty)`

Hai cá thể được so sánh theo thứ tự từ điển, trước hết dựa trên số vi phạm ràng buộc cứng, sau đó dựa trên tổng mức phạt.

Với hai cá thể $x_a$ và $x_b$, cá thể $x_a$ được ưu tiên nếu:

$ H(x_a) < H(x_b) $

hoặc:

$ H(x_a) = H(x_b) and P(x_a) < P(x_b) $

Cơ chế này đảm bảo mọi nghiệm khả thi luôn được ưu tiên hơn nghiệm không khả thi trong quá trình xếp hạng, bất kể sự chênh lệch về điểm phạt mềm và Bonus.


== Khởi tạo quần thể (Population Initialization)

Chất lượng của quần thể ban đầu có ảnh hưởng đáng kể đến quá trình hội tụ của giải thuật di truyền.

Đối với bài toán có mật độ sử dụng tài nguyên cao, việc khởi tạo hoàn toàn ngẫu nhiên có thể tạo ra nhiều xung đột ngay từ thế hệ đầu tiên. Vì vậy, nhóm xây dựng hai phương pháp khởi tạo nhằm đánh giá ảnh hưởng của việc sử dụng tri thức bài toán trong quá trình hình thành quần thể.


=== Random Initialization (Baseline)

Random Initialization được sử dụng trong phiên bản Baseline GA.

Đối với mỗi lớp học phần, thuật toán thực hiện các bước:

+ Chọn ngẫu nhiên một giảng viên trong tập $cal(P)$.

+ Chọn ngẫu nhiên một cặp ngày từ tập cặp ngày hợp lệ $Pi_"valid"$ với phân bố xác suất đồng đều.

+ Chọn ngẫu nhiên ca học cho từng buổi từ tập $cal(T)$.

+ Chọn ngẫu nhiên phòng học cho từng buổi từ tập $cal(R)$.

Quá trình trên được lặp lại cho toàn bộ 480 lớp học phần để tạo thành một nhiễm sắc thể và tiếp tục thực hiện cho đến khi đạt kích thước quần thể yêu cầu.

Ưu điểm của phương pháp này là cấu trúc đơn giản, dễ hiện thực và có khả năng tạo ra nhiều phương án phân bổ khác nhau.

Ngoài việc lựa chọn các cặp ngày hợp lệ, phương pháp không chủ động sử dụng những thông tin về trạng thái phòng học, kích thước phòng, lịch giảng viên hoặc mức độ cân bằng tài nguyên.

Do đó, quần thể ban đầu có thể chứa nhiều vi phạm liên quan đến trùng phòng, trùng lịch giảng viên và kích thước phòng không phù hợp.

Đặc biệt, như đã phân tích tại Chương 3, việc lựa chọn đồng đều các cặp ngày hợp lệ tạo ra tải kỳ vọng 240 buổi học vào thứ Hai và thứ Sáu, vượt quá công suất lý thuyết 210 vị trí phòng–ca mỗi ngày.

Random Initialization được sử dụng làm phương pháp đối chứng nhằm đánh giá mức độ cải thiện khi áp dụng phương pháp khởi tạo có định hướng.


=== Greedy Randomized Initialization (Improved & Proposed)

Để nâng cao chất lượng quần thể ban đầu, nhóm đề xuất phương pháp khởi tạo tham lam ngẫu nhiên kết hợp cân bằng tải theo ngày.

Khác với phương pháp khởi tạo ngẫu nhiên hoàn toàn, Greedy Randomized Initialization sử dụng thông tin về môn học, giảng viên, kích thước phòng và trạng thái sử dụng tài nguyên để định hướng quá trình lựa chọn.

Yếu tố ngẫu nhiên vẫn được duy trì nhằm tạo ra các nhiễm sắc thể có cấu trúc khác nhau, hạn chế nguy cơ toàn bộ quần thể ban đầu tập trung vào một vùng tìm kiếm.

Phương pháp gồm bốn bước chính.

*Bước 1: Xác định buổi học ưu tiên cho từng môn.*

Tập hợp 60 môn học được chia ngẫu nhiên thành hai nhóm:

$ cal(C)_M subset.eq cal(C),
quad |cal(C)_M| = 30 $

$ cal(C)_A subset.eq cal(C),
quad |cal(C)_A| = 30 $

Trong đó:

- $cal(C)_M$: Tập môn học ưu tiên bố trí vào buổi sáng.

- $cal(C)_A$: Tập môn học ưu tiên bố trí vào buổi chiều.

Hai nhóm thỏa mãn:

$ cal(C)_M inter cal(C)_A = emptyset $

$ cal(C)_M union cal(C)_A = cal(C) $

Mỗi môn học có 16 buổi học mỗi tuần. Do đó, việc chia đều 30 môn cho mỗi buổi tạo ra nhu cầu dự kiến:

$ 30 times 16 = 480 $

buổi học cho từng nhóm sáng và chiều.

Cách phân chia này hướng đến giảm mức độ phân tán các buổi học của cùng một môn, tương ứng với ràng buộc mềm $S_4$.

Tuy nhiên, buổi học ưu tiên không được xem là một ràng buộc cứng. Khi tài nguyên trong buổi ưu tiên không còn phù hợp, thuật toán có thể mở rộng phạm vi lựa chọn sang buổi còn lại để ưu tiên tính khả thi.

*Bước 2: Lựa chọn cặp ngày cân bằng tải.*

Dựa trên kết quả phân tích tại Chương 3, nhóm sử dụng phân bố xác suất:

$ q = (0.20, 0.18, 0.02,
0.22, 0.18, 0.20) $

tương ứng với tập cặp ngày:

$ Pi_"valid" = (
(0,2), (0,3), (0,4),
(1,3), (1,4), (2,4)
) $

#table(
  columns: (1.5fr, 1fr, 1fr),
  align: (left, center, center),
  table.header(
    [*Cặp ngày*],
    [*Xác suất đồng đều*],
    [*Xác suất cân bằng*],
  ),
  [Thứ Hai – Thứ Tư], [16,67%], [20%],
  [Thứ Hai – Thứ Năm], [16,67%], [18%],
  [Thứ Hai – Thứ Sáu], [16,67%], [2%],
  [Thứ Ba – Thứ Năm], [16,67%], [22%],
  [Thứ Ba – Thứ Sáu], [16,67%], [18%],
  [Thứ Tư – Thứ Sáu], [16,67%], [20%],
)

Phân bố xác suất trên đưa tải kỳ vọng của mỗi ngày về:

$ E[L_d] = 192,
quad forall d in cal(D) $

Lý do lựa chọn phân bố này là để hạn chế hiện tượng quá tải vào thứ Hai và thứ Sáu ngay từ giai đoạn khởi tạo.

Tuy nhiên, do quá trình lấy mẫu vẫn mang tính ngẫu nhiên, tải thực tế có thể khác với tải kỳ vọng. Vì vậy, việc lựa chọn cặp ngày cần được kết hợp với kiểm tra tài nguyên trong các bước phân bổ tiếp theo.

*Bước 3: Phân công giảng viên.*

Các lớp học phần được xáo trộn thứ tự trước khi thực hiện phân công nhằm giảm sự phụ thuộc vào thứ tự cố định của dữ liệu đầu vào.

Đối với mỗi lớp học phần $s$, nhóm xác định hai tập giảng viên ứng viên:

$ cal(P)_"fav"(s) =
{p in cal(P) | c(s) in F_p} $

$ cal(P)_"eligible"(s) =
{p in cal(P) | c(s) in E_p} $

Trong đó, $cal(P)_"fav"(s)$ là tập giảng viên yêu thích môn học tương ứng, còn $cal(P)_"eligible"(s)$ là tập giảng viên có thể đảm nhận môn học theo giả định mở rộng của nhóm.

Thuật toán ưu tiên lựa chọn giảng viên thuộc danh sách môn yêu thích, đồng thời dành xác suất 12% cho việc lựa chọn từ danh sách giảng viên có thể đảm nhận môn học.

Việc phân bổ một phần lớp học ngoài nhóm yêu thích giúp tăng mức độ linh hoạt trong trường hợp các giảng viên yêu thích môn học đã đạt giới hạn khối lượng giảng dạy.

Với giả định một giảng viên phụ trách cả hai buổi học của mỗi lớp, điều kiện tải được kiểm tra tại bước phân công là:

$ n_p < 10 $

Trong đó, $n_p$ là số lớp học phần hiện tại của giảng viên $p$.

Các giảng viên có tải thấp được ưu tiên thông qua cơ chế trọng số giảm theo số lớp đã được phân công.

Phương pháp này hướng đến ba mục tiêu:

- Hạn chế vi phạm định mức giảng dạy $H_4$.

- Tăng mức độ đáp ứng sở thích môn học $B_(1a)$ và $B_(1b)$.

- Hạn chế phân công ngoài danh sách môn có thể đảm nhận $B_2$.

Việc ưu tiên giảng viên có tải thấp đồng thời giúp phân bố khối lượng giảng dạy đồng đều hơn giữa các giảng viên.

*Bước 4: Phân bổ ca học và phòng học.*

Sau khi xác định cặp ngày và giảng viên phụ trách, các lớp học phần được xử lý theo thứ tự kích thước đăng ký giảm dần.

Cụ thể, lớp kích thước 2 được ưu tiên phân bổ trước, tiếp đến là lớp kích thước 1 và lớp kích thước 0.

Lý do của thứ tự này xuất phát từ số lượng lựa chọn phòng học của từng nhóm lớp:

- Lớp kích thước 2 chỉ có thể sử dụng phòng kích thước 2.

- Lớp kích thước 1 có thể sử dụng phòng kích thước 1 hoặc 2.

- Lớp kích thước 0 có thể sử dụng cả ba loại phòng.

Như vậy, các lớp có kích thước lớn có miền lựa chọn phòng hẹp hơn. Nếu ưu tiên phân bổ các lớp nhỏ trước, những phòng lớn có thể bị sử dụng bởi các lớp có nhiều lựa chọn thay thế, làm giảm khả năng phân bổ của các lớp lớn.

Chiến lược này phù hợp với nguyên tắc ưu tiên xử lý những đối tượng có ít lựa chọn tài nguyên hơn trong các bài toán tối ưu có ràng buộc.

Đối với từng buổi học, thuật toán tìm kiếm vị trí phòng–ca dựa trên các tiêu chí:

+ Phòng học đang khả dụng.

+ Phòng chưa được sử dụng bởi buổi học khác.

+ Giảng viên không có lịch dạy tại cùng thời điểm.

+ Kích thước phòng không nhỏ hơn quy mô lớp.

+ Ưu tiên ca học thuộc buổi đã xác định cho môn học.

+ Ưu tiên phòng có kích thước khớp chính xác với quy mô lớp.

Nếu không tìm được phòng có kích thước khớp chính xác, thuật toán mở rộng tìm kiếm sang những phòng có kích thước lớn hơn nhưng vẫn đảm bảo điều kiện tương thích.

Việc ưu tiên thỏa mãn các điều kiện bắt buộc trước các tiêu chí mềm giúp cải thiện khả năng hình thành nghiệm khả thi.

Tuy nhiên, do phương pháp tham lam đưa ra quyết định dựa trên trạng thái phân bổ hiện tại, một lựa chọn phù hợp ở bước trước có thể làm giảm số lượng lựa chọn ở bước sau.

Vì vậy, Greedy Randomized Initialization có vai trò tạo ra các nghiệm ban đầu có định hướng, nhưng không mặc nhiên đảm bảo mọi nhiễm sắc thể được khởi tạo đều thỏa mãn toàn bộ ràng buộc.


== Thiết kế hàm thích nghi (Fitness Function)

Hàm thích nghi được sử dụng để định lượng chất lượng của các nhiễm sắc thể và định hướng quá trình tiến hóa.

Dựa trên mô hình toán học tại Chương 3, nhóm xây dựng hàm phạt tổng hợp gồm ba thành phần: mức phạt ràng buộc cứng, mức phạt ràng buộc mềm và mức phạt của các tiêu chí mở rộng.


=== Hàm phạt ràng buộc cứng

Tổng số vi phạm ràng buộc cứng được xác định bởi:

$ H(x) = sum_(i=1)^7 H_i(x) $

Mức phạt tương ứng là:

$ P_"hard"(x) = W_H H(x) $

Trong đó, trọng số phạt ràng buộc cứng được lựa chọn là:

$ W_H = 100000 $

Sử dụng trọng số lớn nhằm phản ánh mức độ nghiêm trọng của các vi phạm bắt buộc, bởi một thời khóa biểu tồn tại xung đột phòng học hoặc giảng viên không thể được sử dụng trực tiếp.

Các cá thể có $H(x) = 0$ được xem là nghiệm khả thi đối với hệ thống ràng buộc cứng đã định nghĩa.


=== Hàm phạt ràng buộc mềm và Bonus

Tổng mức phạt ràng buộc mềm được xác định bởi:

$ P_"soft"(x) =
5 S_1(x)
+ 3 S_2(x)
+ 5 S_3(x)
+ 3 S_4(x)
+ S_5(x) $

Tổng mức phạt của các tiêu chí mở rộng được xác định bởi:

$ P_"bonus"(x) =
5000 B_2(x)
+ 2000 B_(1a)(x)
+ 1.5 B_(1b)(x) $

Các thành phần trên cho phép đánh giá đồng thời chất lượng lịch giảng dạy, mức độ phù hợp của phòng học và mức độ đáp ứng nguyện vọng giảng viên.

Việc sử dụng các mức trọng số khác nhau giúp thể hiện mức độ ưu tiên giữa các tiêu chí, thay vì xem mọi vi phạm có ảnh hưởng như nhau.


=== Xác định trọng số

Hệ thống sử dụng các trọng số phạt được trình bày trong bảng sau.

#table(
  columns: (0.7fr, 2.8fr, 0.8fr),
  align: (center, left, center),
  table.header(
    [*Ký hiệu*],
    [*Tiêu chí đánh giá*],
    [*Trọng số*],
  ),
  [$H$], [Vi phạm ràng buộc cứng], [100000],
  [$B_2$], [Phân công ngoài danh sách môn có thể đảm nhận], [5000],
  [$B_(1a)$], [Giảng viên chưa có lớp thuộc môn yêu thích], [2000],
  [$S_1$], [Khoảng trống giữa các ca dạy], [5],
  [$S_2$], [Khoảng trống giữa các ngày dạy], [3],
  [$S_3$], [Giảng viên dạy cả sáng và chiều], [5],
  [$S_4$], [Môn học phân tán giữa sáng và chiều], [3],
  [$S_5$], [Độ dư kích thước phòng học], [1],
  [$B_(1b)$], [Lớp học ngoài danh sách Top-3], [1,5],
)

Việc xác định trọng số dựa trên mức độ ảnh hưởng của từng nhóm ràng buộc đối với chất lượng thời khóa biểu.

Đối với ràng buộc cứng, trọng số 100000 được sử dụng nhằm tạo ra sự chênh lệch đáng kể giữa các nghiệm có mức độ vi phạm khác nhau.

Đối với các tiêu chí mở rộng, trọng số của $B_2$ và $B_(1a)$ được lựa chọn tương đối lớn để ưu tiên sự phù hợp trong phân công chuyên môn và đảm bảo mức độ bao phủ môn học yêu thích giữa các giảng viên.

Trong nhóm ràng buộc mềm, $S_1$ và $S_3$ có trọng số cao nhất do phản ánh trực tiếp mức độ thuận tiện của lịch giảng dạy trong ngày.

Các thành phần $S_2$ và $S_4$ có trọng số trung bình, nhằm hạn chế mức độ phân tán của lịch giảng viên và lịch học theo môn.

Thành phần $S_5$ có trọng số thấp hơn vì việc sử dụng phòng lớn hơn quy mô lớp vẫn đáp ứng yêu cầu bắt buộc, mặc dù chưa tối ưu về hiệu quả sử dụng tài nguyên.

Các trọng số được lựa chọn theo mức độ ưu tiên do nhóm xác định. Đây là tham số thiết kế của thuật toán, không phải các giá trị tối ưu đã được chứng minh về mặt toán học.

Ngoài ra, trọng số phạt lớn không mặc nhiên đảm bảo một nghiệm khả thi luôn có tổng mức phạt thấp hơn nghiệm không khả thi, do tổng mức phạt Bonus có thể nhận giá trị lớn.

Vì vậy, nhóm kết hợp hàm phạt với cơ chế xếp hạng ưu tiên tính khả thi:

$ R(x) = (H(x), P(x)) $

Nhờ đó, việc giảm số lượng vi phạm ràng buộc cứng luôn được ưu tiên trong quá trình chọn lọc, bất kể sự chênh lệch về các thành phần điểm phạt còn lại.


=== Công thức Fitness tổng hợp

Tổng mức phạt của một nhiễm sắc thể được xác định bởi:

$ P(x) =
P_"hard"(x)
+ P_"soft"(x)
+ P_"bonus"(x) $

Hàm thích nghi được xây dựng dưới dạng:

$ F(x) = frac(1, 1 + P(x)) $

Do $P(x) >= 0$, giá trị hàm thích nghi thỏa mãn:

$ F(x) in (0, 1] $

Khi tổng mức phạt giảm, giá trị Fitness tăng. Vì vậy, việc tối đa hóa hàm thích nghi tương đương với việc tối thiểu hóa tổng mức phạt.

Phép biến đổi trên giúp biểu diễn tổng mức phạt dưới dạng một đại lượng dương có miền giá trị xác định, thuận tiện cho việc theo dõi và trực quan hóa quá trình hội tụ.

Tuy nhiên, hàm thích nghi có dạng phi tuyến. Khi tổng mức phạt lớn, giá trị Fitness có thể rất nhỏ và khó thể hiện sự khác biệt giữa các nghiệm trên biểu đồ thông thường.

Do đó, trong quá trình thực nghiệm, nhóm theo dõi đồng thời các chỉ tiêu:

- Fitness Score.
- Tổng số vi phạm ràng buộc cứng.
- Tổng mức phạt ràng buộc mềm.
- Tổng mức phạt Bonus.
- Tổng mức phạt của nghiệm.

Theo các cận dưới được xác định tại Chương 3, đối với mọi nghiệm khả thi trên bộ dữ liệu thực nghiệm:

$ S_3(x) >= 20 $

$ S_5(x) >= 29 $

Với các trọng số tương ứng, tổng mức phạt mềm có cận dưới:

$ P_"soft"(x) >= 5 times 20 + 29 = 129 $

Do đó:

$ F(x) <= frac(1, 1 + 129)
= frac(1, 130)
approx 0.007692 $

Đây là cận trên lý thuyết của Fitness đối với các nghiệm khả thi, chỉ xét từ hai cận dưới đã xác định. Giá trị Fitness tốt nhất thực tế có thể thấp hơn do ảnh hưởng của các ràng buộc còn lại.

Vì vậy, Fitness bằng 1 không phải là mục tiêu khả thi đối với bộ dữ liệu đang xét.

Thuật toán hướng đến việc tìm kiếm nghiệm có $H(x) = 0$ và tiếp tục giảm tổng mức phạt trong giới hạn tính toán, thay vì yêu cầu tất cả các thành phần điểm phạt bằng 0.


== Phương pháp chọn lọc (Tournament Selection)

Nhóm sử dụng phương pháp chọn lọc đấu giải (_Tournament Selection_) để lựa chọn các cá thể cha mẹ từ quần thể hiện tại.

Kích thước đấu giải được thiết lập là:

$ k = 5 $

Trong mỗi lần chọn lọc, thuật toán lấy ngẫu nhiên năm cá thể từ quần thể. Cá thể có khóa xếp hạng tốt nhất được lựa chọn làm cha hoặc mẹ.

Gọi $cal(T)_"tour"$ là tập các cá thể tham gia đấu giải. Cá thể được lựa chọn được xác định bởi:

$ x^* in arg min_(x in cal(T)_"tour") R(x) $

Trong đó, phép so sánh được thực hiện theo thứ tự từ điển của khóa xếp hạng.

Tournament Selection được lựa chọn vì phương pháp này không yêu cầu chuẩn hóa Fitness thành phân bố xác suất chọn lọc, đồng thời có thể sử dụng trực tiếp tiêu chí xếp hạng ưu tiên tính khả thi.

Điều này phù hợp với bài toán đang xét do các giá trị Fitness có thể chênh lệch đáng kể giữa những nghiệm khả thi và không khả thi.

Kích thước đấu giải ảnh hưởng trực tiếp đến áp lực chọn lọc.

Khi $k$ quá nhỏ, quá trình chọn lọc có mức độ ngẫu nhiên cao, có thể làm chậm tốc độ cải thiện chất lượng nghiệm. Ngược lại, khi $k$ quá lớn, các cá thể có chất lượng cao có xu hướng được lựa chọn thường xuyên, làm giảm tính đa dạng của quần thể và tăng nguy cơ hội tụ sớm.

Nhóm lựa chọn $k = 5$ với kích thước quần thể 80 nhằm tạo sự cân bằng giữa khả năng khai thác các nghiệm tốt và duy trì tính đa dạng.

Đây là giá trị cấu hình được sử dụng trong thực nghiệm, không phải giá trị tối ưu chung cho mọi bài toán.


== Phương pháp lai ghép (Crossover)

Toán tử lai ghép được sử dụng để kết hợp thông tin từ hai nhiễm sắc thể cha mẹ, tạo ra các phương án thời khóa biểu mới.

Tỷ lệ lai ghép mặc định được xác định là:

$ p_c = 0.85 $

Nếu lai ghép được thực hiện, hệ thống sử dụng một trong hai phương pháp tùy theo phiên bản thuật toán.

*Uniform Crossover theo lớp học phần (Baseline GA).*

Đối với mỗi vị trí gen $s$, thuật toán lựa chọn thông tin từ một trong hai cá thể cha mẹ với xác suất bằng nhau.

Gọi hai cá thể cha mẹ là $x^A$ và $x^B$. Gen tương ứng của cá thể con thứ nhất được xác định như sau:

$ g_s^C = cases(
  g_s^A & "với xác suất 0,5",
  g_s^B & "với xác suất 0,5"
) $

Cá thể con thứ hai nhận gen tương ứng còn lại.

Do mỗi gen biểu diễn toàn bộ lịch của một lớp học phần, quá trình lai ghép duy trì thông tin giảng viên và hai buổi học của lớp tại thời điểm trao đổi.

Tuy nhiên, các gen được lựa chọn độc lập, khiến những lớp thuộc cùng một môn có thể được lấy từ nhiều cá thể cha mẹ khác nhau.

Điều này có thể làm phá vỡ cấu trúc phân bố buổi học đã được hình thành, đồng thời tạo ra các xung đột phòng học và giảng viên giữa những gen được kết hợp.

*Asymmetric Course-Block Crossover (Improved GA và Proposed GA).*

Để hạn chế những ảnh hưởng trên, nhóm sử dụng phương pháp lai ghép bất đối xứng theo khối môn học.

Mỗi môn học có tám lớp học phần, được xem là một khối gồm tám gen có liên hệ với nhau.

Thay vì trao đổi độc lập từng gen với xác suất 50%, toán tử lựa chọn một tỷ lệ môn học ngẫu nhiên:

$ alpha in [0.08, 0.22] $

Số lượng môn học được lựa chọn để trao đổi được xác định xấp xỉ bởi:

$ N_"block" = alpha |cal(C)| $

Với mỗi môn học được lựa chọn, toàn bộ tám gen thuộc môn đó được sao chép từ cá thể cho sang cá thể nhận.

Gọi $cal(C)_"swap"$ là tập các môn học được lựa chọn để trao đổi. Gen của cá thể con được biểu diễn bởi:

$ g_s^C = cases(
  g_s^B & "nếu" c(s) in cal(C)_"swap",
  g_s^A & "nếu" c(s) in.not cal(C)_"swap"
) $

Phương pháp này giữ lại phần lớn cấu trúc của cá thể nhận và chỉ thay đổi một số khối môn học trong mỗi lần lai ghép.

Việc trao đổi nguyên khối tám lớp học phần giúp bảo toàn cấu trúc phân bố sáng–chiều của môn học được sao chép, qua đó hạn chế sự thay đổi trực tiếp của thành phần $S_4$ đối với khối môn học tương ứng.

Bên cạnh đó, tỷ lệ trao đổi tương đối nhỏ giúp giới hạn số lượng gen bị thay đổi, giảm mức độ xáo trộn đối với thời khóa biểu đang có mật độ sử dụng phòng học cao.

Tuy nhiên, Course-Block Crossover không đảm bảo cá thể con luôn khả thi. Các khối môn học được sao chép vẫn có thể phát sinh xung đột với những lớp được giữ lại từ cá thể nhận.

Do đó, các cá thể con cần được đánh giá lại và có thể được xử lý bởi cơ chế sửa chữa nghiệm sau khi thực hiện lai ghép.


== Phương pháp đột biến (Mutation)

Toán tử đột biến giúp tạo ra những phương án phân bổ mới mà quá trình lai ghép có thể không tạo được, qua đó duy trì tính đa dạng và giảm nguy cơ hội tụ sớm.

Thay vì sử dụng một tỷ lệ đột biến cố định trong suốt quá trình tiến hóa, phương pháp đề xuất sử dụng tỷ lệ đột biến thích nghi trong khoảng:

$ p_m in [0.015, 0.060] $

Giá trị khởi tạo mặc định là:

$ p_m^0 = 0.015 $

Khi chất lượng nghiệm tốt nhất không được cải thiện trong 10 thế hệ liên tiếp, tỷ lệ đột biến được tăng theo công thức:

$ p_m' = min(0.060, 1.15 p_m) $

Khi thuật toán tìm được nghiệm tốt hơn theo tiêu chí xếp hạng, tỷ lệ đột biến được giảm theo công thức:

$ p_m' = max(0.015, 0.85 p_m) $

Việc điều chỉnh tỷ lệ đột biến dựa trên trạng thái hội tụ giúp cân bằng giữa hai mục tiêu:

- _Exploration_: Khám phá các vùng mới của không gian tìm kiếm.

- _Exploitation_: Khai thác và cải thiện những nghiệm hiện có.

Khi quá trình tìm kiếm bị đình trệ, việc tăng tỷ lệ đột biến giúp tạo ra nhiều biến đổi hơn, từ đó mở rộng phạm vi tìm kiếm.

Khi nghiệm tốt nhất tiếp tục được cải thiện, việc giảm tỷ lệ đột biến giúp hạn chế phá vỡ những cấu trúc lịch có chất lượng tốt.

Trên mỗi gen được lựa chọn đột biến, thuật toán có thể thực hiện một trong các dạng biến đổi: thay đổi ca học và phòng học, thay đổi cặp ngày, thay đổi giảng viên hoặc hoán đổi lịch giữa các lớp học phần.


=== Timeslot & Room Mutation

Phương pháp này thực hiện thay đổi thông tin phân bổ của một hoặc cả hai buổi học trong gen.

Đối với buổi học được lựa chọn, toán tử có thể thay đổi ca học và phòng học sang một vị trí khác trong miền giá trị cho phép.

Điều kiện tương thích kích thước phòng được xác định bởi:

$ "size"_"rm"(r_(s,k))
>= "size"_"sec"(s) $

Phòng được lựa chọn cần khả dụng tại ngày và ca học tương ứng.

Ngoài ra, toán tử có thể thay đổi cặp ngày học của lớp từ tập cặp ngày hợp lệ $Pi_"valid"$, sử dụng phân bố xác suất cân bằng đã xây dựng trong giai đoạn khởi tạo.

Việc lựa chọn cặp ngày từ tập hợp lệ giúp hạn chế phát sinh vi phạm khoảng cách giữa hai buổi học.

Phương pháp đột biến ca học và phòng học tạo điều kiện cho thuật toán thay đổi cấu trúc phân bổ tài nguyên, cải thiện độ gọn của lịch giảng viên hoặc mức độ phù hợp giữa kích thước phòng và quy mô lớp.

Tuy nhiên, một vị trí phù hợp về kích thước và trạng thái khả dụng vẫn có thể xảy ra xung đột với các lớp khác hoặc lịch giảng viên. Vì vậy, nghiệm sau đột biến cần được kiểm tra lại.


=== Professor Mutation

Phương pháp này thực hiện thay đổi giảng viên phụ trách của một lớp học phần.

Giảng viên mới được lựa chọn từ các tập ứng viên:

- Tập giảng viên có môn học tương ứng trong danh sách Top-3 yêu thích, với xác suất 70%.

- Tập giảng viên có thể đảm nhận môn học, với xác suất 30%.

Giá trị `professor_id` của gen được thay đổi cho cả hai buổi học.

Cách thực hiện này duy trì giả định một giảng viên phụ trách toàn bộ lớp học phần, đồng thời tạo cơ hội điều chỉnh sự phân bố khối lượng giảng dạy và mức độ đáp ứng sở thích môn học.

Tuy nhiên, việc thay đổi giảng viên có thể tạo ra xung đột tại những ca học đã được phân bổ hoặc làm vượt quá định mức giảng dạy của giảng viên mới.

Do đó, cần đánh giá lại các thành phần $H_3$, $H_4$ và những tiêu chí liên quan đến lịch giảng viên sau khi thực hiện toán tử.


=== Swap Mutation

Swap Mutation thực hiện hoán đổi lịch học giữa hai lớp học phần có cùng kích thước đăng ký.

Gọi hai lớp được lựa chọn là $s_a$ và $s_b$, thỏa mãn:

$ "size"_"sec"(s_a)
= "size"_"sec"(s_b) $

Trước khi thực hiện hoán đổi, thông tin phân bổ của hai lớp là:

$ g_a = (s_a, p_a, u_(a,1), u_(a,2)) $

$ g_b = (s_b, p_b, u_(b,1), u_(b,2)) $

Sau khi hoán đổi:

$ g_a' = (s_a, p_a, u_(b,1), u_(b,2)) $

$ g_b' = (s_b, p_b, u_(a,1), u_(a,2)) $

Định danh lớp học phần và giảng viên phụ trách được giữ nguyên. Chỉ thông tin phân bổ của hai buổi học được trao đổi giữa hai lớp.

Việc lựa chọn hai lớp có cùng kích thước đăng ký giúp duy trì tính tương thích về kích thước phòng nếu hai lịch học ban đầu đã thỏa mãn điều kiện này.

Bên cạnh đó, phép hoán đổi giữ nguyên tập hợp các vị trí phòng–ca đang được sử dụng, do đó không yêu cầu tìm kiếm phòng học còn trống.

Đặc điểm này có ý nghĩa đối với bài toán đang xét vì số lượng vị trí phòng–ca còn dư tương đối nhỏ.

Tuy nhiên, do giảng viên của hai lớp có thể khác nhau, lịch học sau hoán đổi vẫn có khả năng tạo ra xung đột giảng viên hoặc ảnh hưởng đến các ràng buộc mềm.

Vì vậy, Swap Mutation cần được kết hợp với quá trình đánh giá và sửa chữa nghiệm.

Cần phân biệt Swap Mutation với Same-Day Pairwise Swap được sử dụng trong cơ chế sửa chữa. Swap Mutation trao đổi toàn bộ lịch của hai lớp học phần nhằm tạo ra biến đổi trong quá trình tiến hóa, trong khi Same-Day Pairwise Swap khảo sát và chấp nhận những hoán đổi cục bộ có khả năng cải thiện chất lượng nghiệm.


== Cơ chế sửa chữa nghiệm (Repair Mechanism)

Cơ chế sửa chữa nghiệm là một thành phần trọng tâm của phương pháp Proposed GA.

Như đã phân tích tại Chương 3, hệ thống chỉ có 64 vị trí phòng–ca còn dư sau khi phân bổ đầy đủ 960 buổi học vào 1024 vị trí khả dụng.

Trong điều kiện này, các toán tử lai ghép và đột biến có thể tạo ra xung đột, trong khi số lượng vị trí thay thế phù hợp tương đối hạn chế.

Nếu chỉ sử dụng hàm phạt, thuật toán phải tiếp tục thực hiện nhiều thế hệ tiến hóa để tìm kiếm ngẫu nhiên những biến đổi có khả năng loại bỏ xung đột.

Vì vậy, nhóm tích hợp cơ chế sửa chữa nghiệm dựa trên các ràng buộc của bài toán, kết hợp với tìm kiếm cục bộ nhằm cải thiện trực tiếp những cá thể được tạo ra.

Xác suất áp dụng cơ chế sửa chữa trong quá trình sinh cá thể con được thiết lập là:

$ p_"repair" = 0.40 $

Việc chỉ áp dụng Repair với một tỷ lệ nhất định nhằm cân bằng giữa chi phí tính toán, chất lượng nghiệm và tính đa dạng của quần thể.

Cơ chế sửa chữa được tổ chức thành bốn pha tuần tự.

*Pha 1: Sửa chữa phân công giảng viên và định mức giảng dạy.*

Pha đầu tiên tập trung xử lý các vi phạm liên quan đến việc phân công giảng viên, bao gồm:

- Lớp học được giao cho giảng viên ngoài danh sách môn có thể đảm nhận ($B_2$).

- Giảng viên vượt quá định mức 20 buổi học mỗi tuần ($H_4$).

- Giảng viên chưa được phân công bất kỳ lớp nào thuộc danh sách môn yêu thích ($B_(1a)$).

Đối với mỗi lớp có phân công không phù hợp, thuật toán tìm kiếm giảng viên thay thế trong tập ứng viên có khả năng đảm nhận môn học, ưu tiên những giảng viên có tải thấp và chưa đạt giới hạn số lớp.

Đối với giảng viên chưa có lớp thuộc danh sách môn yêu thích, thuật toán tìm kiếm một lớp phù hợp để thực hiện điều chỉnh phân công.

Việc chuyển giao lớp học cần xem xét giới hạn khối lượng giảng dạy của giảng viên mới và tránh làm phát sinh thêm các vi phạm không cần thiết.

Đồng thời, cần xem xét trường hợp giảng viên chuyển giao lớp bị mất lớp yêu thích duy nhất đang được phân công.

Mục tiêu của pha này là giảm các vi phạm $H_4$, $B_2$ và $B_(1a)$, tạo cơ sở cho quá trình xử lý xung đột thời gian và phòng học ở pha tiếp theo.

Tuy nhiên, việc phân công lại giảng viên vẫn có thể tạo ra xung đột thời gian. Những xung đột này tiếp tục được xem xét trong pha 2.

*Pha 2: Xử lý các xung đột ràng buộc cứng.*

Pha thứ hai tập trung sửa chữa những buổi học đang vi phạm các điều kiện bắt buộc về phòng học và thời gian.

Các thành phần được xem xét chủ yếu gồm:

- $H_1$: Kích thước phòng học không phù hợp.

- $H_3$: Xung đột lịch giảng viên.

- $H_5$: Phòng học không khả dụng.

- $H_7$: Xung đột sử dụng phòng học.

Đối với mỗi buổi học có xung đột, thuật toán tìm kiếm các vị trí phòng–ca thay thế trong cùng ngày.

Các vị trí ứng viên được đánh giá dựa trên những điều kiện:

+ Phòng học khả dụng tại thời điểm tương ứng.

+ Phòng học không được sử dụng bởi lớp khác.

+ Giảng viên không có lịch dạy trùng thời điểm.

+ Kích thước phòng đáp ứng yêu cầu của lớp.

+ Không làm vi phạm khoảng cách giữa hai buổi học.

Việc ưu tiên tìm kiếm trong cùng ngày giúp duy trì cấu trúc phân bố tải ngày và hạn chế ảnh hưởng đến cặp ngày đã được lựa chọn.

Nếu không tìm được vị trí phù hợp trong ngày hiện tại, thuật toán có thể mở rộng phạm vi tìm kiếm bằng cách thay đổi cặp ngày của cả lớp học phần.

Cặp ngày mới được lựa chọn từ tập hợp $Pi_"valid"$ nhằm duy trì điều kiện hai buổi học không cùng ngày hoặc liền ngày.

Việc thực hiện sửa chữa ở cấp lớp học phần giúp đảm bảo sự nhất quán giữa hai buổi học trong quá trình thay đổi lịch.

Mục tiêu của pha 2 là đưa số lượng vi phạm ràng buộc cứng về mức thấp nhất có thể, hướng đến:

$ H(x) = 0 $

Do số lượng vị trí thay thế có thể bị giới hạn bởi nhiều điều kiện đồng thời, cơ chế sửa chữa không mặc nhiên đảm bảo loại bỏ được toàn bộ vi phạm trong một lần thực hiện.

*Pha 3: Tinh chỉnh nghiệm thông qua di chuyển đơn lẻ.*

Sau khi xử lý các xung đột chính, thuật toán tiếp tục thực hiện tìm kiếm cục bộ nhằm cải thiện chất lượng thời khóa biểu.

Một số buổi học được lựa chọn để khảo sát những vị trí phòng–ca còn trống trong cùng ngày.

Đối với mỗi vị trí ứng viên, thuật toán đánh giá sự thay đổi của các thành phần chi phí liên quan, bao gồm:

- Khoảng trống giữa các ca dạy của giảng viên ($S_1$).

- Mức độ phân tán lịch giảng viên giữa sáng và chiều ($S_3$).

- Mức độ phân tán buổi học của môn ($S_4$).

- Độ dư kích thước phòng học ($S_5$).

Gọi $C_"local"(x)$ là hàm chi phí cục bộ của những đối tượng bị ảnh hưởng bởi phép di chuyển.

Mức thay đổi chi phí được xác định bởi:

$ Delta C =
C_"local"(x') - C_"local"(x) $

Trong đó, $x$ là nghiệm hiện tại và $x'$ là nghiệm sau khi thực hiện phép di chuyển.

Phép di chuyển được ưu tiên khi:

$ Delta C < 0 $

đồng thời không làm tăng số lượng vi phạm ràng buộc cứng.

Đối với nghiệm đã khả thi, điều kiện cần duy trì là:

$ H(x') = 0 $

Việc đánh giá cục bộ cho phép tập trung vào những thành phần bị ảnh hưởng trực tiếp bởi phép thay đổi, thay vì đánh giá lại toàn bộ 480 lớp học phần cho mỗi vị trí ứng viên.

Tuy nhiên, khả năng cải thiện của pha này bị giới hạn bởi số lượng vị trí phòng–ca còn trống. Khi tài nguyên gần như được sử dụng hết, nhiều phép di chuyển đơn lẻ không thể thực hiện mặc dù tồn tại những phương án sắp xếp tốt hơn.

Đây là cơ sở để nhóm bổ sung pha tìm kiếm cục bộ bằng hoán đổi cặp.

*Pha 4: Hoán đổi cặp buổi học cùng ngày
(Same-Day Pairwise Swap).*

Để mở rộng không gian nghiệm lân cận trong điều kiện tài nguyên hạn chế, nhóm sử dụng phép hoán đổi giữa hai buổi học đã được phân bổ trong cùng một ngày.

Xét hai buổi học $a$ và $b$ có thông tin:

$ u_a = (d_a,t_a,r_a) $

$ u_b = (d_b,t_b,r_b) $

Điều kiện lựa chọn là:

$ d_a = d_b $

Sau khi thực hiện hoán đổi:

$ u_a' = (d_a,t_b,r_b) $

$ u_b' = (d_b,t_a,r_a) $

Như vậy, hai buổi học giữ nguyên ngày học nhưng trao đổi ca học và phòng học.

Phương pháp này có những đặc điểm phù hợp với cấu trúc bài toán:

- Không yêu cầu tồn tại một vị trí phòng–ca còn trống.

- Không làm thay đổi tổng số buổi học của từng ngày.

- Không làm thay đổi cặp ngày của các lớp học phần.

- Không làm thay đổi tập hợp vị trí phòng–ca đang được sử dụng.

Do ngày học của hai buổi được giữ nguyên, phép hoán đổi không làm thay đổi khoảng cách ngày học giữa hai buổi của các lớp liên quan.

Tuy nhiên, trước khi chấp nhận phép hoán đổi, thuật toán vẫn cần kiểm tra các điều kiện:

+ Phòng học sau hoán đổi phải phù hợp với kích thước của từng lớp.

+ Giảng viên của hai lớp không bị trùng lịch tại ca học mới.

+ Trạng thái khả dụng của phòng học được duy trì.

+ Không phát sinh thêm vi phạm ràng buộc cứng.

Sau khi các điều kiện bắt buộc được kiểm tra, thuật toán đánh giá sự thay đổi chi phí mềm cục bộ.

Gọi $Delta C_"swap"$ là mức thay đổi chi phí của các đối tượng liên quan trước và sau khi hoán đổi:

$ Delta C_"swap" =
C_"local"(x') - C_"local"(x) $

Phép hoán đổi được chấp nhận khi chi phí cục bộ giảm và tính khả thi của nghiệm được duy trì.

Đối với một nghiệm khả thi, điều kiện tương ứng là:

$ H(x') = 0
quad "và" quad
Delta C_"swap" < 0 $

Khác với toán tử đột biến ngẫu nhiên, phép hoán đổi trong pha 4 được định hướng bởi mục tiêu cải thiện chất lượng nghiệm.

Việc lựa chọn hai buổi học và kiểm tra điều kiện chấp nhận giúp thuật toán khảo sát các phương án phân bổ mới ngay cả khi không còn vị trí trống phù hợp cho thao tác di chuyển đơn lẻ.

Đây là thành phần tìm kiếm cục bộ giúp phương pháp Proposed GA có đặc trưng của một giải thuật Memetic.

Cần lưu ý rằng việc giảm chi phí cục bộ không mặc nhiên đồng nghĩa với việc giảm mọi thành phần của hàm mục tiêu tổng hợp. Một phép hoán đổi có thể cải thiện lịch giảng viên nhưng làm tăng mức độ phân tán buổi học của môn hoặc độ dư kích thước phòng.

Vì vậy, nghiệm sau quá trình tinh chỉnh cần được đánh giá lại bằng hàm phạt tổng hợp và tiêu chí xếp hạng của hệ thống.

*Nhận xét về cơ chế sửa chữa bốn pha.*

Bốn pha được tổ chức theo thứ tự ưu tiên từ xử lý phân công giảng viên, xử lý xung đột bắt buộc đến cải thiện chất lượng nghiệm.

Hai pha đầu hướng đến giảm số lượng vi phạm ràng buộc cứng và các tiêu chí phân công quan trọng. Hai pha sau tập trung khai thác những nghiệm lân cận nhằm giảm mức phạt mềm.

Cơ chế này giúp kết hợp quá trình khám phá không gian tìm kiếm của giải thuật di truyền với quá trình cải thiện nghiệm dựa trên tri thức chuyên biệt của bài toán.

Tuy nhiên, việc bổ sung Repair và Local Search làm tăng chi phí tính toán của mỗi thế hệ. Do đó, hiệu quả của phương pháp cần được đánh giá đồng thời dựa trên chất lượng nghiệm và thời gian thực thi.


== Cơ chế bảo toàn cá thể tốt nhất (Elitism)

Để hạn chế việc mất đi những nghiệm tốt trong quá trình tiến hóa, nhóm sử dụng cơ chế bảo toàn cá thể ưu tú.

Tại mỗi thế hệ, các cá thể được sắp xếp theo khóa xếp hạng:

$ R(x) = (H(x), P(x)) $

Số lượng cá thể ưu tú được thiết lập là:

$ E = 5 $

Với kích thước quần thể 80, tỷ lệ cá thể ưu tú là:

$ E / N_"pop" times 100%
= 5 / 80 times 100%
= 6.25% $

Năm cá thể có chất lượng tốt nhất được sao chép sang thế hệ tiếp theo mà không thực hiện lai ghép và đột biến.

Các vị trí còn lại được bổ sung bằng những cá thể con được tạo ra từ quá trình tiến hóa.

Việc giữ lại một tỷ lệ cá thể ưu tú tương đối nhỏ giúp duy trì các nghiệm tốt đã tìm được, đồng thời dành phần lớn quần thể cho quá trình khám phá những nghiệm mới.

Trong Proposed GA, sau mỗi năm thế hệ, cá thể tốt nhất được đưa qua một lượt tinh chỉnh chuyên sâu bằng cơ chế sửa chữa và tìm kiếm cục bộ.

Việc áp dụng tinh chỉnh định kỳ thay vì thực hiện trên toàn bộ quần thể tại mọi thế hệ giúp giới hạn chi phí tính toán và tập trung tài nguyên vào những nghiệm có tiềm năng cải thiện cao.

Để duy trì tính chất bảo toàn cá thể ưu tú, kết quả tinh chỉnh cần được đánh giá lại và chỉ thay thế cá thể tốt nhất khi không làm giảm chất lượng theo khóa xếp hạng.

Gọi $x_"best"^g$ là cá thể tốt nhất tại thế hệ thứ $g$. Khi cơ chế bảo toàn được thực hiện đúng theo tiêu chí xếp hạng, ta có:

$ R(x_"best"^(g+1))
<=_( "lex" )
R(x_"best"^g) $

Trong đó, phép so sánh được thực hiện theo thứ tự từ điển.

Tính chất trên đảm bảo nghiệm tốt nhất theo tiêu chí lựa chọn không suy giảm qua các thế hệ.

Tuy nhiên, cơ chế Elitism không đảm bảo thuật toán tìm được nghiệm tối ưu toàn cục.


== Điều kiện dừng thuật toán

Thuật toán được thực hiện với số thế hệ tối đa:

$ G_"max" = 200 $

Việc sử dụng số thế hệ cố định giúp giới hạn chi phí tính toán, đồng thời tạo điều kiện so sánh các phiên bản thuật toán trên cùng số vòng tiến hóa.

Như đã phân tích tại Chương 3, một số ràng buộc mềm có cận dưới lý thuyết khác 0. Vì vậy, điều kiện dừng dựa trên Fitness bằng 1 không phù hợp với bài toán đang xét.

Bên cạnh đó, việc dừng ngay khi tìm được nghiệm có $H(x) = 0$ cũng chưa đáp ứng đầy đủ mục tiêu tối ưu, bởi nghiệm khả thi vẫn có thể chứa nhiều vi phạm mềm và chưa đáp ứng tốt các tiêu chí mở rộng.

Do đó, sau khi đạt được nghiệm khả thi, thuật toán tiếp tục tiến hóa nhằm cải thiện chất lượng nghiệm cho đến khi hoàn thành số thế hệ đã thiết lập.

Sau thế hệ cuối cùng, Proposed GA thực hiện một lượt tinh chỉnh cuối (_Final Polish_) trên cá thể tốt nhất.

Quá trình tinh chỉnh gồm tám vòng quét trên toàn bộ 480 lớp học phần, sử dụng các thao tác sửa chữa và tìm kiếm cục bộ để tiếp tục khảo sát những khả năng cải thiện nghiệm.

Kết quả sau tinh chỉnh được đánh giá lại bằng hệ thống ràng buộc và hàm mục tiêu.

Nghiệm có khóa xếp hạng tốt nhất được lựa chọn làm kết quả đầu ra cuối cùng của hệ thống.

Do giải thuật di truyền là một phương pháp metaheuristic, nghiệm đầu ra được xem là thời khóa biểu tốt nhất tìm được trong giới hạn tính toán, không phải nghiệm tối ưu toàn cục đã được chứng minh.


== Lưu đồ và mã giả thuật toán

Quy trình tổng thể của Proposed GA được chia thành ba giai đoạn chính:

- Khởi tạo quần thể và đánh giá chất lượng nghiệm ban đầu.

- Tiến hóa quần thể kết hợp chọn lọc, lai ghép, đột biến, sửa chữa nghiệm và bảo toàn cá thể ưu tú.

- Tinh chỉnh nghiệm tốt nhất, kiểm tra ràng buộc và trả về kết quả.

@fig_proposed_flowchart minh họa lưu đồ thuật toán tổng thể của Proposed GA.

#figure(
  image("../picture/Lưu đồ thuật toán tổng thể – Mục 4.11.svg", width: 80%),
  caption: [Lưu đồ thuật toán tổng thể của Proposed GA.]
) <fig_proposed_flowchart>

Trong mã giả, hàm `Rank()` thực hiện so sánh theo cặp giá trị `(hard_violations, total_penalty)`.

Việc kiểm tra kích thước quần thể trước khi bổ sung cá thể con thứ hai giúp đảm bảo số lượng cá thể luôn bằng $N_"pop"$.

Điều này cần thiết vì số lượng cá thể ưu tú là 5, trong khi mỗi lần lai ghép tạo ra hai cá thể con. Nếu bổ sung đồng thời cả hai cá thể mà không kiểm tra giới hạn, kích thước quần thể có thể vượt quá giá trị thiết lập.

Việc lưu trữ bản sao của cá thể tốt nhất giúp tránh trường hợp nghiệm đã được ghi nhận bị thay đổi ngoài ý muốn trong các thao tác sửa chữa hoặc tìm kiếm cục bộ.

Các giá trị thống kê được ghi nhận sau mỗi thế hệ để phục vụ quá trình phân tích thực nghiệm, bao gồm Fitness, số lượng vi phạm ràng buộc cứng, điểm phạt mềm, điểm phạt Bonus và tỷ lệ đột biến hiện tại.

Sau khi hoàn thành quá trình tiến hóa, nghiệm tốt nhất được tinh chỉnh, đánh giá lại và kiểm tra toàn bộ hệ thống ràng buộc trước khi xuất kết quả.


== Phân tích độ phức tạp thuật toán

Để phân tích chi phí tính toán của phương pháp đề xuất, nhóm sử dụng các ký hiệu:

- $N = |cal(S)|$: Số lớp học phần.

- $M = |cal(P)|$: Số giảng viên.

- $R = |cal(R)|$: Số phòng học.

- $D = |cal(D)|$: Số ngày học.

- $T = |cal(T)|$: Số ca học mỗi ngày.

- $N_"pop"$: Kích thước quần thể.

- $G_"max"$: Số thế hệ tối đa.

- $K_"hard"$: Số thao tác sửa chữa ràng buộc cứng được thực hiện trên một cá thể.

- $K_"soft"$: Số thao tác tìm kiếm cục bộ được thực hiện trên một cá thể.

*Độ phức tạp của quá trình đánh giá Fitness.*

Để đánh giá một nhiễm sắc thể, hệ thống cần duyệt qua toàn bộ $N$ lớp học phần, tương ứng với $2N$ buổi học.

Trong quá trình duyệt, hệ thống xây dựng hoặc cập nhật các cấu trúc thống kê về mức độ sử dụng phòng học, lịch giảng viên, khối lượng giảng dạy và phân bố buổi học theo môn.

Các cấu trúc đếm và biểu diễn bitmask được sử dụng để hỗ trợ kiểm tra trạng thái sử dụng tài nguyên.

Nếu sử dụng bảng đếm theo toàn bộ miền tài nguyên, độ phức tạp của quá trình đánh giá có thể biểu diễn bởi:

$ C_"eval" =
O(N + M D T + D T R + |cal(C)|) $

Trong đó:

- $N$ tương ứng với chi phí duyệt toàn bộ các lớp học phần.

- $M D T$ tương ứng với không gian thống kê lịch giảng viên.

- $D T R$ tương ứng với không gian thống kê sử dụng phòng học.

- $|cal(C)|$ tương ứng với chi phí tổng hợp thống kê theo môn.

Với số ngày và ca học cố định, chi phí đánh giá tăng gần tuyến tính theo quy mô các đối tượng của bài toán.

Nếu sử dụng cấu trúc dữ liệu thưa và thao tác bitmask hiệu quả, chi phí thực tế có thể được giảm do không cần duyệt những vị trí tài nguyên không được sử dụng.

*Độ phức tạp của quá trình chọn lọc.*

Mỗi lần Tournament Selection cần so sánh tối đa $k$ cá thể.

Do các thuộc tính đánh giá được lưu trữ trong nhiễm sắc thể, việc so sánh hai khóa xếp hạng có chi phí hằng số.

Do đó, độ phức tạp của một lần chọn lọc là:

$ C_"selection" = O(k) $

Với $k = 5$ cố định, chi phí chọn lọc có thể xem là $O(1)$ đối với mỗi lần thực hiện.

*Độ phức tạp của toán tử lai ghép.*

Uniform Crossover cần duyệt qua toàn bộ $N$ gen để lựa chọn thông tin từ hai cá thể cha mẹ.

Course-Block Crossover thực hiện trao đổi các khối gen thuộc những môn được lựa chọn.

Trong trường hợp cần sao chép toàn bộ nhiễm sắc thể để tạo cá thể con độc lập, độ phức tạp của quá trình lai ghép là:

$ C_"crossover" = O(N) $

Chi phí này bao gồm việc tạo bản sao và cập nhật những gen được lựa chọn để trao đổi.

*Độ phức tạp của toán tử đột biến.*

Nếu thuật toán duyệt qua toàn bộ nhiễm sắc thể để quyết định gen nào được đột biến, chi phí duyệt là:

$ O(N) $

Số gen kỳ vọng được lựa chọn đột biến là:

$ E[N_"mutation"] = p_m N $

Gọi $C_"mut"$ là chi phí xử lý một gen được đột biến. Khi đó, chi phí kỳ vọng của toán tử đột biến có thể biểu diễn bởi:

$ O(N + p_m N C_"mut") $

Giá trị $C_"mut"$ phụ thuộc vào phương pháp lựa chọn giảng viên, tìm kiếm phòng–ca và tìm kiếm lớp học phần phù hợp cho phép hoán đổi.

*Độ phức tạp của cơ chế sửa chữa nghiệm.*

Đối với một buổi học cần sửa chữa, thuật toán có thể phải khảo sát nhiều vị trí phòng–ca trong cùng ngày.

Số vị trí ứng viên tối đa trong một ngày là:

$ T R $

Nếu trạng thái tài nguyên được lưu trữ bằng cấu trúc cho phép kiểm tra hiệu quả, chi phí khảo sát các vị trí trong cùng ngày có thể được biểu diễn bởi:

$ O(T R) $

Khi cần thay đổi cả cặp ngày, phạm vi tìm kiếm được mở rộng sang các ngày hợp lệ khác.

Đối với pha tìm kiếm cục bộ bằng hoán đổi cặp, chi phí phụ thuộc vào số cặp buổi học được khảo sát và chi phí đánh giá sự thay đổi của hàm phạt.

Gọi:

- $C_"move"$ là chi phí của một thao tác tìm kiếm vị trí thay thế.

- $C_"local"$ là chi phí của một thao tác tìm kiếm và đánh giá nghiệm lân cận.

Khi đó, chi phí sửa chữa một cá thể có thể biểu diễn tổng quát bởi:

$ C_"repair" =
O(N
+ K_"hard" C_"move"
+ K_"soft" C_"local") $

Thành phần $O(N)$ phản ánh chi phí duyệt và xây dựng các thông tin cần thiết để xác định những buổi học hoặc lớp học cần sửa chữa.

Độ phức tạp thực tế phụ thuộc vào số lượng xung đột hiện có, giới hạn số lần thử sửa chữa, cách tổ chức dữ liệu và phạm vi tìm kiếm của từng pha.

*Độ phức tạp của một thế hệ tiến hóa.*

Trong mỗi thế hệ, thuật toán cần bảo toàn các cá thể ưu tú, thực hiện chọn lọc, lai ghép, đột biến, sửa chữa và đánh giá quần thể mới.

Với giả định các cá thể con được sửa chữa theo xác suất $p_"repair"$, chi phí kỳ vọng của một thế hệ có thể biểu diễn dưới dạng:

$
C_"generation" =
O(
N_"pop" log N_"pop"
+ N_"pop" (
k + N + p_m N C_"mut"
+ C_"eval"
+ p_"repair" C_"repair"
))
$

Trong đó, thành phần $N_"pop" log N_"pop"$ phản ánh chi phí sắp xếp quần thể để lựa chọn các cá thể ưu tú nếu phương pháp sắp xếp toàn bộ được sử dụng.

*Độ phức tạp tổng thể.*

Gọi $C_"init"$ là tổng chi phí khởi tạo và sửa chữa quần thể ban đầu, $C_"polish"$ là chi phí của một lượt tinh chỉnh định kỳ và $C_"final"$ là chi phí tinh chỉnh cuối cùng.

Độ phức tạp kỳ vọng của toàn bộ quá trình được biểu diễn tổng quát bởi:

$
C_"total" =
O(
C_"init"
+ G_"max" C_"generation"
+ floor(G_"max" / 5) C_"polish"
+ C_"final"
)
$

Biểu thức trên cho thấy chi phí tính toán không chỉ phụ thuộc vào kích thước quần thể và số thế hệ mà còn chịu ảnh hưởng của số lượng thao tác sửa chữa và tìm kiếm cục bộ.

So với Baseline GA và Improved GA, Proposed GA cần bổ sung chi phí xử lý của Repair Mechanism và Pairwise Swap.

Đổi lại, các kỹ thuật này hướng đến giảm số lượng xung đột và nâng cao chất lượng nghiệm trong cùng giới hạn số thế hệ.

Trong điều kiện thực nghiệm được trình bày tại Chương 6, Proposed GA có thời gian thực thi khoảng 136,9 giây với kích thước quần thể 80 và 200 thế hệ.

Đây là thời gian đo được trong môi trường thực nghiệm cụ thể, không phải giới hạn thời gian thực thi chung của thuật toán.

Việc đánh giá mức độ phù hợp giữa chất lượng nghiệm và chi phí tính toán sẽ được trình bày chi tiết trong Chương 6.