= KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN (CONCLUSION AND FUTURE WORK)

== Tổng kết kết quả đạt được
Đề tài đã xây dựng hoàn chỉnh hệ thống tự động xếp thời khóa biểu bằng Giải thuật Di truyền cho quy mô 60 môn học, 480 lớp, 960 buổi học, 60 giảng viên và 35 phòng học:
- Mô hình hóa toán học đầy đủ 7 ràng buộc cứng (`H1–H7`), 5 ràng buộc mềm (`S1–S5`), 2 ràng buộc Bonus (`B1–B2`) và chứng minh nút thắt phân bố cặp ngày ở mật độ sử dụng phòng 93,75%.
- Thiết kế và cài đặt thành công thuật toán *Proposed GA (Greedy Randomized Initialization + Repair 4 pha + Pairwise Swap + Elitism)* đạt *0 vi phạm ràng buộc cứng*, *100% thỏa mãn Bonus 1 & 2* và giảm *34,8%* tổng điểm phạt ràng buộc mềm.
- Hoàn thiện mã nguồn chuẩn *Layered Modular Architecture* kèm bộ kiểm thử tự động `pytest` (8/8 PASSED), giao diện web Streamlit (`app.py`) và bộ dữ liệu xuất hoàn chỉnh (`CSV`, `JSON`, `HTML`, `PNG`).

== Ưu điểm của phương pháp đề xuất
- *Tính khả thi đảm bảo:* Cân bằng tải cặp ngày ngay từ bước khởi tạo giúp triệt tiêu hiện tượng quá tải Thứ 2 & Thứ 6, và cơ chế Repair đảm bảo $H = 0$ ngay cả khi phòng học bị khóa bảo trì.
- *Khả năng thoát bế tắc cục bộ:* Toán tử hoán đổi cặp cùng ngày giải quyết triệt để bài toán không còn ô phòng trống để di chuyển đơn lẻ ở mức tải 93,75%.
- *Kiến trúc mở rộng linh hoạt:* Tách biệt rạch ròi ràng buộc, hàm Fitness và toán tử GA giúp dễ dàng thêm quy định mới mà không phải viết lại bộ máy tiến hóa.

== Hạn chế của hệ thống
- Thời gian thực thi của *Proposed GA* (`136,9` giây cho 200 thế hệ) lâu hơn khoảng `2,4` lần so với *Baseline GA* (`56,0` giây) do chi phí tính toán của bộ sửa chữa 4 pha.
- Một số tiêu chí mềm có tính đánh đổi tự nhiên (ví dụ giảm `S1` ca trống đôi khi làm `S4` tăng nhẹ từ `113` lên `167` khi hoán đổi cặp), hiện mới được gộp qua trọng số tuyến tính cố định.

== Hướng phát triển trong tương lai
1. Áp dụng giải thuật tối ưu đa mục tiêu *NSGA-II* (Pareto Front) để giảng vụ có thể lựa chọn phương án cân bằng trực tiếp giữa độ gọn lịch giảng viên (`S1–S3`) và độ đồng nhất buổi môn học (`S4`).
2. Bổ sung ràng buộc khung giờ bận cá nhân của từng giảng viên và khoảng cách di chuyển giữa các tòa nhà phòng học.
3. Song song hóa quá trình đánh giá và sửa chữa cá thể trên nhiều nhân CPU (`multiprocessing`) để rút ngắn thời gian chạy xuống dưới 20 giây.
