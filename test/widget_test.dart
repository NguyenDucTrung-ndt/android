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
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const RecipeApp());
    await tester.pumpAndSettle();
  }

  testWidgets('App khởi động và hiển thị danh sách công thức', (tester) async {
    await pumpAtSize(tester, const Size(390, 844));
    expect(find.text('Sổ tay Nấu ăn'), findsWidgets);
    expect(find.text('Phở bò'), findsOneWidget);
  });

  testWidgets('Kiểm tra toàn bộ luồng nghiệp vụ trên Mobile viewport (360x640)',
      (tester) async {
    await pumpAtSize(tester, const Size(360, 640));

    // 1. Trang chủ: tìm kiếm, lọc loại món, đổi dạng lưới/danh sách, gợi ý ngẫu nhiên
    await tester.enterText(find.byType(TextField), 'pho');
    await tester.pumpAndSettle();
    expect(find.text('Phở bò'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Món chính'));
    await tester.pumpAndSettle();
    expect(find.text('Bún chả'), findsOneWidget);

    await tester.tap(find.text('Tất cả'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.grid_view));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.view_list));
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
    expect(find.text('Món test Web'), findsOneWidget);

    // 5. Tab Yêu thích
    await tester.tap(find.text('Yêu thích'));
    await tester.pumpAndSettle();
    expect(find.text('Phở bò'), findsOneWidget);

    // 6. Tab Đi chợ: thêm tay & tick
    await tester.tap(find.text('Đi chợ'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Thêm món cần mua...'),
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

    // 7. Tab Cài đặt: đổi chế độ tối, đổi ngôn ngữ, mở Thông tin nhóm
    await tester.tap(find.text('Cài đặt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chế độ tối'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);

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
