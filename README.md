## PORTS HIỆN TẠI
| Service | Port | URL |
|---------|------|-----|
| API Backend | 3002 | http://localhost:3002 |

---
## Cấu Trúc Project
...
/FloodSOS-Complete/  <-- Thư mục gốc chứa toàn bộ dự án (Full-stack)
|
├── .vscode           <-- Cấu hình Editor VS Code (tự động sinh ra)
├── build             <-- Thư mục chứa file sau khi build
├── frontend-flutter  <-- PROJECT FLUTTER (Ứng dụng Mobile/Desktop cho Người dùng & Admin)
|   ├── pubspec.lock  <-- File khóa phiên bản các thư viện (để đồng bộ team)
|   ├── pubspec.yaml  <-- Nơi khai báo thư viện (http, flutter_map, location, provider...)
|   ├── README.md     <-- Hướng dẫn chạy App Flutter
|   ├── build         <-- Nơi chứa file build tạm thời hoặc file APK đầu ra
|   ├── lib           <-- THƯ MỤC CODE CHÍNH (Nơi bạn viết code Flutter)
|   |      ├── config
|   |      |    └── app_config.dart  <-- Cấu hình giao diện (Màu sắc, Theme, Font chữ chung)
|   |      ├── screens               <-- Chứa các màn hình giao diện
|   |      |    ├── admin_dashboard_screen.dart  <-- Màn hình Admin (Xem bản đồ cứu hộ, xóa tin giả)
|   |      |    ├── home_screen.dart             <-- Màn hình Người dân (Gửi SOS, Ghi âm, Định vị GPS)
|   |      ├── services              <-- Chứa logic xử lý dữ liệu
|   |      |    └── api_service.dart <-- Cầu nối: Gọi API Server (Gửi/Xóa tin) và API Thời tiết (OpenWeatherMap)
|   |      └── main.dart             <-- File chạy đầu tiên của App (Hàm main, khởi tạo Provider)
|   ├── windows       <-- Thư mục cấu hình riêng để chạy App trên Windows
|   └── README.md
├── Sos-backend       <-- PROJECT SERVER (Node.js Backend - Xử lý dữ liệu)
|   ├── package.json      <-- Khai báo thư viện Node.js (express, mongoose, multer, cors...)
|   ├── package-lock.json <-- File khóa phiên bản thư viện Node.js
|   └── server.js         <-- FILE SERVER CHÍNH (Chạy cổng 3002, Kết nối MongoDB, API nhận SOS/Xóa tin)
├── package-lock.json <-- (File lock của thư mục gốc - thường không dùng nếu tách biệt folder con)
└── README.md         <-- Hướng dẫn chung cho cả dự án
...

---


---
##  KÍCH HOẠT APP

1. Bật terminal 1
PS D:\FloodSOS-Complete> cd sos-backend
PS D:\FloodSOS-Complete\sos-backend> (npm install - Nếu bạn lần đầu sử dụng) npm start

> sos-emergency-backend@1.0.0 start
> node server.js

🚀 1. Đang khởi động Server...
⏳ 2. Đang kết nối Database...

========================================
🚀 SERVER ĐANG CHẠY TẠI: http://localhost:3002       
📡 API Gửi SOS: POST http://localhost:3002/api/sos/voice
📡 API Lấy list: GET http://localhost:3002/api/sos   
========================================

✅ 3. MongoDB Connected thành công!

Nếu có ai điền form và account admin vào thì sẽ hiện ở dưới terminal


2. Bật terminal 2
PS D:\FloodSOS-Complete> cd frontend-flutter
PS D:\FloodSOS-Complete\frontend-flutter> ├── flutter build windows - Chạy trực tiếp trên windows để test ứng dụng
                                          ├── flutter build apk - Tạo bản apk cho bạn để bạn có thể download về điện thoại của mình để trải nghiệm

---

## Cần tải những gì về thiết bị để chạy được

- Tải flutter theo đường dẫn trên: "https://docs.flutter.dev/install/archive" và làm theo hướng dẫn để ADD TO THE PATH
- Tải Java: Tải phiên bản > 1.17.x xong add to the path
- Tải Cmakelists: 3.28.3 (đúng với project này) - có thể nâng thêm.
- Tải MongoDB để setup quyền admin - account admin riêng - còn user thường sẽ chỉ cần điền form cầu cứu để chạy

