import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/controllers/articles_controller.dart';
import 'package:clune/widgets/article_detail_content.dart';

/// Vista de detalle de artículo accesible por ruta nombrada.
class ArticleDetailView extends GetView<ArticlesController> {
  const ArticleDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final article = controller.selectedArticle.value;
    if (article == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ArticleDetailContent(article: article),
    );
  }
}
