import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_state.dart';
import 'l10n/strings.dart';
import 'screens/main_shell.dart';

void main() => runApp(const RecipeApp());

class RecipeApp extends StatefulWidget {
  const RecipeApp({super.key});

  @override
  State<RecipeApp> createState() => _RecipeAppState();
}

class _RecipeAppState extends State<RecipeApp> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: Builder(
        builder: (context) {
          final state = AppScope.of(context);
          return MaterialApp(
            title: S(state.lang).t('app_name'),
            debugShowCheckedModeBanner: false,
            scrollBehavior: const _AppScrollBehavior(),
            locale: state.locale,
            supportedLocales: const [Locale('vi'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: state.themeMode,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            home: const MainShell(),
          );
        },
      ),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  const seed = Color(0xFFEF6C00);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    surface: isDark ? const Color(0xFF1A1614) : const Color(0xFFFDF8F3),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        isDark ? const Color(0xFF171311) : const Color(0xFFFDF8F3),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor:
          isDark ? const Color(0xFF171311) : const Color(0xFFFDF8F3),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF241E1B) : Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF382F29) : const Color(0xFFEFE4D9),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark ? const Color(0xFF211C19) : Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: isDark
          ? const Color(0xFFEF6C00).withValues(alpha: 0.22)
          : const Color(0xFFFFEDE0),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFFE65100), size: 24);
        }
        return IconThemeData(
          color: isDark ? const Color(0xFFB5A99F) : const Color(0xFF6D5E55),
          size: 24,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE65100),
          );
        }
        return TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFFB5A99F) : const Color(0xFF6D5E55),
        );
      }),
    ),
  );
}

/// Hỗ trợ thao tác vuốt/kéo mượt bằng cả cảm ứng, trackpad và chuột trên trình duyệt.
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
