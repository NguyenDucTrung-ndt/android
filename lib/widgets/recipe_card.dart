import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import 'common.dart';

/// Nút tim tròn nổi trên ảnh món ăn.
class _FavoriteOverlayButton extends StatelessWidget {
  const _FavoriteOverlayButton({
    required this.isFavorite,
    required this.onTap,
  });

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.42),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: isFavorite ? const Color(0xFFFF5252) : Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Thẻ công thức nổi bật (cuộn ngang 2 cột như màn hình chính).
class FeaturedRecipeCard extends StatelessWidget {
  const FeaturedRecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.width = 172,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 108,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RecipeVisualBox(
                      emoji: recipe.emoji,
                      color: categoryColor(recipe.category),
                      borderRadius: 0,
                      emojiScale: 0.46,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _FavoriteOverlayButton(
                        isFavorite: recipe.isFavorite,
                        onTap: () => state.toggleFavorite(recipe.id),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name.get(state.lang),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 2,
                        children: [
                          MiniInfo(
                            icon: Icons.access_time,
                            text: '${recipe.minutes} ${s.t('minutes_unit')}',
                          ),
                          MiniInfo(
                            icon: Icons.restaurant_menu_outlined,
                            text: s.difficulty(recipe.difficulty),
                          ),
                        ],
                      ),
                      const Spacer(),
                      CuisineBadge(cuisine: recipe.cuisine),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thẻ công thức dạng danh sách ngang (giống mục Công thức được yêu thích).
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
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              RecipeVisualBox(
                emoji: recipe.emoji,
                color: categoryColor(recipe.category),
                width: 86,
                height: 74,
                borderRadius: 14,
                emojiScale: 0.48,
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.description.get(state.lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        MiniInfo(
                          icon: Icons.access_time,
                          text: '${recipe.minutes} ${s.t('minutes_unit')}',
                        ),
                        MiniInfo(
                          icon: Icons.restaurant_menu_outlined,
                          text: s.difficulty(recipe.difficulty),
                        ),
                        CuisineBadge(cuisine: recipe.cuisine),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: s.t('nav_favorites'),
                icon: Icon(
                  recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: recipe.isFavorite
                      ? const Color(0xFFE53935)
                      : theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () => state.toggleFavorite(recipe.id),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thẻ công thức dạng lưới 2 cột.
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RecipeVisualBox(
                    emoji: recipe.emoji,
                    color: categoryColor(recipe.category),
                    borderRadius: 0,
                    emojiScale: 0.48,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _FavoriteOverlayButton(
                      isFavorite: recipe.isFavorite,
                      onTap: () => state.toggleFavorite(recipe.id),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name.get(state.lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      MiniInfo(
                        icon: Icons.access_time,
                        text: '${recipe.minutes} ${s.t('minutes_unit')}',
                      ),
                      MiniInfo(
                        icon: Icons.restaurant_menu_outlined,
                        text: s.difficulty(recipe.difficulty),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  CuisineBadge(cuisine: recipe.cuisine),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
