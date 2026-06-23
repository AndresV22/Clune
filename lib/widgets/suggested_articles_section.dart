import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/app/routes/app_routes.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/controllers/articles_controller.dart';
import 'package:clune/models/article.dart';
import 'package:clune/widgets/article_card.dart';

/// Sección horizontal de artículos sugeridos según la fase del ciclo.
class SuggestedArticlesSection extends StatelessWidget {
  final List<Article> articles;
  final VoidCallback? onSeeAll;

  const SuggestedArticlesSection({
    super.key,
    required this.articles,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();

    final clune = context.clune;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('home_suggested_articles'.tr, style: clune.label),
            ),
            if (onSeeAll != null)
              TextButton(onPressed: onSeeAll, child: Text('see_all'.tr)),
          ],
        ),
        const SizedBox(height: 8),
        ...articles.map(
          (article) => ArticleCard(
            article: article,
            onTap: () => _openArticle(article),
          ),
        ),
      ],
    );
  }

  void _openArticle(Article article) {
    final controller = Get.find<ArticlesController>();
    controller.selectArticle(article);
    Get.toNamed(AppRoutes.articleDetail);
  }
}
