import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/controllers/articles_controller.dart';
import 'package:clune/widgets/article_card.dart';
import 'package:clune/widgets/article_detail_content.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/app_text_styles.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
/// Vista de artículos educativos por categoría.
class ArticlesView extends GetView<ArticlesController> {
  const ArticlesView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryTeal),
          );
        }

        if (controller.selectedArticle.value != null) {
          return _ArticleDetailContent(
            onBack: controller.backToArticles,
          );
        }

        if (controller.selectedCategory.value != null) {
          return _CategoryArticlesList(
            onBack: controller.backToCategories,
          );
        }

        return _CategoriesList();
      }),
    );
  }
}

class _CategoriesList extends GetView<ArticlesController> {
  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'articles_title'.tr,
            style: AppTextStyles.headingMedium.copyWith(color: clune.textPrimary),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return GestureDetector(
                onTap: () => controller.selectCategory(category),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: clune.chipBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(_iconForCategory(category.id), color: AppColors.primaryTeal),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          category.title,
                          style: AppTextStyles.label.copyWith(color: clune.textPrimary),
                        ),
                      ),
                      Text(
                        '${category.articles.length}',
                        style: AppTextStyles.bodySmall.copyWith(color: clune.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: clune.textSecondary),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _iconForCategory(String id) {
    switch (id) {
      case 'menstruation':
        return Icons.water_drop_outlined;
      case 'sexual_health':
        return Icons.favorite_outline;
      case 'pregnancy':
        return Icons.child_care_outlined;
      case 'wellness':
        return Icons.spa_outlined;
      case 'symptoms':
        return Icons.healing_outlined;
      default:
        return Icons.article_outlined;
    }
  }
}

class _CategoryArticlesList extends GetView<ArticlesController> {
  final VoidCallback onBack;

  const _CategoryArticlesList({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    final category = controller.selectedCategory.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
              Expanded(
                child: Text(
                  category.title,
                  style: AppTextStyles.headingMedium.copyWith(color: clune.textPrimary),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: category.articles.length,
            itemBuilder: (context, index) {
              final article = category.articles[index];
              return ArticleCard(
                article: article,
                onTap: () => controller.selectArticle(article),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ArticleDetailContent extends GetView<ArticlesController> {
  final VoidCallback onBack;

  const _ArticleDetailContent({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final article = controller.selectedArticle.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            ],
          ),
        ),
        Expanded(child: ArticleDetailContent(article: article)),
      ],
    );
  }
}
