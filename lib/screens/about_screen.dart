import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/strings.dart';
import '../team_info.dart';
import '../widgets/common.dart';

/// Trang thông tin nhóm (yêu cầu của đề bài).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;

    Widget infoRow(IconData icon, String label, String value) {
      return ListTile(
        dense: true,
        leading: Icon(icon, color: scheme.primary),
        title: Text(label, style: Theme.of(context).textTheme.labelMedium),
        subtitle: Text(value, style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.t('about_title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                const EmojiBox(
                  emoji: '🍳',
                  color: Colors.deepOrange,
                  size: 88,
                ),
                const SizedBox(height: 12),
                Text(
                  s.t('app_name'),
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                infoRow(Icons.assignment_outlined, s.t('project'),
                    s.t('project_name')),
                infoRow(Icons.menu_book_outlined, s.t('course'),
                    s.t('course_name')),
                infoRow(Icons.school_outlined, s.t('university'),
                    s.t('university_name')),
                infoRow(Icons.class_outlined, s.t('class_code'),
                    '$kClassCode - $kTeamName'),
                infoRow(Icons.code, s.t('source_code'), kGithubUrl),
              ],
            ),
          ),
          SectionTitle(s.t('members')),
          for (final m in kTeamMembers)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: const Icon(Icons.person),
                ),
                title: Text(m.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${s.t('student_id')}: ${m.studentId}\n'
                  '${s.t('role')}: ${m.role.get(AppScope.of(context).lang)}',
                ),
                isThreeLine: true,
              ),
            ),
        ],
      ),
    );
  }
}
