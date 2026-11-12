import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../widgets/common.dart';
import 'about_screen.dart';

/// Màn hình Cài đặt: Giao diện sáng/tối, Thông báo, Ngôn ngữ, Phiên bản và Đăng xuất.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickLanguage(BuildContext context) async {
    final state = AppScope.of(context);
    final s = S.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  s.t('language'),
                  style: Theme.of(ctx)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: const Icon(Icons.translate),
                title: Text(s.t('lang_vi')),
                trailing: state.lang == 'vi'
                    ? const Icon(Icons.check_circle, color: Color(0xFFEF6C00))
                    : null,
                onTap: () {
                  state.setLang('vi');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: const Icon(Icons.language),
                title: Text(s.t('lang_en')),
                trailing: state.lang == 'en'
                    ? const Icon(Icons.check_circle, color: Color(0xFFEF6C00))
                    : null,
                onTap: () {
                  state.setLang('en');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
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
    if (ok == true && context.mounted) {
      state.signOut();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = S.of(context);
    final theme = Theme.of(context);
    final isDark = state.themeMode == ThemeMode.dark;
    final dividerColor =
        isDark ? const Color(0xFF382F29) : const Color(0xFFF3EAE1);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          s.t('settings_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              s.t('appearance'),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                InkWell(
                  onTap: () => state.setDarkMode(false),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wb_sunny_outlined,
                          color: Color(0xFFF9A825),
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            s.t('light_mode'),
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        _ModeCheckBox(checked: !isDark),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
                InkWell(
                  onTap: () => state.setDarkMode(true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.nightlight_outlined,
                          color: Color(0xFFEF6C00),
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            s.t('dark_mode'),
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        _ModeCheckBox(checked: isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              s.t('notifications'),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.notifications_none_rounded, size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      s.t('receive_notifications'),
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Switch(
                    value: state.notificationsEnabled,
                    activeTrackColor: const Color(0xFFEF6C00),
                    onChanged: state.setNotificationsEnabled,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _pickLanguage(context),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(
                      Icons.language_rounded,
                      size: 22,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        s.t('language'),
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      state.lang == 'vi' ? s.t('lang_vi') : s.t('lang_en'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.colorScheme.outline,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                InkWell(
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.t('app_version'),
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          'v1.0.0',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.groups_outlined,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            s.t('team_info'),
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
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
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD84315),
                side: BorderSide(
                  color: isDark
                      ? const Color(0xFF8D5524)
                      : const Color(0xFFD9B89B),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(state.isSignedIn ? Icons.logout : Icons.login),
              label: Text(
                state.isSignedIn ? s.t('sign_out') : s.t('sign_in'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: () => _handleAuthAction(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCheckBox extends StatelessWidget {
  const _ModeCheckBox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: checked ? const Color(0xFFEF6C00) : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          width: 1.5,
          color: checked
              ? const Color(0xFFEF6C00)
              : (isDark ? const Color(0xFF6B5D53) : const Color(0xFFD5C8BC)),
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}
