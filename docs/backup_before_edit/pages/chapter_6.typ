= THỰC NGHIỆM VÀ ĐÁNH GIÁ (EXPERIMENTS AND EVALUATION)

== Mục tiêu thực nghiệm

Sau khi xây dựng mô hình toán học, thiết kế thuật toán và hiện thực hệ thống, nhóm tiến hành thực nghiệm nhằm đánh giá tính đúng đắn, khả năng tìm kiếm nghiệm khả thi và hiệu quả tối ưu hóa của phương pháp đề xuất.

Quá trình thực nghiệm tập trung vào bốn mục tiêu chính:

+ *Kiểm tra tính đúng đắn của hệ thống:* Đánh giá các hàm kiểm tra ràng buộc cứng, ràng buộc mềm, tiêu chí mở rộng, hàm thích nghi và các toán tử di truyền thông qua bộ kiểm thử tự động.

+ *Đánh giá hiệu quả của phương pháp đề xuất:* So sánh kết quả thực thi giữa ba phiên bản Baseline GA, Improved GA và Proposed GA trên cùng bộ dữ liệu và hệ thống tiêu chí đánh giá.

+ *Phân tích ảnh hưởng của các siêu tham số:* Khảo sát sự thay đổi chất lượng nghiệm, khả năng hội tụ và thời gian thực thi khi điều chỉnh kích thước quần thể, tỷ lệ lai ghép, tỷ lệ đột biến và số thế hệ.

+ *Đánh giá chất lượng thời khóa biểu đầu ra:* Kiểm tra mức độ thỏa mãn các ràng buộc và phân tích kết quả dưới góc độ giảng viên, phòng học và môn học.

Thông qua các thực nghiệm này, nhóm hướng đến việc xác định mức độ phù hợp của những kỹ thuật cải tiến đã đề xuất, bao gồm khởi tạo cân bằng tải theo ngày, lai ghép theo khối môn học, cơ chế sửa chữa nghiệm và tìm kiếm cục bộ bằng hoán đổi cặp.

Bên cạnh chất lượng nghiệm, quá trình đánh giá cũng xem xét chi phí tính toán nhằm phân tích sự đánh đổi giữa hiệu quả tối ưu hóa và thời gian thực thi.


== Môi trường và bộ dữ liệu thực nghiệm

*Môi trường thực nghiệm.*

Các thí nghiệm được thực hiện trên hệ điều hành Windows, sử dụng Python 3.12.1 và các thư viện đã được trình bày tại Chương 5.

Ba phiên bản thuật toán được thực thi tuần tự trên cùng môi trường phần cứng và phần mềm, không áp dụng cơ chế song song hóa trong vòng lặp tiến hóa.

Việc sử dụng chung môi trường thực nghiệm giúp hạn chế ảnh hưởng của sự khác biệt về tài nguyên tính toán đối với kết quả so sánh thời gian thực thi.

*Bộ dữ liệu thực nghiệm.*

Bộ dữ liệu được sinh thông qua Data Generation Module với giá trị khởi tạo ngẫu nhiên `seed = 42`.

Các thông số chính của bộ dữ liệu được trình bày trong bảng sau.

#figure(
  table(
    columns: (2.5fr, 1.5fr),
    align: (left, center),
    table.header(
      [*Thông số*],
      [*Giá trị*],
    ),
    [Số môn học], [60],
    [Số lớp học phần], [480],
    [Số buổi học], [960],
    [Số giảng viên], [60],
    [Số phòng học], [35],
    [Số phòng kích thước nhỏ], [11],
    [Số phòng kích thước trung bình], [11],
    [Số phòng kích thước lớn], [13],
    [Số ngày học mỗi tuần], [5],
    [Số ca học mỗi ngày], [6],
    [Số vị trí phòng–ca lý thuyết], [1050],
    [Số vị trí không khả dụng], [26],
    [Số vị trí khả dụng], [1024],
    [Data Seed], [42],
    [GA Seed], [2026],
  ),
  caption: [Thông số của bộ dữ liệu thực nghiệm.]
) <tab_experiment_data>

Trong tổng số 1050 vị trí phòng–ca theo lý thuyết, nhóm mô phỏng 26 vị trí không khả dụng, tương ứng với khoảng 2,48% tổng tài nguyên.

Do đó, số vị trí phòng–ca thực tế khả dụng là:

$ C_"room" = 1050 - 26 = 1024 $

Tỷ lệ sử dụng phòng học cần thiết để phân bổ đầy đủ 960 buổi học được xác định bởi:

$ U_"room" = 960 / 1024 times 100% = 93.75% $

Số vị trí khả dụng còn lại sau khi phân bổ đầy đủ các buổi học chỉ là 64.

Phân bố số vị trí phòng–ca khả dụng theo từng ngày được trình bày trong bảng sau.

#figure(
  table(
    columns: (1.3fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: center,
    table.header(
      [*Ngày*],
      [*Thứ 2*],
      [*Thứ 3*],
      [*Thứ 4*],
      [*Thứ 5*],
      [*Thứ 6*],
    ),
    [Khả dụng], [204], [205], [205], [205], [205],
    [Tải mục tiêu], [192], [192], [192], [192], [192],
    [Dự phòng], [12], [13], [13], [13], [13],
  ),
  caption: [Phân bố tài nguyên phòng học theo ngày.]
) <tab_daily_capacity>

Trong đó, tải mục tiêu 192 buổi mỗi ngày được xác định từ phương pháp cân bằng tải đã phân tích tại Chương 3.

Đối với phân bố theo buổi học, tổng số vị trí khả dụng vào buổi sáng là 515 và vào buổi chiều là 509.

Như vậy, việc chia 60 môn học thành hai nhóm gồm 30 môn ưu tiên buổi sáng và 30 môn ưu tiên buổi chiều tạo ra nhu cầu dự kiến 480 buổi học cho mỗi nhóm, thấp hơn tổng công suất khả dụng tương ứng.

Tuy nhiên, sự phù hợp về tổng công suất không đảm bảo mọi môn học đều có thể được bố trí hoàn toàn trong buổi ưu tiên, do còn tồn tại các ràng buộc về kích thước phòng, lịch giảng viên và khoảng cách giữa hai buổi học.

Đối với dữ liệu giảng viên, mỗi môn học có tối thiểu năm giảng viên có thể đảm nhận và tối thiểu hai giảng viên lựa chọn môn đó trong danh sách Top-3 yêu thích.

Điều kiện này giúp hạn chế tình trạng một số môn học có quá ít ứng viên giảng dạy, đồng thời duy trì đủ sự linh hoạt cho quá trình phân công.

Việc sử dụng giá trị khởi tạo ngẫu nhiên cố định giúp tái lập bộ dữ liệu trong những lần thực nghiệm tiếp theo.

Trong đó, `seed = 42` được sử dụng cho quá trình sinh dữ liệu, còn `ga-seed = 2026` được sử dụng cho các thao tác ngẫu nhiên của giải thuật di truyền.

Việc tách riêng hai giá trị này cho phép giữ nguyên dữ liệu bài toán trong khi thay đổi quá trình tìm kiếm của thuật toán, phục vụ các nghiên cứu đánh giá tính ổn định trong tương lai.


== Cấu hình tham số thuật toán

Để đảm bảo sự nhất quán trong quá trình so sánh, ba phiên bản thuật toán sử dụng cùng bộ dữ liệu, hệ thống trọng số và các tham số tiến hóa chung.

Các giá trị cấu hình mặc định được trình bày trong bảng sau.

#figure(
  table(
    columns: (2fr, 1fr, 2.5fr),
    align: (left, center, left),
    table.header(
      [*Tham số*],
      [*Giá trị*],
      [*Ý nghĩa*],
    ),

    [`POPULATION_SIZE`],
    [80],
    [Số cá thể trong mỗi thế hệ.],

    [`MAX_GENERATIONS`],
    [200],
    [Số thế hệ tiến hóa tối đa.],

    [`CROSSOVER_RATE`],
    [0,85],
    [Xác suất thực hiện lai ghép.],

    [`MUTATION_RATE`],
    [0,015],
    [Tỷ lệ đột biến khởi tạo.],

    [Maximum Mutation Rate],
    [0,060],
    [Giới hạn trên trong chế độ đột biến thích nghi mặc định.],

    [`TOURNAMENT_SIZE`],
    [5],
    [Số cá thể tham gia mỗi lần chọn lọc đấu giải.],

    [`ELITE_SIZE`],
    [5],
    [Số cá thể ưu tú được bảo toàn.],

    [`REPAIR_RATE`],
    [0,40],
    [Xác suất áp dụng Repair trong Proposed GA.],

    [`GA_SEED`],
    [2026],
    [Giá trị khởi tạo ngẫu nhiên cho GA.],
  ),
  caption: [Cấu hình tham số mặc định của giải thuật di truyền.]
) <tab_ga_config>

Việc sử dụng cùng kích thước quần thể và số thế hệ giúp các phiên bản thuật toán được đánh giá trên cùng số vòng tiến hóa.

Tuy nhiên, do Proposed GA thực hiện thêm các thao tác sửa chữa và tìm kiếm cục bộ, chi phí tính toán của mỗi thế hệ không hoàn toàn tương đương với Baseline GA và Improved GA.

Vì vậy, quá trình so sánh cần xem xét đồng thời chất lượng nghiệm và thời gian thực thi, thay vì chỉ dựa trên số thế hệ.

Các phiên bản cũng khác nhau về chiến lược khởi tạo và toán tử lai ghép. Do đó, kết quả thực nghiệm phản ánh hiệu quả tổng hợp của các nhóm kỹ thuật cải tiến.

Cấu hình trên được sử dụng cho thí nghiệm đối chứng chính. Trong các thí nghiệm khảo sát độ nhạy, một số tham số được thay đổi để đánh giá ảnh hưởng của chúng đến hiệu quả thuật toán.


== Tiêu chí đánh giá

Chất lượng của giải thuật di truyền được đánh giá thông qua các nhóm chỉ tiêu về tính khả thi, chất lượng nghiệm, khả năng hội tụ và chi phí tính toán.

*Số vi phạm ràng buộc cứng.*

Tổng số vi phạm ràng buộc cứng được xác định bởi:

$ H(x) = sum_(i=1)^7 H_i(x) $

Đây là tiêu chí có mức độ ưu tiên cao nhất.

Một thời khóa biểu được xem là khả thi khi:

$ H(x) = 0 $

Nếu $H(x) > 0$, nghiệm vẫn tồn tại ít nhất một vi phạm bắt buộc và chưa thể được sử dụng trực tiếp.

*Tổng mức phạt ràng buộc mềm.*

Mức phạt mềm được xác định theo hệ thống trọng số tại Chương 4:

$ P_"soft"(x) = sum_(j=1)^5 w_j S_j(x) $

Giá trị này phản ánh mức độ phân tán của lịch giảng dạy, sự phù hợp về buổi học và hiệu quả phân bổ kích thước phòng.

Đối với các nghiệm khả thi, giá trị điểm phạt mềm thấp hơn thể hiện chất lượng tốt hơn theo hệ thống trọng số đã lựa chọn.

*Mức độ đáp ứng các tiêu chí mở rộng.*

Các thành phần Bonus được đánh giá thông qua:

$ B_(1a)(x), quad B_(1b)(x), quad B_2(x) $

Trong đó:

- $B_(1a)$ phản ánh số giảng viên chưa được phân công môn học yêu thích.

- $B_(1b)$ phản ánh số lớp học phần được phân công ngoài danh sách Top-3.

- $B_2$ phản ánh số lớp được phân công ngoài danh sách môn có thể đảm nhận theo mô hình mở rộng của nhóm.

Việc thống kê riêng các thành phần này giúp tránh tình trạng tổng điểm phạt Bonus che khuất sự khác biệt giữa các tiêu chí phân công giảng viên.

*Giá trị hàm thích nghi.*

Hàm thích nghi được xác định bởi:

$ F(x) = frac(1, 1 + P(x)) $

Trong đó:

$ P(x) =
100000 H(x)
+ P_"soft"(x)
+ P_"bonus"(x) $

Giá trị Fitness càng lớn tương ứng với tổng mức phạt càng nhỏ.

Tuy nhiên, do hệ thống sử dụng cơ chế ưu tiên tính khả thi, việc lựa chọn nghiệm tốt nhất vẫn được thực hiện dựa trên khóa xếp hạng:

$ R(x) = (H(x), P(x)) $

Do đó, Fitness không được sử dụng như tiêu chí duy nhất để xác định nghiệm tốt nhất trong trường hợp các cá thể có số vi phạm cứng khác nhau.

Ngoài ra, theo phân tích cận dưới tại Chương 3, một số thành phần điểm phạt mềm không thể đồng thời đạt giá trị bằng 0 trên bộ dữ liệu đang xét.

Vì vậy, việc đánh giá thuật toán tập trung vào mức độ giảm điểm phạt và chất lượng nghiệm khả thi, thay vì yêu cầu Fitness đạt giá trị bằng 1.

*Thời gian thực thi.*

Thời gian thực thi được sử dụng để đánh giá chi phí tính toán của từng phiên bản thuật toán.

Chỉ tiêu này đặc biệt quan trọng khi so sánh Proposed GA với các phiên bản còn lại, do cơ chế Repair và Local Search yêu cầu thực hiện thêm nhiều thao tác kiểm tra và cập nhật nghiệm.

*Khả năng hội tụ.*

Khả năng hội tụ được đánh giá dựa trên sự thay đổi chất lượng nghiệm qua từng thế hệ.

Các đại lượng được theo dõi bao gồm Fitness, tổng mức phạt, số vi phạm cứng, điểm phạt mềm và tỷ lệ đột biến.

Bên cạnh giá trị cuối cùng, quá trình đánh giá còn xem xét tốc độ cải thiện nghiệm và những giai đoạn thuật toán không tiếp tục tìm được cá thể tốt hơn.

*Khả năng tìm kiếm nghiệm khả thi.*

Khả năng tìm kiếm nghiệm khả thi được xác định dựa trên việc thuật toán có tìm được cá thể thỏa mãn $H(x)=0$ trong giới hạn số thế hệ hay không.

Thế hệ đầu tiên đạt nghiệm khả thi là một chỉ tiêu bổ sung giúp đánh giá hiệu quả của quá trình khởi tạo và sửa chữa nghiệm.

Do thí nghiệm đối chứng hiện tại sử dụng một giá trị GA Seed cố định, kết quả chỉ phản ánh khả năng tìm được nghiệm khả thi trong lần thực nghiệm được báo cáo.

Để xác định tỷ lệ thành công có ý nghĩa thống kê, cần thực hiện nhiều lần chạy độc lập với các giá trị GA Seed khác nhau.


== Kiểm thử tính đúng đắn của các ràng buộc

Trước khi thực hiện thí nghiệm trên bộ dữ liệu đầy đủ, nhóm sử dụng bộ kiểm thử tự động nhằm kiểm tra các thành phần chính của hệ thống.

Bộ kiểm thử được hiện thực bằng thư viện Pytest và tổ chức trong bốn tệp:

#figure(
  table(
    columns: (1.5fr, 3fr),
    align: left,
    table.header(
      [*Tệp kiểm thử*],
      [*Phạm vi kiểm thử*],
    ),

    [`test_constraints.py`],
    [Kiểm tra các hàm đánh giá ràng buộc cứng, mềm và Bonus.],

    [`test_fitness.py`],
    [Kiểm tra công thức tổng mức phạt, hàm thích nghi và tiêu chí đánh giá nghiệm.],

    [`test_genetic.py`],
    [Kiểm tra cấu trúc nhiễm sắc thể và các toán tử di truyền.],

    [`test_scheduler.py`],
    [Kiểm tra luồng tích hợp của hệ thống xếp thời khóa biểu.],
  ),
  caption: [Các nhóm kiểm thử tự động của hệ thống.]
) <tab_test_modules>

Bộ kiểm thử được thực thi thông qua lệnh:

#raw("python -m pytest -v", lang: "bash", block: true)

Kết quả thực thi được tổng hợp như sau.

#figure(
  table(
    columns: (2fr, 1fr),
    align: (left, center),
    table.header(
      [*Chỉ tiêu*],
      [*Kết quả*],
    ),
    [Tổng số ca kiểm thử], [8],
    [Số ca kiểm thử thành công], [8],
    [Số ca kiểm thử thất bại], [0],
    [Tỷ lệ thành công], [100%],
    [Thời gian thực thi], [1,37 giây],
  ),
  caption: [Kết quả thực thi bộ kiểm thử tự động.]
) <tab_test_results>

Kết quả cho thấy toàn bộ tám ca kiểm thử đã xây dựng đều được thực thi thành công.

Điều này cung cấp bằng chứng ban đầu về sự phù hợp giữa mô hình toán học và các chức năng được hiện thực trong chương trình.

Đặc biệt, việc kiểm thử riêng các thành phần ràng buộc giúp hạn chế nguy cơ sai lệch trong quá trình đánh giá Fitness, bởi một lỗi trong hàm tính điểm phạt có thể khiến thuật toán ưu tiên những nghiệm không phù hợp với mục tiêu bài toán.

Tuy nhiên, việc đạt 100% số ca kiểm thử không đồng nghĩa với việc chứng minh chương trình hoàn toàn không có lỗi. Kết quả chỉ xác nhận rằng hệ thống hoạt động đúng đối với các trường hợp đã được xây dựng trong bộ kiểm thử.

Do đó, kết quả thời khóa biểu cuối cùng vẫn cần được kiểm tra lại bằng hệ thống đánh giá ràng buộc trước khi đưa vào sử dụng.


== Kết quả thời khóa biểu cuối cùng

Sau quá trình tiến hóa và tinh chỉnh, Proposed GA tìm được một thời khóa biểu hoàn chỉnh gồm 480 lớp học phần, tương ứng với 960 buổi học trong tuần.

Kết quả được xuất vào các tệp:

- `outputs/best_schedule.csv`.
- `outputs/professor_summary.csv`.
- `outputs/conflict_report.json`.
- `outputs/final_schedule.html`.

Việc đánh giá thời khóa biểu không chỉ dựa trên giá trị Fitness mà còn xem xét trực tiếp cách phân bổ giảng viên, phòng học và môn học.

Cách tiếp cận này cho phép kiểm tra mức độ phù hợp của nghiệm đối với các yêu cầu nghiệp vụ thực tế.


=== Thời khóa biểu theo giảng viên

@fig_timetables minh họa thời khóa biểu của hai giảng viên tiêu biểu là `p23` và `p02`, được trích xuất từ nghiệm tốt nhất tìm được bởi Proposed GA.

#figure(
  image(
    "../../outputs/figures/sample_timetables.png",
    width: 100%
  ),
  caption: [
    Thời khóa biểu tuần của hai giảng viên
    `p23` và `p02` trong nghiệm tốt nhất tìm được.
  ]
) <fig_timetables>

Đối với giảng viên `p23`, hệ thống phân công tổng cộng năm lớp học phần, tương ứng với mười buổi giảng dạy mỗi tuần.

Kết quả cho thấy:

- Không tồn tại ca trống giữa các ca giảng dạy trong cùng một ngày (`Gap = 0`).

- Không có ngày phải giảng dạy đồng thời cả buổi sáng và buổi chiều (`Mixed = 0`).

- Toàn bộ các lớp được phân công đều thuộc danh sách ba môn học yêu thích, gồm `c33`, `c47` và `c04`.

- Tổng số buổi giảng dạy không vượt quá định mức 20 buổi mỗi tuần.

Đối với giảng viên `p02`, hệ thống phân công tám lớp học phần, tương ứng với 16 buổi giảng dạy mỗi tuần.

Kết quả cho thấy giảng viên không có ca trống trong ngày, đồng thời bảy trong tổng số tám lớp được phân công thuộc danh sách Top-3 môn yêu thích.

Hai buổi học của mỗi lớp đều được bố trí vào những ngày khác nhau và không liền kề.

Các kết quả trên minh họa khả năng hình thành những lịch giảng dạy có mức độ tập trung cao, đồng thời đáp ứng các yêu cầu về khối lượng giảng dạy và sở thích môn học.

Tuy nhiên, đây là hai trường hợp tiêu biểu được lựa chọn để minh họa, không đại diện cho toàn bộ 60 giảng viên.

Để đánh giá chất lượng lịch giảng dạy trên phạm vi toàn hệ thống, cần xem xét thêm các chỉ tiêu tổng hợp về số ca trống, số ngày dạy cả hai buổi và mức độ đáp ứng môn học yêu thích.


=== Thời khóa biểu theo phòng học

Hiệu quả sử dụng phòng học được đánh giá thông qua tỷ lệ sử dụng các vị trí phòng–ca khả dụng tại từng thời điểm.

Gọi $O_(d,t)$ là số phòng được sử dụng tại ngày $d$ và ca học $t$.

Số phòng khả dụng tương ứng được xác định bởi:

$ C_(d,t) = sum_(r in cal(R)) A_(d,t,r) $

Đối với nghiệm khả thi, số phòng được sử dụng có thể được xác định thông qua:

$ O_(d,t) =
sum_(r in cal(R))
II[M(d,t,r) > 0] $

Tỷ lệ sử dụng phòng học tại từng thời điểm được tính theo công thức:

$ U_(d,t) =
frac(O_(d,t), C_(d,t)) times 100% $

với điều kiện $C_(d,t) > 0$.

Việc sử dụng số phòng thực tế khả dụng làm mẫu số giúp phản ánh chính xác mức độ khai thác tài nguyên, thay vì giả định toàn bộ 35 phòng luôn có thể được sử dụng.

#figure(
  image(
    "../../outputs/figures/room_utilization_heatmap.png",
    width: 85%
  ),
  caption: [
    Bản đồ nhiệt tỷ lệ sử dụng phòng học khả dụng
    theo ngày và ca học của Proposed GA.
  ]
) <fig_heatmap>

Theo @fig_heatmap, tỷ lệ sử dụng phòng học tại các ca dao động từ khoảng 68% đến 100% công suất khả dụng.

Điều này cho thấy hệ thống đã phân bổ các buổi học trên toàn bộ năm ngày trong tuần, đồng thời không vượt quá số phòng khả dụng tại từng thời điểm.

Kết quả phù hợp với mục tiêu của phương pháp khởi tạo cân bằng tải theo ngày đã trình bày tại Chương 4.

Tuy nhiên, tỷ lệ sử dụng phòng học cao cũng đồng nghĩa với việc có ít vị trí còn trống để thực hiện các thao tác điều chỉnh lịch.

Đặc biệt, tại những ca đạt 100% công suất, việc di chuyển một buổi học sang vị trí khác trong cùng ca có thể không thực hiện được nếu không giải phóng hoặc hoán đổi một vị trí đang được sử dụng.

Điều này minh họa lý do nhóm bổ sung cơ chế Same-Day Pairwise Swap, cho phép khảo sát các phương án phân bổ mới mà không yêu cầu sử dụng thêm vị trí phòng–ca trống.


=== Thời khóa biểu theo môn học

Mỗi môn học trong hệ thống gồm tám lớp học phần, tương ứng với 16 buổi học mỗi tuần.

Khi phân bổ các lớp học phần, thuật toán cần đảm bảo sự phù hợp giữa giảng viên, kích thước phòng và thời gian học, đồng thời hướng đến việc tập trung các buổi học của cùng một môn vào buổi sáng hoặc buổi chiều.

@tab_excerpt trình bày mười buổi học đầu tiên được trích xuất từ thời khóa biểu tại thứ Hai, ca 1.

#figure(
  table(
    columns: (
      auto, auto, auto, auto,
      auto, auto, auto, auto
    ),
    align: center + horizon,
    inset: 4pt,
    fill: (x, y) => {
      if y == 0 {
        rgb("#0f3d7a")
      } else if calc.even(y) {
        rgb("#f1f5f9")
      } else {
        none
      }
    },
    stroke: 0.5pt + luma(180),

    table.header(
      text(fill: white, [*Ngày*]),
      text(fill: white, [*Ca*]),
      text(fill: white, [*Phòng*]),
      text(fill: white, [*Lớp*]),
      text(fill: white, [*Cỡ lớp*]),
      text(fill: white, [*GV*]),
      text(fill: white, [*Yêu thích*]),
      text(fill: white, [*Độ khớp*]),
    ),

    [Thứ 2], [Ca 1], [`rm01` (Sz 1)],
    [`c05-s05`], [Sz 1], [`p21`],
    [Hợp lệ], [Khớp chuẩn],

    [Thứ 2], [Ca 1], [`rm02` (Sz 1)],
    [`c29-s02`], [Sz 1], [`p31`],
    [Hợp lệ], [Khớp chuẩn],

    [Thứ 2], [Ca 1], [`rm03` (Sz 1)],
    [`c23-s01`], [Sz 1], [`p08`],
    [Top-3], [Khớp chuẩn],

    [Thứ 2], [Ca 1], [`rm04` (Sz 0)],
    [`c18-s04`], [Sz 0], [`p39`],
    [Top-3], [Khớp chuẩn],

    [Thứ 2], [Ca 1], [`rm05` (Sz 2)],
    [`c08-s01`], [Sz 2], [`p49`],
    [Top-3], [Khớp chuẩn],

    [Thứ 2], [Ca 1], [`rm06` (Sz 2)],
    [`c03-s06`], [Sz 2], [`p33`],
    [Hợp lệ], [Khớp chuẩn],

    [Thứ 2], [Ca 1], [`rm07` (Sz 2)],
    [`c19-s03`], [Sz 1], [`p27`],
    [Top-3], [Dư +1],

    [Thứ 2], [Ca 1], [`rm08` (Sz 2)],
    [`c03-s03`], [Sz 2], [`p28`],
    [Top-3], [Khớp chuẩn],

    [Thứ 2], [Ca 1], [`rm09` (Sz 2)],
    [`c28-s06`], [Sz 2], [`p18`],
    [Top-3], [Khớp chuẩn],

    [Thứ 2], [Ca 1], [`rm10` (Sz 2)],
    [`c11-s08`], [Sz 2], [`p02`],
    [Top-3], [Khớp chuẩn],
  ),
  caption: [
    Trích xuất mười buổi học tại thứ Hai,
    ca 1 từ thời khóa biểu cuối cùng.
  ]
) <tab_excerpt>

Các buổi học trong bảng minh họa được bố trí vào những phòng có kích thước không nhỏ hơn quy mô lớp.

Phần lớn các trường hợp có kích thước phòng khớp chính xác với kích thước đăng ký của lớp học phần.

Chẳng hạn, lớp `c19-s03` có kích thước trung bình nhưng được bố trí vào phòng kích thước lớn `rm07`.

Trường hợp này không vi phạm ràng buộc cứng $H_1$, nhưng làm tăng điểm phạt mềm $S_5$ thêm một đơn vị.

Đối với toàn bộ thời khóa biểu, số buổi học có kích thước phòng khớp chính xác với quy mô lớp là 894 trên tổng số 960 buổi.

Tỷ lệ khớp kích thước được xác định bởi:

$ R_"size" =
894 / 960 times 100%
approx 93.13% $

Kết quả cho thấy phần lớn các buổi học được bố trí vào phòng có kích thước phù hợp nhất.

Tuy nhiên, như đã phân tích tại Chương 3, số lượng vị trí khả dụng của phòng kích thước trung bình thấp hơn nhu cầu của các lớp thuộc nhóm này.

Do đó, một số buổi học bắt buộc phải sử dụng phòng có kích thước lớn hơn. Việc không đạt tỷ lệ khớp kích thước 100% không đồng nghĩa với việc thời khóa biểu vi phạm ràng buộc cứng.

Bên cạnh đó, tiêu chí kích thước phòng chỉ là một trong nhiều mục tiêu tối ưu. Việc tăng độ khớp kích thước phòng có thể làm giảm số lượng lựa chọn phù hợp về lịch giảng viên hoặc buổi học ưu tiên của môn.

Vì vậy, chất lượng nghiệm cần được đánh giá dựa trên tổng hợp các thành phần điểm phạt thay vì chỉ xem xét riêng tỷ lệ khớp kích thước phòng.


=== Thống kê vi phạm ràng buộc

Kết quả đánh giá nghiệm cuối cùng của Proposed GA cho thấy tổng số vi phạm ràng buộc cứng bằng 0.

#figure(
  table(
    columns: (0.7fr, 3fr, 0.8fr),
    align: (center, left, center),
    table.header(
      [*Mã*],
      [*Ràng buộc cứng*],
      [*Vi phạm*],
    ),
    [$H_1$], [Kích thước phòng học], [0],
    [$H_2$], [Khoảng cách giữa hai buổi học], [0],
    [$H_3$], [Trùng lịch giảng viên], [0],
    [$H_4$], [Khối lượng giảng dạy], [0],
    [$H_5$], [Trạng thái khả dụng của phòng], [0],
    [$H_6$], [Trùng lịch lớp học phần], [0],
    [$H_7$], [Trùng lịch phòng học], [0],
    [*Tổng*], [*Hard Violations*], [*0*],
  ),
  caption: [
    Kết quả đánh giá ràng buộc cứng
    của Proposed GA.
  ]
) <tab_final_hard_constraints>

Do tất cả các thành phần ràng buộc cứng đều không có vi phạm, nghiệm thu được thỏa mãn điều kiện:

$ H(x) = sum_(i=1)^7 H_i(x) = 0 $

Kết quả xác nhận Proposed GA đã tìm được một thời khóa biểu khả thi đối với bộ dữ liệu thực nghiệm và hệ thống ràng buộc đã xây dựng.

Đối với các tiêu chí mở rộng, kết quả được tổng hợp như sau.

#figure(
  table(
    columns: (2.8fr, 1.2fr),
    align: (left, center),
    table.header(
      [*Chỉ tiêu*],
      [*Kết quả*],
    ),
    [Giảng viên có ít nhất một lớp yêu thích],
    [60/60],

    [Tỷ lệ giảng viên có lớp yêu thích],
    [100%],

    [Số lớp thuộc Top-3 yêu thích],
    [443/480],

    [Tỷ lệ lớp thuộc Top-3 yêu thích],
    [92,3%],

    [Số lớp ngoài Top-3 yêu thích],
    [37],

    [Số lớp ngoài danh sách môn có thể đảm nhận],
    [0],

    [$B_(1a)$], [0],
    [$B_(1b)$], [37],
    [$B_2$], [0],
  ),
  caption: [
    Mức độ đáp ứng các tiêu chí mở rộng
    của Proposed GA.
  ]
) <tab_final_bonus_constraints>

Kết quả cho thấy toàn bộ 60 giảng viên đều được phân công ít nhất một lớp học phần thuộc danh sách môn yêu thích.

Đồng thời, không có lớp học phần nào được phân công ngoài danh sách môn có thể đảm nhận theo giả định mở rộng của nhóm.

Tuy nhiên, vẫn tồn tại 37 lớp được phân công ngoài danh sách Top-3 yêu thích.

Các lớp này thuộc danh sách môn có thể đảm nhận nhưng không thuộc nhóm môn được giảng viên ưu tiên.

Do đó, cần phân biệt hai kết quả:

- Proposed GA đáp ứng hoàn toàn tiêu chí mỗi giảng viên có ít nhất một lớp yêu thích và không phân công ngoài danh sách môn có thể đảm nhận.

- Tỷ lệ đáp ứng sở thích trên tổng số lớp học phần đạt 92,3%, chưa đạt mức tuyệt đối.

Nếu Bonus 2 của đề bài được hiểu theo nghĩa giảng viên chỉ được dạy các môn thuộc danh sách Top-3 yêu thích, kết quả hiện tại chưa thỏa mãn hoàn toàn yêu cầu này.

Sự phân biệt trên đảm bảo kết quả thực nghiệm được diễn giải thống nhất với mô hình toán học và các giả định đã trình bày tại Chương 3.


== Biểu đồ hội tụ Fitness (Fitness Plot)

Để đánh giá quá trình cải thiện chất lượng nghiệm, nhóm ghi nhận các giá trị Fitness và điểm phạt qua từng thế hệ.

@fig_fitness trình bày kết quả hội tụ của ba phiên bản thuật toán.

#figure(
  image(
    "../../outputs/fitness_plot.png",
    width: 100%
  ),
  caption: [
    Biểu đồ hội tụ Fitness và tổng mức phạt
    của ba phiên bản giải thuật di truyền.
  ]
) <fig_fitness>

Do hàm thích nghi được xác định theo nghịch đảo của tổng mức phạt:

$ F(x) = frac(1, 1 + P(x)) $

các nghiệm có nhiều vi phạm cứng có thể nhận giá trị Fitness rất nhỏ.

Đặc biệt, với trọng số phạt cứng bằng 100000, sự khác biệt giữa nghiệm khả thi và không khả thi có thể lên đến nhiều bậc độ lớn.

Nếu chỉ sử dụng biểu đồ tuyến tính, sự thay đổi chất lượng của những nghiệm có Fitness thấp có thể khó quan sát.

Vì vậy, tổng mức phạt được biểu diễn bổ sung trên thang logarithm nhằm hỗ trợ so sánh quá trình hội tụ giữa các phiên bản thuật toán.

Kết quả thực nghiệm cho thấy Baseline GA vẫn tồn tại nhiều vi phạm cứng sau 200 thế hệ.

Improved GA đạt chất lượng nghiệm tốt hơn đáng kể nhờ sử dụng phương pháp khởi tạo có định hướng và lai ghép theo khối môn học. Tuy nhiên, phiên bản này vẫn chưa loại bỏ được toàn bộ xung đột giảng viên trong lần thực nghiệm đang xét.

Proposed GA tìm được nghiệm thỏa mãn toàn bộ ràng buộc cứng và tiếp tục cải thiện các thành phần điểm phạt mềm.

@fig_conv trình bày chi tiết quá trình thay đổi điểm phạt và tỷ lệ đột biến của Proposed GA.

#figure(
  image(
    "../../outputs/figures/penalty_breakdown.png",
    width: 100%
  ),
  caption: [
    Diễn biến hội tụ của Proposed GA,
    bao gồm vi phạm cứng, điểm phạt mềm
    và tỷ lệ đột biến thích nghi.
  ]
) <fig_conv>

Mức phạt mềm của Proposed GA giảm từ 2322 tại giai đoạn đầu xuống 1515 trong kết quả được báo cáo.

Tỷ lệ cải thiện được xác định bởi:

$ R_"improve" =
frac(2322 - 1515, 2322)
times 100%
approx 34.75% $

Như vậy, Proposed GA giảm khoảng 34,8% tổng mức phạt mềm so với giá trị ban đầu được ghi nhận.

Kết quả cho thấy việc tìm được nghiệm khả thi không phải là điểm kết thúc của quá trình tối ưu hóa.

Sau khi số vi phạm cứng đạt 0, thuật toán vẫn có thể tiếp tục cải thiện lịch giảng viên, mức độ phù hợp của phòng học và sự phân bố buổi học.

Sự cải thiện này phù hợp với vai trò của cơ chế Repair và tìm kiếm cục bộ trong thiết kế thuật toán.

Bên cạnh đó, tỷ lệ đột biến được điều chỉnh dựa trên trạng thái cải thiện nghiệm. Khi thuật toán không tìm được nghiệm tốt hơn trong nhiều thế hệ liên tiếp, tỷ lệ đột biến được tăng nhằm mở rộng phạm vi tìm kiếm.

Khi tìm được nghiệm tốt hơn, tỷ lệ đột biến được giảm để hạn chế phá vỡ các cấu trúc lịch có chất lượng tốt.

Tuy nhiên, cơ chế đột biến thích nghi không đảm bảo thuật toán sẽ thoát khỏi mọi nghiệm tối ưu cục bộ.

Các kết quả hội tụ chỉ phản ánh quá trình tìm kiếm trong giới hạn số thế hệ và cấu hình thực nghiệm đã lựa chọn.


== Đánh giá ảnh hưởng của các tham số

Các siêu tham số của giải thuật di truyền ảnh hưởng trực tiếp đến khả năng khám phá không gian tìm kiếm, tốc độ hội tụ và chi phí tính toán.

Để đánh giá mức độ ảnh hưởng của từng tham số, nhóm tiến hành khảo sát bốn nhóm tham số chính:

- Kích thước quần thể (Population Size).
- Tỷ lệ lai ghép (Crossover Rate).
- Tỷ lệ đột biến (Mutation Rate).
- Số thế hệ tối đa (Maximum Generations).

Đối với ba nhóm tham số đầu tiên, các thí nghiệm được thực hiện trong 60 thế hệ.

Đối với số thế hệ tối đa, nhóm sử dụng các mốc được ghi nhận trong quá trình tiến hóa của cấu hình 200 thế hệ.

Kết quả khảo sát được trình bày tại @fig_sens.

#figure(
  image(
    "../../outputs/figures/parameter_sensitivity.png",
    width: 96%
  ),
  caption: [
    Phân tích ảnh hưởng của các siêu tham số
    đến Proposed GA.
  ]
) <fig_sens>


=== Population Size

Kích thước quần thể được khảo sát với ba giá trị: 20, 40 và 80 cá thể.

#figure(
  table(
    columns: (1fr, 0.8fr, 1fr, 1.3fr, 1fr),
    align: center,
    table.header(
      [*Population*],
      [*Hard*],
      [*Soft*],
      [*Fitness*],
      [*Time (s)*],
    ),
    [20], [0], [1596], [0,000612], [6,39],
    [40], [0], [1659], [0,000582], [14,80],
    [80], [0], [*1521*], [*0,000634*], [29,44],
  ),
  caption: [
    Ảnh hưởng của kích thước quần thể
    trong thí nghiệm 60 thế hệ.
  ]
) <tab_population_sensitivity>

Kết quả cho thấy cả ba cấu hình đều tìm được nghiệm khả thi.

Trong đó, kích thước quần thể 80 đạt mức phạt mềm thấp nhất là 1521.

So với kích thước quần thể 20, mức giảm điểm phạt mềm là:

$ frac(1596 - 1521, 1596)
times 100%
approx 4.70% $

Tuy nhiên, thời gian thực thi tăng từ 6,39 giây lên 29,44 giây.

Điều này phù hợp với đặc điểm của giải thuật di truyền, bởi quần thể lớn yêu cầu đánh giá, lai ghép, đột biến và xử lý nhiều cá thể hơn trong mỗi thế hệ.

Quần thể lớn cũng có khả năng duy trì nhiều phương án phân bổ khác nhau, tạo điều kiện cho quá trình tìm kiếm khám phá nhiều vùng nghiệm.

Mặc dù vậy, kết quả không cho thấy chất lượng nghiệm cải thiện đơn điệu theo kích thước quần thể. Cấu hình 40 cá thể có điểm phạt mềm cao hơn cấu hình 20 cá thể trong lần thực nghiệm này.

Sự khác biệt có thể liên quan đến tính ngẫu nhiên của quần thể ban đầu và quá trình tiến hóa.

Do đó, không thể kết luận rằng việc tăng kích thước quần thể luôn cải thiện chất lượng nghiệm.

Trong phạm vi các cấu hình khảo sát, giá trị 80 mang lại chất lượng nghiệm tốt nhất, nhưng yêu cầu chi phí tính toán cao hơn.


=== Crossover Rate

Tỷ lệ lai ghép được khảo sát với ba giá trị 0,65; 0,85 và 0,95, sử dụng kích thước quần thể bằng 40.

#figure(
  table(
    columns: (1fr, 0.8fr, 1fr, 1.3fr, 1fr),
    align: center,
    table.header(
      [*Crossover*],
      [*Hard*],
      [*Soft*],
      [*Fitness*],
      [*Time (s)*],
    ),
    [0,65], [0], [*1556*], [*0,000620*], [12,84],
    [0,85], [0], [1659], [0,000582], [12,98],
    [0,95], [0], [1668], [0,000580], [13,01],
  ),
  caption: [
    Ảnh hưởng của tỷ lệ lai ghép
    với quần thể 40 cá thể.
  ]
) <tab_crossover_sensitivity>

Kết quả cho thấy tỷ lệ lai ghép 0,65 đạt mức phạt mềm thấp nhất trong ba cấu hình khảo sát.

Một cách giải thích phù hợp với đặc điểm bài toán là khi tỷ lệ lai ghép quá cao, những cấu trúc lịch có chất lượng tốt đã hình thành trong quần thể có thể bị thay đổi thường xuyên hơn.

Đối với bài toán có mật độ sử dụng phòng học cao, việc kết hợp các khối môn học từ những cá thể khác nhau có thể làm phát sinh xung đột mới về phòng học hoặc giảng viên.

Tỷ lệ lai ghép vừa phải có thể giúp duy trì tốt hơn những cấu trúc nghiệm đã được cải thiện, đồng thời vẫn tạo ra các cá thể mới phục vụ quá trình tìm kiếm.

Tuy nhiên, đây là nhận định dựa trên đặc điểm thuật toán và kết quả quan sát được, chưa phải kết luận nhân quả đã được chứng minh bằng nhiều lần thực nghiệm độc lập.

Thời gian thực thi của ba cấu hình tương đối gần nhau, dao động từ 12,84 đến 13,01 giây.

Trong phạm vi khảo sát, tỷ lệ lai ghép 0,65 cho kết quả tốt hơn về cả điểm phạt mềm và Fitness.


=== Mutation Rate

Tỷ lệ đột biến được khảo sát với ba giá trị 0,005; 0,015 và 0,04, sử dụng kích thước quần thể bằng 40.

#figure(
  table(
    columns: (1fr, 0.8fr, 1fr, 1.3fr, 1fr),
    align: center,
    table.header(
      [*Mutation*],
      [*Hard*],
      [*Soft*],
      [*Fitness*],
      [*Time (s)*],
    ),
    [0,005], [0], [*1473*], [*0,000654*], [12,54],
    [0,015], [0], [1659], [0,000582], [12,93],
    [0,040], [0], [1643], [0,000588], [13,77],
  ),
  caption: [
    Ảnh hưởng của tỷ lệ đột biến
    với quần thể 40 cá thể.
  ]
) <tab_mutation_sensitivity>

Kết quả cho thấy cả ba cấu hình đều đạt nghiệm khả thi.

Trong đó, cấu hình có tỷ lệ đột biến 0,005 đạt mức phạt mềm thấp nhất là 1473, đồng thời có Fitness cao nhất trong nhóm khảo sát.

Đối với các cá thể đã được hình thành thông qua phương pháp khởi tạo có định hướng, tỷ lệ đột biến thấp có thể giúp duy trì những cấu trúc phân bổ phòng học và giảng viên có chất lượng tốt.

Ngược lại, tỷ lệ đột biến cao tạo ra nhiều biến đổi hơn, có thể giúp mở rộng không gian tìm kiếm nhưng đồng thời làm tăng nguy cơ phát sinh xung đột hoặc phá vỡ cấu trúc nghiệm đang có.

Trong Proposed GA, cơ chế Repair và tìm kiếm cục bộ đã hỗ trợ trực tiếp việc cải thiện nghiệm. Vì vậy, thuật toán có thể đạt chất lượng tốt ngay cả khi sử dụng tỷ lệ đột biến tương đối thấp.

Tuy nhiên, tỷ lệ đột biến quá thấp cũng có thể làm giảm tính đa dạng của quần thể và tăng nguy cơ hội tụ sớm.

Do đó, kết quả thực nghiệm không đồng nghĩa với việc tỷ lệ 0,005 luôn là lựa chọn tốt nhất đối với mọi kích thước quần thể, số thế hệ hoặc bộ dữ liệu.

Giá trị này thấp hơn giới hạn dưới của khoảng đột biến thích nghi mặc định đã trình bày tại Chương 4. Vì vậy, cần xem đây là một cấu hình khảo sát riêng và phân biệt với chế độ thích nghi mặc định khi diễn giải kết quả.


=== Maximum Generations

Sự thay đổi chất lượng nghiệm theo số thế hệ được khảo sát thông qua các mốc 0, 50, 100, 150 và 200 của Proposed GA.

#figure(
  table(
    columns: (1fr, 1fr, 1.5fr),
    align: center,
    table.header(
      [*Thế hệ*],
      [*Hard*],
      [*Soft Penalty*],
    ),
    [0], [0], [2322],
    [50], [0], [1736],
    [100], [0], [1666],
    [150], [0], [1577],
    [200], [0], [*1515*],
  ),
  caption: [
    Sự thay đổi điểm phạt mềm của Proposed GA
    theo số thế hệ được ghi nhận.
  ]
) <tab_generation_sensitivity>

Kết quả cho thấy Proposed GA đã có nghiệm khả thi tại thế hệ 0 được ghi nhận, tức là sau giai đoạn khởi tạo, sửa chữa ban đầu và đánh giá quần thể.

Trong các thế hệ tiếp theo, thuật toán tiếp tục cải thiện chất lượng nghiệm bằng cách giảm tổng mức phạt mềm.

Mức cải thiện lớn nhất trong các khoảng thế hệ được khảo sát xuất hiện ở giai đoạn từ thế hệ 0 đến thế hệ 50:

$ 2322 - 1736 = 586 $

Tương ứng với mức giảm khoảng 25,2% so với giá trị ban đầu.

Trong khoảng từ thế hệ 150 đến thế hệ 200, mức cải thiện là:

$ 1577 - 1515 = 62 $

Kết quả cho thấy tốc độ cải thiện có xu hướng giảm ở những giai đoạn sau.

Một cách giải thích là khi chất lượng nghiệm đã được nâng cao, số lượng phép biến đổi có khả năng tiếp tục giảm điểm phạt trở nên hạn chế hơn.

Đây là hiện tượng thường gặp trong các phương pháp tìm kiếm heuristic, khi việc cải thiện nghiệm ở giai đoạn sau có thể yêu cầu nhiều thao tác tìm kiếm hơn so với giai đoạn đầu.

Mặc dù điểm phạt mềm giảm liên tục tại các mốc được khảo sát, điều này không đủ để khẳng định thành phần điểm phạt mềm luôn giảm tại mọi thế hệ.

Cơ chế Elitism bảo toàn nghiệm theo tiêu chí xếp hạng tổng hợp, trong khi một thành phần điểm phạt riêng lẻ vẫn có thể tăng nếu những thành phần khác được cải thiện.

Việc tăng số thế hệ giúp thuật toán có thêm cơ hội tìm kiếm, nhưng đồng thời làm tăng chi phí tính toán.

Do đó, số thế hệ 200 được sử dụng như một giới hạn thực nghiệm nhằm cân bằng giữa chất lượng nghiệm và thời gian thực thi.


=== Nhận xét tổng hợp về độ nhạy tham số

Kết quả khảo sát cho thấy các siêu tham số có ảnh hưởng đáng kể đến chất lượng nghiệm và thời gian thực thi.

Trong các cấu hình được khảo sát:

- Population Size bằng 80 đạt mức phạt mềm thấp nhất trong nhóm khảo sát kích thước quần thể.

- Crossover Rate bằng 0,65 đạt kết quả tốt nhất trong nhóm khảo sát tỷ lệ lai ghép.

- Mutation Rate bằng 0,005 đạt kết quả tốt nhất trong nhóm khảo sát tỷ lệ đột biến.

- Việc tăng số thế hệ giúp cải thiện nghiệm, nhưng mức độ cải thiện có xu hướng giảm tại các giai đoạn sau.

Đáng chú ý, cấu hình Mutation Rate bằng 0,005 đạt điểm phạt mềm 1473, thấp hơn điểm phạt mềm 1515 của thí nghiệm đối chứng chính.

Điều này cho thấy cấu hình mặc định không nhất thiết là cấu hình tốt nhất trong toàn bộ không gian siêu tham số.

Cần lưu ý rằng các nhóm khảo sát được thực hiện với những điều kiện cấu hình khác nhau. Do đó, không thể trực tiếp kết hợp các giá trị tốt nhất của từng nhóm để khẳng định một cấu hình tổng hợp sẽ mang lại kết quả tốt nhất.

Chẳng hạn, hiệu quả của tỷ lệ đột biến có thể phụ thuộc vào kích thước quần thể, tỷ lệ lai ghép và mức độ áp dụng cơ chế Repair.

Để xác định cấu hình tối ưu một cách đáng tin cậy hơn, cần thực hiện khảo sát nhiều tổ hợp tham số và lặp lại các thí nghiệm với nhiều giá trị khởi tạo ngẫu nhiên.

Trong phạm vi đề tài, kết quả khảo sát được sử dụng để phân tích xu hướng ảnh hưởng của từng tham số và xác định những cấu hình có tiềm năng cải thiện thuật toán.


== So sánh các phiên bản thuật toán

Để đánh giá hiệu quả của các kỹ thuật cải tiến, nhóm thực hiện so sánh ba phiên bản Baseline GA, Improved GA và Proposed GA trên cùng bộ dữ liệu với `seed = 42`.

Các phiên bản sử dụng kích thước quần thể 80 và giới hạn tiến hóa 200 thế hệ trong thí nghiệm đối chứng chính.

Kết quả tổng hợp được trình bày tại @tab_compare.

#figure(
  table(
    columns: (
      1.6fr, 1.2fr, 1.4fr,
      0.6fr, 0.8fr, 1.2fr, 0.8fr
    ),
    align: center + horizon,
    inset: 4pt,
    fill: (x, y) => {
      if y == 0 {
        rgb("#0f3d7a")
      } else if y == 3 {
        rgb("#dcfce7")
      } else if calc.even(y) {
        rgb("#f1f5f9")
      } else {
        none
      }
    },
    stroke: 0.5pt + luma(180),

    table.header(
      text(fill: white, [*Thuật toán*]),
      text(fill: white, [*Fitness*]),
      text(fill: white, [*Total Penalty*]),
      text(fill: white, [*Hard*]),
      text(fill: white, [*Soft*]),
      text(fill: white, [*Bonus*]),
      text(fill: white, [*Time (s)*]),
    ),

    [Baseline GA],
    [$2.41 times 10^(-8)$],
    [41.485.175,5],
    [393],
    [4493],
    [2.180.682,5],
    [56,0],

    [Improved GA],
    [$3.31 times 10^(-6)$],
    [302.501,0],
    [3],
    [2459],
    [42,0],
    [109,6],

    [*Proposed GA*],
    [*$6.36 times 10^(-4)$*],
    [*1570,5*],
    [*0*],
    [*1515*],
    [55,5],
    [136,9],
  ),
  caption: [
    So sánh kết quả thực nghiệm
    giữa ba phiên bản giải thuật di truyền.
  ]
) <tab_compare>

Trong bảng, các giá trị Fitness được biểu diễn dưới dạng ký hiệu khoa học nhằm thuận tiện cho việc so sánh những giá trị có độ lớn khác nhau.

@fig_bars trình bày trực quan mức độ vi phạm của các nhóm ràng buộc chính.

#figure(
  image(
    "../../outputs/figures/constraint_satisfaction.png",
    width: 96%
  ),
  caption: [
    So sánh mức độ vi phạm các ràng buộc chính
    giữa ba phiên bản thuật toán.
  ]
) <fig_bars>


=== Baseline Genetic Algorithm

Baseline GA sử dụng phương pháp khởi tạo ngẫu nhiên và lai ghép Uniform Crossover theo từng lớp học phần.

Sau khi hoàn thành 200 thế hệ, phiên bản này đạt:

- Tổng số vi phạm cứng: 393.
- Tổng mức phạt mềm: 4493.
- Tổng mức phạt Bonus: 2.180.682,5.
- Thời gian thực thi: 56,0 giây.

Trong đó, các nhóm vi phạm cứng chủ yếu bao gồm:

- 183 vi phạm trùng phòng học.
- 157 vi phạm kích thước phòng học.
- 43 vi phạm trùng lịch giảng viên.
- 10 vi phạm trạng thái khả dụng của phòng.

Kết quả cho thấy Baseline GA chưa tìm được nghiệm khả thi trong giới hạn thực nghiệm đã thiết lập.

Nguyên nhân có thể được giải thích từ đặc điểm của phương pháp khởi tạo và lai ghép.

Việc lựa chọn đồng đều các cặp ngày hợp lệ tạo ra xu hướng mất cân bằng tải vào thứ Hai và thứ Sáu. Đồng thời, việc lựa chọn ngẫu nhiên giảng viên, phòng học và ca học không khai thác trực tiếp các thông tin về trạng thái sử dụng tài nguyên.

Uniform Crossover cũng có thể làm phát sinh xung đột khi kết hợp những lớp học được phân bổ độc lập từ hai cá thể cha mẹ.

Trong điều kiện mật độ sử dụng phòng học cao, quá trình sửa lỗi gián tiếp thông qua chọn lọc và đột biến có thể gặp nhiều khó khăn.

Mặc dù Baseline GA có thời gian thực thi thấp nhất, kết quả đầu ra chưa đáp ứng các điều kiện bắt buộc của bài toán.

Vì vậy, thời gian thực thi thấp không đủ để kết luận phiên bản này có hiệu quả tốt hơn các phương pháp còn lại.


=== GA with Greedy Initialization

Improved GA kết hợp phương pháp Greedy Randomized Initialization với Course-Block Crossover.

Kết quả thực nghiệm cho thấy:

- Tổng số vi phạm cứng: 3.
- Tổng mức phạt mềm: 2459.
- Tổng mức phạt Bonus: 42.
- Thời gian thực thi: 109,6 giây.

So với Baseline GA, mức giảm số vi phạm cứng được xác định bởi:

$ frac(393 - 3, 393)
times 100%
approx 99.24% $

Như vậy, Improved GA giảm khoảng 99,2% số vi phạm ràng buộc cứng trong thí nghiệm đối chứng.

Tổng mức phạt mềm cũng giảm đáng kể:

$ frac(4493 - 2459, 4493)
times 100%
approx 45.27% $

Kết quả phù hợp với mục tiêu của phương pháp khởi tạo có định hướng, trong đó quá trình phân bổ sử dụng thông tin về kích thước lớp, trạng thái phòng học, khả năng đảm nhận môn học của giảng viên và phân bố tải theo ngày.

Bên cạnh đó, Course-Block Crossover giúp duy trì cấu trúc lịch của từng môn học tốt hơn so với việc trao đổi độc lập từng lớp học phần.

Tuy nhiên, Improved GA vẫn tồn tại ba vi phạm trùng lịch giảng viên sau khi hoàn thành quá trình tiến hóa.

Ngoài ra, tổng số ca trống trong lịch giảng viên vẫn ở mức 218.

Kết quả cho thấy việc cải thiện phương pháp khởi tạo và lai ghép có thể giúp thuật toán tiến gần vùng nghiệm khả thi, nhưng chưa đủ để loại bỏ toàn bộ xung đột trong cấu hình thực nghiệm đang xét.

Khi số lượng xung đột còn lại tương đối nhỏ, các phép lai ghép và đột biến có thể làm thay đổi nhiều thành phần khác của lịch, dẫn đến khó khăn trong việc tạo ra một nghiệm tốt hơn mà không phát sinh xung đột mới.

Đây là cơ sở thực nghiệm cho việc bổ sung cơ chế sửa chữa nghiệm và tìm kiếm cục bộ trong Proposed GA.


=== GA with Greedy Initialization and Repair

Proposed GA được phát triển từ Improved GA bằng cách tích hợp thêm cơ chế sửa chữa nghiệm gồm bốn pha và tìm kiếm cục bộ thông qua Same-Day Pairwise Swap.

Kết quả thực nghiệm cho thấy:

- Tổng số vi phạm cứng: 0.
- Tổng mức phạt mềm: 1515.
- Tổng mức phạt Bonus: 55,5.
- Thời gian thực thi: 136,9 giây.

Proposed GA là phiên bản duy nhất trong thí nghiệm đối chứng tìm được nghiệm thỏa mãn toàn bộ bảy thành phần ràng buộc cứng.

So với Improved GA, tổng mức phạt mềm giảm từ 2459 xuống 1515.

Tỷ lệ cải thiện được xác định bởi:

$ frac(2459 - 1515, 2459)
times 100%
approx 38.39% $

Như vậy, Proposed GA giảm khoảng 38,4% tổng mức phạt mềm so với Improved GA.

Đối với số ca trống trong lịch giảng viên, giá trị $S_1$ giảm từ 218 xuống 51.

Tỷ lệ cải thiện tương ứng là:

$ frac(218 - 51, 218)
times 100%
approx 76.61% $

Bên cạnh đó, số cặp giảng viên–ngày có lịch giảng dạy ở cả buổi sáng và buổi chiều giảm từ 192 xuống 135, tương ứng với mức giảm:

$ frac(192 - 135, 192)
times 100%
approx 29.69% $

Kết quả phù hợp với mục tiêu của cơ chế tìm kiếm cục bộ, đặc biệt là các thao tác di chuyển và hoán đổi được thiết kế nhằm cải thiện mức độ tập trung của lịch giảng viên.

Tuy nhiên, Proposed GA không cải thiện đồng thời tất cả các chỉ tiêu.

Tổng mức phạt Bonus tăng từ 42 lên 55,5 so với Improved GA. Tỷ lệ khớp kích thước phòng học cũng giảm từ 95,6% xuống 93,1%.

Những thay đổi này phản ánh sự đánh đổi giữa các mục tiêu tối ưu trong bài toán.

Một phương án phân bổ có thể cải thiện lịch giảng viên và loại bỏ xung đột cứng, nhưng đồng thời làm giảm mức độ phù hợp của một số tiêu chí mềm hoặc sở thích giảng dạy.

Theo hàm mục tiêu và cơ chế ưu tiên tính khả thi đã xác định, Proposed GA vẫn được đánh giá tốt hơn do đạt $H(x)=0$ và có tổng mức phạt thấp hơn đáng kể.


== Nhận xét và thảo luận kết quả

=== Đánh giá khả năng tìm kiếm nghiệm khả thi

Kết quả thực nghiệm cho thấy sự khác biệt rõ rệt giữa ba phiên bản thuật toán về khả năng xử lý các ràng buộc bắt buộc.

Baseline GA kết thúc với 393 vi phạm cứng, trong khi Improved GA giảm số vi phạm xuống còn 3.

Proposed GA tiếp tục cải thiện kết quả và tìm được nghiệm không có vi phạm cứng.

Sự khác biệt này cho thấy việc sử dụng tri thức chuyên biệt của bài toán trong quá trình khởi tạo, lai ghép và sửa chữa có thể cải thiện đáng kể khả năng tìm kiếm nghiệm khả thi.

Đặc biệt, phương pháp cân bằng tải ngày giúp hạn chế sự mất cân đối tài nguyên ngay từ giai đoạn khởi tạo.

Cơ chế Repair tiếp tục xử lý những xung đột còn tồn tại bằng các phép biến đổi có định hướng, thay vì chỉ phụ thuộc vào những thay đổi ngẫu nhiên của toán tử di truyền.

Tuy nhiên, kết quả hiện tại chỉ xác nhận thuật toán đã tìm được nghiệm khả thi trên bộ dữ liệu thực nghiệm đang xét.

Chưa thể từ đó suy ra Proposed GA luôn tìm được nghiệm khả thi với mọi bộ dữ liệu hoặc mọi giá trị khởi tạo ngẫu nhiên.


=== Đánh giá chất lượng thời khóa biểu

Bên cạnh việc thỏa mãn các ràng buộc cứng, Proposed GA đạt mức phạt mềm thấp nhất trong ba phiên bản của thí nghiệm đối chứng chính.

Các kết quả cải thiện quan trọng được tổng hợp trong bảng sau.

#figure(
  table(
    columns: (2.2fr, 1fr, 1fr, 1.1fr),
    align: (left, center, center, center),
    table.header(
      [*Chỉ tiêu*],
      [*Improved*],
      [*Proposed*],
      [*Cải thiện*],
    ),
    [Vi phạm cứng], [3], [0], [100%],
    [Tổng phạt mềm], [2459], [1515], [38,4%],
    [Số ca trống GV], [218], [51], [76,6%],
    [Số ngày–GV dạy cả hai buổi],
    [192], [135], [29,7%],
  ),
  caption: [
    Mức cải thiện của Proposed GA
    so với Improved GA.
  ]
) <tab_improvement_summary>

Trong đó, sự cải thiện về số ca trống của giảng viên là một trong những kết quả đáng chú ý nhất.

Việc giảm số ca trống từ 218 xuống 51 cho thấy thời khóa biểu có mức độ tập trung cao hơn, từ đó giảm thời gian chờ giữa các ca giảng dạy.

Kết quả này phù hợp với mục tiêu của cơ chế di chuyển đơn lẻ và Same-Day Pairwise Swap.

Do phép hoán đổi cặp không yêu cầu tìm thêm vị trí phòng–ca trống, phương pháp có khả năng khảo sát những nghiệm lân cận mà thao tác di chuyển đơn lẻ khó thực hiện trong điều kiện tài nguyên hạn chế.

Mặc dù vậy, chưa thể xác định chính xác tỷ lệ cải thiện do riêng phép hoán đổi cặp tạo ra, bởi Proposed GA đồng thời sử dụng nhiều pha sửa chữa và tìm kiếm cục bộ.

Để đánh giá riêng đóng góp của từng kỹ thuật, cần thực hiện thêm các thí nghiệm loại bỏ từng thành phần (_Ablation Study_).


=== Phân tích sự đánh đổi giữa các mục tiêu

Bài toán xếp thời khóa biểu không chỉ tối ưu một tiêu chí duy nhất mà bao gồm nhiều yêu cầu có thể ảnh hưởng lẫn nhau.

Chẳng hạn, việc chuyển một buổi học sang ca liền kề với lịch giảng viên có thể giúp giảm số ca trống, nhưng phòng phù hợp tại ca mới có thể có kích thước lớn hơn quy mô lớp.

Tương tự, một phép điều chỉnh có thể giúp giảng viên chỉ dạy trong một buổi của ngày, nhưng khiến các lớp thuộc cùng một môn bị phân tán giữa buổi sáng và buổi chiều.

Do đó, việc cải thiện một ràng buộc mềm không nhất thiết dẫn đến sự cải thiện của tất cả các ràng buộc khác.

Kết quả thực nghiệm phản ánh đặc điểm này thông qua sự thay đổi tỷ lệ khớp kích thước phòng và tổng mức phạt Bonus giữa Improved GA và Proposed GA.

Improved GA đạt tỷ lệ khớp kích thước phòng 95,6%, cao hơn giá trị 93,1% của Proposed GA.

Tuy nhiên, Proposed GA loại bỏ toàn bộ vi phạm cứng và đạt tổng mức phạt mềm thấp hơn.

Điều này phù hợp với tiêu chí xếp hạng ưu tiên tính khả thi và hệ thống trọng số mà nhóm đã lựa chọn.

Vì vậy, không nên đánh giá chất lượng nghiệm chỉ dựa trên một chỉ tiêu riêng lẻ.

Hệ thống cần xem xét đồng thời tính khả thi, tổng mức phạt và mức độ đáp ứng từng nhóm ràng buộc để xác định phương án phân bổ phù hợp.


=== Phân tích chi phí tính toán

Việc bổ sung các kỹ thuật sửa chữa và tìm kiếm cục bộ giúp cải thiện chất lượng nghiệm nhưng đồng thời làm tăng chi phí tính toán.

Thời gian thực thi của ba phiên bản lần lượt là:

- Baseline GA: 56,0 giây.
- Improved GA: 109,6 giây.
- Proposed GA: 136,9 giây.

So với Improved GA, mức tăng thời gian thực thi của Proposed GA là:

$ frac(136.9 - 109.6, 109.6)
times 100%
approx 24.91% $

Như vậy, Proposed GA yêu cầu thời gian thực thi cao hơn khoảng 24,9% so với Improved GA trong thí nghiệm đối chứng.

So với Baseline GA, tỷ lệ thời gian thực thi là:

$ 136.9 / 56.0 approx 2.44 $

Chi phí tăng thêm phù hợp với đặc điểm của phương pháp đề xuất, bởi thuật toán thực hiện nhiều thao tác kiểm tra, tìm kiếm vị trí thay thế, sửa chữa và đánh giá nghiệm lân cận hơn.

Tuy nhiên, Proposed GA mang lại nghiệm khả thi với chất lượng lịch tốt hơn đáng kể.

Đối với một bài toán lập thời khóa biểu theo tuần, thời gian tính toán cao hơn có thể được chấp nhận nếu kết quả đáp ứng các yêu cầu bắt buộc và giảm được công sức điều chỉnh lịch thủ công.

Kết quả cho thấy việc đánh đổi một phần thời gian thực thi để cải thiện tính khả thi và chất lượng nghiệm là phù hợp với mục tiêu của đề tài.

Tuy nhiên, các giá trị thời gian trên chỉ phản ánh môi trường thực nghiệm cụ thể và có thể thay đổi khi sử dụng cấu hình phần cứng hoặc bộ tham số khác.


=== Đánh giá đóng góp của phương pháp đề xuất

Kết quả thực nghiệm cung cấp bằng chứng cho thấy việc kết hợp giải thuật di truyền với các kỹ thuật chuyên biệt của bài toán có thể mang lại chất lượng nghiệm tốt hơn so với việc chỉ sử dụng GA cơ bản.

Các đóng góp chính của phương pháp đề xuất bao gồm:

- Phân tích cấu trúc tập cặp ngày hợp lệ và xây dựng phương pháp khởi tạo cân bằng tải theo ngày.

- Biểu diễn nghiệm theo lớp học phần nhằm duy trì tính nhất quán giữa giảng viên và hai buổi học.

- Lai ghép theo khối môn học nhằm hạn chế phá vỡ cấu trúc lịch đã hình thành.

- Sửa chữa nghiệm dựa trên thông tin về các ràng buộc và trạng thái sử dụng tài nguyên.

- Tìm kiếm cục bộ thông qua hoán đổi cặp buổi học trong cùng ngày.

Sự kết hợp giữa các thành phần trên giúp Proposed GA vừa duy trì khả năng khám phá không gian tìm kiếm, vừa cải thiện trực tiếp những nghiệm ứng viên đã được tạo ra.

Trong phạm vi thực nghiệm đối chứng, phương pháp đề xuất đạt được mục tiêu quan trọng nhất là xây dựng thời khóa biểu hoàn chỉnh cho toàn bộ 960 buổi học mà không vi phạm các ràng buộc cứng.

Bên cạnh đó, kết quả cho thấy mức độ cải thiện đáng kể về chất lượng lịch giảng viên và tổng điểm phạt mềm.


=== Giới hạn của thực nghiệm

Mặc dù phương pháp đề xuất đạt kết quả khả quan, quá trình thực nghiệm hiện tại vẫn tồn tại một số giới hạn cần được xem xét.

Thứ nhất, các thí nghiệm đối chứng được thực hiện trên một bộ dữ liệu sinh với `seed = 42` và một giá trị GA Seed cố định.

Do giải thuật di truyền có tính ngẫu nhiên, kết quả có thể thay đổi khi sử dụng những giá trị khởi tạo khác.

Vì vậy, cần thực hiện nhiều lần chạy độc lập để đánh giá độ ổn định, giá trị trung bình, độ lệch chuẩn và tỷ lệ tìm được nghiệm khả thi.

Thứ hai, các phiên bản thuật toán khác nhau ở nhiều thành phần thiết kế. Kết quả so sánh hiện tại phản ánh hiệu quả tổng hợp của các kỹ thuật cải tiến, chưa xác định được đóng góp riêng của từng toán tử hoặc từng pha Repair.

Một hướng đánh giá bổ sung là thực hiện Ablation Study, trong đó lần lượt loại bỏ từng kỹ thuật để khảo sát sự thay đổi về chất lượng nghiệm và thời gian thực thi.

Thứ ba, khảo sát độ nhạy tham số mới xem xét một số giá trị rời rạc và chưa phân tích đầy đủ sự tương tác giữa các siêu tham số.

Do đó, các cấu hình tốt nhất được ghi nhận chỉ có ý nghĩa trong phạm vi thí nghiệm tương ứng.

Thứ tư, hệ thống sử dụng hàm phạt có trọng số cố định để tổng hợp nhiều mục tiêu tối ưu.

Chất lượng nghiệm vì vậy phụ thuộc vào mức độ ưu tiên mà nhóm đã xác định cho từng ràng buộc.

Những hệ thống có yêu cầu nghiệp vụ khác có thể cần sử dụng một bộ trọng số khác hoặc phương pháp tối ưu đa mục tiêu.

Cuối cùng, giải thuật di truyền không thực hiện duyệt toàn bộ không gian tìm kiếm và không cung cấp chứng minh về tính tối ưu toàn cục.

Do đó, nghiệm thu được được xem là nghiệm khả thi tốt nhất tìm được trong điều kiện thực nghiệm, không phải nghiệm tối ưu toàn cục đã được chứng minh.

Nhìn chung, kết quả thực nghiệm cho thấy phương pháp Proposed GA phù hợp với bài toán xếp thời khóa biểu có mật độ sử dụng tài nguyên cao trong phạm vi dữ liệu đã xây dựng.

Các kết quả đạt được, những hạn chế còn tồn tại và định hướng cải tiến tiếp theo sẽ được tổng hợp tại Chương 7.