# Recipe Notebook - Ứng dụng & Mobile Website Sổ tay Công thức Nấu ăn

Bài tập lớn môn **Lập trình thiết bị di động** - Trường Công nghệ Thông tin, Đại học Phenikaa.

Dự án được phát triển bằng Flutter/Dart theo giao diện **Mobile-first**, chạy trực tiếp trên trình duyệt **Google Chrome (Mobile Web)** cũng như thiết bị di động, giữ trọn vẹn toàn bộ nghiệp vụ, dữ liệu, đa ngôn ngữ Việt - Anh và giao diện Sáng / Tối.

## Thông tin nhóm

| STT | Họ và tên | Mã sinh viên | Nhiệm vụ |
|-----|-----------|--------------|----------|
| 1 | Nguyễn Minh Hưng | <Mã sinh viên 1> | Quản lý trạng thái, dữ liệu công thức đa quốc gia, màn hình chi tiết & chế độ nấu |
| 2 | Nguyễn Đức Trung | <Mã sinh viên 2> | Giao diện Mobile Web, Trang chủ, Tìm kiếm, Danh mục, Đi chợ, Cá nhân, Cài đặt & Kiểm thử |

Repository: `https://github.com/NguyenDucTrung-ndt/android`

## Tính năng chính

- **Trang chủ phong cách sổ tay ấm áp**: Header minh họa, nút gợi ý món ngẫu nhiên *"Hôm nay ăn gì?"*, chuyển đổi hiển thị danh sách / lưới 2 cột, dải chọn nhanh theo quốc gia & loại món, mục *Công thức nổi bật*, *Công thức được yêu thích* và toàn bộ danh sách công thức.
- **Kho 38 công thức mẫu đa dạng quốc gia & khu vực**: Phân loại theo **Việt Nam**, **Món Ý**, **Món Âu**, **Nhật Bản**, **Hàn Quốc**, **Thái Lan**, **Khác** và 5 nhóm món (*Món chính*, *Canh - Súp*, *Khai vị*, *Tráng miệng*, *Đồ uống*).
- **Tìm kiếm & Bộ lọc nâng cao (`SearchScreen`, `recipe_filter_sheet.dart`)**: Thanh tìm kiếm không phân biệt dấu tiếng Việt, gợi ý *Từ khóa phổ biến* dạng pill, lọc đồng thời theo **Quốc gia**, **Loại món**, **Độ khó** (*Dễ / Trung bình / Khó*) và **Nguyên liệu** (chọn nhanh hoặc tự nhập).
- **Màn hình Danh Mục (`CatalogScreen`)**: Mở từ nút *"Xem tất cả"* trên Trang chủ, hiển thị dải chip lọc cuộn ngang theo quốc gia & loại món cùng danh sách thẻ công thức.
- **Chi tiết công thức (`RecipeDetailScreen`)**: Thanh điều hướng nổi cố định trên ảnh món ăn, phần giới thiệu, danh sách nguyên liệu kèm biểu tượng món ăn, tăng/giảm khẩu phần tự động quy đổi định lượng, thêm nhanh vào danh sách đi chợ và nút *"Bắt đầu nấu"* ghim cố định phía dưới.
- **Chế độ nấu từng bước (`CookingModeScreen`)**: Hướng dẫn tuần tự từng bước kèm đồng hồ hẹn giờ đếm ngược và chuông báo tương thích trình duyệt Web (`Web Audio API`).
- **Danh sách đi chợ có định lượng (`ShoppingScreen`)**: Thêm từ công thức hoặc nhập tay kèm **tên món, số lượng và đơn vị** (ví dụ: *Trứng gà - 2 quả*, *Trứng vịt - 3 quả*), chọn nhanh đơn vị, theo dõi tiến độ đã mua, vuốt để xóa hoặc xóa hàng loạt.
- **Thêm / Sửa / Xóa công thức (`RecipeFormScreen`)**: Biểu mẫu đầy đủ chọn quốc gia, loại món, độ khó, thời gian, khẩu phần, nguyên liệu và các bước thực hiện có kiểm tra dữ liệu đầu vào.
- **Cá nhân & Cài đặt (`ProfileScreen`, `SettingsScreen`, `AboutScreen`)**: Hồ sơ cá nhân với thống kê công thức/yêu thích/đã xem, *Công thức của tôi*, *Lịch sử xem*, chỉnh sửa thông tin, đăng xuất/đăng nhập chế độ Khách, chuyển **Chế độ sáng / Chế độ tối**, bật/tắt thông báo, chuyển **Tiếng Việt / English** và trang **Thông tin nhóm**.

## Công nghệ

- **Flutter (Material 3) & Dart** (Flutter 3.27+, Dart 3.6+).
- Không phụ thuộc package bên ngoài ngoài các thư viện đi kèm SDK (`flutter`, `flutter_localizations`).
- Quản lý trạng thái bằng `ChangeNotifier` + `InheritedNotifier` (`AppState` / `AppScope`), hỗ trợ đa nền tảng Web (chuông báo qua `dart:js_interop` + Web Audio API trong `alert_sound_web.dart`).

## Cấu trúc thư mục

```text
assets/
  images/hero_cookbook.jpg       Ảnh minh họa sổ tay công thức trên Trang chủ
lib/
  main.dart                      Điểm vào, MaterialApp, theme Sáng/Tối, đa ngôn ngữ
  app_state.dart                 AppState (ChangeNotifier) + AppScope (InheritedNotifier)
  models.dart                    Recipe, Ingredient, ShoppingItem, Bi, Cuisine/Category/Difficulty, tiện ích
  team_info.dart                 Thông tin thành viên nhóm và repository
  data/
    sample_data.dart             38 công thức mẫu (Việt Nam, Ý, Âu, Nhật, Hàn, Thái...)
  l10n/
    strings.dart                 Từ điển giao diện song ngữ Việt - Anh
  utils/
    alert_sound.dart             Conditional import âm thanh cảnh báo
    alert_sound_stub.dart        Bản dự phòng non-web
    alert_sound_web.dart         Chuông báo hẹn giờ bằng Web Audio API trên Chrome
  screens/
    main_shell.dart              Điều hướng 4 tab (Trang chủ, Yêu thích, Đi chợ, Cá nhân)
    home_screen.dart             Trang chủ
    search_screen.dart           Tìm kiếm & từ khóa phổ biến
    catalog_screen.dart          Danh mục công thức theo chip lọc
    recipe_detail_screen.dart    Chi tiết công thức & quy đổi khẩu phần
    cooking_mode_screen.dart     Chế độ nấu từng bước & hẹn giờ
    recipe_form_screen.dart      Thêm / sửa công thức
    favorites_screen.dart        Danh sách yêu thích
    shopping_screen.dart         Danh sách đi chợ kèm định lượng
    profile_screen.dart          Trang Cá nhân, công thức của tôi & lịch sử xem
    settings_screen.dart         Cài đặt giao diện, ngôn ngữ, thông báo
    about_screen.dart            Thông tin nhóm
  widgets/
    common.dart                  Widget dùng chung (EmojiBox, EmptyState, badge...)
    recipe_card.dart             Thẻ công thức nổi bật, danh sách ngang & lưới 2 cột
    recipe_filter_sheet.dart     Bottom sheet bộ lọc đa tiêu chí dùng chung
web/
  index.html, manifest.json      Cấu hình chạy Mobile Website trên trình duyệt Chrome
test/
  widget_test.dart               Kiểm thử đơn vị, luồng nghiệp vụ & chống tràn màn hình
```

## Chạy Website (Chrome) & Kiểm thử

```bash
flutter pub get

# Chạy trực tiếp dưới dạng Web trên Google Chrome
flutter run -d chrome

# Chạy toàn bộ kiểm thử tự động (bao gồm viewport 320x568, 360x640, 390x844, 640x360)
flutter analyze
flutter test

# Build bản phát hành Mobile Web (output tại build/web/)
flutter build web --release
```

Trong Chrome Desktop, mở DevTools (`F12` hoặc `Ctrl+Shift+I`) và bật **Toggle device toolbar (`Ctrl+Shift+M`)** để trải nghiệm giao diện chuẩn Mobile Web.
