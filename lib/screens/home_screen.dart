import 'dart:math';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../widgets/common.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

/// Trang chủ: tìm kiếm, lọc theo loại, xem dạng danh sách hoặc lưới.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  Category? _category;
  bool _grid = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
          content: Column(
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

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);
    final results = state.search(_query, _category);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('app_name')),
        actions: [
          IconButton(
            tooltip: s.t('random_title'),
            icon: const Icon(Icons.casino_outlined),
            onPressed: _suggest,
          ),
          IconButton(
            tooltip: _grid ? s.t('view_list') : s.t('view_grid'),
            icon: Icon(_grid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _grid = !_grid),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: s.t('search_hint'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(s.t('all')),
                    selected: _category == null,
                    onSelected: (_) => setState(() => _category = null),
                  ),
                ),
                for (final c in Category.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(s.category(c)),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                s.f('recipe_count', [results.length]),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: results.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    message: s.t('no_results'),
                  )
                : _grid
                    ? GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: results.length,
                        itemBuilder: (context, i) => RecipeGridCard(
                          recipe: results[i],
                          onTap: () => _openDetail(results[i]),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => RecipeCard(
                          recipe: results[i],
                          onTap: () => _openDetail(results[i]),
                        ),
                      ),
          ),
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
