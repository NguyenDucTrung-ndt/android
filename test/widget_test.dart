import 'package:flutter_test/flutter_test.dart';

import 'package:recipe_notebook/main.dart';
import 'package:recipe_notebook/models.dart';

void main() {
  testWidgets('App khởi động và hiển thị danh sách công thức', (tester) async {
    await tester.pumpWidget(const RecipeApp());
    await tester.pumpAndSettle();
    expect(find.text('Sổ tay Nấu ăn'), findsWidgets);
    expect(find.text('Phở bò'), findsOneWidget);
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
