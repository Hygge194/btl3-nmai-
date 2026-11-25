= THIẾT KẾ VÀ HIỆN THỰC HỆ THỐNG (SYSTEM DESIGN AND IMPLEMENTATION)

== Công nghệ và môi trường phát triển

Hệ thống được phát triển bằng ngôn ngữ Python 3.12, kết hợp với các thư viện hỗ trợ tính toán, xử lý dữ liệu, kiểm thử và trực quan hóa kết quả.

Python được lựa chọn nhờ cú pháp rõ ràng, khả năng biểu diễn linh hoạt các cấu trúc dữ liệu và hệ sinh thái thư viện phù hợp với việc nghiên cứu, hiện thực các thuật toán trí tuệ nhân tạo. Việc sử dụng Python cũng giúp nhóm tập trung vào thiết kế thuật toán và phương pháp tối ưu thay vì phải xử lý nhiều vấn đề liên quan đến quản lý bộ nhớ hoặc phát triển hạ tầng phần mềm.

Các công nghệ và thư viện chính được sử dụng trong hệ thống được trình bày trong bảng sau.

#table(
  columns: (1fr, 0.8fr, 3.2fr),
  align: (left, center, left),
  table.header(
    [*Công nghệ*],
    [*Phiên bản*],
    [*Mục đích sử dụng*],
  ),
  [Python],
  [3.12],
  [Ngôn ngữ lập trình chính, hiện thực mô hình dữ liệu, thuật toán di truyền và các module xử lý ràng buộc.],

  [`numpy`],
  [$>= 1.26$],
  [Sinh số ngẫu nhiên có kiểm soát, tổ chức dữ liệu dạng mảng và hỗ trợ truy xuất thông tin phục vụ đánh giá nghiệm.],

  [`pandas`],
  [$>= 2.1$],
  [Tổng hợp thời khóa biểu, thống kê kết quả thực nghiệm và xuất dữ liệu dạng CSV.],

  [`matplotlib`],
  [$>= 3.8$],
  [Trực quan hóa quá trình hội tụ, mức độ vi phạm ràng buộc và hiệu quả sử dụng tài nguyên.],

  [`pytest`],
  [$>= 8.0$],
  [Kiểm thử tự động các thành phần ràng buộc, hàm thích nghi, toán tử di truyền và luồng tích hợp.],

  [`streamlit`],
  [$>= 1.32$],
  [Xây dựng giao diện web hỗ trợ cấu hình thuật toán, thực thi và tra cứu thời khóa biểu.],
)

Trong đó, NumPy được sử dụng để hỗ trợ tổ chức và truy xuất các thông tin thường xuyên được sử dụng trong quá trình đánh giá cá thể, chẳng hạn như:

- `section_size_arr`: Kích thước đăng ký của các lớp học phần.

- `room_avail_arr`: Trạng thái khả dụng của phòng học theo ngày và ca học.

- `is_eligible_arr`: Thông tin về khả năng đảm nhận môn học của giảng viên.

- `fav_rank_arr`: Thông tin về mức độ ưu tiên môn học của giảng viên.

Việc tổ chức các thông tin này dưới dạng mảng chỉ số giúp giảm số lần tìm kiếm và chuyển đổi dữ liệu trong vòng lặp tiến hóa, đặc biệt khi hệ thống cần đánh giá một số lượng lớn nhiễm sắc thể.

Đối với việc lưu trữ dữ liệu, nhóm sử dụng các định dạng JSON, CSV và HTML thay cho hệ quản trị cơ sở dữ liệu. Nguyên nhân là dữ liệu của bài toán có quy mô hữu hạn, cấu trúc tương đối ổn định và không yêu cầu xử lý giao dịch đồng thời giữa nhiều người dùng.

Cách tiếp cận này giúp đơn giản hóa quá trình cài đặt, tăng khả năng di chuyển của hệ thống và thuận tiện cho việc tái lập các thí nghiệm.

Các thư viện phụ thuộc được khai báo trong tệp `requirements.txt`, cho phép thiết lập môi trường phát triển và thực thi hệ thống trên các máy tính khác nhau.


== Kiến trúc tổng thể hệ thống

Hệ thống được tổ chức theo kiến trúc module phân lớp theo trách nhiệm (_Layered Modular Architecture_).

Thay vì tập trung toàn bộ quá trình sinh dữ liệu, kiểm tra ràng buộc, thực hiện thuật toán di truyền và xuất kết quả trong một chương trình duy nhất, nhóm phân chia hệ thống thành các thành phần có trách nhiệm riêng biệt.

Việc lựa chọn kiến trúc này xuất phát từ đặc điểm của bài toán: các quy tắc nghiệp vụ, phương pháp đánh giá nghiệm và toán tử tối ưu có thể được điều chỉnh độc lập trong quá trình phát triển và thực nghiệm.

Chẳng hạn, việc bổ sung một ràng buộc mềm mới không nên yêu cầu thay đổi toàn bộ vòng lặp tiến hóa. Tương tự, việc thay đổi phương pháp lai ghép không nên ảnh hưởng trực tiếp đến cấu trúc dữ liệu đầu vào hoặc giao diện hiển thị kết quả.

Hệ thống bao gồm sáu thành phần chính.

*Presentation Layer – Tầng giao diện.*

Tầng giao diện cung cấp hai phương thức tương tác với hệ thống:

- Giao diện dòng lệnh (Command Line Interface – CLI) thông qua `main.py`.

- Giao diện web tương tác thông qua `app.py` được xây dựng bằng Streamlit.

Tầng này tiếp nhận các tham số cấu hình, gửi yêu cầu thực thi đến tầng ứng dụng và trình bày kết quả cho người dùng.

Việc tách giao diện khỏi thuật toán giúp hệ thống có thể thay đổi phương thức tương tác mà không cần thay đổi logic tối ưu hóa bên trong.

*Application Layer – Tầng ứng dụng.*

Tầng ứng dụng được hiện thực chủ yếu trong `src/services/scheduler.py`, với thành phần trung tâm là `SchedulerService`.

Thành phần này chịu trách nhiệm điều phối quá trình thực thi, bao gồm:

- Chuẩn bị dữ liệu và cấu hình thuật toán.

- Khởi tạo bộ máy giải thuật di truyền.

- Thực hiện một hoặc nhiều phiên bản thuật toán.

- Thu thập, tổng hợp và đóng gói kết quả thực nghiệm.

- Chuyển kết quả đến các module thống kê, xuất dữ liệu và trực quan hóa.

Kết quả thực nghiệm được tổ chức thông qua cấu trúc `ExperimentBundle`, giúp thống nhất cách trao đổi dữ liệu giữa quá trình thực thi thuật toán và các thành phần xử lý đầu ra.

Cách tổ chức này cho phép giao diện dòng lệnh và giao diện web sử dụng chung luồng xử lý nghiệp vụ, hạn chế việc lặp lại mã nguồn.

*Domain Layer – Tầng mô hình nghiệp vụ.*

Tầng Domain nằm trong thư mục `src/models/`, định nghĩa các đối tượng cơ bản của bài toán, bao gồm:

- `Course`: Môn học.
- `Section`: Lớp học phần.
- `Session`: Buổi học.
- `Professor`: Giảng viên.
- `Room`: Phòng học.
- `Gene`: Thông tin phân bổ một lớp học phần.
- `Chromosome`: Một phương án thời khóa biểu hoàn chỉnh.

Các đối tượng này là cơ sở để biểu diễn dữ liệu đầu vào và nghiệm ứng viên được sử dụng trong quá trình tối ưu.

Việc tách riêng tầng Domain giúp thống nhất cách biểu diễn dữ liệu giữa các module, hạn chế tình trạng mỗi thành phần sử dụng một cấu trúc dữ liệu khác nhau.

*Data Layer – Tầng xử lý dữ liệu.*

Tầng dữ liệu được hiện thực thông qua `data_generator.py` và `data_loader.py`.

Các nhiệm vụ chính bao gồm sinh bộ dữ liệu đầu vào, kiểm tra các điều kiện cần về khả năng đáp ứng tài nguyên, lưu dữ liệu dưới dạng JSON và chuyển đổi dữ liệu từ tệp sang các đối tượng Domain.

Việc tách quá trình sinh dữ liệu khỏi thuật toán di truyền giúp hệ thống có thể thực hiện nhiều thí nghiệm trên cùng một bộ dữ liệu mà không cần thay đổi logic tối ưu.

Đây cũng là cơ sở để đảm bảo các phiên bản thuật toán được so sánh trong cùng điều kiện đầu vào.

*Constraint and Genetic Algorithm Engine – Tầng xử lý ràng buộc và tối ưu.*

Đây là thành phần xử lý chính của hệ thống, bao gồm hai nhóm module:

- `src/constraints/`: Hiện thực các hàm đánh giá ràng buộc cứng, ràng buộc mềm và các tiêu chí mở rộng.

- `src/genetic/`: Hiện thực phương pháp khởi tạo, đánh giá Fitness, chọn lọc, lai ghép, đột biến, sửa chữa nghiệm và vòng lặp tiến hóa.

Việc tách logic kiểm tra ràng buộc khỏi vòng lặp giải thuật di truyền giúp các quy tắc nghiệp vụ có thể được kiểm thử và điều chỉnh độc lập.

Bên cạnh đó, ba phiên bản Baseline GA, Improved GA và Proposed GA có thể sử dụng chung hệ thống đánh giá, từ đó duy trì sự nhất quán trong quá trình so sánh chất lượng nghiệm.

*Output Module – Module xử lý kết quả.*

Module xử lý kết quả nằm trong thư mục `src/utils/`, bao gồm các thành phần thống kê, xuất dữ liệu và trực quan hóa.

Module này chuyển đổi nghiệm tốt nhất tìm được và lịch sử tiến hóa thành các dạng kết quả phù hợp với mục đích sử dụng, chẳng hạn như bảng thời khóa biểu, báo cáo vi phạm ràng buộc và biểu đồ hội tụ.

Việc tách module đầu ra khỏi bộ máy giải thuật di truyền giúp tránh đưa các thao tác xuất tệp và trực quan hóa không cần thiết vào vòng lặp tối ưu.

@fig_sys_arch minh họa kiến trúc module phân lớp và quan hệ phụ thuộc giữa các tầng của hệ thống.

#figure(
  image("../picture/System Architecture Diagram – Mục 5.2.svg", width: 96%),
  caption: [Kiến trúc module phân lớp của hệ thống xếp thời khóa biểu.]
) <fig_sys_arch>

Sơ đồ kiến trúc tổng thể thể hiện sự phân chia trách nhiệm giữa các thành phần của hệ thống. Tầng giao diện tiếp nhận yêu cầu từ người dùng, trong khi tầng ứng dụng điều phối quá trình chuẩn bị dữ liệu và thực thi thuật toán.

GA Engine sử dụng các đối tượng Domain và các hàm đánh giá ràng buộc để thực hiện quá trình tối ưu. Kết quả sau khi tiến hóa được chuyển đến module xử lý đầu ra để thống kê, xuất dữ liệu và trực quan hóa.

Cách tổ chức này giúp hạn chế sự phụ thuộc trực tiếp giữa giao diện người dùng và các thành phần xử lý thuật toán.

Nhìn chung, kiến trúc được lựa chọn hướng đến tính phân tách trách nhiệm (_Separation of Concerns_), khả năng tái sử dụng, khả năng kiểm thử và khả năng mở rộng.

Do hệ thống được xây dựng trong phạm vi một bài toán tối ưu độc lập, kiến trúc module trong một ứng dụng Python phù hợp hơn việc triển khai các dịch vụ phân tán hoặc kiến trúc Microservices, vốn làm tăng độ phức tạp triển khai mà không trực tiếp cải thiện chất lượng thuật toán.


== Cấu trúc thư mục mã nguồn

Mã nguồn của hệ thống được tổ chức theo từng nhóm chức năng nhằm đảm bảo sự nhất quán với kiến trúc đã trình bày.

Trách nhiệm của các nhóm thư mục và tệp chính được trình bày trong bảng sau.

#table(
  columns: (1.2fr, 3fr),
  align: left,
  table.header(
    [*Thành phần*],
    [*Trách nhiệm*],
  ),
  [`config.py`],
  [Quản lý thông số bài toán, siêu tham số GA và trọng số hàm phạt.],

  [`main.py`],
  [Điểm khởi chạy hệ thống thông qua giao diện dòng lệnh.],

  [`app.py`],
  [Cung cấp giao diện web tương tác.],

  [`data/`],
  [Lưu trữ dữ liệu đầu vào của bài toán.],

  [`src/models/`],
  [Định nghĩa các đối tượng nghiệp vụ và cấu trúc nghiệm.],

  [`src/constraints/`],
  [Hiện thực các quy tắc kiểm tra và đánh giá ràng buộc.],

  [`src/genetic/`],
  [Hiện thực giải thuật di truyền và các kỹ thuật cải tiến.],

  [`src/services/`],
  [Điều phối quá trình chuẩn bị dữ liệu và thực thi thuật toán.],

  [`src/utils/`],
  [Thống kê, trực quan hóa và xuất kết quả.],

  [`tests/`],
  [Kiểm thử tự động các thành phần của hệ thống.],

  [`outputs/`],
  [Lưu kết quả thời khóa biểu và dữ liệu thực nghiệm.],

  [`docs/`],
  [Lưu mã nguồn Typst và tài liệu báo cáo.],
)

Cách tổ chức mã nguồn theo từng nhóm chức năng giúp giảm sự phụ thuộc giữa các thành phần.

Chẳng hạn, khi cần thay đổi chiến lược lai ghép, nhóm có thể tập trung chỉnh sửa module `crossover.py` và các ca kiểm thử tương ứng mà không cần thay đổi module xuất thời khóa biểu.

Tương tự, khi bổ sung một ràng buộc mới, phần thay đổi chủ yếu tập trung vào module kiểm tra ràng buộc và hàm đánh giá Fitness.

Các tham số được tập trung trong `config.py` nhằm hạn chế việc khai báo trực tiếp các giá trị cố định trong nhiều module khác nhau. Điều này đặc biệt hữu ích đối với quá trình khảo sát độ nhạy tham số được thực hiện tại Chương 6.


== Thiết kế mô hình dữ liệu

Mô hình dữ liệu được xây dựng dựa trên các tập hợp, biến quyết định và phương pháp biểu diễn nghiệm đã trình bày tại Chương 3 và Chương 4.

Mục tiêu của thiết kế là duy trì sự tương ứng giữa mô hình toán học và cấu trúc dữ liệu trong chương trình, đồng thời hỗ trợ việc truy xuất thông tin và thực hiện các toán tử di truyền.


=== Class Diagram (Quan hệ giữa các lớp Domain)

Các đối tượng của tầng Domain được tổ chức thành hai nhóm chính.

Nhóm thứ nhất bao gồm các đối tượng mô tả dữ liệu đầu vào:

- `Course`.
- `Section`.
- `Professor`.
- `Room`.

Nhóm thứ hai bao gồm các đối tượng biểu diễn phương án phân bổ thời khóa biểu:

- `Session`.
- `Gene`.
- `Chromosome`.
- `Population`.

Trong đó, `Population` thuộc nhóm module thuật toán di truyền nhưng sử dụng trực tiếp các đối tượng của tầng Domain.

Quan hệ giữa các lớp được xác định như sau:

- Một `Course` tương ứng với tám `Section`.

- Mỗi `Section` thuộc về một `Course`, được xác định thông qua thuộc tính `course_id`.

- Mỗi `Gene` biểu diễn thông tin phân bổ của một `Section` và tham chiếu đến một `Professor`.

- Một `Gene` chứa đúng hai đối tượng `Session`, tương ứng với hai buổi học của lớp.

- Mỗi `Session` xác định ngày học, ca học và phòng học được sử dụng.

- Một `Chromosome` chứa 480 đối tượng `Gene`.

- Một `Population` chứa $N_"pop"$ đối tượng `Chromosome`, với giá trị mặc định là 80.

@fig_class_diagram minh họa sơ đồ lớp tổng thể cùng các thuộc tính, phương thức chính và quan hệ cấu trúc giữa mô hình dữ liệu bài toán và cấu trúc nghiệm GA.

#figure(
  image("../picture/Class Diagram – Mục 5.4.1.svg", width: 96%),
  caption: [Sơ đồ lớp biểu diễn quan hệ giữa mô hình dữ liệu và các cấu trúc nghiệm của giải thuật di truyền.]
) <fig_class_diagram>

Sơ đồ lớp thể hiện sự phân biệt giữa các đối tượng mô tả dữ liệu bài toán và những đối tượng biểu diễn nghiệm ứng viên. Trong đó, `Gene` đóng vai trò liên kết lớp học phần với giảng viên phụ trách và hai buổi học tương ứng. `Chromosome` tổng hợp toàn bộ 480 `Gene` để biểu diễn một phương án thời khóa biểu hoàn chỉnh. Các đối tượng mô tả dữ liệu bài toán được tham chiếu thông qua định danh, trong khi thông tin phân bổ thuộc từng nhiễm sắc thể cần được quản lý độc lập để tránh ảnh hưởng giữa các cá thể trong quá trình tiến hóa.

Chi tiết các quan hệ cấu trúc trong sơ đồ lớp và mối liên hệ với mô hình toán học được tổng hợp trong @tab_class_relations và @tab_domain_mapping.

#figure(
  table(
    columns: (1.5fr, 1.1fr, 2.4fr),
    align: left,
    table.header(
      [*Quan hệ*],
      [*Kiểu quan hệ*],
      [*Ý nghĩa*],
    ),
    [`Population` -- `Chromosome`], [Quan hệ chứa], [Một quần thể quản lý nhiều nhiễm sắc thể ($N_"pop" = 80$).],
    [`Chromosome` -- `Gene`], [Quan hệ chứa], [Một nhiễm sắc thể gồm 480 `Gene`.],
    [`Gene` -- `Session`], [Composition], [Một `Gene` chứa đúng hai buổi học (`session_1`, `session_2`).],
    [`Gene` -- `Professor`], [Association], [Tham chiếu giảng viên phụ trách thông qua `professor_id`.],
    [`Gene` -- `Section`], [Association], [Tham chiếu lớp học phần thông qua `section_id`.],
    [`Section` -- `Course`], [Association], [Tám lớp học phần thuộc một môn học (`course_id`).],
    [`Session` -- `Room`], [Association], [Buổi học được phân bổ vào một phòng (`room_id`).],
  ),
  caption: [Tổng hợp các quan hệ cấu trúc trong Class Diagram.]
) <tab_class_relations>

#figure(
  table(
    columns: (1fr, 1.2fr, 2.8fr),
    align: left,
    table.header(
      [*Ký hiệu*],
      [*Lớp dữ liệu*],
      [*Ý nghĩa*],
    ),
    [$cal(C)$], [`Course`], [Tập môn học.],
    [$cal(S)$], [`Section`], [Tập lớp học phần.],
    [$cal(P)$], [`Professor`], [Tập giảng viên.],
    [$cal(R)$], [`Room`], [Tập phòng học.],
    [$u_(s,k)$], [`Session`], [Thông tin phân bổ một buổi học.],
    [$g_s$], [`Gene`], [Thông tin phân bổ một lớp học phần.],
    [$x$], [`Chromosome`], [Một phương án thời khóa biểu hoàn chỉnh.],
    [$cal(P)_g$], [`Population`], [Quần thể tại một thế hệ tiến hóa.],
  ),
  caption: [Ánh xạ giữa các ký hiệu toán học và các lớp dữ liệu trong chương trình.]
) <tab_domain_mapping>

Trong thiết kế này, các đối tượng như `Course`, `Section`, `Professor` và `Room` mô tả dữ liệu của bài toán, trong khi `Gene` và `Chromosome` mô tả trạng thái phân bổ của một nghiệm ứng viên.

Việc phân biệt dữ liệu bài toán và dữ liệu nghiệm có ý nghĩa quan trọng đối với hiệu quả sử dụng bộ nhớ. Các nhiễm sắc thể không cần lưu lặp lại toàn bộ thông tin môn học, kích thước phòng hoặc danh sách môn yêu thích của giảng viên mà có thể tham chiếu đến dữ liệu thông qua các chỉ số định danh.

Bên cạnh đó, mỗi nhiễm sắc thể cần duy trì trạng thái phân bổ độc lập. Khi thực hiện sao chép cá thể, lai ghép hoặc đột biến, việc thay đổi một gen của cá thể con không được làm thay đổi ngoài ý muốn các cá thể cha mẹ hoặc cá thể ưu tú.


=== Cấu trúc dữ liệu đầu vào (`data/*.json`)

Dữ liệu đầu vào được tổ chức thành bốn tệp JSON độc lập, tương ứng với bốn nhóm đối tượng chính của bài toán.

#table(
  columns: (1.4fr, 0.7fr, 3fr),
  align: (left, center, left),
  table.header(
    [*Tệp dữ liệu*],
    [*Số lượng*],
    [*Thông tin lưu trữ*],
  ),
  [`courses.json`],
  [60],
  [Định danh và thông tin môn học.],

  [`sections.json`],
  [480],
  [Định danh lớp, môn học tương ứng và kích thước đăng ký.],

  [`professors.json`],
  [60],
  [Định danh giảng viên, danh sách môn có thể đảm nhận, Top-3 môn yêu thích và định mức giảng dạy.],

  [`rooms.json`],
  [35],
  [Định danh phòng, kích thước phòng và ma trận khả dụng theo ngày, ca học.],
)

Đối với giảng viên, hệ thống lưu trữ hai danh sách:

- `eligible_courses`: Danh sách sáu môn học có thể đảm nhận.

- `favorite_courses`: Danh sách ba môn học yêu thích.

Hai danh sách này phục vụ việc đánh giá riêng mức độ phù hợp về khả năng đảm nhận môn học và mức độ đáp ứng nguyện vọng giảng dạy, theo giả định mở rộng đã được trình bày tại Chương 3.

Đối với phòng học, trạng thái khả dụng được biểu diễn bằng ma trận:

$ A_r in {0,1}^(5 times 6) $

Trong đó, mỗi phần tử của ma trận biểu diễn trạng thái khả dụng của phòng tại một ngày và ca học tương ứng.

Việc sử dụng JSON giúp dữ liệu đầu vào có cấu trúc rõ ràng, dễ đọc và thuận tiện cho việc kiểm tra hoặc thay đổi cấu hình.

Ngoài ra, việc lưu bộ dữ liệu đầu vào thành các tệp riêng biệt cho phép sử dụng lại cùng một bộ dữ liệu trong nhiều lần thực nghiệm, tránh ảnh hưởng của sự thay đổi dữ liệu đến kết quả so sánh thuật toán.

Trong hệ thống, giá trị `seed` được sử dụng cho quá trình sinh dữ liệu, còn `ga-seed` được sử dụng cho quá trình tìm kiếm ngẫu nhiên của giải thuật di truyền.

Việc tách hai giá trị khởi tạo ngẫu nhiên giúp nhóm có thể giữ nguyên dữ liệu bài toán trong khi thay đổi quá trình tiến hóa để phục vụ các thí nghiệm đánh giá thuật toán.


=== Cấu trúc dữ liệu đầu ra (`outputs/`)

Kết quả thực thi được lưu trữ trong thư mục `outputs/` dưới nhiều định dạng khác nhau nhằm phục vụ việc kiểm chứng nghiệm, phân tích thực nghiệm và sử dụng thời khóa biểu.

*Thời khóa biểu hoàn chỉnh (`best_schedule.csv`).*

Tệp này lưu toàn bộ 960 buổi học, trong đó mỗi dòng dữ liệu tương ứng với một buổi học đã được phân bổ.

Các trường thông tin chính gồm:

#table(
  columns: (1.4fr, 2.8fr),
  align: left,
  table.header(
    [*Trường dữ liệu*],
    [*Ý nghĩa*],
  ),
  [`section`], [Định danh lớp học phần.],
  [`course`], [Môn học tương ứng.],
  [`professor`], [Giảng viên phụ trách.],
  [`day`], [Ngày học.],
  [`timeslot`], [Ca học.],
  [`period`], [Buổi sáng hoặc buổi chiều.],
  [`room`], [Phòng học được phân bổ.],
  [`room_size`], [Kích thước phòng học.],
  [`section_size`], [Kích thước đăng ký của lớp.],
  [`is_favorite_course`], [Trạng thái môn học có thuộc danh sách yêu thích của giảng viên hay không.],
  [`size_waste`], [Độ dư kích thước phòng so với quy mô lớp.],
)

Việc lưu thông tin chi tiết ở cấp buổi học cho phép kiểm tra trực tiếp từng phương án phân bổ, đồng thời hỗ trợ xây dựng các bảng thời khóa biểu theo giảng viên, phòng học hoặc môn học.

*Lịch sử tiến hóa (`fitness_history.csv`).*

Tệp này lưu thông tin đánh giá qua từng thế hệ của các phiên bản thuật toán.

Các trường chính bao gồm:

- `best_fitness`: Fitness của cá thể tốt nhất được ghi nhận.

- `avg_fitness`: Fitness trung bình của quần thể.

- `best_hard`: Số vi phạm cứng của cá thể tốt nhất.

- `best_soft_penalty`: Tổng điểm phạt mềm của cá thể tốt nhất.

- `mutation_rate`: Tỷ lệ đột biến tại thế hệ tương ứng.

Dữ liệu lịch sử được sử dụng để xây dựng biểu đồ hội tụ và phân tích sự thay đổi chất lượng nghiệm trong quá trình tiến hóa.

Do hệ thống sử dụng khóa xếp hạng ưu tiên tính khả thi, cá thể được xem là tốt nhất được xác định theo `rank_key()`, không nhất thiết là cá thể có giá trị Fitness lớn nhất khi quần thể còn chứa các nghiệm không khả thi.

*Báo cáo vi phạm ràng buộc (`conflict_report.json`).*

Tệp này lưu các kết quả đánh giá chi tiết của hệ thống, bao gồm bảy thành phần ràng buộc cứng, năm thành phần ràng buộc mềm, ba thành phần đánh giá Bonus và các thông tin thống kê liên quan.

Việc lưu kết quả chi tiết thay vì chỉ lưu Fitness giúp xác định nguyên nhân của các vi phạm và phân tích sự đánh đổi giữa những tiêu chí tối ưu khác nhau.

*Bảng thống kê giảng viên (`professor_summary.csv`).*

Tệp này tổng hợp các thông tin liên quan đến lịch giảng dạy của từng giảng viên, bao gồm số buổi dạy, các khoảng trống trong lịch và mức độ đáp ứng môn học yêu thích.

*Thời khóa biểu tương tác (`final_schedule.html`).*

Tệp HTML cung cấp một phương thức tra cứu thời khóa biểu trực tiếp trên trình duyệt, cho phép người dùng tìm kiếm và lọc thông tin mà không cần chạy lại giải thuật di truyền.

Việc xuất kết quả dưới nhiều định dạng giúp phân biệt mục đích sử dụng của từng loại dữ liệu: CSV phục vụ kiểm tra và phân tích, JSON phục vụ lưu trữ kết quả đánh giá có cấu trúc, còn HTML hỗ trợ tra cứu trực quan.


== Hiện thực các module chức năng

Các module chức năng được xây dựng dựa trên nguyên tắc phân tách trách nhiệm, trong đó mỗi module tập trung xử lý một nhóm nhiệm vụ cụ thể.

Phần này trình bày cách hiện thực các thành phần chính của hệ thống và sự tương ứng với mô hình, thuật toán đã được xây dựng ở các chương trước.


=== Data Generation Module (`data_generator.py`)

Module sinh dữ liệu có nhiệm vụ xây dựng bộ dữ liệu đầu vào phù hợp với quy mô và các yêu cầu của bài toán.

Các thông tin được sinh ngẫu nhiên bao gồm:

- Kích thước đăng ký của 480 lớp học phần.

- Kích thước của 35 phòng học.

- Danh sách môn học có thể đảm nhận và môn học yêu thích của giảng viên.

- Trạng thái khả dụng của phòng học theo ngày và ca học.

Trong cấu hình thực nghiệm, nhóm sử dụng giá trị `seed = 42` để hỗ trợ khả năng tái lập dữ liệu.

Tổng số vị trí phòng–ca lý thuyết trong một tuần là:

$ 35 times 5 times 6 = 1050 $

Hệ thống mô phỏng 26 vị trí không khả dụng, tương ứng với khoảng 2,48% tổng số vị trí phòng–ca.

Số vị trí khả dụng còn lại là:

$ 1050 - 26 = 1024 $

Nếu các thông tin về kích thước phòng và quy mô lớp được sinh ngẫu nhiên hoàn toàn mà không kiểm tra khả năng đáp ứng, bộ dữ liệu có thể chứa những trường hợp không khả thi ngay từ đầu.

Ví dụ, nếu tổng số buổi học của các lớp kích thước lớn vượt quá số vị trí khả dụng của phòng kích thước lớn thì không tồn tại phương án phân bổ thỏa mãn ràng buộc kích thước phòng, bất kể thuật toán tối ưu được sử dụng.

Để hạn chế vấn đề này, module sinh dữ liệu thực hiện kiểm tra các điều kiện tích lũy về khả năng đáp ứng kích thước phòng.

Gọi $"req"_i$ là tổng số buổi học có kích thước đăng ký bằng $i$:

$ "req"_i =
2 sum_(s in cal(S))
II["size"_"sec"(s) = i] $

Gọi $"avail"_i$ là tổng số vị trí phòng–ca khả dụng của các phòng có kích thước bằng $i$:

$ "avail"_i =
sum_(r in cal(R): "size"_"rm"(r) = i)
sum_(d in cal(D))
sum_(t in cal(T))
A_(d,t,r) $

Các điều kiện cần về khả năng đáp ứng kích thước phòng bao gồm:

$ "req"_2 <= "avail"_2 $

$ "req"_2 + "req"_1
<= "avail"_2 + "avail"_1 $

$ sum_(i=0)^2 "req"_i
<= sum_(i=0)^2 "avail"_i $

Trong quá trình sinh dữ liệu, nhóm bổ sung các khoảng dự phòng tài nguyên:

$ "req"_2 <= "avail"_2 - 20 $

$ "req"_2 + "req"_1
<= "avail"_2 + "avail"_1 - 30 $

Đồng thời, công suất phòng học khả dụng trong mỗi ngày được yêu cầu không nhỏ hơn 202 vị trí.

Các khoảng dự phòng được sử dụng nhằm hạn chế những trường hợp tài nguyên theo kích thước hoặc theo ngày bị phân bố quá sát giới hạn.

Ngoài ra, danh sách môn học của giảng viên được kiểm tra nhằm hạn chế tình trạng một môn học có quá ít giảng viên có thể đảm nhận.

Tuy nhiên, các điều kiện kiểm tra trên chỉ giúp loại bỏ một số trường hợp không khả thi về mặt tài nguyên. Chúng không phải là điều kiện đủ để chứng minh sự tồn tại của một thời khóa biểu thỏa mãn đồng thời toàn bộ ràng buộc.

Nguyên nhân là tính khả thi còn phụ thuộc vào sự tương tác giữa lịch giảng viên, cặp ngày học, kích thước phòng và trạng thái khả dụng tại từng thời điểm.

Do đó, tính khả thi của bộ dữ liệu cần được xác nhận thông qua việc tìm được một thời khóa biểu cụ thể thỏa mãn $H(x) = 0$.

Cách tiếp cận này giúp phân biệt các vấn đề xuất phát từ dữ liệu đầu vào với các hạn chế trong quá trình tìm kiếm nghiệm của thuật toán.


=== Domain Models Module (`src/models/`)

Các đối tượng nghiệp vụ được xây dựng bằng cơ chế `@dataclass` của Python.

Việc sử dụng `dataclass` giúp khai báo các thuộc tính của đối tượng một cách rõ ràng, giảm lượng mã nguồn cần thiết cho các phương thức khởi tạo và hỗ trợ việc tổ chức dữ liệu có cấu trúc.

Các chú thích kiểu dữ liệu (_Type Hints_) được sử dụng để mô tả kiểu giá trị của từng thuộc tính, giúp tăng khả năng đọc hiểu mã nguồn và hỗ trợ các công cụ kiểm tra kiểu tĩnh.

Tuy nhiên, `dataclass` và Type Hints không tự động đảm bảo mọi giá trị được gán đều hợp lệ tại thời điểm thực thi. Các điều kiện về miền giá trị và ràng buộc nghiệp vụ vẫn cần được kiểm tra thông qua logic của hệ thống.

Đối với cấu trúc nhiễm sắc thể, một yêu cầu quan trọng là đảm bảo tính độc lập giữa các cá thể.

Trong quá trình lai ghép và đột biến, các đối tượng `Gene` hoặc `Session` có thể bị thay đổi. Nếu hai nhiễm sắc thể cùng tham chiếu đến một đối tượng có thể thay đổi, thao tác trên cá thể con có thể làm thay đổi ngoài ý muốn cá thể cha mẹ.

Điều này đặc biệt ảnh hưởng đến cơ chế Elitism vì những cá thể tốt nhất có thể bị thay đổi sau khi được lưu giữ.

Do đó, phương thức sao chép nhiễm sắc thể `copy()` cần đảm bảo rằng các đối tượng biểu diễn trạng thái phân bổ có thể thay đổi được sao chép độc lập.

Các dữ liệu bài toán không bị thay đổi trong quá trình tiến hóa có thể được sử dụng chung nhằm hạn chế chi phí bộ nhớ.

Cách tổ chức này hướng đến sự cân bằng giữa tính độc lập của các nghiệm ứng viên và hiệu quả sử dụng tài nguyên trong quá trình tiến hóa.


=== Constraint Checking Module (`src/constraints/`)

Module kiểm tra ràng buộc hiện thực các công thức toán học được xây dựng tại Chương 3.

Các hàm đánh giá được phân chia thành ba nhóm:

#table(
  columns: (1.6fr, 2.6fr),
  align: left,
  table.header(
    [*Module*],
    [*Trách nhiệm*],
  ),
  [`hard_constraints.py`],
  [Đánh giá bảy thành phần ràng buộc cứng từ $H_1$ đến $H_7$.],

  [`soft_constraints.py`],
  [Đánh giá năm thành phần ràng buộc mềm từ $S_1$ đến $S_5$.],

  [`bonus_constraints.py`],
  [Đánh giá các tiêu chí mở rộng $B_(1a)$, $B_(1b)$ và $B_2$.],
)

Module cung cấp các hàm kiểm tra riêng lẻ, chẳng hạn như:

- `check_room_capacity()`.
- `check_session_spacing()`.
- `professor_idle_gap()`.

Những hàm này hỗ trợ kiểm thử độc lập từng quy tắc, giúp phát hiện và xác định nguyên nhân khi kết quả đánh giá không phù hợp với mô hình toán học.

Bên cạnh các hàm kiểm tra riêng lẻ, hệ thống sử dụng các hàm đánh giá tổng hợp như `evaluate_hard_constraints()` và `evaluate_soft_constraints()`.

Thay vì duyệt toàn bộ nhiễm sắc thể nhiều lần để kiểm tra từng ràng buộc, phương pháp đánh giá tổng hợp xây dựng các cấu trúc thống kê dùng chung trong quá trình duyệt dữ liệu.

Những cấu trúc này bao gồm thông tin về:

- Số buổi học của mỗi giảng viên.

- Trạng thái sử dụng ca học của giảng viên.

- Số buổi học được phân bổ vào từng vị trí phòng–ca.

- Phân bố buổi sáng và buổi chiều của từng môn học.

Một kỹ thuật được sử dụng trong quá trình đánh giá lịch giảng viên là biểu diễn trạng thái các ca dạy bằng bitmask.

Do mỗi ngày có sáu ca học, trạng thái giảng dạy của một giảng viên trong một ngày có thể được biểu diễn bằng một số nguyên gồm sáu bit.

Gọi $b_(p,d)$ là bitmask biểu diễn lịch giảng dạy của giảng viên $p$ tại ngày $d$:

$ b_(p,d) =
sum_(t in cal(T))
2^t II[N_p(d,t) > 0] $

Bit thứ $t$ nhận giá trị 1 nếu giảng viên có ít nhất một buổi dạy tại ca tương ứng.

Ví dụ, nếu một giảng viên dạy ở ca 1 và ca 6, bitmask biểu diễn lịch trong ngày là:

`100001`

Trong đó, hai bit được thiết lập tương ứng với hai ca có lịch dạy.

Số ca trống nằm giữa hai ca dạy là:

$ 6 - 2 = 4 $

Để xác định giảng viên có dạy cả buổi sáng và buổi chiều hay không, hệ thống có thể sử dụng hai mặt nạ bit:

- Mặt nạ buổi sáng: `0b000111`.

- Mặt nạ buổi chiều: `0b111000`.

Ràng buộc $S_3$ bị vi phạm tại một ngày nếu kết quả phép AND bit giữa bitmask lịch giảng viên với cả hai mặt nạ đều khác 0.

Do số lượng ca học mỗi ngày cố định bằng sáu, các phép kiểm tra trên bitmask có thể được thực hiện với chi phí hằng số $O(1)$ cho mỗi cặp giảng viên–ngày.

Tuy nhiên, bitmask chỉ biểu diễn trạng thái có hoặc không có lịch tại một ca. Nó không thể phân biệt một giảng viên có một hay nhiều buổi học trùng nhau tại cùng thời điểm.

Vì vậy, đối với các ràng buộc phát hiện xung đột như $H_3$ và $H_7$, hệ thống vẫn cần sử dụng các bộ đếm hoặc cấu trúc dữ liệu tương đương để ghi nhận số lượng buổi học thực tế.

Việc kết hợp bộ đếm và bitmask giúp hỗ trợ cả kiểm tra tính khả thi và đánh giá chất lượng lịch giảng dạy mà không làm mất thông tin cần thiết.


=== Fitness Evaluation Module (`fitness.py`)

Module đánh giá Fitness có nhiệm vụ kết hợp kết quả của các module kiểm tra ràng buộc thành các đại lượng đánh giá chất lượng nhiễm sắc thể.

Quy trình đánh giá gồm các bước:

+ Tính tổng số vi phạm ràng buộc cứng $H(x)$.

+ Tính tổng điểm phạt mềm $P_"soft"(x)$.

+ Tính tổng điểm phạt Bonus $P_"bonus"(x)$.

+ Tính tổng mức phạt $P(x)$.

+ Chuyển đổi tổng mức phạt thành Fitness.

Hàm thích nghi được xác định theo công thức đã trình bày tại Chương 4:

$ F(x) = frac(1, 1 + P(x)) $

Trong đó:

$ P(x) =
W_H H(x)
+ P_"soft"(x)
+ P_"bonus"(x) $

Sau khi đánh giá, các kết quả được cập nhật vào những thuộc tính tương ứng của đối tượng `Chromosome`.

Việc lưu trữ kết quả đánh giá cho phép các toán tử chọn lọc và cơ chế Elitism sử dụng trực tiếp thông tin đã được tính toán, thay vì thực hiện lại toàn bộ quá trình kiểm tra ràng buộc trong mỗi lần so sánh cá thể.

Khi nhiễm sắc thể bị thay đổi, các thuộc tính đánh giá cũ có thể không còn phản ánh trạng thái hiện tại. Do đó, nghiệm cần được đánh giá lại trước khi sử dụng trong quá trình xếp hạng.

Module Fitness đồng thời đóng vai trò thống nhất tiêu chí đánh giá giữa ba phiên bản thuật toán. Điều này giúp các kết quả thực nghiệm được so sánh dựa trên cùng một mô hình ràng buộc và hệ thống trọng số.


=== Genetic Algorithm Engine (`engine.py`)

Module `engine.py` chịu trách nhiệm điều phối toàn bộ quá trình tiến hóa của giải thuật di truyền.

Thay vì hiện thực ba chương trình độc lập cho Baseline GA, Improved GA và Proposed GA, hệ thống sử dụng chung một bộ máy tiến hóa với các chế độ cấu hình khác nhau.

Ba chế độ thực thi gồm:

- `baseline`.
- `improved`.
- `proposed`.

Các chế độ sử dụng những chiến lược khởi tạo, lai ghép và sửa chữa nghiệm tương ứng với thiết kế tại Chương 4.

Việc tổ chức nhiều phiên bản thuật toán trên cùng một bộ máy tiến hóa giúp hạn chế lặp lại mã nguồn và giảm nguy cơ xuất hiện sự khác biệt không cần thiết trong các thành phần được sử dụng chung.

Các nhiệm vụ chính của GA Engine bao gồm:

+ Khởi tạo quần thể.

+ Đánh giá các nhiễm sắc thể.

+ Quản lý quá trình chọn lọc, lai ghép và đột biến.

+ Điều phối cơ chế sửa chữa nghiệm tùy theo phiên bản.

+ Bảo toàn các cá thể ưu tú.

+ Cập nhật tỷ lệ đột biến thích nghi theo trạng thái hội tụ.

+ Ghi nhận lịch sử tiến hóa.

+ Thực hiện tinh chỉnh cuối và trả về nghiệm tốt nhất.

Trong quá trình tiến hóa, các toán tử di truyền được gọi thông qua những module tương ứng:

#table(
  columns: (1.5fr, 2.7fr),
  align: left,
  table.header(
    [*Module*],
    [*Chức năng*],
  ),
  [`population.py`],
  [Quản lý danh sách cá thể và xếp hạng quần thể.],

  [`initialization.py`],
  [Khởi tạo quần thể ngẫu nhiên hoặc có định hướng.],

  [`selection.py`],
  [Thực hiện Tournament Selection.],

  [`crossover.py`],
  [Thực hiện Uniform Crossover hoặc Course-Block Crossover.],

  [`mutation.py`],
  [Thực hiện các toán tử đột biến và hoán đổi.],

  [`repair.py`],
  [Sửa chữa nghiệm và tìm kiếm cục bộ.],

  [`fitness.py`],
  [Đánh giá chất lượng nghiệm và cập nhật các thuộc tính liên quan.],
)

Theo cách tổ chức này, `engine.py` tập trung vào việc quản lý luồng thực thi, trong khi logic chi tiết của từng toán tử được hiện thực tại các module riêng biệt.

Việc phân chia trên tạo điều kiện để thay đổi hoặc bổ sung một toán tử mà không cần viết lại toàn bộ thuật toán tiến hóa.

Ngoài ra, việc ghi nhận lịch sử qua từng thế hệ giúp theo dõi trạng thái tìm kiếm và cung cấp dữ liệu đầu vào cho module phân tích thực nghiệm.


=== Repair Module (`repair.py`)

Module Repair hiện thực cơ chế sửa chữa và tìm kiếm cục bộ gồm bốn pha đã được thiết kế tại Chương 4.

Trong quá trình xử lý một nhiễm sắc thể, module cần truy xuất thường xuyên các thông tin về lịch giảng viên, trạng thái sử dụng phòng học, kích thước phòng và những vị trí còn khả dụng.

Để hỗ trợ việc kiểm tra các phương án thay thế, trạng thái sử dụng tài nguyên cần được tổ chức dưới dạng những cấu trúc có thể truy xuất và cập nhật hiệu quả.

Các thông tin cần quản lý bao gồm:

- Lịch dạy hiện tại của từng giảng viên.

- Số lớp học phần được phân công cho mỗi giảng viên.

- Các vị trí phòng–ca đã được sử dụng.

- Các vị trí phòng–ca còn khả dụng.

- Thông tin kích thước phòng và lớp học.

- Mối liên hệ giữa hai buổi học của mỗi lớp học phần.

Khi thực hiện một phép di chuyển hoặc hoán đổi, module cần xem xét đồng thời trạng thái trước và sau của các tài nguyên liên quan.

Quá trình này bao gồm việc kiểm tra tính hợp lệ của vị trí mới, đánh giá sự thay đổi chi phí và cập nhật thông tin phân bổ khi phép biến đổi được chấp nhận.

Đối với Same-Day Pairwise Swap, hai buổi học được hoán đổi đồng thời nhằm tránh việc đánh giá sai xung đột do một buổi vẫn còn chiếm vị trí đang được trao đổi.

Bốn pha của module Repair được tổ chức tương ứng với các nhóm nhiệm vụ sau:

#table(
  columns: (0.6fr, 2fr, 1.7fr),
  align: (center, left, left),
  table.header(
    [*Pha*],
    [*Nhiệm vụ*],
    [*Tiêu chí liên quan*],
  ),
  [1],
  [Điều chỉnh phân công giảng viên.],
  [$H_4$, $B_(1a)$, $B_2$],

  [2],
  [Xử lý xung đột thời gian và phòng học.],
  [$H_1$, $H_3$, $H_5$, $H_7$],

  [3],
  [Cải thiện nghiệm bằng di chuyển đơn lẻ.],
  [Các thành phần chi phí mềm liên quan.],

  [4],
  [Cải thiện nghiệm bằng hoán đổi cặp cùng ngày.],
  [Chi phí cục bộ và tính khả thi.],
)

Việc sử dụng các thông tin trạng thái cục bộ có thể giảm chi phí đánh giá trong quá trình khảo sát nhiều vị trí thay thế.

Chẳng hạn, khi thay đổi ca học của một buổi trong cùng ngày, hệ thống chỉ cần xem xét những thay đổi liên quan đến giảng viên, môn học và vị trí phòng học bị ảnh hưởng.

Tuy nhiên, việc đánh giá cục bộ không thay thế hoàn toàn quá trình đánh giá tổng thể. Sau khi cơ chế sửa chữa hoàn tất, nhiễm sắc thể cần được đánh giá lại bằng Fitness Evaluation Module để xác định chính xác số vi phạm và chất lượng nghiệm.

Việc tách Repair thành một module độc lập cho phép hệ thống bật hoặc tắt cơ chế này tùy theo phiên bản thuật toán, đồng thời hỗ trợ việc đánh giá ảnh hưởng của nhóm kỹ thuật cải tiến trong các thí nghiệm đối chứng.


=== Visualization and Export Module (`src/utils/`)

Module trực quan hóa và xuất dữ liệu chịu trách nhiệm chuyển đổi kết quả của thuật toán thành những thông tin có thể kiểm tra, phân tích và sử dụng.

Các thành phần chính gồm:

- `statistics.py`: Tổng hợp các chỉ tiêu đánh giá, thông tin phân bổ và thống kê thực nghiệm.

- `exporter.py`: Chuyển đổi và lưu kết quả dưới các định dạng CSV, JSON, HTML và TXT.

- `visualization.py`: Xây dựng các biểu đồ phục vụ phân tích hiệu quả thuật toán.

Các biểu đồ được xuất dưới định dạng PNG với độ phân giải 300 DPI nhằm đảm bảo chất lượng khi đưa vào báo cáo.

#table(
  columns: (1.8fr, 2.5fr),
  align: left,
  table.header(
    [*Tệp biểu đồ*],
    [*Nội dung thể hiện*],
  ),
  [`fitness_plot.png`],
  [Quá trình hội tụ Fitness của các phiên bản thuật toán.],

  [`penalty_breakdown.png`],
  [Sự thay đổi của các thành phần điểm phạt.],

  [`constraint_satisfaction.png`],
  [So sánh mức độ vi phạm ràng buộc.],

  [`room_utilization_heatmap.png`],
  [Tỷ lệ sử dụng phòng theo từng ngày và ca học.],

  [`sample_timetables.png`],
  [Minh họa thời khóa biểu của các đối tượng được lựa chọn.],

  [`parameter_sensitivity.png`],
  [Ảnh hưởng của các siêu tham số đến chất lượng nghiệm và thời gian thực thi.],
)

Việc trực quan hóa nhiều chỉ tiêu thay vì chỉ sử dụng Fitness giúp phản ánh đầy đủ hơn chất lượng nghiệm.

Đặc biệt, do hàm thích nghi sử dụng nghịch đảo của tổng điểm phạt, sự khác biệt giữa các nghiệm có điểm phạt lớn có thể khó quan sát trên biểu đồ tuyến tính.

Vì vậy, các biểu đồ về số vi phạm cứng, tổng điểm phạt và từng thành phần ràng buộc được sử dụng bổ sung để hỗ trợ phân tích kết quả.

Các biểu đồ và dữ liệu thực nghiệm được trình bày chi tiết tại Chương 6.


== Luồng hoạt động của hệ thống

Luồng hoạt động tổng thể của hệ thống được tổ chức từ giai đoạn chuẩn bị dữ liệu đến giai đoạn xuất kết quả.

Khi người dùng thực thi chương trình thông qua `main.py`, hệ thống thực hiện các giai đoạn sau.

*Giai đoạn 1: Chuẩn bị cấu hình và dữ liệu.*

Hệ thống tiếp nhận các tham số cấu hình từ tệp `config.py` hoặc từ giao diện dòng lệnh.

Data Generation Module thực hiện sinh dữ liệu theo giá trị khởi tạo ngẫu nhiên đã được thiết lập, kiểm tra các điều kiện cần về khả năng đáp ứng tài nguyên và lưu dữ liệu vào thư mục `data/`.

Data Loader chuyển đổi dữ liệu đầu vào thành các đối tượng Domain và những cấu trúc dữ liệu cần thiết cho quá trình đánh giá nghiệm.

*Giai đoạn 2: Thực thi thuật toán.*

`SchedulerService` tiếp nhận dữ liệu đã chuẩn bị và điều phối quá trình thực thi các phiên bản thuật toán.

Trong chế độ thực nghiệm đối chứng, ba phiên bản được thực thi lần lượt:

+ Baseline GA.

+ Improved GA.

+ Proposed GA.

Mỗi phiên bản sử dụng cùng bộ dữ liệu bài toán và cùng hệ thống đánh giá ràng buộc.

GA Engine thực hiện quá trình khởi tạo, tiến hóa, sửa chữa nghiệm tùy theo cấu hình và ghi nhận lịch sử thực nghiệm.

*Giai đoạn 3: Đánh giá và lựa chọn nghiệm.*

Sau khi hoàn thành quá trình tiến hóa, các nghiệm tốt nhất của từng phiên bản được thu thập và đánh giá.

Việc lựa chọn nghiệm được thực hiện theo khóa xếp hạng:

$ R(x) = (H(x), P(x)) $

Trong đó, nghiệm có ít vi phạm cứng hơn được ưu tiên. Nếu số vi phạm cứng bằng nhau, nghiệm có tổng mức phạt thấp hơn được lựa chọn.

Nếu nghiệm tốt nhất vẫn tồn tại vi phạm ràng buộc cứng, hệ thống cần thể hiện rõ trạng thái không khả thi trong kết quả đánh giá, thay vì xem đó là thời khóa biểu hợp lệ.

*Giai đoạn 4: Xuất kết quả.*

Các kết quả được tổng hợp và chuyển đến Output Module.

Module này thực hiện:

- Xuất thời khóa biểu chi tiết.

- Tổng hợp kết quả của các phiên bản thuật toán.

- Xuất báo cáo vi phạm ràng buộc.

- Sinh biểu đồ hội tụ và biểu đồ phân tích.

- Tạo thời khóa biểu tương tác dưới dạng HTML.

Toàn bộ dữ liệu đầu ra được lưu vào thư mục `outputs/`.

@fig_sys_activity minh họa luồng thực thi tổng thể của hệ thống trong chế độ thực nghiệm đối chứng, đồng thời @tab_activity_vs_flowchart phân biệt rõ phạm vi giữa sơ đồ hoạt động hệ thống ở Chương 5 và lưu đồ thuật toán ở Chương 4.

#figure(
  image("../picture/System Activity Diagram – Mục 5.6.svg", width: 92%),
  caption: [Luồng thực thi tổng thể của hệ thống trong chế độ thực nghiệm đối chứng.]
) <fig_sys_activity>

#figure(
  table(
    columns: (1.1fr, 1.8fr, 2.1fr),
    align: left,
    table.header(
      [*Nội dung*],
      [*Lưu đồ Chương 4*],
      [*Activity Diagram Chương 5*],
    ),
    [Phạm vi], [Thuật toán GA], [Toàn bộ hệ thống phần mềm],
    [Điểm bắt đầu], [Khởi tạo quần thể], [Tiếp nhận cấu hình và tham số],
    [Xử lý chính], [Tiến hóa, Repair, Mutation], [Sinh/nạp dữ liệu, điều phối GA, đánh giá],
    [Kết quả], [Nhiễm sắc thể tốt nhất], [Thời khóa biểu, thống kê, báo cáo, biểu đồ],
    [Mục đích], [Giải thích chi tiết thuật toán], [Giải thích luồng thực thi phần mềm],
  ),
  caption: [Phân biệt vai trò giữa lưu đồ thuật toán (Chương 4) và sơ đồ hoạt động hệ thống (Chương 5).]
) <tab_activity_vs_flowchart>

Việc tách các giai đoạn chuẩn bị dữ liệu, thực thi thuật toán, đánh giá và xuất kết quả giúp quá trình thực nghiệm có cấu trúc rõ ràng, đồng thời thuận tiện cho việc kiểm tra và tái lập kết quả.


== Thiết kế giao diện người dùng (Streamlit)

Mặc dù yêu cầu chính của Homework 3 tập trung vào việc thiết kế thuật toán và đánh giá chất lượng thời khóa biểu, nhóm bổ sung giao diện web nhằm hỗ trợ quá trình tương tác và sử dụng kết quả.

Giao diện được xây dựng bằng Streamlit thông qua tệp `app.py`.

Streamlit được lựa chọn vì có khả năng tích hợp trực tiếp với mã nguồn Python và các thư viện xử lý dữ liệu, giúp xây dựng giao diện mà không cần phát triển riêng một hệ thống Frontend và Backend.

Giao diện được tổ chức thành ba nhóm chức năng chính.

*Dashboard và cấu hình thuật toán.*

Nhóm chức năng này hiển thị các thông tin tổng quan của bài toán, bao gồm số môn học, số lớp học phần, số giảng viên, số phòng học và các tham số thuật toán.

Người dùng có thể thay đổi những tham số được hỗ trợ, chẳng hạn như:

- Kích thước quần thể (Population Size).

- Số thế hệ tối đa (Maximum Generations).

- Phiên bản giải thuật di truyền.

Sau khi cấu hình, người dùng có thể thực hiện quá trình xếp thời khóa biểu thông qua giao diện.

*Tra cứu thời khóa biểu.*

Chức năng này cho phép người dùng xem và lọc kết quả thời khóa biểu theo các nhóm đối tượng:

- Giảng viên.

- Phòng học.

- Môn học.

Do kết quả đầy đủ chứa 960 buổi học, việc sử dụng các bộ lọc giúp người dùng tập trung vào những thông tin cần thiết thay vì phải xem toàn bộ dữ liệu cùng lúc.

*Phân tích kết quả.*

Nhóm chức năng phân tích kết quả hiển thị các chỉ tiêu đánh giá chính, bao gồm số vi phạm cứng, tổng điểm phạt mềm, Fitness và kết quả đánh giá Bonus.

Bên cạnh đó, giao diện hỗ trợ hiển thị các biểu đồ hội tụ và thông tin chi tiết về mức độ vi phạm ràng buộc.

Việc hiển thị đồng thời nhiều chỉ tiêu giúp người dùng phân biệt giữa tính khả thi và chất lượng của thời khóa biểu.

Giao diện Streamlit đóng vai trò hỗ trợ tương tác và trình bày kết quả, không trực tiếp hiện thực các toán tử di truyền hoặc công thức kiểm tra ràng buộc.

Do đó, hệ thống vẫn có thể thực thi đầy đủ các chức năng tối ưu hóa thông qua giao diện dòng lệnh mà không phụ thuộc vào giao diện web.

