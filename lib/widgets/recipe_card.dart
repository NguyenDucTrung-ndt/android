import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import 'common.dart';

/// Thẻ công thức dạng danh sách (ngang).
class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              EmojiBox(
                emoji: recipe.emoji,
                color: categoryColor(recipe.category),
                size: 72,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name.get(state.lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.description.get(state.lang),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        MiniInfo(
                          icon: Icons.timer_outlined,
                          text: '${recipe.minutes} ${s.t('minutes_unit')}',
                        ),
                        MiniInfo(
                          icon: Icons.local_fire_department_outlined,
                          text: s.difficulty(recipe.difficulty),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: s.t('nav_favorites'),
                icon: Icon(
                  recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: recipe.isFavorite ? Colors.redAccent : null,
                ),
                onPressed: () => state.toggleFavorite(recipe.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thẻ công thức dạng lưới (dọc).
class RecipeGridCard extends StatelessWidget {
  const RecipeGridCard({super.key, required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                color: categoryColor(recipe.category).withValues(alpha: 0.2),
                child: Text(recipe.emoji, style: const TextStyle(fontSize: 54)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name.get(state.lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: MiniInfo(
                          icon: Icons.timer_outlined,
                          text: '${recipe.minutes} ${s.t('minutes_unit')}',
                        ),
                      ),
                      InkResponse(
                        onTap: () => state.toggleFavorite(recipe.id),
                        child: Icon(
                          recipe.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color: recipe.isFavorite ? Colors.redAccent : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
