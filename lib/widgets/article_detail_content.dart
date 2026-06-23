import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/app_text_styles.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/models/article.dart';
import 'package:clune/widgets/article_stat_card.dart';

/// Contenido enriquecido de un artículo educativo.
class ArticleDetailContent extends StatelessWidget {
  final Article article;

  const ArticleDetailContent({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            style: AppTextStyles.headingLarge.copyWith(color: clune.textPrimary),
          ),
          if (article.subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              article.subtitle,
              style: AppTextStyles.bodyMedium.copyWith(color: clune.textSecondary),
            ),
          ],
          if (article.readingTimeMinutes > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'article_reading_time'.trParams({'min': '${article.readingTimeMinutes}'}),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (article.stats.isNotEmpty) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: article.stats.length,
                separatorBuilder: (_, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) =>
                    ArticleStatCard(stat: article.stats[index]),
              ),
            ),
          ],
          if (article.body.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              article.body,
              style: AppTextStyles.bodyLarge.copyWith(
                height: 1.6,
                color: clune.textPrimary,
              ),
            ),
          ],
          ...article.sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: AppTextStyles.label.copyWith(
                      color: clune.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    section.content,
                    style: AppTextStyles.bodyLarge.copyWith(
                      height: 1.6,
                      color: clune.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (article.sources.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text(
              'article_sources'.tr,
              style: AppTextStyles.label.copyWith(color: clune.textPrimary),
            ),
            const SizedBox(height: 10),
            ...article.sources.map(
              (source) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _openUrl(source.url),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      Icon(Icons.link, size: 16, color: AppColors.primaryTeal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          source.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryTeal,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'article_disclaimer'.tr,
            style: AppTextStyles.bodySmall.copyWith(
              color: clune.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
