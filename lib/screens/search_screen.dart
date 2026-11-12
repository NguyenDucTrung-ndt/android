import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../widgets/common.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_filter_sheet.dart';
import 'recipe_detail_screen.dart';

/// Màn hình Tìm kiếm công thức: thanh tìm kiếm có nút quay lại & bộ lọc,
/// từ khóa phổ biến dạng pill và danh sách kết quả tìm kiếm.
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    this.initialCategory,
    this.initialCuisine,
    this.initialDifficulty,
    this.initialPresetIds = const {},
    this.initialCustomIngredients = const {},
  });

  final Category? initialCategory;
  final Cuisine? initialCuisine;
  final Difficulty? initialDifficulty;
  final Set<String> initialPresetIds;
  final Set<String> initialCustomIngredients;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const List<Bi> _popularKeywords = [
    Bi('Phở', 'Pho'),
    Bi('Bánh xèo', 'Banh xeo'),
    Bi('Mì Ý', 'Spaghetti'),
    Bi('Pizza', 'Pizza'),
    Bi('Cơm', 'Rice'),
    Bi('Súp', 'Soup'),
    Bi('Bít tết', 'Beefsteak'),
    Bi('Trứng', 'Egg'),
  ];

  final TextEditingController _ctrl = TextEditingController();
  String _query = '';
  late Category? _category = widget.initialCategory;
  late Cuisine? _cuisine = widget.initialCuisine;
  late Difficulty? _difficulty = widget.initialDifficulty;
  late final Set<String> _presetIds = Set<String>.from(widget.initialPresetIds);
  late final Set<String> _customIngredients =
      Set<String>.from(widget.initialCustomIngredients);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _category != null ||
      _cuisine != null ||
      _difficulty != null ||
      _presetIds.isNotEmpty ||
      _customIngredients.isNotEmpty;

  int get _filterCount =>
      (_category != null ? 1 : 0) +
      (_cuisine != null ? 1 : 0) +
      (_difficulty != null ? 1 : 0) +
      _presetIds.length +
      _customIngredients.length;

  void _clearAll() {
    setState(() {
      _ctrl.clear();
      _query = '';
      _category = null;
      _cuisine = null;
      _difficulty = null;
      _presetIds.clear();
      _customIngredients.clear();
    });
  }

  void _selectKeyword(String keyword) {
    setState(() {
      if (normalizeText(_query) == normalizeText(keyword)) {
        _ctrl.clear();
        _query = '';
      } else {
        _ctrl.text = keyword;
        _ctrl.selection = TextSelection.collapsed(offset: keyword.length);
        _query = keyword;
      }
    });
  }

  Future<void> _openFilterSheet() async {
    final result = await showRecipeFilterSheet(
      context: context,
      initialCategory: _category,
      initialCuisine: _cuisine,
      initialDifficulty: _difficulty,
      initialPresetIds: _presetIds,
      initialCustom: _customIngredients,
    );
    if (!mounted || result == null) return;
    setState(() {
      _category = result.category;
      _cuisine = result.cuisine;
      _difficulty = result.difficulty;
      _presetIds
        ..clear()
        ..addAll(result.presetIds);
      _customIngredients
        ..clear()
        ..addAll(result.customIngredients);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final results = state.search(
      _query,
      _category,
      cuisine: _cuisine,
      difficulty: _difficulty,
      presetIds: _presetIds,
      customIngredients: _customIngredients,
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 10, 14, 12),
                child: Row(
                  children: [
                    const BackButton(),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF241E1B) : Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF3A302A)
                                : const Color(0xFFEDE1D5),
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF8D6E63)
                                        .withValues(alpha: 0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                        child: TextField(
                          controller: _ctrl,
                          onChanged: (v) => setState(() => _query = v),
                          decoration: InputDecoration(
                            hintText: s.t('search_hint'),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _ctrl.clear();
                                      setState(() => _query = '');
                                    },
                                  ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: s.t('filters_title'),
                      child: IconButton(
                        onPressed: _openFilterSheet,
                        icon: Badge(
                          label: Text('$_filterCount'),
                          isLabelVisible: _filterCount > 0,
                          child: Icon(
                            Icons.tune_rounded,
                            color: _filterCount > 0
                                ? const Color(0xFFEF6C00)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.t('popular_keywords'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final kw in _popularKeywords)
                          _KeywordPill(
                            label: kw.get(s.lang),
                            selected: normalizeText(_query) ==
                                normalizeText(kw.get(s.lang)),
                            onTap: () => _selectKeyword(kw.get(s.lang)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_hasFilters)
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
                            onPressed: _clearAll,
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
                              onDeleted: () =>
                                  setState(() => _category = null),
                            ),
                          ),
                        if (_difficulty != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InputChip(
                              label: Text(s.difficulty(_difficulty!)),
                              onDeleted: () =>
                                  setState(() => _difficulty = null),
                            ),
                          ),
                        for (final preset in AppState.ingredientPresets)
                          if (_presetIds.contains(preset.id))
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InputChip(
                                label: Text(preset.label.get(s.lang)),
                                onDeleted: () => setState(
                                  () => _presetIds.remove(preset.id),
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 2,
                        children: [
                          Text(
                            s.t('search_results'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '(${s.f('recipe_count', [results.length])})',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_query.isNotEmpty || _hasFilters)
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _clearAll,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                s.t('see_all'),
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
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList.separated(
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
      ),
    );
  }
}

class _KeywordPill extends StatelessWidget {
  const _KeywordPill({
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
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: selected
              ? const Color(0xFFEF6C00)
              : (isDark ? const Color(0xFF3C312A) : const Color(0xFFEBE0D6)),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
    );
  }
}

