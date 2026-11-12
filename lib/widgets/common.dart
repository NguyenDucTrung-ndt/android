import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models.dart';

/// Màu đặc trưng cho từng loại món ăn.
Color categoryColor(Category c) {
  switch (c) {
    case Category.main:
      return const Color(0xFFEF6C00);
    case Category.soup:
      return const Color(0xFF1E88E5);
    case Category.appetizer:
      return const Color(0xFF43A047);
    case Category.dessert:
      return const Color(0xFFD81B60);
    case Category.drink:
      return const Color(0xFF8E24AA);
  }
}

/// Màu đặc trưng cho từng quốc gia / khu vực ẩm thực.
Color cuisineColor(Cuisine c) {
  switch (c) {
    case Cuisine.vietnamese:
      return const Color(0xFFEF6C00);
    case Cuisine.italian:
      return const Color(0xFFE53935);
    case Cuisine.european:
      return const Color(0xFF1E88E5);
    case Cuisine.japanese:
      return const Color(0xFF5E35B1);
    case Cuisine.korean:
      return const Color(0xFFD81B60);
    case Cuisine.thai:
      return const Color(0xFF00897B);
    case Cuisine.other:
      return const Color(0xFF6D4C41);
  }
}

/// Nhãn màu pastel hiển thị quốc gia / khu vực món ăn.
class CuisineBadge extends StatelessWidget {
  const CuisineBadge({super.key, required this.cuisine});

  final Cuisine cuisine;

  @override
  Widget build(BuildContext context) {
    final color = cuisineColor(cuisine);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.24 : 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        S.of(context).cuisine(cuisine),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? color.withValues(alpha: 0.95) : color,
        ),
      ),
    );
  }
}

/// Khung minh họa món ăn dạng đĩa sứ + nền gradient ấm áp.
class RecipeVisualBox extends StatelessWidget {
  const RecipeVisualBox({
    super.key,
    required this.emoji,
    required this.color,
    this.width,
    this.height,
    this.borderRadius = 14,
    this.emojiScale = 0.5,
  });

  final String emoji;
  final Color color;
  final double? width;
  final double? height;
  final double borderRadius;
  final double emojiScale;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: isDark ? 0.34 : 0.24),
              color.withValues(alpha: isDark ? 0.14 : 0.08),
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final shortest = constraints.biggest.shortestSide;
            final boxSize = shortest.isFinite && shortest > 0 ? shortest : 64.0;
            final plateSize = boxSize * 0.72;
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  right: -boxSize * 0.18,
                  top: -boxSize * 0.18,
                  child: Container(
                    width: boxSize * 0.55,
                    height: boxSize * 0.55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: isDark ? 0.18 : 0.12),
                    ),
                  ),
                ),
                Container(
                  width: plateSize,
                  height: plateSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.24)
                        : Colors.white.withValues(alpha: 0.85),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.16),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: boxSize * emojiScale),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
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
    return RecipeVisualBox(
      emoji: emoji,
      color: color,
      width: size,
      height: size,
      borderRadius: 16,
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
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ),
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
      child: SingleChildScrollView(
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
  const SectionTitle(this.text, {super.key, this.trailing, this.icon});

  final String text;
  final Widget? trailing;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Row(
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
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
