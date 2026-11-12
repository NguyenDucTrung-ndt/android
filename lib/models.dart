/// Các lớp mô hình dữ liệu (Model) của ứng dụng.

/// Phân loại món ăn.
enum Category { main, soup, appetizer, dessert, drink }

/// Phân loại theo quốc gia / khu vực ẩm thực.
enum Cuisine { vietnamese, italian, european, japanese, korean, thai, other }

/// Độ khó của công thức.
enum Difficulty { easy, medium, hard }

/// Chuỗi văn bản song ngữ (Việt - Anh).
class Bi {
  const Bi(this.vi, this.en);

  /// Dùng cho dữ liệu người dùng tự nhập (một ngôn ngữ duy nhất).
  const Bi.same(String text)
      : vi = text,
        en = text;

  final String vi;
  final String en;

  String get(String lang) => lang == 'vi' ? vi : en;
}

/// Một nguyên liệu trong công thức.
class Ingredient {
  const Ingredient(this.name, this.amount, this.unit);

  final Bi name;
  final double amount;
  final Bi unit;
}

/// Một công thức nấu ăn.
class Recipe {
  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    this.cuisine = Cuisine.vietnamese,
    required this.difficulty,
    required this.minutes,
    required this.servings,
    required this.ingredients,
    required this.steps,
    this.isFavorite = false,
    this.isCustom = false,
  });

  final String id;
  final Bi name;
  final Bi description;
  final String emoji;
  final Category category;
  final Cuisine cuisine;
  final Difficulty difficulty;
  final int minutes;
  final int servings;
  final List<Ingredient> ingredients;
  final List<Bi> steps;
  bool isFavorite;
  final bool isCustom;
}

/// Một mục trong danh sách đi chợ.
class ShoppingItem {
  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.checked = false,
  });

  final String id;
  final Bi name;
  final Bi quantity;
  bool checked;
}

/// Định dạng số lượng: bỏ phần thập phân thừa (2 -> "2", 0.50 -> "0.5").
String formatAmount(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  var s = value.toStringAsFixed(2);
  while (s.endsWith('0')) {
    s = s.substring(0, s.length - 1);
  }
  if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  return s;
}

const Map<String, String> _vietnameseGroups = {
  'a': 'àáạảãâầấậẩẫăằắặẳẵ',
  'e': 'èéẹẻẽêềếệểễ',
  'i': 'ìíịỉĩ',
  'o': 'òóọỏõôồốộổỗơờớợởỡ',
  'u': 'ùúụủũưừứựửữ',
  'y': 'ỳýỵỷỹ',
  'd': 'đ',
};

/// Một bộ lọc nhanh theo nhóm nguyên liệu.
class IngredientPreset {
  const IngredientPreset({
    required this.id,
    required this.label,
    required this.terms,
  });

  final String id;
  final Bi label;
  final List<String> terms;
}

/// Chuẩn hóa chuỗi để tìm kiếm: chữ thường, bỏ dấu tiếng Việt.
String normalizeText(String input) {
  var out = input.toLowerCase();
  _vietnameseGroups.forEach((base, chars) {
    for (final c in chars.split('')) {
      out = out.replaceAll(c, base);
    }
  });
  return out;
}
