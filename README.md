# 🌊 FloodSOS - Hệ Thống Cứu Hộ Lũ Lụt Thông Minh

> Ứng dụng cứu hộ khẩn cấp kết hợp AI, GPS và dữ liệu thời tiết thực để hỗ trợ người dân trong tình huống lũ lụt.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com)

---

## 📋 Mục Lục

- [Giới Thiệu](#-giới-thiệu)
- [Tính Năng](#-tính-năng)
- [Công Nghệ Sử Dụng](#-công-nghệ-sử-dụng)
- [Cấu Trúc Dự Án](#-cấu-trúc-dự-án)
- [Yêu Cầu Hệ Thống](#-yêu-cầu-hệ-thống)
- [Cài Đặt](#-cài-đặt)
- [Khởi Chạy Ứng Dụng](#-khởi-chạy-ứng-dụng)
- [API Endpoints](#-api-endpoints)
- [Đóng Góp](#-đóng-góp)
- [License](#-license)

---

## 🎯 Giới Thiệu

**FloodSOS** là một hệ thống cứu hộ toàn diện được thiết kế để hỗ trợ người dân trong tình huống lũ lụt khẩn cấp. Ứng dụng kết hợp công nghệ định vị GPS, ghi âm giọng nói, và dữ liệu thời tiết thời gian thực để:

- 🆘 Gửi tín hiệu cứu hộ nhanh chóng
- 📍 Xác định vị trí chính xác của nạn nhân
- 🎙️ Ghi lại thông tin khẩn cấp qua giọng nói
- 🗺️ Hiển thị bản đồ cứu hộ cho admin
- ☁️ Cung cấp thông tin thời tiết thực tế

---

## ✨ Tính Năng

### Dành cho Người Dùng
- ✅ Gửi tín hiệu SOS với định vị GPS tự động
- ✅ Ghi âm tin nhắn khẩn cấp
- ✅ Điền form thông tin cứu hộ nhanh chóng
- ✅ Xem thông tin thời tiết hiện tại
- ✅ Giao diện thân thiện, dễ sử dụng trong tình huống khẩn cấp

### Dành cho Admin
- ✅ Xem danh sách tất cả yêu cầu cứu hộ
- ✅ Hiển thị vị trí nạn nhân trên bản đồ
- ✅ Xóa tin giả hoặc tin đã xử lý
- ✅ Quản lý dữ liệu cứu hộ tập trung

---

## 🛠️ Công Nghệ Sử Dụng

### Frontend (Mobile & Desktop)
- **Flutter** - Framework đa nền tảng (Android, iOS, Windows, macOS, Linux)
- **Dart** - Ngôn ngữ lập trình
- **Provider** - Quản lý state
- **flutter_map** - Hiển thị bản đồ tương tác
- **location** - Truy cập GPS
- **http** - Gọi API

### Backend
- **Node.js** - Runtime JavaScript
- **Express.js** - Web framework
- **MongoDB** - Cơ sở dữ liệu NoSQL
- **Mongoose** - ODM cho MongoDB
- **Multer** - Xử lý file upload
- **CORS** - Bảo mật cross-origin

### API Bên Thứ Ba
- **OpenWeatherMap API** - Dữ liệu thời tiết

---

## 📁 Cấu Trúc Dự Án

```
FloodSOS-Complete/
│
├── 📱 frontend-flutter/          # Ứng dụng Flutter
│   ├── lib/
│   │   ├── config/
│   │   │   └── app_config.dart       # Cấu hình theme, màu sắc
│   │   ├── screens/
│   │   │   ├── admin_dashboard_screen.dart  # Màn hình Admin
│   │   │   └── home_screen.dart             # Màn hình Người dùng
│   │   ├── services/
│   │   │   └── api_service.dart      # Service gọi API
│   │   └── main.dart                 # Entry point
│   ├── pubspec.yaml                  # Dependencies
│   └── README.md
│
├── 🔧 sos-backend/               # Server Node.js
│   ├── server.js                 # Main server file
│   ├── package.json              # Dependencies
│   └── package-lock.json
│
└── 📄 README.md                  # File này
```

---

## 💻 Yêu Cầu Hệ Thống

### Phần Mềm Cần Thiết

| Công Cụ | Phiên Bản | Link Tải |
|---------|-----------|----------|
| **Flutter SDK** | Latest stable | [flutter.dev/install](https://docs.flutter.dev/install/archive) |
| **Java JDK** | ≥ 1.17.x | [oracle.com/java](https://www.oracle.com/java/technologies/downloads/) |
| **CMake** | ≥ 3.28.3 | [cmake.org](https://cmake.org/download/) |
| **Node.js** | ≥ 14.x | [nodejs.org](https://nodejs.org/) |
| **MongoDB** | ≥ 4.x | [mongodb.com](https://www.mongodb.com/try/download/community) |

### Hệ Điều Hành Hỗ Trợ
- ✅ Windows 10/11
- ✅ macOS
- ✅ Linux
- ✅ Android (via APK)
- ✅ iOS (cần macOS để build)

---

## 🚀 Cài Đặt

### 1. Clone Repository

```bash
git clone https://github.com/your-username/FloodSOS-Complete.git
cd FloodSOS-Complete
```

### 2. Cài Đặt Backend

```bash
cd sos-backend
npm install
```

**Cấu hình MongoDB:**
- Đảm bảo MongoDB đang chạy trên máy
- Mặc định kết nối: `mongodb://localhost:27017/floodsos`
- Tạo account admin (nếu cần) trong MongoDB

### 3. Cài Đặt Frontend

```bash
cd ../frontend-flutter
flutter pub get
```

**Cấu hình Flutter:**
- Đảm bảo Flutter đã được thêm vào PATH
- Chạy `flutter doctor` để kiểm tra thiếu dependencies gì

---

## 🎮 Khởi Chạy Ứng Dụng

### Bước 1: Khởi động Backend Server

Mở **Terminal 1**:

```bash
cd sos-backend
npm start
```

**Kết quả mong đợi:**

```
🚀 1. Đang khởi động Server...
⏳ 2. Đang kết nối Database...

========================================
🚀 SERVER ĐANG CHẠY TẠI: http://localhost:3002       
📡 API Gửi SOS: POST http://localhost:3002/api/sos/voice
📡 API Lấy list: GET http://localhost:3002/api/sos   
========================================

✅ 3. MongoDB Connected thành công!
```

### Bước 2: Khởi động Flutter App

Mở **Terminal 2**:

#### Chạy trên Windows Desktop:
```bash
cd frontend-flutter
flutter run -d windows
```

#### Hoặc build APK cho Android:
```bash
flutter build apk --release
```
File APK sẽ được tạo tại: `build/app/outputs/flutter-apk/app-release.apk`

#### Hoặc build cho production:
```bash
flutter build windows
```

---

## 📡 API Endpoints

### Base URL
```
http://localhost:3002
```

### Endpoints

| Method | Endpoint | Mô Tả | Body |
|--------|----------|-------|------|
| `POST` | `/api/sos/voice` | Gửi yêu cầu SOS | `{ name, phone, location, audio, weather }` |
| `GET` | `/api/sos` | Lấy danh sách tất cả SOS | - |
| `DELETE` | `/api/sos/:id` | Xóa một yêu cầu SOS | - |

### Ví dụ Request

```javascript
// Gửi SOS
POST http://localhost:3002/api/sos/voice
Content-Type: application/json

{
  "name": "Nguyễn Văn A",
  "phone": "0123456789",
  "location": {
    "latitude": 10.762622,
    "longitude": 106.660172
  },
  "message": "Cần cứu hộ gấp, nước dâng cao",
  "weather": "Rain, 28°C"
}
```

---

## 🌐 Cấu Hình Ports

| Service | Port | URL |
|---------|------|-----|
| Backend API | `3002` | http://localhost:3002 |
| Flutter (Dev) | `Auto` | Auto-assigned by Flutter |

---

## 🔧 Xử Lý Lỗi Thường Gặp

### 1. MongoDB Connection Error
```
❌ Lỗi: MongoDB connection failed
```
**Giải pháp:**
- Kiểm tra MongoDB đã khởi động chưa: `mongod`
- Kiểm tra port 27017 có bị chiếm không

### 2. Flutter Build Error
```
❌ Lỗi: CMake not found
```
**Giải pháp:**
- Cài đặt CMake và thêm vào PATH
- Restart terminal sau khi cài

### 3. API Connection Error
```
❌ Lỗi: Failed to connect to backend
```
**Giải pháp:**
- Đảm bảo backend đang chạy ở port 3002
- Kiểm tra firewall không block port

---

## 🤝 Đóng Góp

Chúng tôi hoan nghênh mọi đóng góp! Để contribute:

1. Fork repository này
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

---

## 👥 Tác Giả

- **Khanh Vu** - [GitHub](https://github.com/KhanhKH069)
 
---

