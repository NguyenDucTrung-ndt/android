import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../widgets/common.dart';
import 'about_screen.dart';

/// Cài đặt: ngôn ngữ, chế độ tối, thông tin nhóm, giới thiệu ứng dụng.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.t('settings_title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionTitle(s.t('language')),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'vi',
                label: Text(s.t('lang_vi')),
                icon: const Icon(Icons.translate),
              ),
              ButtonSegment(
                value: 'en',
                label: Text(s.t('lang_en')),
                icon: const Icon(Icons.language),
              ),
            ],
            selected: {state.lang},
            onSelectionChanged: (set) => state.setLang(set.first),
          ),
          SectionTitle(s.t('appearance')),
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: Text(s.t('dark_mode')),
              value: state.themeMode == ThemeMode.dark,
              onChanged: state.setDarkMode,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.groups_outlined),
                  title: Text(s.t('team_info')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(s.t('about_app')),
                  subtitle: Text('${s.t('version')} 1.0.0'),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: s.t('app_name'),
                    applicationVersion: '1.0.0',
                    applicationIcon: const EmojiBox(
                      emoji: '🍳',
                      color: Colors.deepOrange,
                      size: 48,
                    ),
                    children: [
                      const SizedBox(height: 12),
                      Text(s.t('about_app_desc')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
