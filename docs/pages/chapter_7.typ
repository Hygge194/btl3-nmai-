= KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN (CONCLUSION AND FUTURE WORK)

== Tổng kết kết quả đạt được

Đề tài đã hoàn thành trọn vẹn cả bốn mục tiêu đặt ra tại Chương 1, xây dựng thành công hệ thống tự động xếp thời khóa biểu đại học bằng Giải thuật Di truyền cho bài toán quy mô lớn gồm 60 môn học, 480 lớp học phần, 960 buổi học, 60 giảng viên và 35 phòng học:

+ *Về mô hình hóa toán học và phân tích lý thuyết:* Đã chuẩn hóa đầy đủ 7 ràng buộc cứng (`H1–H7`), 5 ràng buộc mềm (`S1–S5`), 3 thành phần mở rộng (`B1a`, `B1b`, `B2`) theo quan hệ phân cấp chuyên môn $E_p supset.eq F_p$, cùng hàm thích nghi chuẩn hóa $F(x) = 1/(1+P(x))$ và cơ chế xếp hạng ưu tiên khả thi theo thứ tự từ điển $R(x) = (H(x), P(x))$. Đặc biệt, nhóm đã phát hiện và giải quyết về mặt toán học *nút thắt phân bố cặp ngày* (quá tải kỳ vọng 240 buổi/ngày ở Thứ Hai và Thứ Sáu) bằng vector xác suất cân bằng $q$, đồng thời chứng minh cận dưới chặt $S_3 >= 20$, $S_5 >= 29$ và cận trên $F(x) <= 1/130 < 1$ trên dữ liệu thực nghiệm.
+ *Về thiết kế thuật toán:* Đã đề xuất thành công *Proposed GA* theo kiến trúc giải thuật *Memetic*, kết hợp biểu diễn theo lớp học phần (480 gen), khởi tạo tham lam cân bằng tải ngày, lai ghép bất đối xứng theo khối môn học, đột biến thông minh thích nghi và cơ chế sửa chữa nghiệm bốn pha tích hợp tìm kiếm cục bộ hoán đổi cặp cùng ngày (*Same-Day Pairwise Swap*).
+ *Về hiện thực phần mềm:* Đã hoàn thiện ứng dụng Python 3.12 theo kiến trúc module phân lớp rõ ràng, áp dụng tối ưu bitmask 6-bit và mảng chỉ số NumPy, đạt *8/8 PASSED (100%)* trong `1,37` giây với bộ kiểm thử tự động `pytest`, cung cấp đầy đủ công cụ xuất dữ liệu (`CSV`, `JSON`, `HTML`), 6 biểu đồ 300 DPI và giao diện web tra cứu tương tác bằng Streamlit (`app.py`).
+ *Về thực nghiệm đối chứng:* Trên bộ dữ liệu mật độ phòng `93,75%` (chỉ dư 64 vị trí trống), *Proposed GA* là phiên bản duy nhất đạt *0 vi phạm ràng buộc cứng* ($H_1$–$H_7 = 0$), *60/60 (100%)* giảng viên có môn Top-3 yêu thích ($B_(1a) = 0$), *0 lớp* ngoài danh sách năng lực ($B_2 = 0$, đạt `92,3%` lớp thuộc Top-3), giảm *34,8%* tổng điểm phạt mềm qua 200 thế hệ (`2322` $arrow.r$ `1515`), và cắt giảm *76,6%* số ca trống trong ngày của giảng viên (`218` $arrow.r$ `51`) so với *Improved GA*.

== Đánh giá ưu điểm và hạn chế của hệ thống

*Ưu điểm nổi bật:*
- *Khả năng vượt nút thắt tài nguyên cao:* Sự kết hợp giữa khởi tạo cân bằng tải theo vector $q$ và phép hoán đổi cặp cùng ngày *Same-Day Pairwise Swap* cho phép thuật toán đạt nghiệm khả thi ngay từ thế hệ 0 và tiếp tục tối ưu sâu ngay cả khi nhiều ca học đã kín `100%` công suất phòng.
- *Cơ chế xếp hạng nhất quán và minh bạch:* Xếp hạng từ điển `rank_key() = (H(x), P(x))` loại bỏ hoàn toàn rủi ro nghiệm không khả thi lấn át nghiệm khả thi, trong khi báo cáo tách bạch đầy đủ 15 chỉ tiêu ràng buộc (bao gồm cả $B_2$ và $B_(1b)$).
- *Kiến trúc phần mềm sạch và dễ mở rộng:* Sự tách biệt giữa dữ liệu, ràng buộc, thuật toán và giao diện giúp dễ kiểm thử độc lập, tái lập chính xác thực nghiệm nhờ tách riêng `seed` dữ liệu và `ga-seed` tiến hóa.

*Hạn chế tồn tại:*
- *Chi phí tính toán cao hơn các bản GA nền:* Do tích hợp sửa chữa bốn pha với xác suất `0,40` và tinh chỉnh định kỳ, thời gian chạy 200 thế hệ của *Proposed GA* (`136,9` giây đơn luồng) cao hơn `24,9%` so với *Improved GA* (`109,6s`) và gấp `2,44` lần *Baseline GA* (`56,0s`).
- *Đánh đổi tuyến tính cố định giữa các tiêu chí mềm:* Việc gộp các tiêu chí mềm bằng trọng số cố định dẫn đến sự đánh đổi tự nhiên giữa độ gọn lịch giảng viên ($S_1, S_3$) với độ tập trung buổi môn ($S_4$) và độ khớp kích thước phòng ($S_5$).
- *Phạm vi kiểm chứng thống kê và nghiệp vụ thực tế:* Thực nghiệm hiện tại mới thực hiện trên một cặp seed cố định (`seed = 42`, `ga-seed = 2026`), chưa có thống kê đa seed và *Ablation Study* tách riêng từng toán tử; đồng thời mô hình chưa xét đến lịch bận cá nhân của giảng viên hay xung đột đăng ký môn học của sinh viên.

== Hướng phát triển trong tương lai

Để nâng cao giá trị nghiên cứu và khả năng triển khai thực tế, hệ thống có thể mở rộng theo bốn hướng chính:

+ *Tối ưu hóa đa mục tiêu (NSGA-II):* Thay thế hàm phạt trọng số cố định bằng *NSGA-II* để xây dựng tập nghiệm biên *Pareto*, cho phép chọn trực tiếp phương án cân bằng nhất giữa độ gọn lịch giảng viên (`S1–S3`), đồng nhất buổi môn (`S4`) và độ khớp phòng (`S5`).
+ *Thực nghiệm đa seed và Ablation Study:* Mở rộng đánh giá trên 10–30 bộ dữ liệu ngẫu nhiên (báo cáo trung bình, độ lệch chuẩn, tỷ lệ khả thi) và chạy *Ablation Study* tách riêng từng thành phần (*Course-Block Crossover*, *Adaptive Mutation*, *Same-Day Pairwise Swap*) để lượng hóa đóng góp riêng lẻ.
+ *Bổ sung ràng buộc thực tế:* Tích hợp lịch bận cá nhân của giảng viên, phòng thí nghiệm/phòng máy chuyên dụng, khoảng cách di chuyển giữa các tòa nhà và dữ liệu đăng ký học phần của sinh viên.
+ *Tăng tốc tính toán song song:* Ứng dụng đa tiến trình CPU (`multiprocessing`) hoặc `Cython`/`Numba` cho bước đánh giá quần thể và sửa chữa cá thể nhằm rút ngắn thời gian chạy khi mở rộng quy mô lên hàng nghìn lớp.

Nhìn chung, đề tài đã chứng minh hiệu quả của hướng tiếp cận giải thuật di truyền lai (*Memetic GA*) cho bài toán xếp thời khóa biểu mật độ tài nguyên cao, tạo nền tảng vững chắc về cả lý thuyết lẫn kỹ thuật phần mềm cho các nghiên cứu tiếp theo.
