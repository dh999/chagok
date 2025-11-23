import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String icon;
  final String? subtitle;
  final double? progress;
  final Color color;
  final bool compact;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.progress,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? AppSizes.sm : AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Row(
            children: [
              Text(icon, style: TextStyle(fontSize: compact ? 20 : 24)),
              SizedBox(width: compact ? 6 : 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: compact ? 12 : 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: compact ? 4 : 8),

          // 값
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: compact ? 20 : 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: compact ? 11 : 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // 프로그레스 바
          if (progress != null) ...[
            SizedBox(height: compact ? 8 : 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress!.clamp(0, 1),
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: compact ? 6 : 8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
