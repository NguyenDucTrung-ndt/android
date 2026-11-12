import 'package:flutter/material.dart';

import 'data/sample_data.dart';
import 'models.dart';

/// Trạng thái toàn ứng dụng (công thức, danh sách đi chợ, ngôn ngữ, giao diện).
/// Dữ liệu chỉ lưu tạm trong bộ nhớ theo yêu cầu đề bài.
class AppState extends ChangeNotifier {
  AppState() : _recipes = buildSampleRecipes();

  final List<Recipe> _recipes;
  final List<ShoppingItem> _shopping = [];
  final List<String> _viewedIds = [];
  String _lang = 'vi';
  ThemeMode _themeMode = ThemeMode.light;
  bool _notificationsEnabled = true;
  bool _isSignedIn = true;
  String _userName = 'Nguyễn Văn Trung';
  String _userEmail = 'trungnguyen@gmail.com';
  int _idCounter = 0;

  // ---------- Getter ----------
  List<Recipe> get recipes => List.unmodifiable(_recipes);
  List<Recipe> get myRecipes =>
      _recipes.where((r) => r.isCustom).toList(growable: false);
  List<Recipe> get favorites =>
      _recipes.where((r) => r.isFavorite).toList(growable: false);
  List<Recipe> get viewedRecipes {
    final out = <Recipe>[];
    for (final id in _viewedIds) {
      final r = byId(id);
      if (r != null) out.add(r);
    }
    return List.unmodifiable(out);
  }

  List<ShoppingItem> get shopping => List.unmodifiable(_shopping);
  int get uncheckedShoppingCount => _shopping.where((i) => !i.checked).length;
  String get lang => _lang;
  Locale get locale => Locale(_lang);
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isSignedIn => _isSignedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;

  // ---------- Cài đặt & Hồ sơ ----------
  void setLang(String lang) {
    if (lang == _lang) return;
    _lang = lang;
    notifyListeners();
  }

  void setDarkMode(bool dark) {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    if (_notificationsEnabled == enabled) return;
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  void markViewed(String id) {
    if (byId(id) == null) return;
    _viewedIds.remove(id);
    _viewedIds.insert(0, id);
    if (_viewedIds.length > 30) {
      _viewedIds.removeLast();
    }
    notifyListeners();
  }

  void clearHistory() {
    if (_viewedIds.isEmpty) return;
    _viewedIds.clear();
    notifyListeners();
  }

  void updateProfile(String name, String email) {
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    if (cleanName.isNotEmpty) _userName = cleanName;
    if (cleanEmail.isNotEmpty) _userEmail = cleanEmail;
    _isSignedIn = true;
    notifyListeners();
  }

  void signOut() {
    _isSignedIn = false;
    notifyListeners();
  }

  void signIn([String? name, String? email]) {
    if (name != null && name.trim().isNotEmpty) _userName = name.trim();
    if (email != null && email.trim().isNotEmpty) _userEmail = email.trim();
    _isSignedIn = true;
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

  /// Các nhóm nguyên liệu phổ biến dùng cho bộ lọc nhanh.
  static const List<IngredientPreset> ingredientPresets = [
    IngredientPreset(
      id: 'egg',
      label: Bi('Trứng', 'Eggs'),
      terms: ['trung', 'egg'],
    ),
    IngredientPreset(
      id: 'pork',
      label: Bi('Thịt heo', 'Pork'),
      terms: [
        'thit heo',
        'ba chi',
        'thit xay',
        'suon cot let',
        'bi heo',
        'thit xong khoi',
        'pork',
        'bacon',
      ],
    ),
    IngredientPreset(
      id: 'beef',
      label: Bi('Thịt bò', 'Beef'),
      terms: ['thit bo', 'xuong bo', 'than bo', 'beef'],
    ),
    IngredientPreset(
      id: 'chicken',
      label: Bi('Thịt gà', 'Chicken'),
      terms: ['thit ga', 'uc ga'],
    ),
    IngredientPreset(
      id: 'shrimp',
      label: Bi('Tôm', 'Shrimp'),
      terms: ['tom', 'shrimp'],
    ),
    IngredientPreset(
      id: 'fish',
      label: Bi('Cá / Hải sản', 'Fish / Seafood'),
      terms: ['ca loc', 'ca hoi', 'cua dong', 'muc', 'fish', 'salmon', 'crab', 'squid'],
    ),
    IngredientPreset(
      id: 'tofu',
      label: Bi('Đậu hũ', 'Tofu'),
      terms: ['dau hu', 'tofu'],
    ),
    IngredientPreset(
      id: 'noodle',
      label: Bi('Bún / Phở / Mì Ý', 'Noodles / Pasta'),
      terms: [
        'bun',
        'banh pho',
        'mien',
        'mi y',
        'spaghetti',
        'pho mai',
        'banh gao',
        'rice noodles',
        'vermicelli',
        'glass noodles',
      ],
    ),
    IngredientPreset(
      id: 'tomato',
      label: Bi('Cà chua', 'Tomato'),
      terms: ['ca chua', 'tomato'],
    ),
    IngredientPreset(
      id: 'coconut',
      label: Bi('Cốt dừa / Nước dừa', 'Coconut'),
      terms: ['nuoc cot dua', 'nuoc dua', 'coconut'],
    ),
    IngredientPreset(
      id: 'milk',
      label: Bi('Sữa / Kem / Phô mai', 'Dairy / Cheese'),
      terms: ['sua', 'kem tuoi', 'pho mai', 'mascarpone', 'bo lat', 'milk', 'cream', 'cheese', 'yogurt'],
    ),
  ];

  /// Tìm kiếm theo tên món hoặc nguyên liệu và lọc theo loại, quốc gia, độ khó, nguyên liệu.
  List<Recipe> search(
    String query,
    Category? category, {
    Cuisine? cuisine,
    Difficulty? difficulty,
    Set<String> presetIds = const {},
    Set<String> customIngredients = const {},
  }) {
    final queryTerms = query
        .split(',')
        .map((e) => normalizeText(e.trim()))
        .where((e) => e.isNotEmpty)
        .toList();

    final activePresets = [
      for (final p in ingredientPresets)
        if (presetIds.contains(p.id)) p,
    ];
    final normalizedCustom = customIngredients
        .map((e) => normalizeText(e.trim()))
        .where((e) => e.isNotEmpty)
        .toList();

    return _recipes.where((r) {
      if (category != null && r.category != category) return false;
      if (cuisine != null && r.cuisine != cuisine) return false;
      if (difficulty != null && r.difficulty != difficulty) return false;

      final ingBuffer = StringBuffer();
      for (final i in r.ingredients) {
        ingBuffer
          ..write(' ')
          ..write(i.name.vi)
          ..write(' ')
          ..write(i.name.en);
      }
      final normalizedIngs = normalizeText(ingBuffer.toString());

      for (final preset in activePresets) {
        final matched = preset.terms.any((term) => normalizedIngs.contains(term));
        if (!matched) return false;
      }

      for (final custom in normalizedCustom) {
        if (!normalizedIngs.contains(custom)) return false;
      }

      if (queryTerms.isEmpty) return true;
      final fullText = normalizeText('${r.name.vi} ${r.name.en}$ingBuffer');
      return queryTerms.every(fullText.contains);
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

  void addManualShopping(String text, {String amount = '', Bi? unit}) {
    final t = text.trim();
    if (t.isEmpty) return;
    final cleanAmount = amount.trim().replaceAll(',', '.');
    final hasAmount = cleanAmount.isNotEmpty;
    final hasUnit = unit != null && (unit.vi.trim().isNotEmpty || unit.en.trim().isNotEmpty);

    final Bi quantity;
    if (hasAmount && hasUnit) {
      quantity = Bi(
        '$cleanAmount ${unit.vi.trim()}'.trim(),
        '$cleanAmount ${unit.en.trim()}'.trim(),
      );
    } else if (hasAmount) {
      quantity = Bi.same(cleanAmount);
    } else if (hasUnit) {
      quantity = unit;
    } else {
      quantity = const Bi.same('');
    }

    _shopping.add(ShoppingItem(id: newId(), name: Bi.same(t), quantity: quantity));
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
