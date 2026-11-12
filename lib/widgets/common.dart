import 'package:flutter/material.dart';

import '../models.dart';

/// Màu đặc trưng cho từng loại món ăn.
Color categoryColor(Category c) {
  switch (c) {
    case Category.main:
      return const Color(0xFFFF7043);
    case Category.soup:
      return const Color(0xFF42A5F5);
    case Category.appetizer:
      return const Color(0xFF66BB6A);
    case Category.dessert:
      return const Color(0xFFEC407A);
    case Category.drink:
      return const Color(0xFFAB47BC);
  }
}

/// Ô vuông bo góc hiển thị emoji đại diện món ăn.
class EmojiBox extends StatelessWidget {
  const EmojiBox({
    super.key,
    required this.emoji,
    required this.color,
    this.size = 64,
  });

  final String emoji;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}

/// Dòng thông tin nhỏ gồm icon và chữ.
class MiniInfo extends StatelessWidget {
  const MiniInfo({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}

/// Trạng thái rỗng dùng chung cho các danh sách.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: color),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tiêu đề từng phần trong màn hình.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
