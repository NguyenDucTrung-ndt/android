import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../widgets/common.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

/// Danh sách món yêu thích. Vuốt ngang để bỏ yêu thích (có hoàn tác).
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);
    final favs = state.favorites;

    return Scaffold(
      appBar: AppBar(title: Text(s.t('nav_favorites'))),
      body: favs.isEmpty
          ? EmptyState(icon: Icons.favorite_border, message: s.t('no_favorites'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final Recipe r = favs[i];
                return Dismissible(
                  key: ValueKey('fav_${r.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.heart_broken, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    state.toggleFavorite(r.id);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(s.t('removed_favorite')),
                          action: SnackBarAction(
                            label: s.t('undo'),
                            onPressed: () => state.toggleFavorite(r.id),
                          ),
                        ),
                      );
                  },
                  child: RecipeCard(
                    recipe: r,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailScreen(recipeId: r.id),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
