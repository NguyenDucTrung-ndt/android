# Recipe Notebook - Ứng dụng Sổ tay Công thức Nấu ăn

Bài tập lớn môn **Lập trình thiết bị di động** - Trường Công nghệ Thông tin, Đại học Phenikaa.

## Thông tin nhóm

| STT | Họ và tên | Mã sinh viên | Nhiệm vụ |
|-----|-----------|--------------|----------|
| 1 | Nguyễn Minh | <Mã sinh viên 1> | Trưởng nhóm - Quản lý trạng thái, màn hình chi tiết |
| 2 | <Họ và tên thành viên 2> | <Mã sinh viên 2> | Giao diện trang chủ, tìm kiếm, đa ngôn ngữ |
| 3 | <Họ và tên thành viên 3> | <Mã sinh viên 3> | Biểu mẫu công thức, danh sách đi chợ, kiểm thử |

Repository: `2026_2027_1_1_LTTBDD_N0x_Nhom_ii`

## Tính năng chính

- Danh sách công thức dạng danh sách / lưới, tìm kiếm theo tên hoặc nguyên liệu (không phân biệt dấu), lọc theo loại món.
- Chi tiết công thức, tự động quy đổi định lượng khi thay đổi khẩu phần.
- Thêm / sửa / xóa công thức (biểu mẫu có kiểm tra dữ liệu).
- Yêu thích (vuốt để bỏ, có hoàn tác).
- Chế độ nấu từng bước kèm đồng hồ hẹn giờ đếm ngược.
- Danh sách đi chợ (thêm từ công thức hoặc nhập tay, tick đã mua, vuốt để xóa).
- Gợi ý món ngẫu nhiên "Hôm nay ăn gì?".
- Hai ngôn ngữ Việt - Anh, chế độ sáng / tối, trang thông tin nhóm.

## Công nghệ

Flutter (Material 3), Dart. Không dùng package ngoài ngoài các thư viện đi kèm SDK
(`flutter`, `flutter_localizations`). Quản lý trạng thái bằng `ChangeNotifier` + `InheritedNotifier`.
Dữ liệu lưu tạm trong bộ nhớ theo yêu cầu đề bài.

## Cấu trúc thư mục `lib/`

```
lib/
  main.dart                  Điểm vào, MaterialApp, theme, đa ngôn ngữ
  app_state.dart             AppState (ChangeNotifier) + AppScope (InheritedNotifier)
  models.dart                Recipe, Ingredient, ShoppingItem, Bi, enum, hàm tiện ích
  team_info.dart             Thông tin nhóm
  data/sample_data.dart      8 công thức mẫu
  l10n/strings.dart          Chuỗi giao diện Việt - Anh
  screens/                   Các màn hình
  widgets/                   Widget dùng chung (thẻ công thức, trạng thái rỗng...)
```

## Chạy ứng dụng

Yêu cầu: Flutter 3.27 trở lên (Dart 3.6+).

```bash
flutter create recipe_notebook        # sinh thư mục android/ ios/ ... (commit đầu tiên)
# chép thư mục lib/, test/ và file pubspec.yaml của dự án này đè vào
cd recipe_notebook
flutter pub get
flutter run
flutter test
```
