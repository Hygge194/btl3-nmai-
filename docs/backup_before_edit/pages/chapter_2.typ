= CƠ SỞ LÝ THUYẾT (THEORETICAL BACKGROUND)

== Tổng quan bài toán xếp thời khóa biểu

Bài toán xếp thời khóa biểu giáo dục (_Educational Timetabling Problem_) là quá trình phân bổ các hoạt động giáo dục vào một tập hữu hạn các khung thời gian và tài nguyên, sao cho thỏa mãn những ràng buộc được xác định trước @schaerf1999survey.

Trong môi trường đại học, bài toán xếp thời khóa biểu thường được phân thành hai nhóm chính:

- *Xếp lịch thi (Examination Timetabling):* Phân bổ các kỳ thi vào những khung thời gian và phòng thi phù hợp, đồng thời hạn chế xung đột lịch thi của sinh viên.

- *Xếp lịch học (Course Timetabling):* Phân bổ các lớp học phần vào những khung thời gian, phòng học và giảng viên phù hợp, đảm bảo đáp ứng các yêu cầu về tổ chức giảng dạy và sử dụng tài nguyên.

Bài toán được nghiên cứu trong Homework 3 thuộc nhóm xếp lịch học đại học (_University Course Timetabling Problem – UCTP_). Trong đó, hệ thống cần thực hiện đồng thời việc phân công giảng viên, lựa chọn phòng học và bố trí thời gian cho từng lớp học phần.

Bên cạnh các ràng buộc phổ biến như không trùng lịch giảng viên và không trùng phòng học, bài toán còn yêu cầu sự tương thích giữa kích thước phòng và quy mô lớp học, đồng thời đảm bảo hai buổi học của mỗi lớp được bố trí vào những ngày khác nhau và không liền kề.

Ngoài việc tìm kiếm một thời khóa biểu hợp lệ, bài toán còn hướng đến nâng cao chất lượng lịch giảng dạy, giảm thời gian chờ giữa các ca học và tối ưu hóa hiệu quả sử dụng phòng học.


== Bài toán tối ưu tổ hợp

Bài toán tối ưu tổ hợp (_Combinatorial Optimization Problem_) là một dạng bài toán tối ưu hóa trong đó các biến quyết định nhận giá trị từ những tập hữu hạn hoặc rời rạc. Mục tiêu của bài toán là tìm kiếm một nghiệm có giá trị hàm mục tiêu tốt nhất trong tập các nghiệm khả thi.

Một bài toán tối ưu tổ hợp có thể được biểu diễn bởi bộ ba:

$ cal(P) = (Omega, cal(F), f) $

Trong đó:

- $Omega$ là không gian tìm kiếm (_Search Space_), bao gồm tất cả các nghiệm ứng viên có thể được biểu diễn.

- $cal(F) subset.eq Omega$ là tập nghiệm khả thi (_Feasible Solutions_), bao gồm những nghiệm thỏa mãn toàn bộ các ràng buộc bắt buộc.

- $f: Omega arrow.r RR$ là hàm mục tiêu (_Objective Function_), được sử dụng để đánh giá chất lượng của từng nghiệm.

Đối với bài toán tối thiểu hóa, nghiệm tối ưu toàn cục được xác định như sau:

$ x^* in arg min_(x in cal(F)) f(x) $

Trong bài toán xếp thời khóa biểu, mỗi nghiệm ứng viên tương ứng với một phương án phân bổ giảng viên, phòng học và thời gian cho toàn bộ các lớp học phần. Không gian tìm kiếm được hình thành từ tổ hợp của các phương án phân bổ này.

Nhiều biến thể của bài toán xếp thời khóa biểu đại học thuộc lớp bài toán NP-hard @lewis2008survey. Điều này cho thấy việc tìm kiếm nghiệm tối ưu toàn cục trong trường hợp tổng quát gặp nhiều khó khăn về độ phức tạp tính toán.

Khi quy mô bài toán tăng lên, các phương pháp tìm kiếm chính xác như vét cạn hoặc quay lui có thể đòi hỏi chi phí tính toán rất lớn. Vì vậy, các phương pháp heuristic và metaheuristic thường được sử dụng nhằm tìm kiếm những nghiệm có chất lượng tốt trong khoảng thời gian tính toán phù hợp.


== Bài toán tối ưu có ràng buộc

Bài toán tối ưu có ràng buộc (_Constrained Optimization Problem_) là bài toán tìm kiếm nghiệm tối ưu trong một không gian nghiệm chịu sự giới hạn của các điều kiện xác định trước.

Một mô hình tổng quát của bài toán tối thiểu hóa có ràng buộc được biểu diễn như sau:

$ min_(x in Omega) f(x) $

với các điều kiện:

$ g_i(x) <= 0, quad i = 1, 2, ..., m $

$ h_j(x) = 0, quad j = 1, 2, ..., n $

Trong bài toán xếp thời khóa biểu, các ràng buộc thường được phân thành hai nhóm chính:

- *Ràng buộc cứng (Hard Constraints):* Là những điều kiện bắt buộc phải được thỏa mãn để nghiệm có thể sử dụng trong thực tế. Ví dụ, một giảng viên không thể phụ trách hai lớp học tại cùng một thời điểm, hoặc một phòng học không thể được sử dụng đồng thời bởi nhiều lớp. Một nghiệm vi phạm ít nhất một ràng buộc cứng được xem là nghiệm không khả thi.

- *Ràng buộc mềm (Soft Constraints):* Là những điều kiện phản ánh mức độ thuận tiện và chất lượng của thời khóa biểu. Ví dụ, hạn chế các khoảng trống giữa những ca dạy của giảng viên hoặc ưu tiên sử dụng phòng học có kích thước phù hợp với quy mô lớp. Việc vi phạm ràng buộc mềm không làm mất tính khả thi của nghiệm nhưng làm giảm chất lượng nghiệm.

Gọi $H(x)$ là tổng số vi phạm ràng buộc cứng và $S(x)$ là tổng mức phạt ràng buộc mềm của nghiệm $x$. Khi đó, mục tiêu tổng quát của bài toán có thể được biểu diễn như sau:

$ min_(x in Omega) S(x) $

với điều kiện:

$ H(x) = 0 $

Như vậy, quá trình giải quyết bài toán cần ưu tiên tìm kiếm nghiệm khả thi trước khi tiếp tục cải thiện chất lượng nghiệm thông qua việc giảm mức độ vi phạm các ràng buộc mềm.


== Thuật toán di truyền (Genetic Algorithm)

Giải thuật di truyền (_Genetic Algorithm – GA_) là một phương pháp tối ưu hóa thuộc nhóm thuật toán tiến hóa (_Evolutionary Algorithms_), được phát triển dựa trên các nguyên lý của quá trình chọn lọc tự nhiên và di truyền sinh học.

Nền tảng lý thuyết của giải thuật di truyền được xây dựng bởi John Holland @holland1992adaptation và tiếp tục được phát triển, hệ thống hóa bởi David Goldberg @goldberg1989genetic.

Thay vì tìm kiếm trên một nghiệm duy nhất, GA duy trì một quần thể gồm nhiều nghiệm ứng viên. Qua mỗi thế hệ, các nghiệm được đánh giá và cải thiện thông qua những toán tử di truyền, bao gồm chọn lọc, lai ghép và đột biến.

Quy trình hoạt động tổng quát của giải thuật di truyền gồm các bước:

+ Khởi tạo quần thể nghiệm ban đầu.
+ Đánh giá chất lượng của từng cá thể.
+ Lựa chọn các cá thể cha mẹ.
+ Thực hiện lai ghép để tạo ra cá thể con.
+ Thực hiện đột biến nhằm duy trì tính đa dạng.
+ Hình thành quần thể cho thế hệ tiếp theo.
+ Lặp lại quá trình cho đến khi thỏa mãn điều kiện dừng.

Thông qua quá trình tiến hóa, GA hướng đến việc cải thiện dần chất lượng của các nghiệm trong quần thể. @fig_ga_flowchart minh họa quy trình hoạt động tổng quát của giải thuật di truyền.

#figure(
  image("../picture/quy trinh ga tong quat.svg", width: 70%),
  caption: [Sơ đồ quy trình hoạt động tổng quát của giải thuật di truyền (Genetic Algorithm).]
) <fig_ga_flowchart>


=== Gene và Chromosome

*Gene (Gen)* là đơn vị thông tin cơ bản trong giải thuật di truyền, được sử dụng để biểu diễn một biến quyết định hoặc một nhóm biến quyết định có mối liên hệ với nhau.

*Chromosome (Nhiễm sắc thể)* là một cấu trúc dữ liệu bao gồm tập hợp có thứ tự các gen, biểu diễn đầy đủ một nghiệm ứng viên của bài toán.

Một nhiễm sắc thể có thể được biểu diễn dưới dạng:

$ X = (g_1, g_2, ..., g_n) $

Trong đó, $g_i$ là gen thứ $i$ và $n$ là tổng số gen trong nhiễm sắc thể.

Đối với bài toán xếp thời khóa biểu trong đề tài, mỗi gen được sử dụng để biểu diễn thông tin phân bổ của một lớp học phần, bao gồm giảng viên phụ trách và thông tin lịch học của hai buổi trong tuần.

Một nhiễm sắc thể hoàn chỉnh gồm 480 gen, tương ứng với thời khóa biểu của toàn bộ 480 lớp học phần.

Việc lựa chọn phương pháp biểu diễn nhiễm sắc thể phù hợp có ảnh hưởng trực tiếp đến hiệu quả của các toán tử di truyền, khả năng duy trì cấu trúc nghiệm và chi phí kiểm tra ràng buộc.


=== Population và Generation

*Population (Quần thể)* là tập hợp các nhiễm sắc thể được duy trì tại một thời điểm trong quá trình tiến hóa.

Quần thể tại thế hệ thứ $t$ được biểu diễn như sau:

$ P_t = {X_1^t, X_2^t, ..., X_(N_"pop")^t} $

Trong đó:

- $N_"pop"$ là kích thước quần thể.
- $X_i^t$ là cá thể thứ $i$ tại thế hệ thứ $t$.

Việc duy trì nhiều cá thể trong quần thể cho phép giải thuật di truyền khám phá nhiều vùng khác nhau của không gian tìm kiếm.

*Generation (Thế hệ)* là một bước tiến hóa của thuật toán, trong đó quần thể hiện tại được sử dụng để tạo ra quần thể mới thông qua quá trình chọn lọc, lai ghép, đột biến và thay thế cá thể.

Kích thước quần thể và số thế hệ là hai tham số có ảnh hưởng đáng kể đến sự cân bằng giữa chất lượng nghiệm và thời gian tính toán.


=== Fitness Function

Hàm thích nghi (_Fitness Function_) là hàm đánh giá chất lượng của mỗi cá thể trong quần thể. Giá trị của hàm thích nghi được sử dụng để định hướng quá trình chọn lọc và xác định mức độ ưu tiên của các cá thể trong quá trình tiến hóa.

Trong trường hợp bài toán được xây dựng dưới dạng tối đa hóa độ thích nghi, nghiệm có giá trị Fitness cao hơn thường được ưu tiên trong quá trình chọn lọc.

Đối với bài toán tối thiểu hóa, một phương pháp chuyển đổi thường được sử dụng là:

$ F(x) = 1 / (1 + P(x)) $

Trong đó:

- $P(x) >= 0$ là tổng chi phí hoặc tổng mức phạt của nghiệm $x$.

- $F(x) in (0, 1]$ là giá trị độ thích nghi tương ứng.

Khi tổng mức phạt giảm, giá trị Fitness tăng. Do đó, việc tối đa hóa hàm thích nghi tương đương với việc tối thiểu hóa tổng mức phạt.

Đối với bài toán xếp thời khóa biểu, hàm thích nghi cần phản ánh cả tính khả thi và chất lượng của nghiệm. Vì vậy, quá trình đánh giá thường kết hợp số lượng vi phạm ràng buộc cứng, mức phạt ràng buộc mềm và các tiêu chí mở rộng.

Công thức hàm thích nghi cụ thể được sử dụng trong đề tài sẽ được trình bày tại Chương 4.


=== Selection

Toán tử chọn lọc (_Selection_) có nhiệm vụ lựa chọn các cá thể từ quần thể hiện tại để tham gia vào quá trình sinh ra thế hệ tiếp theo.

Mục tiêu của quá trình chọn lọc là ưu tiên những cá thể có chất lượng tốt, đồng thời duy trì mức độ đa dạng cần thiết của quần thể.

Một số phương pháp chọn lọc phổ biến bao gồm:

- Roulette Wheel Selection.
- Rank-based Selection.
- Tournament Selection.

Trong đề tài này, nhóm sử dụng phương pháp chọn lọc đấu giải (_Tournament Selection_).

Phương pháp hoạt động bằng cách lựa chọn ngẫu nhiên $k$ cá thể từ quần thể và xác định cá thể tốt nhất trong nhóm theo tiêu chí đánh giá đã được thiết lập.

Kích thước đấu giải $k$ ảnh hưởng đến áp lực chọn lọc (_Selection Pressure_). Khi $k$ tăng, các cá thể có chất lượng cao có xu hướng được lựa chọn thường xuyên hơn. Tuy nhiên, áp lực chọn lọc quá lớn có thể làm giảm tính đa dạng và dẫn đến hiện tượng hội tụ sớm.

Tournament Selection được lựa chọn nhờ cấu trúc đơn giản, dễ hiện thực và không yêu cầu giá trị Fitness của các cá thể phải tuân theo một phân bố xác suất cụ thể.


=== Crossover

Toán tử lai ghép (_Crossover_) là quá trình kết hợp thông tin di truyền từ hai cá thể cha mẹ để tạo ra các cá thể con.

Quá trình lai ghép thường được thực hiện với xác suất $p_c$, được gọi là tỷ lệ lai ghép (_Crossover Rate_).

Mục tiêu của toán tử này là kết hợp những đặc điểm phù hợp từ các nghiệm hiện có, từ đó tạo ra những phương án phân bổ mới có khả năng cải thiện chất lượng nghiệm.

Một số phương pháp lai ghép phổ biến bao gồm:

- *Single-point Crossover:* Thực hiện trao đổi các đoạn gen tại một vị trí cắt.

- *Two-point Crossover:* Thực hiện trao đổi đoạn gen nằm giữa hai vị trí cắt.

- *Uniform Crossover:* Lựa chọn gen tại từng vị trí từ một trong hai cá thể cha mẹ.

- *Block-based Crossover:* Thực hiện trao đổi các nhóm gen có mối liên hệ với nhau theo cấu trúc bài toán.

Đối với bài toán xếp thời khóa biểu, việc trao đổi nguyên vẹn một gen hoặc một khối gen tương ứng với một môn học có thể giúp duy trì cấu trúc lịch của từng lớp học phần.

Tuy nhiên, quá trình lai ghép vẫn có thể tạo ra những xung đột mới về phòng học hoặc giảng viên. Vì vậy, các cá thể con cần được đánh giá và xử lý ràng buộc sau khi thực hiện lai ghép.


=== Mutation

Toán tử đột biến (_Mutation_) thực hiện các thay đổi trên một hoặc nhiều gen của nhiễm sắc thể nhằm tạo ra những cấu trúc nghiệm mới.

Quá trình đột biến được điều khiển bởi tỷ lệ đột biến $p_m$ (_Mutation Rate_). Tùy theo cách thiết kế thuật toán, tỷ lệ này có thể được áp dụng trên từng gen hoặc từng cá thể.

Đột biến đóng vai trò quan trọng trong việc duy trì tính đa dạng của quần thể, mở rộng phạm vi tìm kiếm và giảm nguy cơ hội tụ sớm tại các nghiệm tối ưu cục bộ (_Local Optima_).

Trong bài toán xếp thời khóa biểu, một số dạng đột biến phù hợp bao gồm:

- Thay đổi ngày học hoặc ca học.
- Thay đổi phòng học.
- Thay đổi giảng viên phụ trách.
- Hoán đổi thông tin lịch giữa các lớp hoặc buổi học.

Việc lựa chọn tỷ lệ đột biến cần đảm bảo sự cân bằng giữa khả năng khám phá các nghiệm mới và khả năng duy trì những cấu trúc có chất lượng tốt đã được hình thành trong quá trình tiến hóa.


=== Elitism

Cơ chế bảo toàn cá thể ưu tú (_Elitism_) được sử dụng nhằm duy trì những cá thể có chất lượng tốt nhất từ thế hệ hiện tại sang thế hệ tiếp theo.

Giả sử quần thể có kích thước $N_"pop"$ và số lượng cá thể ưu tú được giữ lại là $E$, với:

$ 1 <= E < N_"pop" $

Khi đó, $E$ cá thể tốt nhất được sao chép trực tiếp sang quần thể mới mà không chịu tác động của các toán tử lai ghép và đột biến.

Nếu các cá thể ưu tú được giữ nguyên và tiêu chí xếp hạng không thay đổi, chất lượng của cá thể tốt nhất theo tiêu chí đó sẽ không suy giảm qua các thế hệ.

Trong trường hợp xếp hạng trực tiếp theo Fitness, tính chất này được biểu diễn như sau:

$ F_"best"^(t+1) >= F_"best"^t $

Trong đó, $F_"best"^t$ là giá trị Fitness tốt nhất tại thế hệ thứ $t$.

Cơ chế Elitism giúp hạn chế việc mất đi những nghiệm tốt trong quá trình tiến hóa. Tuy nhiên, số lượng cá thể ưu tú quá lớn có thể làm giảm tính đa dạng của quần thể.

Ngoài ra, Elitism chỉ đảm bảo duy trì chất lượng nghiệm tốt nhất theo tiêu chí đánh giá đã chọn, không đảm bảo thuật toán sẽ tìm được nghiệm tối ưu toàn cục.


=== Điều kiện dừng

Do giải thuật di truyền là một phương pháp tìm kiếm lặp, quá trình tiến hóa cần được giới hạn thông qua các điều kiện dừng phù hợp.

Một số điều kiện dừng thường được sử dụng bao gồm:

- Đạt số thế hệ tối đa $G_"max"$ đã được thiết lập.

- Tìm được nghiệm có chất lượng đạt ngưỡng mục tiêu xác định trước.

- Chất lượng của cá thể tốt nhất không tiếp tục cải thiện sau một số thế hệ liên tiếp.

- Đạt giới hạn về thời gian hoặc tài nguyên tính toán.

Việc lựa chọn điều kiện dừng cần cân bằng giữa chất lượng nghiệm và chi phí thực thi.

Đối với bài toán xếp thời khóa biểu có nhiều ràng buộc mềm, việc tìm kiếm nghiệm không có bất kỳ điểm phạt nào có thể không khả thi. Do đó, điều kiện dừng cần được xây dựng dựa trên đặc điểm của bài toán và mục tiêu thực nghiệm.


== Phương pháp xử lý ràng buộc

Một trong những thách thức khi áp dụng giải thuật di truyền vào bài toán tối ưu có ràng buộc là các toán tử di truyền có thể tạo ra những nghiệm không khả thi.

Để xử lý vấn đề này, nhiều phương pháp đã được nghiên cứu, trong đó hàm phạt (_Penalty Function_) và cơ chế sửa chữa nghiệm (_Repair Mechanism_) là hai hướng tiếp cận thường được sử dụng trong các thuật toán tiến hóa @coello2002theoretical.


=== Penalty Function

Phương pháp hàm phạt (_Penalty Function_) đánh giá mức độ vi phạm ràng buộc của một nghiệm bằng cách bổ sung các thành phần chi phí vào hàm mục tiêu.

Xét một bài toán tối thiểu hóa có hàm mục tiêu ban đầu là $f(x)$. Hàm mục tiêu có bổ sung thành phần phạt được biểu diễn tổng quát như sau:

$ P(x) = f(x) + sum_(i=1)^m w_i v_i(x) $

Trong đó:

- $m$ là số lượng ràng buộc được đánh giá.
- $v_i(x) >= 0$ là mức độ vi phạm ràng buộc thứ $i$ của nghiệm $x$.
- $w_i > 0$ là trọng số phạt tương ứng.

Đối với bài toán có cả ràng buộc cứng và ràng buộc mềm, hàm phạt có thể được biểu diễn dưới dạng:

$ P(x) = W_H H(x) + sum_(j=1)^n w_j S_j(x) $

Trong đó:

- $H(x)$ là tổng số vi phạm ràng buộc cứng.
- $W_H$ là trọng số phạt ràng buộc cứng.
- $S_j(x)$ là mức độ vi phạm ràng buộc mềm thứ $j$.
- $w_j$ là trọng số của ràng buộc mềm tương ứng.

Thông thường, trọng số phạt ràng buộc cứng được lựa chọn lớn hơn các trọng số phạt ràng buộc mềm nhằm hướng quá trình tìm kiếm về vùng nghiệm khả thi.

Tuy nhiên, việc sử dụng trọng số lớn không mặc nhiên đảm bảo mọi nghiệm khả thi đều được ưu tiên hơn nghiệm không khả thi. Điều này chỉ được đảm bảo khi trọng số phạt đủ lớn so với cận trên của các thành phần chi phí còn lại.

Một phương pháp bổ sung là sử dụng tiêu chí xếp hạng ưu tiên tính khả thi (_Feasibility-first Ranking_), trong đó các nghiệm được so sánh theo thứ tự:

+ Ưu tiên nghiệm có số vi phạm ràng buộc cứng thấp hơn.
+ Nếu có cùng số vi phạm ràng buộc cứng, ưu tiên nghiệm có tổng mức phạt thấp hơn.

Tiêu chí này có thể được biểu diễn thông qua bộ giá trị xếp hạng:

$ R(x) = (H(x), P(x)) $

Các nghiệm được so sánh theo thứ tự từ điển (_Lexicographic Ordering_).

Cách tiếp cận này giúp phân biệt rõ mục tiêu tìm kiếm nghiệm khả thi và mục tiêu cải thiện chất lượng nghiệm.


=== Repair Mechanism

Cơ chế sửa chữa nghiệm (_Repair Mechanism_) là phương pháp sử dụng thông tin về cấu trúc bài toán và các ràng buộc để điều chỉnh trực tiếp những nghiệm được tạo ra trong quá trình tìm kiếm.

Thay vì chỉ đánh giá và áp dụng mức phạt đối với các nghiệm không khả thi, cơ chế sửa chữa thực hiện những thay đổi có định hướng nhằm loại bỏ hoặc giảm số lượng vi phạm ràng buộc.

Trong bài toán xếp thời khóa biểu, các thao tác sửa chữa có thể bao gồm:

- Thay đổi phòng học khi xảy ra xung đột hoặc không đáp ứng yêu cầu về kích thước.

- Thay đổi ngày học hoặc ca học để giải quyết xung đột thời gian.

- Điều chỉnh phân công giảng viên nhằm đáp ứng giới hạn khối lượng giảng dạy.

- Hoán đổi vị trí giữa các buổi học để cải thiện phương án phân bổ tài nguyên.

Bên cạnh việc sửa chữa các vi phạm ràng buộc cứng, thuật toán tiến hóa có thể được kết hợp với phương pháp tìm kiếm cục bộ (_Local Search_) nhằm tiếp tục cải thiện chất lượng của các nghiệm khả thi.

Tìm kiếm cục bộ khảo sát những nghiệm lân cận được tạo ra từ các phép biến đổi nhỏ trên nghiệm hiện tại. Một ví dụ là kỹ thuật hoán đổi cặp (_Pairwise Swap_), trong đó thông tin phân bổ của hai buổi học được trao đổi để tìm kiếm phương án có mức phạt thấp hơn.

Sự kết hợp giữa thuật toán tiến hóa và cơ chế cải thiện nghiệm cục bộ là đặc trưng của giải thuật Memetic (_Memetic Algorithm_) @moscato1989memetic.

Trong cách tiếp cận này, giải thuật di truyền đảm nhiệm quá trình khám phá trên không gian nghiệm, trong khi tìm kiếm cục bộ hỗ trợ khai thác và cải thiện các nghiệm đã được hình thành.

Tuy nhiên, hiệu quả của cơ chế sửa chữa và tìm kiếm cục bộ phụ thuộc vào cách thiết kế các phép biến đổi, cấu trúc dữ liệu và đặc điểm ràng buộc của từng bài toán. Các phương pháp này không mặc nhiên đảm bảo tìm được nghiệm khả thi hoặc nghiệm tối ưu trong mọi trường hợp.


== Lý do lựa chọn thuật toán di truyền

Bài toán xếp thời khóa biểu đại học có không gian tìm kiếm lớn, nhiều biến quyết định rời rạc và các ràng buộc có mối liên hệ chặt chẽ với nhau. Vì vậy, việc lựa chọn phương pháp tối ưu cần xem xét đồng thời khả năng biểu diễn nghiệm, xử lý ràng buộc, chất lượng nghiệm và chi phí tính toán.

Một số phương pháp metaheuristic thường được áp dụng cho các bài toán tối ưu tổ hợp bao gồm Mô phỏng tôi luyện (_Simulated Annealing_), Tìm kiếm Tabu (_Tabu Search_) và Giải thuật Di truyền (_Genetic Algorithm_).

Trong khi các phiên bản cơ bản của Simulated Annealing và Tabu Search thường thực hiện quá trình tìm kiếm dựa trên một nghiệm hiện tại và tập nghiệm lân cận, giải thuật di truyền duy trì một quần thể gồm nhiều nghiệm ứng viên.

Trong phạm vi đề tài, giải thuật di truyền được lựa chọn dựa trên các đặc điểm sau:

+ *Khả năng khám phá không gian tìm kiếm:* Việc duy trì một quần thể gồm nhiều phương án thời khóa biểu giúp thuật toán khảo sát nhiều vùng khác nhau của không gian nghiệm, thay vì chỉ tập trung vào một phương án phân bổ.

+ *Khả năng biểu diễn nghiệm linh hoạt:* Cấu trúc gen và nhiễm sắc thể có thể được thiết kế phù hợp với đặc điểm của từng lớp học phần, hỗ trợ việc bảo toàn mối liên hệ giữa giảng viên và hai buổi học.

+ *Khả năng xử lý nhiều tiêu chí đánh giá:* Hàm thích nghi có thể tích hợp các thành phần đánh giá ràng buộc cứng, ràng buộc mềm và những yêu cầu mở rộng trong cùng một mô hình tối ưu.

+ *Khả năng kết hợp với các kỹ thuật cải tiến:* Giải thuật di truyền có thể được mở rộng bằng phương pháp khởi tạo tham lam, cơ chế sửa chữa nghiệm, đột biến thích nghi và tìm kiếm cục bộ nhằm nâng cao hiệu quả tìm kiếm.

Mặc dù có những ưu điểm trên, giải thuật di truyền vẫn tồn tại một số hạn chế như chi phí đánh giá quần thể, sự phụ thuộc vào các tham số thuật toán và nguy cơ hội tụ sớm. Ngoài ra, thuật toán không đảm bảo tìm được nghiệm tối ưu toàn cục trong mọi trường hợp.

Do đó, nhóm lựa chọn giải thuật di truyền làm phương pháp tối ưu chính, đồng thời nghiên cứu kết hợp các kỹ thuật xử lý ràng buộc và cải thiện nghiệm phù hợp với đặc điểm của bài toán xếp thời khóa biểu.

Mô hình toán học cụ thể của bài toán sẽ được trình bày tại Chương 3, làm cơ sở cho việc thiết kế và hiện thực thuật toán tại Chương 4.