import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../widgets/common.dart';
import 'cooking_mode_screen.dart';
import 'recipe_form_screen.dart';

/// Chi tiết công thức: thông tin, chỉnh khẩu phần, nguyên liệu, các bước.
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            actions: [
              IconButton(
                tooltip: s.t('nav_favorites'),
                icon: Icon(
                  recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: recipe.isFavorite ? Colors.redAccent : null,
                ),
                onPressed: () => state.toggleFavorite(recipe.id),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => RecipeFormScreen(recipe: recipe),
                    ));
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
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.name.get(s.lang),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.55),
                      color.withValues(alpha: 0.15),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(recipe.emoji, style: const TextStyle(fontSize: 96)),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.timer_outlined, size: 18),
                      label: Text('${recipe.minutes} ${s.t('minutes_unit')}'),
                    ),
                    Chip(
                      avatar: const Icon(Icons.local_fire_department_outlined,
                          size: 18),
                      label: Text(s.difficulty(recipe.difficulty)),
                    ),
                    Chip(
                      avatar: const Icon(Icons.category_outlined, size: 18),
                      label: Text(s.category(recipe.category)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(recipe.description.get(s.lang),
                    style: theme.textTheme.bodyLarge),
                SectionTitle(
                  s.t('ingredients'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: '-',
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: servings > 1
                            ? () => setState(() => _servings = servings - 1)
                            : null,
                      ),
                      Text(
                        '$servings ${s.t('servings_unit')}',
                        style: theme.textTheme.titleSmall,
                      ),
                      IconButton(
                        tooltip: '+',
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: servings < 20
                            ? () => setState(() => _servings = servings + 1)
                            : null,
                      ),
                    ],
                  ),
                ),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < recipe.ingredients.length; i++)
                        CheckboxListTile(
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: _checked.contains(i),
                          onChanged: (v) => setState(() {
                            if (v == true) {
                              _checked.add(i);
                            } else {
                              _checked.remove(i);
                            }
                          }),
                          title: Text(
                            recipe.ingredients[i].name.get(s.lang),
                            style: TextStyle(
                              decoration: _checked.contains(i)
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          secondary: Text(
                            '${formatAmount(recipe.ingredients[i].amount * factor)} '
                            '${recipe.ingredients[i].unit.get(s.lang)}',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
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
                SectionTitle(s.t('steps')),
                for (var i = 0; i < recipe.steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          child: Text('${i + 1}',
                              style: const TextStyle(fontSize: 13)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(recipe.steps[i].get(s.lang),
                              style: theme.textTheme.bodyLarge),
                        ),
                      ],
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.play_arrow),
        label: Text(s.t('start_cooking')),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CookingModeScreen(recipeId: recipe.id),
          ),
        ),
      ),
    );
  }
}
