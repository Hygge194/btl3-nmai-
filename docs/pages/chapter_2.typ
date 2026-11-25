= CƠ SỞ LÝ THUYẾT (THEORETICAL BACKGROUND)

== Bài toán xếp thời khóa biểu và tối ưu tổ hợp có ràng buộc

Bài toán xếp thời khóa biểu giáo dục (_Educational Timetabling Problem_) là quá trình phân bổ một tập hợp các sự kiện giảng dạy (lớp học phần, kỳ thi) vào tập hữu hạn khung thời gian và tài nguyên (phòng học, giảng viên) sao cho đáp ứng đầy đủ các quy định bắt buộc đồng thời nâng cao chất lượng sử dụng tài nguyên @schaerf1999survey. Trong môi trường đại học, bài toán thường được chia thành hai nhánh chính: xếp lịch thi (_Examination Timetabling_) — tập trung vào sức chứa phòng thi và giãn cách giữa các môn thi của sinh viên — và xếp lịch học phần (_University Course Timetabling Problem – UCTP_). Đề tài thuộc nhánh UCTP, với đặc thù là mỗi lớp học phần gồm nhiều buổi học lặp lại theo tuần và gắn chặt với cùng một giảng viên phụ trách.

Về mặt toán học, UCTP là một bài toán *tối ưu tổ hợp có ràng buộc* (_Constrained Combinatorial Optimization Problem_), được biểu diễn bởi bộ ba $cal(P) = (Omega, cal(F), f)$, trong đó $Omega$ là không gian tìm kiếm rời rạc chứa toàn bộ các cấu hình phân bổ có thể có, $cal(F) subset.eq Omega$ là miền nghiệm khả thi chứa các cấu hình thỏa mãn toàn bộ điều kiện bắt buộc, và $f: Omega arrow.r RR$ là hàm mục tiêu đánh giá chi phí hoặc chất lượng nghiệm. Với bài toán tối thiểu hóa, nghiệm tối ưu toàn cục thỏa mãn:
$ x^* in arg min_(x in cal(F)) f(x) $

Nhiều biến thể tổng quát của UCTP thuộc lớp *NP-hard* @lewis2008survey, có nghĩa là hiện chưa có thuật toán thời gian đa thức nào đảm bảo tìm được nghiệm tối ưu toàn cục cho mọi trường hợp đầu vào. Khi số lượng lớp học phần lên tới hàng trăm, không gian tìm kiếm $Omega$ bùng nổ theo hàm mũ, khiến các thuật toán tìm kiếm chính xác gặp giới hạn nghiêm trọng về bộ nhớ và thời gian thực thi. Do đó, các phương pháp *metaheuristic* thường được lựa chọn nhằm tìm nghiệm khả thi chất lượng cao trong giới hạn thời gian hợp lý.

Các điều kiện ràng buộc trong UCTP được phân tách thành hai nhóm có vai trò khác nhau:
- *Ràng buộc cứng (Hard Constraints):* Là các quy định mang tính bắt buộc tuyệt đối để một thời khóa biểu có thể triển khai trong thực tế, chẳng hạn không xếp hai lớp cùng phòng tại cùng khung giờ, không xếp một giảng viên dạy hai lớp cùng lúc, không vượt sức chứa phòng học và không sử dụng phòng đang bảo trì. Gọi $H(x) >= 0$ là tổng số vi phạm ràng buộc cứng, một nghiệm $x$ được gọi là *khả thi* khi và chỉ khi $H(x) = 0$.
- *Ràng buộc mềm (Soft Constraints):* Là các tiêu chí phản ánh chất lượng, sự thuận tiện và mức độ tối ưu trong vận hành (như hạn chế ca trống trong ngày của giảng viên, tập trung lịch dạy theo buổi, giảm lãng phí sức chứa phòng học). Mức độ vi phạm các tiêu chí này được tổng hợp thành hàm phạt mềm $S(x) >= 0$. Bài toán tối ưu tổng quát được phát biểu như sau:
$ min_(x in Omega) S(x) quad "với điều kiện" quad H(x) = 0 $

== Giải thuật di truyền (Genetic Algorithm)

Giải thuật di truyền (_Genetic Algorithm – GA_) thuộc nhóm thuật toán tìm kiếm ngẫu nhiên dựa trên quần thể, mô phỏng cơ chế tiến hóa và chọn lọc tự nhiên do John Holland đề xuất @holland1992adaptation và David Goldberg hệ thống hóa @goldberg1989genetic. Khác với các thuật toán tìm kiếm cục bộ chỉ duy trì một trạng thái hiện tại, GA vận hành trên một quần thể $P_t = {X_1^t, X_2^t, ..., X_(N_"pop")^t}$ gồm $N_"pop"$ cá thể ở thế hệ $t$ và liên tục cải thiện quần thể qua các bước đánh giá, chọn lọc, lai ghép, đột biến và thay thế (@fig_ga_flowchart).

#block(breakable: false)[
  #figure(
    image("../picture/quy trinh ga tong quat.svg", width: 52%),
    caption: [Sơ đồ quy trình hoạt động tổng quát của giải thuật di truyền (Genetic Algorithm).]
  ) <fig_ga_flowchart>
]

Cơ chế hoạt động của GA dựa trên sự phối hợp giữa hai quá trình đối nghịch nhưng bổ trợ lẫn nhau là *khám phá toàn cục (Exploration)* — tìm kiếm trên nhiều vùng mới của không gian trạng thái thông qua lai ghép và đột biến — và *khai thác cục bộ (Exploitation)* — tập trung tinh chỉnh quanh các nghiệm tốt thông qua chọn lọc và bảo toàn ưu tú. Các thành phần cốt lõi của GA bao gồm:

+ *Biểu diễn nghiệm (Gene và Chromosome):* Mỗi nghiệm ứng viên được mã hóa thành một nhiễm sắc thể $X = (g_1, g_2, ..., g_n)$ gồm $n$ gen. Bên cạnh mã hóa nhị phân truyền thống, các bài toán lập lịch hiện đại thường sử dụng *biểu diễn trực tiếp theo cấu trúc nghiệp vụ* (mỗi gen chứa bộ thuộc tính giảng viên, ngày, ca và phòng của một lớp học phần) nhằm giảm chi phí giải mã và giúp toán tử di truyền bảo toàn cấu trúc bài toán.
+ *Quần thể và Khởi tạo (Population & Initialization):* Kích thước quần thể $N_"pop"$ quyết định độ phủ không gian tìm kiếm và chi phí tính toán mỗi thế hệ. Nếu quần thể quá nhỏ, thuật toán dễ mất đa dạng và hội tụ sớm; nếu quá lớn, thời gian tính toán mỗi thế hệ tăng nhanh. Với bài toán có mật độ ràng buộc cao, *khởi tạo có định hướng (Heuristic / Greedy Randomized Initialization)* giúp tạo quần thể ban đầu nằm gần miền khả thi nhưng vẫn duy trì đủ yếu tố ngẫu nhiên để khám phá.
+ *Hàm thích nghi (Fitness Function):* Là thước đo định lượng chất lượng của từng cá thể, dẫn hướng cho quá trình chọn lọc. Đối với bài toán tối thiểu hóa tổng mức phạt $P(x) >= 0$, dạng chuẩn hóa nghịch đảo thường được sử dụng là:
  $ F(x) = frac(1, 1 + P(x)) in (0, 1] $
  Hàm $F(x)$ nghịch biến chặt theo $P(x)$: tổng phạt càng nhỏ thì độ thích nghi càng lớn và đạt cực đại bằng 1 khi $P(x) = 0$.
+ *Toán tử chọn lọc (Selection):* Chọn ra các cá thể cha mẹ có chất lượng tốt để sinh sản nhưng vẫn tạo cơ hội cho các cá thể trung bình nhằm bảo tồn tính đa dạng di truyền. Các cơ chế phổ biến gồm *Roulette Wheel Selection* (xác suất chọn tỷ lệ với giá trị Fitness, dễ bị chi phối khi Fitness chênh lệch nhiều bậc độ lớn), *Rank Selection* (chọn theo thứ hạng) và *Tournament Selection* (chọn ngẫu nhiên $k$ cá thể và lấy cá thể tốt nhất). Trong bài toán có ràng buộc cứng và mềm đan xen, *Tournament Selection* tỏ ra đặc biệt phù hợp vì không phụ thuộc vào tỷ lệ số học của giá trị Fitness, chỉ cần phép so sánh thứ tự giữa hai nghiệm và cho phép điều chỉnh áp lực chọn lọc trực tiếp qua kích thước giải đấu $k$.
+ *Toán tử lai ghép (Crossover):* Kết hợp vật liệu di truyền từ hai cá thể cha mẹ với xác suất $p_c$ (thường nằm trong khoảng $0.7$–$0.95$) để tạo cá thể con thừa hưởng các cấu trúc tốt (_building blocks_). Ngoài các dạng kinh điển như lai ghép một điểm (_Single-point_), hai điểm (_Two-point_) và đồng đều (_Uniform Crossover_), bài toán lập lịch thường sử dụng *lai ghép theo khối (Block-based Crossover)* để trao đổi trọn vẹn nhóm gen có liên kết chặt (chẳng hạn toàn bộ các lớp của cùng một môn học), tránh phá vỡ các cấu trúc đã tối ưu.
+ *Toán tử đột biến (Mutation):* Tạo các biến đổi cục bộ ngẫu nhiên trên gen với xác suất nhỏ $p_m$ nhằm khôi phục các giá trị bị mất trong quá trình chọn lọc và giúp thuật toán thoát khỏi cực trị cục bộ. Phiên bản *đột biến thích nghi (Adaptive Mutation)* tự động tăng $p_m$ khi quần thể có dấu hiệu chững lại qua nhiều thế hệ và giảm $p_m$ khi tìm thấy nghiệm cải thiện để tăng độ ổn định hội tụ.
+ *Bảo toàn ưu tú (Elitism) và Điều kiện dừng:* Elitism sao chép trực tiếp $E$ cá thể tốt nhất ($1 <= E < N_"pop"$) sang thế hệ tiếp theo mà không qua lai ghép hay đột biến, đảm bảo chất lượng nghiệm tốt nhất không bao giờ bị suy giảm qua các thế hệ ($F_"best"^(t+1) >= F_"best"^t$ theo tiêu chí xếp hạng). Về điều kiện dừng, do các bài toán tối ưu có ràng buộc mềm thường có cận dưới dương ($P(x) > 0$), thuật toán thường dừng khi đạt số thế hệ tối đa $G_"max"$ hoặc khi nghiệm tốt nhất không cải thiện sau một ngưỡng thế hệ quy định.

== Phương pháp xử lý ràng buộc và giải thuật Memetic

Các toán tử lai ghép và đột biến thuần túy mang tính ngẫu nhiên nên rất dễ tạo ra nghiệm không khả thi trong các bài toán có độ chặt tài nguyên cao. Trong lĩnh vực tính toán tiến hóa, các chiến lược xử lý ràng buộc chủ đạo bao gồm @coello2002theoretical:

*1. Phương pháp hàm phạt (Penalty Function) và Xếp hạng ưu tiên khả thi (Feasibility-first Ranking):*
Phương pháp hàm phạt biến đổi bài toán có ràng buộc thành bài toán không ràng buộc bằng cách cộng chi phí vi phạm vào hàm mục tiêu:
$ P(x) = W_H H(x) + sum_(j=1)^n w_j S_j(x) $
Ưu điểm của phương pháp này là đơn giản, dễ cài đặt và cho phép GA đi qua vùng nghiệm không khả thi để tìm cầu nối sang vùng khả thi tốt hơn. Tuy nhiên, việc chọn trọng số $W_H$ theo kinh nghiệm tiềm ẩn rủi ro: nếu $W_H$ quá nhỏ, nghiệm không khả thi có thể đạt tổng phạt thấp hơn nghiệm khả thi; nếu $W_H$ quá lớn, chênh lệch giá trị Fitness trở nên cực đoan. Để khắc phục triệt để, phương pháp *xếp hạng ưu tiên khả thi theo thứ tự từ điển (Lexicographic Feasibility-first Ranking)* định nghĩa khóa so sánh $R(x) = (H(x), P(x))$: mọi nghiệm có $H(x)$ nhỏ hơn luôn được đánh giá tốt hơn bất kể $P(x)$, và chỉ khi hai nghiệm có cùng $H(x)$ thì mới so sánh $P(x)$.

*2. Cơ chế sửa chữa nghiệm (Repair Mechanism) và Giải thuật Memetic (Memetic Algorithm):*
Thay vì chỉ phạt thụ động các cá thể lỗi, cơ chế sửa chữa khai thác tri thức đặc thù của miền bài toán để chủ động hiệu chỉnh các gen gây xung đột (điều chuyển giảng viên quá tải, dời buổi học khỏi phòng bảo trì hoặc trùng lịch). Khi kết hợp khung tiến hóa toàn cục của GA với các bước sửa chữa và tìm kiếm cục bộ trên vùng lân cận (ví dụ di chuyển đơn lẻ hoặc hoán đổi cặp _Pairwise Swap_), thuật toán trở thành *Giải thuật Memetic* (_Memetic Algorithm_) @moscato1989memetic @burke2007graph. Trong mô hình lai này, GA đóng vai trò định vị các vùng nghiệm hứa hẹn trên toàn không gian, còn tìm kiếm cục bộ tinh chỉnh từng cá thể tới cực trị địa phương tốt hơn, giúp rút ngắn đáng kể số thế hệ cần thiết để đạt trạng thái khả thi và tối ưu sâu.

== Lý do lựa chọn giải thuật di truyền và so sánh phương pháp

Để làm rõ cơ sở lựa chọn GA kết hợp Memetic cho bài toán xếp thời khóa biểu Homework 3, @tab_method_compare đối chiếu đặc điểm của GA với các hướng tiếp cận phổ biến khác trong giải bài toán UCTP @lewis2008survey @russell2020artificial.

#block(breakable: false)[
  #figure(
    table(
      columns: (1.45fr, 2.05fr, 2.05fr),
      align: (left, left, left),
      inset: 4.5pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Phương pháp*]),
        text(fill: white, [*Ưu điểm chính*]),
        text(fill: white, [*Hạn chế đối với bài toán đề tài*]),
      ),
      [Tìm kiếm chính xác (CSP / Backtracking / ILP)], [Đảm bảo tìm nghiệm chính xác hoặc tối ưu toàn cục ở quy mô nhỏ–vừa.], [Thời gian tính toán tăng nhanh khi quy mô 960 buổi có nhiều ràng buộc phi tuyến như ca trống $S_1$, ngày trống $S_2$.],
      [Tìm kiếm đơn nghiệm (Simulated Annealing, Tabu Search)], [Cài đặt gọn, chi phí mỗi bước lặp thấp, khai thác vùng lân cận tốt.], [Chỉ duy trì một nghiệm hiện tại; dễ mắc kẹt cục bộ khi mật độ phòng 93,75% tạo nhiều "hàng rào" xung đột cứng.],
      [*Giải thuật Di truyền lai (GA / Memetic)*], [Duy trì quần thể đa dạng khảo sát song song nhiều vùng; dễ mã hóa cấu trúc lớp học phần; dễ kết hợp nhiều tiêu chí và Repair cục bộ.], [Chi phí đánh giá quần thể lớn hơn tìm kiếm đơn nghiệm; không chứng minh được tính tối ưu toàn cục.],
    ),
    caption: [So sánh các nhóm phương pháp tiếp cận bài toán UCTP.]
  ) <tab_method_compare>
]

Từ sự so sánh trên, giải thuật di truyền lai theo hướng Memetic được lựa chọn vì đáp ứng đồng thời bốn yêu cầu của đề tài: (1) xử lý hiệu quả không gian tìm kiếm rất lớn thông qua cơ chế tiến hóa quần thể; (2) cho phép biểu diễn tự nhiên cấu trúc 480 lớp học phần gắn liền giảng viên và hai buổi học; (3) dễ dàng tích hợp đồng thời ba lớp tiêu chí cứng, mềm và mở rộng trong cùng khung đánh giá; và (4) thuận lợi để thiết kế thực nghiệm đối chứng từng bước cải tiến từ GA cơ bản đến GA lai có sửa chữa nghiệm.
