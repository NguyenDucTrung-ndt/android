import 'package:flutter/material.dart';

import 'data/sample_data.dart';
import 'models.dart';

/// Trạng thái toàn ứng dụng (công thức, danh sách đi chợ, ngôn ngữ, giao diện).
/// Dữ liệu chỉ lưu tạm trong bộ nhớ theo yêu cầu đề bài.
class AppState extends ChangeNotifier {
  AppState() : _recipes = buildSampleRecipes();

  final List<Recipe> _recipes;
  final List<ShoppingItem> _shopping = [];
  String _lang = 'vi';
  ThemeMode _themeMode = ThemeMode.light;
  int _idCounter = 0;

  // ---------- Getter ----------
  List<Recipe> get recipes => List.unmodifiable(_recipes);
  List<Recipe> get favorites =>
      _recipes.where((r) => r.isFavorite).toList(growable: false);
  List<ShoppingItem> get shopping => List.unmodifiable(_shopping);
  int get uncheckedShoppingCount => _shopping.where((i) => !i.checked).length;
  String get lang => _lang;
  Locale get locale => Locale(_lang);
  ThemeMode get themeMode => _themeMode;

  // ---------- Cài đặt ----------
  void setLang(String lang) {
    if (lang == _lang) return;
    _lang = lang;
    notifyListeners();
  }

  void setDarkMode(bool dark) {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // ---------- Công thức ----------
  String newId() {
    _idCounter++;
    return 'u${DateTime.now().millisecondsSinceEpoch}_$_idCounter';
  }

  Recipe? byId(String id) {
    for (final r in _recipes) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Tìm kiếm theo tên món hoặc nguyên liệu (không phân biệt dấu) và lọc theo loại.
  List<Recipe> search(String query, Category? category) {
    final q = normalizeText(query.trim());
    return _recipes.where((r) {
      if (category != null && r.category != category) return false;
      if (q.isEmpty) return true;
      final buffer = StringBuffer()
        ..write(r.name.vi)
        ..write(' ')
        ..write(r.name.en);
      for (final i in r.ingredients) {
        buffer
          ..write(' ')
          ..write(i.name.vi)
          ..write(' ')
          ..write(i.name.en);
      }
      return normalizeText(buffer.toString()).contains(q);
    }).toList();
  }

  void addRecipe(Recipe recipe) {
    _recipes.insert(0, recipe);
    notifyListeners();
  }

  void updateRecipe(Recipe recipe) {
    final index = _recipes.indexWhere((r) => r.id == recipe.id);
    if (index == -1) return;
    _recipes[index] = recipe;
    notifyListeners();
  }

  void deleteRecipe(String id) {
    _recipes.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final r = byId(id);
    if (r == null) return;
    r.isFavorite = !r.isFavorite;
    notifyListeners();
  }

  // ---------- Danh sách đi chợ ----------
  /// Thêm toàn bộ nguyên liệu của công thức (đã quy đổi theo khẩu phần) vào danh sách.
  void addToShopping(Recipe recipe, int servings) {
    final factor = servings / recipe.servings;
    for (final ing in recipe.ingredients) {
      final amount = formatAmount(ing.amount * factor);
      _shopping.add(ShoppingItem(
        id: newId(),
        name: ing.name,
        quantity: Bi('$amount ${ing.unit.vi}'.trim(), '$amount ${ing.unit.en}'.trim()),
      ));
    }
    notifyListeners();
  }

  void addManualShopping(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    _shopping.add(ShoppingItem(id: newId(), name: Bi.same(t), quantity: const Bi.same('')));
    notifyListeners();
  }

  void toggleShopping(String id) {
    for (final i in _shopping) {
      if (i.id == id) {
        i.checked = !i.checked;
        break;
      }
    }
    notifyListeners();
  }

  void removeShopping(String id) {
    _shopping.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void clearCheckedShopping() {
    _shopping.removeWhere((i) => i.checked);
    notifyListeners();
  }

  void clearAllShopping() {
    _shopping.clear();
    notifyListeners();
  }
}

/// Cung cấp [AppState] cho toàn bộ cây widget (không cần package ngoài).
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }
}
