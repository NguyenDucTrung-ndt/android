import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../widgets/common.dart';
import '../widgets/recipe_card.dart';
import 'about_screen.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';
import 'settings_screen.dart';

/// Trang Cá nhân: ảnh đại diện, thông tin người dùng, thẻ thống kê 3 cột
/// (Công thức / Yêu thích / Đã xem) và danh sách thao tác cá nhân.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.onOpenHome,
    required this.onOpenFavorites,
  });

  final VoidCallback onOpenHome;
  final VoidCallback onOpenFavorites;

  Future<void> _editProfile(BuildContext context) async {
    final state = AppScope.of(context);
    final s = S.of(context);
    final nameCtrl = TextEditingController(text: state.userName);
    final emailCtrl = TextEditingController(text: state.userEmail);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.t('edit_profile')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: s.t('profile_name'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: s.t('profile_email'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.t('save')),
          ),
        ],
      ),
    );
    if (saved == true) {
      state.updateProfile(nameCtrl.text, emailCtrl.text);
    }
    nameCtrl.dispose();
    emailCtrl.dispose();
  }

  Future<void> _handleAuthAction(BuildContext context) async {
    final state = AppScope.of(context);
    final s = S.of(context);
    if (!state.isSignedIn) {
      state.signIn();
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.t('sign_out_title')),
        content: Text(s.t('sign_out_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.t('sign_out')),
          ),
        ],
      ),
    );
    if (ok == true) {
      state.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor =
        isDark ? const Color(0xFF382F29) : const Color(0xFFF3EAE1);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          tooltip: s.t('settings_title'),
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _editProfile(context),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: isDark
                                  ? const Color(0xFF3A303E)
                                  : const Color(0xFFE7DFEC),
                              child: Text(
                                state.isSignedIn ? '👨‍🍳' : '🙂',
                                style: const TextStyle(fontSize: 44),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF6C00),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.isSignedIn
                            ? state.userName
                            : s.t('guest_user'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => state.isSignedIn
                            ? _editProfile(context)
                            : state.signIn(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: Text(
                            state.isSignedIn
                                ? state.userEmail
                                : s.t('guest_subtitle'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Card(
                        margin: EdgeInsets.zero,
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.bakery_dining_outlined,
                                  iconColor: const Color(0xFFEF6C00),
                                  count: '${state.recipes.length}',
                                  label: s.t('stat_recipes'),
                                  onTap: onOpenHome,
                                ),
                              ),
                              VerticalDivider(
                                width: 1,
                                thickness: 1,
                                indent: 14,
                                endIndent: 14,
                                color: dividerColor,
                              ),
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.favorite,
                                  iconColor: const Color(0xFFE53935),
                                  count: '${state.favorites.length}',
                                  label: s.t('stat_favorites'),
                                  onTap: onOpenFavorites,
                                ),
                              ),
                              VerticalDivider(
                                width: 1,
                                thickness: 1,
                                indent: 14,
                                endIndent: 14,
                                color: dividerColor,
                              ),
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.access_time_filled_rounded,
                                  iconColor: const Color(0xFF1E88E5),
                                  count: '${state.viewedRecipes.length}',
                                  label: s.t('stat_viewed'),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const _ViewHistoryScreen(),
                                    ),
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
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverToBoxAdapter(
              child: Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _ProfileMenuRow(
                      icon: Icons.bakery_dining_outlined,
                      title: s.t('my_recipes'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const _MyRecipesScreen(),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: dividerColor,
                    ),
                    _ProfileMenuRow(
                      icon: Icons.favorite_border_rounded,
                      title: s.t('favorite_list'),
                      onTap: onOpenFavorites,
                    ),
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: dividerColor,
                    ),
                    _ProfileMenuRow(
                      icon: Icons.access_time_rounded,
                      title: s.t('view_history'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const _ViewHistoryScreen(),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: dividerColor,
                    ),
                    _ProfileMenuRow(
                      icon: Icons.settings_outlined,
                      title: s.t('settings_title'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: dividerColor,
                    ),
                    _ProfileMenuRow(
                      icon: Icons.help_outline_rounded,
                      title: s.t('help_support'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: dividerColor,
                    ),
                    _ProfileMenuRow(
                      icon: state.isSignedIn ? Icons.logout : Icons.login,
                      title: state.isSignedIn
                          ? s.t('sign_out')
                          : s.t('sign_in'),
                      color: state.isSignedIn
                          ? const Color(0xFFD84315)
                          : const Color(0xFFEF6C00),
                      showChevron: false,
                      onTap: () => _handleAuthAction(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String count;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              count,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 22, color: effectiveColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: effectiveColor,
                ),
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.outline,
              ),
          ],
        ),
      ),
    );
  }
}

class _MyRecipesScreen extends StatelessWidget {
  const _MyRecipesScreen();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);
    final list = state.myRecipes;
    return Scaffold(
      appBar: AppBar(title: Text(s.t('my_recipes'))),
      body: list.isEmpty
          ? EmptyState(
              icon: Icons.bakery_dining_outlined,
              message: s.t('no_my_recipes'),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final Recipe r = list[i];
                return RecipeCard(
                  recipe: r,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipeId: r.id),
                    ),
                  ),
                );
              },
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

class _ViewHistoryScreen extends StatelessWidget {
  const _ViewHistoryScreen();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);
    final list = state.viewedRecipes;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('view_history')),
        actions: [
          if (list.isNotEmpty)
            TextButton(
              onPressed: state.clearHistory,
              child: Text(s.t('clear_history')),
            ),
        ],
      ),
      body: list.isEmpty
          ? EmptyState(
              icon: Icons.history,
              message: s.t('no_history'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final Recipe r = list[i];
                return RecipeCard(
                  recipe: r,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipeId: r.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

