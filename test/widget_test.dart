import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipe_notebook/main.dart';
import 'package:recipe_notebook/models.dart';

void main() {
  Future<void> pumpAtSize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(RecipeApp(key: UniqueKey()));
    await tester.pumpAndSettle();
  }

  testWidgets('App khởi động và hiển thị 38 công thức mẫu', (tester) async {
    await pumpAtSize(tester, const Size(390, 844));
    expect(find.text('Sổ tay Nấu ăn'), findsWidgets);
    expect(find.text('Công thức nổi bật'), findsOneWidget);
    expect(find.text('Công thức được yêu thích'), findsOneWidget);
    expect(find.text('38 công thức'), findsWidgets);
    expect(find.text('Phở bò'), findsWidgets);
  });

  testWidgets('Lọc theo quốc gia, độ khó và nguyên liệu trên Mobile (360x640)',
      (tester) async {
    await pumpAtSize(tester, const Size(360, 640));

    // Lọc theo Quốc gia = Món Ý (ô chọn nhanh)
    await tester.ensureVisible(find.text('Món Ý').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Món Ý').first);
    await tester.pumpAndSettle();
    expect(find.text('4 công thức'), findsOneWidget);
    expect(find.text('Mì Ý sốt bò bằm'), findsOneWidget);

    // Đổi sang Món Âu
    await tester.ensureVisible(find.text('Món Âu').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Món Âu').first);
    await tester.pumpAndSettle();
    expect(find.text('5 công thức'), findsOneWidget);
    expect(find.text('Bít tết bò áp chảo'), findsOneWidget);

    // Đổi sang Nhật Bản
    await tester.ensureVisible(find.text('Nhật Bản').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nhật Bản').first);
    await tester.pumpAndSettle();
    expect(find.text('3 công thức'), findsOneWidget);
    expect(find.text('Cơm cà ri Nhật Bản'), findsOneWidget);

    // Xóa lọc quốc gia
    await tester.ensureVisible(find.text('Xóa lọc'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa lọc'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.text('38 công thức'), findsWidgets);

    // Lọc theo Độ khó = Khó trong Bộ lọc công thức
    await tester.tap(find.byTooltip('Bộ lọc công thức'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Khó'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Khó'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Áp dụng'));
    await tester.pumpAndSettle();
    expect(find.text('3 công thức'), findsOneWidget);
    expect(find.text('Cơm tấm sườn bì chả'), findsOneWidget);

    // Xóa lọc độ khó
    await tester.ensureVisible(find.text('Xóa lọc'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa lọc'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.text('38 công thức'), findsWidgets);

    // Lọc theo Nguyên liệu: chọn Trứng + nhập thêm cà chua
    await tester.tap(find.byTooltip('Bộ lọc công thức'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Trứng'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trứng'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(
          TextField, 'Nhập thêm nguyên liệu (vd: trứng gà, tôm)...'),
      'cà chua',
    );
    await tester.tap(find.text('Thêm'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Áp dụng'));
    await tester.pumpAndSettle();

    expect(find.text('Canh trứng cà chua'), findsOneWidget);
    expect(find.text('Bún riêu cua'), findsOneWidget);
    expect(find.text('2 công thức'), findsOneWidget);

    // Xóa bộ lọc
    await tester.ensureVisible(find.text('Xóa lọc'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa lọc'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.text('38 công thức'), findsWidgets);
  });

  testWidgets('Đi chợ: thêm món kèm định lượng (trứng gà 2 quả, trứng vịt 3 quả)',
      (tester) async {
    await pumpAtSize(tester, const Size(360, 640));

    await tester.tap(find.text('Đi chợ'));
    await tester.pumpAndSettle();

    // Thêm Trứng gà (2 quả) bằng cách chọn đơn vị từ menu
    await tester.enterText(
      find.widgetWithText(TextField, 'Thêm món cần mua (vd: Trứng gà)...'),
      'Trứng gà',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'SL (vd: 2)'),
      '2',
    );
    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();
    await tester.tap(find.text('quả').last);
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Trứng gà'), findsOneWidget);
    expect(find.text('2 quả'), findsOneWidget);

    // Thêm Trứng vịt (3 quả) bằng cách gõ đơn vị trực tiếp
    await tester.enterText(
      find.widgetWithText(TextField, 'Thêm món cần mua (vd: Trứng gà)...'),
      'Trứng vịt',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'SL (vd: 2)'),
      '3',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Đơn vị (quả, g...)'),
      'quả',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Trứng vịt'), findsOneWidget);
    expect(find.text('3 quả'), findsOneWidget);
  });

  testWidgets('Kiểm tra toàn bộ luồng nghiệp vụ trên Mobile viewport (360x640)',
      (tester) async {
    await pumpAtSize(tester, const Size(360, 640));

    // 1. Trang chủ -> mở Trang tìm kiếm, chọn từ khóa phổ biến, gõ tìm kiếm, quay lại
    await tester.tap(find.text('Tìm món ăn hoặc nguyên liệu...'));
    await tester.pumpAndSettle();
    expect(find.text('Từ khóa phổ biến'), findsOneWidget);
    expect(find.text('Kết quả tìm kiếm'), findsOneWidget);

    await tester.tap(find.text('Pizza'));
    await tester.pumpAndSettle();
    expect(find.text('Pizza Margherita'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'pho');
    await tester.pumpAndSettle();
    expect(find.text('Phở bò'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Mở Danh Mục từ nút "Xem tất cả" trên Trang chủ
    await tester.tap(find.text('Xem tất cả').first);
    await tester.pumpAndSettle();
    expect(find.text('Danh Mục'), findsOneWidget);
    expect(find.text('Phở bò'), findsOneWidget);
    await tester.tap(find.text('Món Ý'));
    await tester.pumpAndSettle();
    expect(find.text('Mì Ý sốt bò bằm'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Món chính'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Món chính'));
    await tester.pumpAndSettle();
    expect(find.text('Bún chả'), findsOneWidget);

    await tester.ensureVisible(find.text('Tất cả').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tất cả').first);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.view_list_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.casino_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Gợi ý cho bạn'), findsOneWidget);
    await tester.tap(find.text('Gợi ý khác'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();

    // 2. Chi tiết công thức: tăng khẩu phần, thêm vào đi chợ, vào chế độ nấu
    await tester.tap(find.text('Phở bò').first);
    await tester.pumpAndSettle();
    expect(find.text('4 người'), findsOneWidget);

    await Scrollable.ensureVisible(
      tester.element(find.byIcon(Icons.add_circle_outline)),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();
    expect(find.text('5 người'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Thêm vào danh sách đi chợ'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thêm vào danh sách đi chợ'));
    await tester.pumpAndSettle();
    expect(find.text('Đã thêm nguyên liệu vào danh sách đi chợ'), findsOneWidget);

    await tester.tap(find.text('Bắt đầu nấu'));
    await tester.pumpAndSettle();

    // 3. Chế độ nấu: kiểm tra điều hướng bước và đồng hồ hẹn giờ
    expect(find.text('Bước 1 / 6'), findsOneWidget);
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text('Tạm dừng'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đặt lại'));
    await tester.pumpAndSettle();
    expect(find.text('05:00'), findsOneWidget);

    await tester.tap(find.text('Tiếp'));
    await tester.pumpAndSettle();
    expect(find.text('Bước 2 / 6'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // 4. Thêm công thức mới
    await tester.tap(find.text('Thêm món'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tên món ăn *'),
      'Món test Web',
    );
    await tester.scrollUntilVisible(
      find.widgetWithText(TextFormField, 'Nguyên liệu'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nguyên liệu'),
      'Trứng gà',
    );
    await tester.scrollUntilVisible(
      find.widgetWithText(TextFormField, 'Mô tả bước thực hiện'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mô tả bước thực hiện'),
      'Chiên vàng đều',
    );
    await tester.tap(find.text('Lưu').first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Món test Web'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Món test Web'), findsOneWidget);

    // 5. Tab Yêu thích
    await tester.tap(find.text('Yêu thích'));
    await tester.pumpAndSettle();
    expect(find.text('Phở bò'), findsOneWidget);

    // 6. Tab Đi chợ: thêm tay & kiểm tra
    await tester.tap(find.text('Đi chợ'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Thêm món cần mua (vd: Trứng gà)...'),
      'Muối biển',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Muối biển'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Muối biển'), findsOneWidget);

    // 7. Tab Cá nhân & Cài đặt: kiểm tra hồ sơ, đổi chế độ tối, đổi ngôn ngữ, mở Thông tin nhóm
    await tester.tap(find.text('Cá nhân'));
    await tester.pumpAndSettle();
    expect(find.text('Nguyễn Văn Trung'), findsOneWidget);
    expect(find.text('Công thức của tôi'), findsOneWidget);

    await tester.tap(find.byTooltip('Cài đặt'));
    await tester.pumpAndSettle();
    expect(find.text('Chế độ sáng'), findsOneWidget);
    expect(find.text('Chế độ tối'), findsOneWidget);
    await tester.tap(find.text('Chế độ tối'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ngôn ngữ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Team information'),
      150,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Team information'));
    await tester.pumpAndSettle();
    expect(find.text('Phenikaa University - School of Information Technology'),
        findsOneWidget);
  });

  testWidgets('Không tràn giao diện trên màn hình rất nhỏ (320x568) và ngang (640x360)',
      (tester) async {
    for (final size in [const Size(320, 568), const Size(640, 360)]) {
      await pumpAtSize(tester, size);
      expect(tester.takeException(), isNull, reason: 'Home overflow at $size');

      await tester.tap(find.text('Tìm món ăn hoặc nguyên liệu...'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Search overflow at $size');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await Scrollable.ensureVisible(
        tester.element(find.text('Xem tất cả').first),
        alignment: 0.3,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xem tất cả').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Catalog overflow at $size');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Đi chợ'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Shopping overflow at $size');

      await tester.tap(find.text('Cá nhân'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Profile overflow at $size');

      await tester.tap(find.byTooltip('Cài đặt'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Settings overflow at $size');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trang chủ'));
      await tester.pumpAndSettle();
      if (find.text('Phở bò').evaluate().isEmpty) {
        await tester.scrollUntilVisible(
          find.text('Phở bò'),
          150,
          scrollable: find.byType(Scrollable).first,
        );
      }
      await Scrollable.ensureVisible(
        tester.element(find.text('Phở bò').first),
        alignment: 0.3,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Phở bò').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Detail overflow at $size');

      await tester.tap(find.text('Bắt đầu nấu'));
      await tester.pumpAndSettle();
      final err = tester.takeException();
      expect(err, isNull, reason: 'Cooking overflow at $size: $err');

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thêm món'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Form overflow at $size');
    }
  });

  test('normalizeText bỏ dấu tiếng Việt', () {
    expect(normalizeText('Phở Bò Đặc Biệt'), 'pho bo dac biet');
  });

  test('formatAmount định dạng số lượng', () {
    expect(formatAmount(2), '2');
    expect(formatAmount(0.5), '0.5');
    expect(formatAmount(1.25), '1.25');
  });
}
