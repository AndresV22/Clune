import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/app_text_styles.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/models/article.dart';

/// Tarjeta de artículo educativo en listas.
class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: clune.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: clune.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: AppTextStyles.label.copyWith(color: clune.textPrimary),
                  ),
                  if (article.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      article.subtitle,
                      style: AppTextStyles.bodySmall.copyWith(color: clune.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (article.readingTimeMinutes > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      'article_reading_time'.trParams({
                        'min': '${article.readingTimeMinutes}',
                      }),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryTeal,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: clune.textSecondary),
          ],
        ),
      ),
    );
  }
}
