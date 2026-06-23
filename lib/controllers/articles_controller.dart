import 'package:get/get.dart';
import 'package:clune/models/article.dart';
import 'package:clune/repositories/article_repository.dart';

/// Controlador de artículos educativos.
class ArticlesController extends GetxController {
  final ArticleRepository _articleRepo = Get.find();

  /// Categorías cargadas.
  final categories = <ArticleCategory>[].obs;

  /// Categoría seleccionada.
  final selectedCategory = Rxn<ArticleCategory>();

  /// Artículo seleccionado para detalle.
  final selectedArticle = Rxn<Article>();

  /// Indica carga en progreso.
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadArticles();
  }

  /// Carga categorías desde JSON local.
  Future<void> loadArticles() async {
    isLoading.value = true;
    categories.value = await _articleRepo.getCategories();
    isLoading.value = false;
  }

  /// Selecciona una categoría para ver sus artículos.
  void selectCategory(ArticleCategory category) {
    selectedCategory.value = category;
  }

  /// Selecciona un artículo para ver detalle.
  void selectArticle(Article article) {
    selectedArticle.value = article;
  }

  /// Vuelve a la lista de categorías.
  void backToCategories() {
    selectedCategory.value = null;
    selectedArticle.value = null;
  }

  /// Vuelve a la lista de artículos de la categoría.
  void backToArticles() {
    selectedArticle.value = null;
  }
}
