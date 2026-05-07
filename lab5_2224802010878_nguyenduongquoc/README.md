# Lab 5 – Flutter Todo App with ASP.NET Core JWT Backend

**Sinh viên:** Nguyễn Dương Quốc | **MSSV:** 2224802010878

---

## ✅ Trạng thái: Hoàn thành – 0 lỗi

```
flutter analyze → No issues found!
```

---

## 🗂️ Cấu trúc Project

```
lab5_2224802010878_nguyenduongquoc/
│
├── lib/                              # Flutter Frontend
│   ├── main.dart                     # Entry: kiểm tra JWT còn hạn
│   ├── config/
│   │   └── api_config.dart           # Base URL & API endpoints
│   ├── models/
│   │   ├── todo_model.dart           # TodoModel (id, title, desc, isCompleted)
│   │   └── user_model.dart           # UserModel (id, email, fullName)
│   ├── services/
│   │   ├── auth_service.dart         # login / register / logout
│   │   └── todo_service.dart         # getTodos / create / update / delete
│   └── screens/
│       ├── login_screen.dart         # Màn hình đăng nhập + animation
│       ├── register_screen.dart      # Màn hình đăng ký
│       └── dashboard_screen.dart     # Todo list + CRUD + stats header
│
└── TodoApi/                          # ASP.NET Core 8 Backend
    ├── Controllers/
    │   ├── AuthController.cs         # POST /api/auth/register, /login
    │   └── TodoController.cs         # GET/POST/PUT/DELETE /api/todos
    ├── Data/
    │   └── AppDbContext.cs           # EF Core + Identity DbContext
    ├── DTOs/
    │   └── Dtos.cs                   # RegisterDto, LoginDto, TodoDto...
    ├── Models/
    │   ├── ApplicationUser.cs        # IdentityUser + FullName
    │   └── TodoItem.cs               # Entity: Id, Title, Desc, UserId
    ├── Services/
    │   ├── AuthService.cs            # Register, Login, GenerateJWT
    │   └── TodoService.cs            # CRUD scoped to user
    ├── Program.cs                    # DI, JWT, Identity, CORS, Swagger
    └── appsettings.json              # ConnectionString + JwtSettings
```

---

## 🚀 Hướng dẫn chạy

### Bước 1 – Chạy Backend (ASP.NET Core)

> **Yêu cầu:** .NET 8 SDK + SQL Server LocalDB

```powershell
cd d:\FlutterProjects\lab5_2224802010878_nguyenduongquoc\TodoApi
dotnet restore
dotnet run
```

- API: `http://localhost:5000`
- Swagger UI: `http://localhost:5000/swagger`
- DB tự tạo khi khởi động (`EnsureCreated`)

---

### Bước 2 – Chạy Flutter App

```powershell
cd d:\FlutterProjects\lab5_2224802010878_nguyenduongquoc
flutter run
```

> ⚠️ **Lưu ý lỗi thường gặp:**
> - Gõ đúng `flutter run` (không phải `fluter run`)
> - Android Emulator dùng IP `10.0.2.2:5000` (đã cấu hình sẵn)
> - Thiết bị thật: đổi IP trong `lib/config/api_config.dart`

---

## 🔐 Luồng JWT hoạt động

```
1. User nhập email + password → Flutter gọi POST /api/auth/login
2. Backend (Identity) xác thực → tạo JWT token (HS256, 24h)
3. Flutter nhận token → lưu vào SharedPreferences
4. Mọi request sau gửi: Authorization: Bearer <token>
5. Backend validate token → trả về dữ liệu của đúng user đó
6. Khi token hết hạn (24h) → tự động về trang Login
```

---

## 📡 API Endpoints

| Method | Endpoint | Auth | Mô tả |
|--------|----------|------|-------|
| `POST` | `/api/auth/register` | ❌ | Đăng ký tài khoản mới |
| `POST` | `/api/auth/login` | ❌ | Đăng nhập → nhận JWT token |
| `GET` | `/api/todos` | ✅ JWT | Lấy tất cả todo của user |
| `POST` | `/api/todos` | ✅ JWT | Tạo todo mới |
| `PUT` | `/api/todos/{id}` | ✅ JWT | Cập nhật todo (title/desc/isCompleted) |
| `DELETE` | `/api/todos/{id}` | ✅ JWT | Xóa todo |

---

## 📱 Tính năng Flutter App

| Tính năng | Mô tả |
|-----------|-------|
| **Đăng ký** | Form validation, password ≥ 6 ký tự |
| **Đăng nhập** | Lưu JWT vào SharedPreferences |
| **Auto-login** | Kiểm tra token còn hạn khi mở app |
| **Dashboard** | Stats: Tổng / Hoàn thành / Còn lại |
| **Thêm todo** | Dialog nhập tiêu đề + mô tả |
| **Sửa todo** | Vuốt trái → nút Sửa → dialog |
| **Xóa todo** | Vuốt trái → nút Xóa |
| **Toggle done** | Nhấn vào vòng tròn → gạch ngang title |
| **Đăng xuất** | Xóa token → về Login screen |

---

## 📦 Dependencies

### Flutter (`pubspec.yaml`)
```yaml
http: ^1.2.1            # Gọi HTTP API
jwt_decoder: ^2.0.1     # Giải mã & kiểm tra JWT
shared_preferences: ^2.2.3  # Lưu token local
flutter_slidable: ^3.1.0    # Swipe action (sửa/xóa)
```

### ASP.NET Core (`TodoApi.csproj`)
```xml
Microsoft.AspNetCore.Identity.EntityFrameworkCore  # User management
Microsoft.AspNetCore.Authentication.JwtBearer      # JWT middleware
Microsoft.EntityFrameworkCore.SqlServer            # SQL Server ORM
Swashbuckle.AspNetCore                             # Swagger UI
```

---

## 📚 Tài liệu tham khảo

1. [Flutter Todo App with NodeJS & MongoDB](https://protocoderspoint.com/flutter-todo-app-with-nodejs-mongodb-at-backend/)
2. [User Microservice with ASP.NET Core Web API](https://dotnettutorials.net/lesson/user-microservice-withasp-net-core-web-api/)
3. [Building a Secure Flutter App with JWT and APIs](https://medium.com/@areesh-ali/building-a-secure-flutter-app-with-jwt-and-apis-e22ade2b2d5f)
