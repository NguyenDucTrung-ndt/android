import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../widgets/common.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

/// Màn hình Danh Mục: thanh tiêu đề với nút quay lại, các chip lọc cuộn ngang
/// (Tất cả, theo quốc gia, theo loại món) và danh sách công thức.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    super.key,
    this.initialCuisine,
    this.initialCategory,
  });

  final Cuisine? initialCuisine;
  final Category? initialCategory;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Cuisine? _cuisine = widget.initialCuisine;
  late Category? _category = widget.initialCategory;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);
    final theme = Theme.of(context);
    final results = state.search('', _category, cuisine: _cuisine);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        centerTitle: true,
        title: Text(
          s.t('catalog_title'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              children: [
                _CatalogPill(
                  label: s.t('all'),
                  selected: _cuisine == null && _category == null,
                  onTap: () => setState(() {
                    _cuisine = null;
                    _category = null;
                  }),
                ),
                const SizedBox(width: 8),
                for (final cuisine in Cuisine.values) ...[
                  _CatalogPill(
                    label: s.cuisine(cuisine),
                    selected: _cuisine == cuisine,
                    onTap: () => setState(() {
                      _category = null;
                      _cuisine = _cuisine == cuisine ? null : cuisine;
                    }),
                  ),
                  const SizedBox(width: 8),
                ],
                for (final category in Category.values) ...[
                  _CatalogPill(
                    label: s.category(category),
                    selected: _category == category,
                    onTap: () => setState(() {
                      _cuisine = null;
                      _category = _category == category ? null : category;
                    }),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: results.isEmpty
                ? EmptyState(
                    icon: Icons.menu_book_outlined,
                    message: s.t('no_results'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => RecipeCard(
                      recipe: results[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              RecipeDetailScreen(recipeId: results[i].id),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CatalogPill extends StatelessWidget {
  const _CatalogPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: selected
          ? const Color(0xFFEF6C00)
          : (isDark ? const Color(0xFF28211D) : const Color(0xFFF6ECE3)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: selected
              ? const Color(0xFFEF6C00)
              : (isDark ? const Color(0xFF3C312A) : const Color(0xFFEBE0D6)),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? Colors.white
                    : (isDark
                        ? const Color(0xFFE8DDD4)
                        : const Color(0xFF3E2723)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

