= GIỚI THIỆU ĐỀ TÀI (INTRODUCTION)

== Bối cảnh và phát biểu bài toán

Trong công tác tổ chức đào tạo tại các trường đại học, lập thời khóa biểu học phần (_University Course Timetabling Problem – UCTP_) là bài toán quản lý tài nguyên có tác động trực tiếp đến hiệu quả giảng dạy của giảng viên, trải nghiệm học tập của sinh viên và hiệu suất khai thác cơ sở vật chất. Mỗi học kỳ, phòng đào tạo phải phân bổ đồng thời giảng viên, phòng học và khung thời gian cho hàng trăm lớp học phần, sao cho vừa không phát sinh xung đột lịch trình vừa tối ưu hóa mức độ thuận tiện cho người tham gia. Khi quy mô đào tạo lớn và hạ tầng phòng học có giới hạn, việc xếp lịch thủ công hoặc dựa vào kinh nghiệm rời rạc thường tốn nhiều thời gian, khó kiểm soát toàn cục và dễ bỏ sót các ràng buộc chồng chéo.

Về phương diện thuật toán, nhiều biến thể của UCTP đã được chứng minh thuộc lớp bài toán *NP-hard* @schaerf1999survey @lewis2008survey. Không gian nghiệm tăng theo hàm mũ theo số lớp học phần, số phòng học và số khung giờ, khiến các thuật toán tìm kiếm chính xác như vét cạn (_Brute-force_), quay lui (_Backtracking_) hoặc quy hoạch nguyên tuyến tính (_Integer Linear Programming – ILP_) gặp trở ngại lớn về thời gian tính toán ở quy mô thực tế. Trong bối cảnh đó, các thuật toán tiến hóa — đặc biệt là *Giải thuật di truyền (Genetic Algorithm – GA)* — trở thành hướng tiếp cận metaheuristic hiệu quả nhờ khả năng duy trì quần thể đa dạng, tìm kiếm song song trên nhiều vùng của không gian trạng thái và dễ dàng kết hợp với cơ chế xử lý ràng buộc, tìm kiếm cục bộ @holland1992adaptation @goldberg1989genetic.

Theo đặc tả *Homework 3* môn Nhập môn Trí tuệ nhân tạo (CO3061), hệ thống cần tự động xây dựng thời khóa biểu một tuần tiêu chuẩn (từ Thứ Hai đến Thứ Sáu, 6 ca học mỗi ngày gồm 3 ca sáng và 3 ca chiều) với quy mô được tổng hợp tại @tab_problem_params.

#block(breakable: false)[
  #figure(
    table(
      columns: (1.85fr, 0.75fr, 3.0fr),
      align: (left + horizon, right + horizon, left + horizon),
      inset: 4pt,
      fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        text(fill: white, [*Thành phần*]),
        text(fill: white, [*Số lượng*]),
        text(fill: white, [*Mô tả chi tiết theo đặc tả Homework 3*])
      ),
      [Môn học (Course)], [60], [Định danh từ `c01` đến `c60`; mỗi môn mở 8 lớp (16 buổi/tuần).],
      [Lớp học phần (Section)], [480], [Quy mô 3 mức (nhỏ, trung bình, lớn); 2 buổi/tuần không liền ngày.],
      [Buổi học (Session)], [960], [Tổng số vị trí phòng–ca cần phân bổ trong tuần ($480 times 2$).],
      [Giảng viên (Professor)], [60], [Tối đa 20 buổi (10 lớp)/tuần; 6 môn năng lực, 3 môn Top-3 yêu thích.],
      [Phòng học (Room)], [35], [3 mức kích thước; ma trận trạng thái khả dụng theo ngày–ca.],
      [Khung thời gian (Slot)], [30], [5 ngày (Thứ 2–Thứ 6) $times$ 6 ca/ngày (3 sáng, 3 chiều).],
    ),
    caption: [Các đối tượng và thông số quy mô bài toán Homework 3.]
  ) <tab_problem_params>
]

Thách thức cốt lõi của bài toán nằm ở *mật độ sử dụng tài nguyên phòng học cực cao* kết hợp với *ràng buộc cặp ngày không liền kề*. Xét tổng công suất phòng học lý thuyết toàn tuần là $35 times 5 times 6 = 1050$ vị trí phòng–ca, tỷ lệ lấp đầy tối thiểu cho 960 buổi học đã đạt `91,43%`. Khi đưa vào yếu tố thực tế là 26 vị trí phòng–ca không khả dụng do bảo trì hoặc bận lịch (`2,48%`), tổng công suất khả dụng giảm xuống còn `1024` vị trí, đẩy tỷ lệ khai thác phòng lên `93,75%` và chỉ còn dư đúng *64 vị trí trống* (`6,25%` độ dư) trên toàn bộ tuần học. Ở mức bão hòa này, một thay đổi nhỏ ở một buổi học có thể gây hiệu ứng dây chuyền xung đột phòng và giảng viên trên nhiều lớp khác. Bên cạnh đó, lịch phân bổ phải đồng thời thỏa mãn toàn bộ *ràng buộc cứng* (_Hard Constraints_), tối thiểu hóa mức phạt *ràng buộc mềm* (_Soft Constraints_) và đáp ứng các tiêu chí *ràng buộc mở rộng* (_Bonus Constraints_) về chuyên môn và nguyện vọng giảng dạy.

== Mục tiêu và phạm vi đề tài

Xuất phát từ phân tích trên, đề tài đặt ra bốn mục tiêu cụ thể:

+ *Mô hình hóa toán học đầy đủ:* Xây dựng hệ thống ký hiệu tập hợp, tham số, biến quyết định, hàm đánh giá ràng buộc cứng, ràng buộc mềm, ràng buộc mở rộng và hàm mục tiêu chuẩn hóa; đồng thời phân tích tính khả thi, nút thắt phân bố ngày và cận dưới lý thuyết của hàm mục tiêu.
+ *Thiết kế và cải tiến giải thuật di truyền:* Đề xuất giải thuật di truyền lai theo hướng *Memetic Algorithm* có khả năng tìm ra nghiệm khả thi tuyệt đối ($H(x) = 0$) và tối ưu sâu chất lượng thời khóa biểu trong điều kiện mật độ phòng học `93,75%`.
+ *Hiện thực hệ thống phần mềm hoàn chỉnh:* Xây dựng ứng dụng bằng Python 3.12 theo kiến trúc module phân lớp, hỗ trợ kiểm thử tự động (`pytest`), xuất kết quả đa định dạng (`CSV`, `JSON`, `HTML`), trực quan hóa (`matplotlib`) và giao diện web tra cứu (`Streamlit`).
+ *Thực nghiệm đối chứng và đánh giá định lượng:* Tổ chức thực nghiệm đối chứng ba phiên bản thuật toán trên cùng dữ liệu, phân tích đồ thị hội tụ, khảo sát độ nhạy siêu tham số và đánh giá khách quan ưu điểm, hạn chế cùng sự đánh đổi đa mục tiêu.

*Phạm vi và giả định của đề tài:* Hệ thống làm việc trên bộ dữ liệu sinh ngẫu nhiên có kiểm soát (`seed = 42`) tuân thủ đầy đủ quy mô Homework 3. Tập yêu cầu nghiệp vụ được mô hình hóa thành 7 hàm ràng buộc cứng (`H1–H7`), 5 hàm ràng buộc mềm (`S1–S5`) và 3 thành phần mở rộng (`B1a`, `B1b`, `B2`) dựa trên quan hệ bao hàm giữa tập môn đủ năng lực (6 môn) và tập Top-3 yêu thích (3 môn) của giảng viên. Đề tài giới hạn trong bài toán xếp lịch ngoại tuyến cho một tuần điển hình, giả định mỗi lớp học phần do một giảng viên duy nhất phụ trách cả hai buổi và chưa xét đến lịch đăng ký cá nhân của từng sinh viên hay các biến động đột xuất giữa học kỳ.

== Phương pháp tiếp cận, đóng góp chính và cấu trúc báo cáo

Để giải quyết bài toán mật độ tài nguyên cao, nhóm áp dụng phương pháp tiếp cận theo từng tầng từ phân tích toán học đến thiết kế thuật toán lai:

- *Tầng 1 – Biểu diễn và phân tích nút thắt:* Sử dụng biểu diễn theo lớp học phần (_Section-based Representation_, 480 gen) gắn kết chung giảng viên và cặp buổi học, đồng thời giải hệ phương trình cân bằng tải ngày để triệt tiêu nút thắt quá tải Thứ Hai và Thứ Sáu khi chọn cặp ngày hợp lệ.
- *Tầng 2 – Giải thuật di truyền lai (Proposed GA):* Kết hợp khởi tạo tham lam cân bằng tải theo ngày, xếp hạng ưu tiên khả thi (_Feasibility-first Ranking_), lai ghép bất đối xứng theo khối môn học (_Asymmetric Course-Block Crossover_), đột biến thích nghi (_Adaptive Smart Swap Mutation_) và cơ chế sửa chữa nghiệm bốn pha tích hợp tìm kiếm cục bộ hoán đổi cặp cùng ngày (_Same-Day Pairwise Swap_).
- *Tầng 3 – Đánh giá đối chứng có kiểm soát:* Xây dựng ba phiên bản thuật toán trên cùng một bộ máy tiến hóa và hàm đánh giá gồm *Baseline GA* (khởi tạo ngẫu nhiên, lai ghép đồng đều), *Improved GA* (khởi tạo tham lam cân bằng tải, lai ghép theo khối môn) và *Proposed GA* (bổ sung cơ chế sửa chữa bốn pha và hoán đổi cặp) để lượng hóa rõ ràng hiệu quả của từng nhóm cải tiến.

Nội dung còn lại của báo cáo được tổ chức thành 6 chương tiếp theo. *Chương 2* trình bày cơ sở lý thuyết về bài toán xếp thời khóa biểu, tối ưu tổ hợp có ràng buộc, giải thuật di truyền và giải thuật Memetic. *Chương 3* mô hình hóa toán học đầy đủ các tập dữ liệu, ràng buộc, hàm mục tiêu cùng phân tích nút thắt cặp ngày và cận dưới lý thuyết. *Chương 4* đi sâu vào thiết kế thuật toán đề xuất, mã giả và phân tích độ phức tạp tính toán. *Chương 5* trình bày kiến trúc module phân lớp, mô hình dữ liệu, kỹ thuật tối ưu cài đặt và hướng dẫn sử dụng hệ thống. *Chương 6* báo cáo kết quả kiểm thử tự động, thời khóa biểu tối ưu, đồ thị hội tụ, khảo sát độ nhạy tham số và so sánh đối chứng ba phiên bản GA. Cuối cùng, *Chương 7* tổng kết các kết quả đạt được, phân tích ưu nhược điểm và đề xuất hướng phát triển tiếp theo.
