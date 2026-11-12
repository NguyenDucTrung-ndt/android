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
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE65100),
      brightness: brightness,
    ),
    appBarTheme: const AppBarTheme(centerTitle: false),
  );
}
