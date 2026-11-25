= GIỚI THIỆU ĐỀ TÀI (INTRODUCTION)

== Bối cảnh đề tài
Trong các cơ sở giáo dục đại học, xây dựng thời khóa biểu là một trong những công việc quan trọng nhằm đảm bảo hoạt động giảng dạy và học tập diễn ra hiệu quả. Quá trình này đòi hỏi sự phối hợp giữa nhiều yếu tố như số lượng môn học, lớp học phần, giảng viên, phòng học và các khung thời gian giảng dạy. Khi quy mô đào tạo ngày càng mở rộng, việc lập thời khóa biểu bằng phương pháp thủ công trở nên phức tạp, tốn nhiều thời gian và dễ phát sinh các xung đột về tài nguyên.

Bài toán xếp thời khóa biểu đại học (_University Course Timetabling Problem – UCTP_) là một dạng bài toán tối ưu tổ hợp có ràng buộc, trong đó nhiều biến thể thuộc lớp bài toán *NP-hard* @schaerf1999survey. Với số lượng lớn các biến quyết định và mối quan hệ ràng buộc giữa chúng, không gian tìm kiếm tăng nhanh theo quy mô bài toán. Điều này khiến các phương pháp tìm kiếm truyền thống như vét cạn (_Exhaustive Search_) hoặc quay lui (_Backtracking_) gặp nhiều hạn chế về chi phí tính toán khi áp dụng vào những bài toán có kích thước lớn.

Trong số các phương pháp tối ưu hóa hiện nay, giải thuật di truyền (_Genetic Algorithm – GA_) là một hướng tiếp cận phù hợp nhờ khả năng duy trì một quần thể nghiệm ứng viên và cải thiện chất lượng nghiệm thông qua các quá trình chọn lọc, lai ghép và đột biến @holland1992adaptation. Bên cạnh đó, giải thuật di truyền có khả năng kết hợp với các phương pháp xử lý ràng buộc và tìm kiếm cục bộ nhằm nâng cao hiệu quả tìm kiếm.

Xuất phát từ những vấn đề trên, nhóm thực hiện đề tài *“Class Scheduling Using Genetic Algorithm”* nhằm nghiên cứu, thiết kế và hiện thực một hệ thống tự động xây dựng thời khóa biểu, hướng đến việc thỏa mãn các ràng buộc bắt buộc, đồng thời tối ưu hóa hiệu quả sử dụng tài nguyên và chất lượng lịch giảng dạy.

== Phát biểu bài toán
Theo yêu cầu của Homework 3 thuộc môn Nhập môn Trí tuệ nhân tạo (CO3061), bài toán đặt ra là xây dựng thời khóa biểu giảng dạy trong một tuần, từ thứ Hai đến thứ Sáu, với sáu ca học mỗi ngày. Các đối tượng và thông số của bài toán được trình bày trong @tab_problem_params.

#figure(
  table(
    columns: (2fr, 1fr, 2.5fr),
    align: (left + horizon, right + horizon, left + horizon),
    fill: (x, y) => if y == 0 { rgb("#0f3d7a") } else if calc.even(y) { rgb("#f1f5f9") } else { none },
    stroke: 0.5pt + luma(180),
    table.header(
      text(fill: white, [*Thành phần*]),
      text(fill: white, [*Số lượng*]),
      text(fill: white, [*Mô tả*])
    ),
    [Môn học (Course)], [60], [Định danh từ `c01` đến `c60`],
    [Lớp học phần (Section)], [480], [Mỗi môn học gồm 8 lớp],
    [Buổi học (Session)], [960], [Mỗi lớp có 2 buổi học mỗi tuần],
    [Giảng viên (Professor)], [60], [Tối đa 20 buổi dạy mỗi tuần],
    [Phòng học (Room)], [35], [Gồm 3 mức kích thước],
    [Ngày học (Day)], [5], [Từ thứ Hai đến thứ Sáu],
    [Ca học (Timeslot)], [6], [Mỗi ca tương ứng với một buổi học],
  ),
  caption: [Các đối tượng và thông số của bài toán xếp thời khóa biểu.]
) <tab_problem_params>

Mỗi phòng học và lớp học phần được phân loại theo ba mức kích thước tương ứng: nhỏ, trung bình và lớn. Ngoài ra, mỗi phòng học có trạng thái khả dụng theo từng ngày và ca học. Trong phạm vi mở rộng, hệ thống xem xét thêm danh sách các môn học mà giảng viên có thể đảm nhận và ba môn học yêu thích của mỗi giảng viên.

Nhiệm vụ của hệ thống là xác định giảng viên phụ trách, ngày học, ca học và phòng học phù hợp cho từng lớp học phần, sao cho hai buổi học của mỗi lớp được bố trí hợp lệ và không xảy ra xung đột trong quá trình sử dụng tài nguyên.

Một trong những thách thức chính của bài toán là mật độ sử dụng phòng học cao. Với 35 phòng học, 5 ngày học và 6 ca học mỗi ngày, tổng số vị trí phòng–ca khả dụng tối đa về mặt lý thuyết là `1.050`. Để bố trí đầy đủ `960` buổi học, tỷ lệ sử dụng tài nguyên tối thiểu đạt khoảng `91,43%` trong điều kiện tất cả phòng học đều khả dụng.

Trong trường hợp giả định khoảng `2,5%` số vị trí phòng–ca không khả dụng do bảo trì, số vị trí còn lại giảm xuống `1.024`, tương ứng với tỷ lệ sử dụng cần thiết là `93,75%`. Điều này làm giảm mức độ linh hoạt trong quá trình phân bổ và gia tăng khả năng phát sinh xung đột.

Do đó, bài toán không chỉ yêu cầu tìm kiếm một thời khóa biểu khả thi thỏa mãn toàn bộ ràng buộc cứng (_Hard Constraints_), mà còn hướng đến tối thiểu hóa mức độ vi phạm các ràng buộc mềm (_Soft Constraints_) và cải thiện mức độ đáp ứng các yêu cầu mở rộng (_Bonus Constraints_).

== Mục tiêu đề tài
Mục tiêu tổng quát của đề tài là xây dựng hệ thống tự động xếp thời khóa biểu dựa trên giải thuật di truyền, có khả năng tìm kiếm các phương án phân bổ lịch học hợp lệ và tối ưu hóa chất lượng thời khóa biểu trong điều kiện tài nguyên giới hạn.

Để đạt được mục tiêu tổng quát, đề tài tập trung vào các mục tiêu cụ thể sau:
- *Mô hình hóa bài toán:* Xác định các tập dữ liệu, biến quyết định, miền giá trị, hệ thống ràng buộc và hàm mục tiêu dưới dạng toán học, tạo cơ sở cho việc thiết kế thuật toán tối ưu.
- *Thiết kế và cải tiến giải thuật di truyền:* Xây dựng phương pháp biểu diễn nhiễm sắc thể phù hợp với cấu trúc lớp học phần, thiết kế hàm thích nghi và các toán tử di truyền. Đồng thời, nghiên cứu kết hợp phương pháp khởi tạo tham lam, cân bằng tải theo ngày và cơ chế sửa chữa nghiệm thông qua hoán đổi cặp nhằm cải thiện khả năng tìm kiếm nghiệm khả thi.
- *Xây dựng hệ thống phần mềm:* Hiện thực thuật toán bằng ngôn ngữ Python theo kiến trúc module phân lớp, đảm bảo khả năng kiểm thử, bảo trì và mở rộng. Hệ thống hỗ trợ sinh dữ liệu đầu vào, thực thi thuật toán, kiểm tra ràng buộc và trực quan hóa kết quả.
- *Đánh giá hiệu quả của phương pháp đề xuất:* Thực hiện các thí nghiệm nhằm so sánh chất lượng nghiệm, khả năng hội tụ và thời gian thực thi giữa các phiên bản giải thuật di truyền. Qua đó, phân tích ảnh hưởng của các tham số và đánh giá hiệu quả của những kỹ thuật cải tiến.

Kết quả đầu ra hướng đến một thời khóa biểu hoàn chỉnh cho 480 lớp học phần, kèm theo biểu đồ hội tụ của hàm thích nghi, thống kê mức độ vi phạm ràng buộc và các kết quả đánh giá thực nghiệm.

== Phạm vi đề tài
Đề tài tập trung nghiên cứu và giải quyết bài toán xếp thời khóa biểu trong phạm vi các yêu cầu được quy định tại Homework 3, kết hợp với một số giả định và kỹ thuật mở rộng do nhóm đề xuất:

- *Về dữ liệu:* Hệ thống sử dụng bộ dữ liệu được sinh ngẫu nhiên có kiểm soát, bao gồm 60 môn học, 480 lớp học phần, 960 buổi học, 60 giảng viên và 35 phòng học. Quá trình sinh dữ liệu sử dụng giá trị khởi tạo ngẫu nhiên cố định (_random seed_), với giá trị mặc định bằng `42`, nhằm hỗ trợ khả năng tái lập các thí nghiệm. Dữ liệu được kiểm tra các điều kiện cần về khả năng đáp ứng tài nguyên trước khi đưa vào thuật toán tối ưu.
- *Về ràng buộc:* Đề tài xem xét đầy đủ sáu nhóm ràng buộc cứng và bốn nhóm ràng buộc mềm theo đặc tả bài toán. Trong quá trình mô hình hóa, các nhóm ràng buộc này được phân tách thành bảy thành phần kiểm tra ràng buộc cứng (`H1–H7`) và năm thành phần đánh giá ràng buộc mềm (`S1–S5`). Ngoài ra, nhóm xem xét hai yêu cầu mở rộng liên quan đến sở thích và khả năng phân công môn học cho giảng viên.
- *Về thuật toán:* Đề tài tập trung vào giải thuật di truyền và các kỹ thuật cải tiến liên quan, bao gồm khởi tạo quần thể có định hướng, hàm phạt ràng buộc, cơ chế bảo toàn cá thể tốt nhất, sửa chữa nghiệm và tìm kiếm cục bộ thông qua hoán đổi cặp.
- *Về công nghệ:* Hệ thống được định hướng triển khai bằng Python 3.12, kết hợp các thư viện NumPy, Pandas, Matplotlib, Pytest và Streamlit phục vụ xử lý dữ liệu, kiểm thử, trực quan hóa và tương tác với người dùng. Dữ liệu đầu vào và kết quả đầu ra được quản lý thông qua các định dạng JSON, CSV và HTML.

Đề tài giới hạn trong phạm vi lập lịch giảng dạy cho một tuần điển hình, chưa xem xét các yếu tố như lịch học cá nhân của sinh viên, chương trình đào tạo, sự thay đổi lịch học đột xuất hoặc việc điều chỉnh thời khóa biểu trong suốt học kỳ.

== Phương pháp tiếp cận
Để giải quyết bài toán xếp thời khóa biểu có mật độ sử dụng tài nguyên cao, nhóm đề xuất phương pháp tiếp cận kết hợp giải thuật di truyền với các kỹ thuật xử lý ràng buộc và cải thiện nghiệm. Phương pháp được xây dựng dựa trên ba định hướng chính:

- *Thứ nhất, phân tích tính khả thi trước khi thực hiện tối ưu.* Nhóm phân tích khả năng đáp ứng của phòng học, khối lượng giảng dạy của giảng viên và sự phân bố các buổi học theo từng ngày trong tuần. Đặc biệt, việc lựa chọn đồng đều các cặp ngày hợp lệ có thể dẫn đến sự mất cân bằng tải giữa các ngày học. Trên cơ sở đó, nhóm đề xuất phương pháp khởi tạo tham lam kết hợp cân bằng tải theo ngày nhằm hạn chế xung đột ngay từ giai đoạn hình thành quần thể ban đầu.
- *Thứ hai, biểu diễn nhiễm sắc thể theo lớp học phần (Section-based Chromosome Representation).* Thay vì biểu diễn từng buổi học như một gen độc lập, mỗi gen được thiết kế để mã hóa toàn bộ thông tin lịch học của một lớp học phần, bao gồm giảng viên phụ trách và hai buổi học trong tuần. Cách biểu diễn này giúp duy trì mối liên hệ giữa hai buổi học của cùng một lớp, đồng thời hỗ trợ quá trình kiểm tra ràng buộc và thực hiện các toán tử di truyền.
- *Thứ ba, kết hợp giải thuật di truyền với cơ chế sửa chữa nghiệm và tìm kiếm cục bộ.* Giải thuật di truyền đảm nhiệm quá trình khám phá không gian tìm kiếm thông qua các toán tử chọn lọc, lai ghép và đột biến. Các nghiệm sinh ra được kiểm tra và điều chỉnh bằng cơ chế sửa chữa nhằm giảm số lượng vi phạm ràng buộc cứng. Bên cạnh đó, kỹ thuật hoán đổi cặp (_Pairwise Swap_) được xem xét để cải thiện nghiệm trong vùng lân cận mà không cần thay đổi toàn bộ cấu trúc thời khóa biểu.

Để đánh giá đóng góp của từng kỹ thuật cải tiến, nhóm xây dựng ba phiên bản thuật toán:
- *Baseline GA:* Giải thuật di truyền cơ bản với phương pháp khởi tạo ngẫu nhiên.
- *Improved GA:* Giải thuật di truyền kết hợp phương pháp khởi tạo tham lam và cân bằng tải.
- *Proposed GA:* Giải thuật di truyền kết hợp khởi tạo có định hướng, cơ chế sửa chữa nghiệm và kỹ thuật hoán đổi cặp.

Các phiên bản được đánh giá trên cùng bộ dữ liệu và các điều kiện thực nghiệm có thể so sánh, dựa trên chất lượng nghiệm, số lượng vi phạm ràng buộc, khả năng hội tụ và thời gian thực thi.

== Cấu trúc báo cáo
Báo cáo được tổ chức thành bảy chương với nội dung như sau:
- *Chương 1 – Giới thiệu đề tài:* Trình bày bối cảnh, phát biểu bài toán, mục tiêu, phạm vi nghiên cứu và phương pháp tiếp cận tổng thể.
- *Chương 2 – Cơ sở lý thuyết:* Trình bày các kiến thức nền tảng về bài toán xếp thời khóa biểu, tối ưu tổ hợp, giải thuật di truyền và các phương pháp xử lý ràng buộc.
- *Chương 3 – Mô hình hóa bài toán:* Xây dựng mô hình toán học, định nghĩa các tập dữ liệu, biến quyết định, ràng buộc cứng, ràng buộc mềm và hàm mục tiêu. Đồng thời, phân tích các điều kiện liên quan đến tính khả thi của bài toán.
- *Chương 4 – Thiết kế thuật toán:* Trình bày chi tiết phương pháp biểu diễn nghiệm, khởi tạo quần thể, hàm thích nghi, các toán tử di truyền và những kỹ thuật cải tiến được đề xuất.
- *Chương 5 – Thiết kế và hiện thực hệ thống:* Trình bày kiến trúc phần mềm, mô hình dữ liệu, cấu trúc mã nguồn, các module chức năng và quá trình hiện thực thuật toán.
- *Chương 6 – Thực nghiệm và đánh giá:* Trình bày phương pháp thực nghiệm, kết quả xếp thời khóa biểu, biểu đồ hội tụ, phân tích độ nhạy tham số và so sánh hiệu quả giữa các phiên bản thuật toán.
- *Chương 7 – Kết luận và hướng phát triển:* Tổng kết những kết quả đạt được, phân tích các hạn chế còn tồn tại và đề xuất các hướng nghiên cứu, phát triển trong tương lai.
