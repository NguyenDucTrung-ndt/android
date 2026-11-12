import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
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
        children: const [
          HomeScreen(),
          FavoritesScreen(),
          ShoppingScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: s.t('nav_home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
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
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: s.t('nav_settings'),
          ),
        ],
      ),
    );
  }
}
