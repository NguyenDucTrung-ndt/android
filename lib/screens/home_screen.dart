import 'dart:math';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../widgets/common.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_filter_sheet.dart';
import 'catalog_screen.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';
import 'search_screen.dart';

/// Trang chủ: header minh họa, tìm kiếm, bộ lọc nhanh theo quốc gia/loại,
/// công thức nổi bật, được yêu thích và toàn bộ danh sách.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _featuredIds = [
    'r1',
    'r23',
    'r27',
    'r32',
    'r35',
    'r37',
    'r26',
    'r2',
  ];

  Category? _category;
  Cuisine? _cuisine;
  Difficulty? _difficulty;
  final Set<String> _presetIngredientIds = {};
  final Set<String> _customIngredients = {};
  bool _grid = false;

  void _openCatalog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatalogScreen(
          initialCuisine: _cuisine,
          initialCategory: _category,
        ),
      ),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          initialCategory: _category,
          initialCuisine: _cuisine,
          initialDifficulty: _difficulty,
          initialPresetIds: _presetIngredientIds,
          initialCustomIngredients: _customIngredients,
        ),
      ),
    );
  }

  void _openDetail(Recipe r) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipeId: r.id)),
    );
  }

  Future<void> _suggest() async {
    final state = AppScope.of(context);
    final s = S.of(context);
    final all = state.recipes;
    if (all.isEmpty) return;
    final rnd = Random();
    var pick = all[rnd.nextInt(all.length)];
    while (true) {
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(s.t('random_hint')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EmojiBox(
                  emoji: pick.emoji,
                  color: categoryColor(pick.category),
                  size: 96,
                ),
                const SizedBox(height: 16),
                Text(
                  pick.name.get(s.lang),
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  pick.description.get(s.lang),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'close'),
              child: Text(s.t('close')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'again'),
              child: Text(s.t('random_again')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'view'),
              child: Text(s.t('random_view')),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (action == 'again') {
        pick = all[rnd.nextInt(all.length)];
        continue;
      }
      if (action == 'view') _openDetail(pick);
      return;
    }
  }

  bool get _hasAnyFilter =>
      _category != null ||
      _cuisine != null ||
      _difficulty != null ||
      _presetIngredientIds.isNotEmpty ||
      _customIngredients.isNotEmpty;

  int get _advancedFilterCount =>
      (_category != null ? 1 : 0) +
      (_cuisine != null ? 1 : 0) +
      (_difficulty != null ? 1 : 0) +
      _presetIngredientIds.length +
      _customIngredients.length;

  void _clearAllFilters() {
    setState(() {
      _category = null;
      _cuisine = null;
      _difficulty = null;
      _presetIngredientIds.clear();
      _customIngredients.clear();
    });
  }

  Future<void> _openFilterSheet() async {
    final result = await showRecipeFilterSheet(
      context: context,
      initialCategory: _category,
      initialCuisine: _cuisine,
      initialDifficulty: _difficulty,
      initialPresetIds: _presetIngredientIds,
      initialCustom: _customIngredients,
    );
    if (!mounted || result == null) return;
    setState(() {
      _category = result.category;
      _cuisine = result.cuisine;
      _difficulty = result.difficulty;
      _presetIngredientIds
        ..clear()
        ..addAll(result.presetIds);
      _customIngredients
        ..clear()
        ..addAll(result.customIngredients);
    });
  }

  List<Recipe> _pickFeatured(List<Recipe> all) {
    final byId = {for (final r in all) r.id: r};
    final out = <Recipe>[];
    for (final id in _featuredIds) {
      final found = byId[id];
      if (found != null) out.add(found);
    }
    if (out.isEmpty) return all.take(6).toList();
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final results = state.search(
      '',
      _category,
      cuisine: _cuisine,
      difficulty: _difficulty,
      presetIds: _presetIngredientIds,
      customIngredients: _customIngredients,
    );
    final isDiscoveryMode = !_hasAnyFilter && !_grid;
    final featured = _pickFeatured(state.recipes);
    final favorites = state.favorites;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HomeHeroHeader(
              title: s.t('app_name'),
              subtitle: s.t('hero_subtitle'),
              countLabel: s.f('recipe_count', [state.recipes.length]),
              isGrid: _grid,
              suggestTooltip: s.t('random_title'),
              viewTooltip: _grid ? s.t('view_list') : s.t('view_grid'),
              onSuggest: _suggest,
              onToggleView: () => setState(() => _grid = !_grid),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: isDark ? const Color(0xFF241E1B) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF3A302A)
                              : const Color(0xFFEDE1D5),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      elevation: isDark ? 0 : 1,
                      shadowColor:
                          const Color(0xFF8D6E63).withValues(alpha: 0.14),
                      child: InkWell(
                        onTap: _openSearch,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  s.t('search_hint'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: isDark ? const Color(0xFF241E1B) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: _advancedFilterCount > 0
                            ? const Color(0xFFEF6C00)
                            : (isDark
                                ? const Color(0xFF3A302A)
                                : const Color(0xFFEDE1D5)),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _openFilterSheet,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Tooltip(
                          message: s.t('filters_title'),
                          child: Center(
                            child: Badge(
                              label: Text('$_advancedFilterCount'),
                              isLabelVisible: _advancedFilterCount > 0,
                              child: Icon(
                                Icons.tune_rounded,
                                color: _advancedFilterCount > 0
                                    ? const Color(0xFFEF6C00)
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _QuickTileBar(
              selectedCategory: _category,
              selectedCuisine: _cuisine,
              onSelectAll: () => setState(() {
                _category = null;
                _cuisine = null;
              }),
              onSelectCuisine: (c) => setState(() {
                _category = null;
                _cuisine = _cuisine == c ? null : c;
              }),
              onSelectCategory: (cat) => setState(() {
                _cuisine = null;
                _category = _category == cat ? null : cat;
              }),
            ),
          ),
          if (_hasAnyFilter)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          avatar: const Icon(Icons.close, size: 16),
                          label: Text(s.t('clear_filters')),
                          onPressed: _clearAllFilters,
                        ),
                      ),
                      if (_cuisine != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InputChip(
                            label: Text(s.cuisine(_cuisine!)),
                            onDeleted: () => setState(() => _cuisine = null),
                          ),
                        ),
                      if (_category != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InputChip(
                            label: Text(s.category(_category!)),
                            onDeleted: () => setState(() => _category = null),
                          ),
                        ),
                      if (_difficulty != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InputChip(
                            label: Text(s.difficulty(_difficulty!)),
                            onDeleted: () => setState(() => _difficulty = null),
                          ),
                        ),
                      for (final preset in AppState.ingredientPresets)
                        if (_presetIngredientIds.contains(preset.id))
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InputChip(
                              label: Text(preset.label.get(s.lang)),
                              onDeleted: () => setState(
                                () => _presetIngredientIds.remove(preset.id),
                              ),
                            ),
                          ),
                      for (final item in _customIngredients)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InputChip(
                            label: Text(item),
                            onDeleted: () => setState(
                              () => _customIngredients.remove(item),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (isDiscoveryMode) ...[
            SliverToBoxAdapter(
              child: _SectionHeaderRow(
                icon: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFEF6C00),
                  size: 22,
                ),
                title: s.t('featured_recipes'),
                actionLabel: s.t('see_all'),
                onAction: _openCatalog,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 214,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: featured.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => FeaturedRecipeCard(
                    recipe: featured[i],
                    onTap: () => _openDetail(featured[i]),
                  ),
                ),
              ),
            ),
            if (favorites.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeaderRow(
                  icon: const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF9A825),
                    size: 22,
                  ),
                  title: s.t('favorite_recipes'),
                  actionLabel: s.t('see_all'),
                  onAction: _openCatalog,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: favorites.length > 3 ? 3 : favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => RecipeCard(
                    recipe: favorites[i],
                    onTap: () => _openDetail(favorites[i]),
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: _SectionHeaderRow(
                icon: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF6D4C41),
                  size: 20,
                ),
                title: s.t('all_recipes'),
                trailingText: s.f('recipe_count', [results.length]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              sliver: SliverList.separated(
                itemCount: results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => RecipeCard(
                  recipe: results[i],
                  onTap: () => _openDetail(results[i]),
                ),
              ),
            ),
          ] else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  s.f('recipe_count', [results.length]),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (results.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.search_off,
                  message: s.t('no_results'),
                ),
              )
            else if (_grid)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => RecipeGridCard(
                      recipe: results[i],
                      onTap: () => _openDetail(results[i]),
                    ),
                    childCount: results.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                sliver: SliverList.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => RecipeCard(
                    recipe: results[i],
                    onTap: () => _openDetail(results[i]),
                  ),
                ),
              ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RecipeFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: Text(s.t('add_recipe')),
      ),
    );
  }
}

/// Phần đầu trang chủ mang phong cách sổ tay ấm áp.
class _HomeHeroHeader extends StatelessWidget {
  const _HomeHeroHeader({
    required this.title,
    required this.subtitle,
    required this.countLabel,
    required this.isGrid,
    required this.suggestTooltip,
    required this.viewTooltip,
    required this.onSuggest,
    required this.onToggleView,
  });

  final String title;
  final String subtitle;
  final String countLabel;
  final bool isGrid;
  final String suggestTooltip;
  final String viewTooltip;
  final VoidCallback onSuggest;
  final VoidCallback onToggleView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final showIllustration = width >= 300;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF28201B), Color(0xFF171311)]
              : const [Color(0xFFFAF0E4), Color(0xFFFDF8F3)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF6C00)
                          .withValues(alpha: isDark ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      countLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFFFFB74D)
                            : const Color(0xFFE65100),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _HeaderActionButton(
                    tooltip: suggestTooltip,
                    icon: Icons.casino_outlined,
                    showDot: true,
                    onTap: onSuggest,
                  ),
                  const SizedBox(width: 8),
                  _HeaderActionButton(
                    tooltip: viewTooltip,
                    icon: isGrid
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                    onTap: onToggleView,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF6C00)
                                    .withValues(alpha: isDark ? 0.25 : 0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.bakery_dining_outlined,
                                size: 20,
                                color: Color(0xFFEF6C00),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                  color: isDark
                                      ? const Color(0xFFFFF3E0)
                                      : const Color(0xFF3E2723),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 72,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF6C00)
                                .withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? const Color(0xFFD7CCC8)
                                      : const Color(0xFF5D4037),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.favorite_border_rounded,
                              size: 14,
                              color: Color(0xFFEF6C00),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (showIllustration) ...[
                    const SizedBox(width: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: width < 360 ? 84 : 110,
                        height: width < 360 ? 68 : 84,
                        child: Image.asset(
                          'assets/images/hero_cookbook.jpg',
                          fit: BoxFit.cover,
                          color: isDark ? null : const Color(0xFFFAF0E4),
                          colorBlendMode:
                              isDark ? null : BlendMode.multiply,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF8D5524)
                                  .withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.menu_book_rounded,
                              size: 36,
                              color: Color(0xFF8D5524),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isDark ? const Color(0xFF2E2622) : Colors.white.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0xFF42362F) : const Color(0xFFEEDFD1),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 20),
                if (showDot)
                  const Positioned(
                    top: 7,
                    right: 7,
                    child: CircleAvatar(
                      radius: 3.5,
                      backgroundColor: Color(0xFFEF6C00),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Thanh ô vuông bo góc chọn nhanh Tất cả / Quốc gia / Loại món.
class _QuickTileBar extends StatelessWidget {
  const _QuickTileBar({
    required this.selectedCategory,
    required this.selectedCuisine,
    required this.onSelectAll,
    required this.onSelectCuisine,
    required this.onSelectCategory,
  });

  final Category? selectedCategory;
  final Cuisine? selectedCuisine;
  final VoidCallback onSelectAll;
  final ValueChanged<Cuisine> onSelectCuisine;
  final ValueChanged<Category> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final tiles = <_QuickTileData>[
      _QuickTileData(
        label: s.t('all'),
        icon: Icons.restaurant_menu_rounded,
        selected: selectedCategory == null && selectedCuisine == null,
        onTap: onSelectAll,
      ),
      _QuickTileData(
        label: s.cuisine(Cuisine.vietnamese),
        icon: Icons.rice_bowl_outlined,
        selected: selectedCuisine == Cuisine.vietnamese,
        onTap: () => onSelectCuisine(Cuisine.vietnamese),
      ),
      _QuickTileData(
        label: s.cuisine(Cuisine.italian),
        icon: Icons.local_pizza_outlined,
        selected: selectedCuisine == Cuisine.italian,
        onTap: () => onSelectCuisine(Cuisine.italian),
      ),
      _QuickTileData(
        label: s.cuisine(Cuisine.european),
        icon: Icons.public,
        selected: selectedCuisine == Cuisine.european,
        onTap: () => onSelectCuisine(Cuisine.european),
      ),
      _QuickTileData(
        label: s.cuisine(Cuisine.japanese),
        icon: Icons.ramen_dining_outlined,
        selected: selectedCuisine == Cuisine.japanese,
        onTap: () => onSelectCuisine(Cuisine.japanese),
      ),
      _QuickTileData(
        label: s.cuisine(Cuisine.korean),
        icon: Icons.soup_kitchen_outlined,
        selected: selectedCuisine == Cuisine.korean,
        onTap: () => onSelectCuisine(Cuisine.korean),
      ),
      _QuickTileData(
        label: s.cuisine(Cuisine.thai),
        icon: Icons.local_fire_department_outlined,
        selected: selectedCuisine == Cuisine.thai,
        onTap: () => onSelectCuisine(Cuisine.thai),
      ),
      _QuickTileData(
        label: s.category(Category.main),
        icon: Icons.dinner_dining_outlined,
        selected: selectedCategory == Category.main,
        onTap: () => onSelectCategory(Category.main),
      ),
      _QuickTileData(
        label: s.category(Category.dessert),
        icon: Icons.cake_outlined,
        selected: selectedCategory == Category.dessert,
        onTap: () => onSelectCategory(Category.dessert),
      ),
      _QuickTileData(
        label: s.category(Category.drink),
        icon: Icons.local_cafe_outlined,
        selected: selectedCategory == Category.drink,
        onTap: () => onSelectCategory(Category.drink),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          for (var i = 0; i < tiles.length; i++)
            Padding(
              padding: EdgeInsets.only(right: i == tiles.length - 1 ? 0 : 10),
              child: _QuickTileButton(data: tiles[i]),
            ),
        ],
      ),
    );
  }
}

class _QuickTileData {
  const _QuickTileData({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
}

class _QuickTileButton extends StatelessWidget {
  const _QuickTileButton({required this.data});

  final _QuickTileData data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = data.selected
        ? const Color(0xFFEF6C00)
        : (isDark ? const Color(0xFF28211D) : const Color(0xFFF3ECE4));
    final fg = data.selected
        ? Colors.white
        : (isDark ? const Color(0xFFE0D5CB) : const Color(0xFF4E342E));

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: data.onTap,
        child: Container(
          width: 66,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(data.icon, size: 22, color: fg),
              const SizedBox(height: 5),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: data.selected ? FontWeight.w700 : FontWeight.w500,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeaderRow extends StatelessWidget {
  const _SectionHeaderRow({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailingText,
  });

  final Widget icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 12, 10),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                trailingText!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (actionLabel != null && onAction != null)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF6C00),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Color(0xFFEF6C00),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
