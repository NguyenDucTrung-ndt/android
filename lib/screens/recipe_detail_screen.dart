import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../widgets/common.dart';
import 'cooking_mode_screen.dart';
import 'recipe_form_screen.dart';

/// Chi tiết công thức: banner đầu trang bo góc chồng nền, giới thiệu,
/// nguyên liệu kèm icon & chỉnh khẩu phần, các bước thực hiện và nút Bắt đầu nấu.
class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int? _servings; // null = dùng khẩu phần gốc của công thức
  final Set<int> _checked = {};
  Recipe? _lastRecipe; // giữ bản cuối để không nháy trắng khi vừa xóa
  bool _recordedView = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_recordedView) {
      _recordedView = true;
      final state = AppScope.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) state.markViewed(widget.recipeId);
      });
    }
  }

  Future<void> _confirmDelete(Recipe recipe) async {
    final state = AppScope.of(context);
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.t('delete_title')),
        content: Text(s.f('delete_body', [recipe.name.get(s.lang)])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.t('delete')),
          ),
        ],
      ),
    );
    if (ok == true) {
      navigator.pop();
      state.deleteRecipe(recipe.id);
      messenger.showSnackBar(SnackBar(content: Text(s.t('deleted'))));
    }
  }

  String _ingredientEmoji(Ingredient item) {
    final n = normalizeText('${item.name.vi} ${item.name.en}');
    if (n.contains('thit bo') || n.contains('beef') || n.contains('steak')) {
      return '🥩';
    }
    if (n.contains('ga') || n.contains('chicken')) return '🍗';
    if (n.contains('thit heo') ||
        n.contains('suon') ||
        n.contains('ba chi') ||
        n.contains('pork') ||
        n.contains('bacon') ||
        n.contains('cha')) {
      return '🥓';
    }
    if (n.contains('tom') || n.contains('shrimp')) return '🍤';
    if (n.contains('ca hoi') ||
        n.contains('ca ') ||
        n.contains('salmon') ||
        n.contains('fish') ||
        n.contains('muc') ||
        n.contains('squid') ||
        n.contains('cua')) {
      return '🐟';
    }
    if (n.contains('trung') || n.contains('egg')) return '🥚';
    if (n.contains('banh pho') ||
        n.contains('bun') ||
        n.contains('mi ') ||
        n.contains('mi y') ||
        n.contains('spaghetti') ||
        n.contains('noodle') ||
        n.contains('pasta')) {
      return '🍜';
    }
    if (n.contains('com') || n.contains('gao') || n.contains('rice')) {
      return '🍚';
    }
    if (n.contains('banh mi') ||
        n.contains('bot') ||
        n.contains('bread') ||
        n.contains('flour') ||
        n.contains('dough') ||
        n.contains('ladyfinger')) {
      return '🥖';
    }
    if (n.contains('ca chua') || n.contains('tomato')) return '🍅';
    if (n.contains('hanh tay') ||
        n.contains('hanh tim') ||
        n.contains('toi') ||
        n.contains('onion') ||
        n.contains('garlic')) {
      return '🧅';
    }
    if (n.contains('ca rot') || n.contains('carrot')) return '🥕';
    if (n.contains('khoai') || n.contains('potato')) return '🥔';
    if (n.contains('bi do') || n.contains('pumpkin')) return '🎃';
    if (n.contains('nam') || n.contains('mushroom')) return '🍄';
    if (n.contains('chanh') || n.contains('lemon') || n.contains('lime')) {
      return '🍋';
    }
    if (n.contains('ot') || n.contains('chili') || n.contains('pepper')) {
      return '🌶️';
    }
    if (n.contains('chuoi') || n.contains('banana')) return '🍌';
    if (n.contains('dau hu') || n.contains('tofu')) return '🧈';
    if (n.contains('pho mai') ||
        n.contains('cheese') ||
        n.contains('bo lat') ||
        n.contains('butter')) {
      return '🧀';
    }
    if (n.contains('sua') ||
        n.contains('kem') ||
        n.contains('milk') ||
        n.contains('cream')) {
      return '🥛';
    }
    if (n.contains('ca phe') ||
        n.contains('espresso') ||
        n.contains('tra') ||
        n.contains('matcha') ||
        n.contains('coffee') ||
        n.contains('tea')) {
      return '🍵';
    }
    if (n.contains('hanh la') ||
        n.contains('rau') ||
        n.contains('xa lach') ||
        n.contains('mang tay') ||
        n.contains('rong bien') ||
        n.contains('la ') ||
        n.contains('herb') ||
        n.contains('basil') ||
        n.contains('lettuce')) {
      return '🥬';
    }
    if (n.contains('nuoc mam') ||
        n.contains('nuoc tuong') ||
        n.contains('duong') ||
        n.contains('muoi') ||
        n.contains('dau') ||
        n.contains('sot') ||
        n.contains('sauce') ||
        n.contains('oil') ||
        n.contains('sugar')) {
      return '🧂';
    }
    return '🥣';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);
    final recipe = state.byId(widget.recipeId) ?? _lastRecipe;
    if (recipe == null) return const Scaffold();
    _lastRecipe = recipe;

    final servings = _servings ?? recipe.servings;
    final factor = servings / recipe.servings;
    final color = categoryColor(recipe.category);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                // Banner món ăn phía trên
                SizedBox(
                  height: 256,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RecipeVisualBox(
                        emoji: recipe.emoji,
                        color: color,
                        borderRadius: 0,
                        emojiScale: 0.42,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.34),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Phần nội dung bo góc chồng lên phần dưới ảnh
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 224),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name.get(s.lang),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 14,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      MiniInfo(
                        icon: Icons.access_time_rounded,
                        text: '${recipe.minutes} ${s.t('minutes_unit')}',
                      ),
                      MiniInfo(
                        icon: Icons.bakery_dining_outlined,
                        text: s.difficulty(recipe.difficulty),
                      ),
                      MiniInfo(
                        icon: Icons.category_outlined,
                        text: s.category(recipe.category),
                      ),
                      CuisineBadge(cuisine: recipe.cuisine),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    s.t('intro'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipe.description.get(s.lang),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.t('ingredients'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFFEF6C00).withValues(alpha: 0.2)
                              : const Color(0xFFFFEFE0),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                              tooltip: '-',
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                                color: Color(0xFFE65100),
                              ),
                              onPressed: servings > 1
                                  ? () =>
                                      setState(() => _servings = servings - 1)
                                  : null,
                            ),
                            PopupMenuButton<int>(
                              initialValue: servings,
                              onSelected: (v) => setState(() => _servings = v),
                              itemBuilder: (_) => [
                                for (var count = 1; count <= 12; count++)
                                  PopupMenuItem(
                                    value: count,
                                    child: Text(
                                      '$count ${s.t('servings_unit')}',
                                    ),
                                  ),
                              ],
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  '$servings ${s.t('servings_unit')}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFFFFCC80)
                                        : const Color(0xFFD84315),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                              tooltip: '+',
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                                color: Color(0xFFE65100),
                              ),
                              onPressed: servings < 20
                                  ? () =>
                                      setState(() => _servings = servings + 1)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < recipe.ingredients.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: isDark
                                  ? const Color(0xFF382F29)
                                  : const Color(0xFFF3EAE1),
                            ),
                          InkWell(
                            borderRadius: BorderRadius.vertical(
                              top: i == 0
                                  ? const Radius.circular(18)
                                  : Radius.zero,
                              bottom: i == recipe.ingredients.length - 1
                                  ? const Radius.circular(18)
                                  : Radius.zero,
                            ),
                            onTap: () => setState(() {
                              if (_checked.contains(i)) {
                                _checked.remove(i);
                              } else {
                                _checked.add(i);
                              }
                            }),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF312925)
                                          : const Color(0xFFF8F2EB),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _ingredientEmoji(recipe.ingredients[i]),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      recipe.ingredients[i].name.get(s.lang),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        decoration: _checked.contains(i)
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: _checked.contains(i)
                                            ? theme.colorScheme.outline
                                            : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${formatAmount(recipe.ingredients[i].amount * factor)} '
                                    '${recipe.ingredients[i].unit.get(s.lang)}',
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: _checked.contains(i)
                                          ? theme.colorScheme.outline
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(s.t('add_to_shopping')),
                      onPressed: () {
                        state.addToShopping(recipe, servings);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(content: Text(s.t('added_to_shopping'))),
                          );
                      },
                    ),
                  ),
                  SectionTitle(s.t('steps')),
                  for (var i = 0; i < recipe.steps.length; i++)
                    Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 13,
                              backgroundColor: const Color(0xFFEF6C00),
                              foregroundColor: Colors.white,
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                recipe.steps[i].get(s.lang),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
              ],
            ),
          ),

          // Thanh nút nổi ghim cố định ở đỉnh màn hình khi cuộn
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    _CircleOverlayAction(
                      child: const BackButton(color: Colors.white),
                    ),
                    const Spacer(),
                    _CircleOverlayAction(
                      child: IconButton(
                        tooltip: s.t('nav_favorites'),
                        icon: Icon(
                          recipe.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: recipe.isFavorite
                              ? const Color(0xFFFF5252)
                              : Colors.white,
                        ),
                        onPressed: () => state.toggleFavorite(recipe.id),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CircleOverlayAction(
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          color: Colors.white,
                        ),
                        onSelected: (v) {
                          if (v == 'edit') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecipeFormScreen(recipe: recipe),
                              ),
                            );
                          } else if (v == 'delete') {
                            _confirmDelete(recipe);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: const Icon(Icons.edit_outlined),
                              title: Text(s.t('edit_recipe')),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: const Icon(Icons.delete_outline),
                              title: Text(s.t('delete')),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF211C19) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? const Color(0xFF382F29)
                  : const Color(0xFFEDE2D8),
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF6C00),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.bakery_dining_outlined),
              label: Text(
                s.t('start_cooking'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CookingModeScreen(recipeId: recipe.id),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleOverlayAction extends StatelessWidget {
  const _CircleOverlayAction({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.42),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
