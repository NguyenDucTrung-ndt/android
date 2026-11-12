import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'shopping_screen.dart';

/// Khung chính của ứng dụng với thanh điều hướng dưới (4 tab).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pending = AppScope.of(context).uncheckedShoppingCount;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          const FavoritesScreen(),
          const ShoppingScreen(),
          ProfileScreen(
            onOpenHome: () => setState(() => _index = 0),
            onOpenFavorites: () => setState(() => _index = 1),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF382F29)
                  : const Color(0xFFEDE2D8),
            ),
          ),
        ),
        child: NavigationBar(
          height: 68,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: s.t('nav_home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.bookmark_border_rounded),
              selectedIcon: const Icon(Icons.bookmark_rounded),
              label: s.t('nav_favorites'),
            ),
            NavigationDestination(
              icon: Badge(
                label: Text('$pending'),
                isLabelVisible: pending > 0,
                child: const Icon(Icons.shopping_basket_outlined),
              ),
              selectedIcon: Badge(
                label: Text('$pending'),
                isLabelVisible: pending > 0,
                child: const Icon(Icons.shopping_basket),
              ),
              label: s.t('nav_shopping'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: s.t('nav_profile'),
            ),
          ],
        ),
      ),
    );
  }
}
