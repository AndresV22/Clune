import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:clune/models/article.dart';
import 'package:clune/utils/enums.dart';

/// Repositorio de artículos educativos (JSON local, migrable a Firebase).
class ArticleRepository {
  ArticlesData? _cachedData;

  /// Carga artículos desde el asset JSON local.
  Future<ArticlesData> loadArticles() async {
    if (_cachedData != null) return _cachedData!;
    final jsonString = await rootBundle.loadString('assets/articles/articles.json');
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    _cachedData = ArticlesData.fromJson(json);
    return _cachedData!;
  }

  /// Obtiene todas las categorías.
  Future<List<ArticleCategory>> getCategories() async {
    final data = await loadArticles();
    return data.categories;
  }

  /// Busca un artículo por id en todas las categorías.
  Future<Article?> getArticleById(String articleId) async {
    final data = await loadArticles();
    for (final category in data.categories) {
      for (final article in category.articles) {
        if (article.id == articleId) return article;
      }
    }
    return null;
  }

  /// Limpia caché (útil al migrar a Firebase).
  void clearCache() {
    _cachedData = null;
  }

  /// Artículos sugeridos según fase o sub-fase del ciclo.
  Future<List<Article>> getSuggestedArticles({
    CyclePhase? phase,
    CycleSubPhase? subPhase,
    int limit = 3,
  }) async {
    final ids = _articleIdsFor(subPhase: subPhase, phase: phase);
    final data = await loadArticles();
    final articles = <Article>[];

    for (final id in ids) {
      final article = await _findArticleById(data, id);
      if (article != null) articles.add(article);
      if (articles.length >= limit) break;
    }
    return articles;
  }

  List<String> _articleIdsFor({CycleSubPhase? subPhase, CyclePhase? phase}) {
    if (subPhase != null) {
      switch (subPhase) {
        case CycleSubPhase.earlyMenstruation:
          return ['cramps', 'what-is-cycle', 'sleep'];
        case CycleSubPhase.earlyFollicular:
          return ['cycle-phases', 'nutrition', 'exercise'];
        case CycleSubPhase.lateFollicular:
          return ['cycle-phases', 'fertility', 'nutrition'];
        case CycleSubPhase.ovulation:
          return ['fertility', 'ovulation-pregnancy', 'contraceptives'];
        case CycleSubPhase.earlyLuteal:
          return ['pms', 'sleep', 'nutrition'];
        case CycleSubPhase.lateLuteal:
          return ['pms', 'migraines', 'sleep'];
      }
    }
    switch (phase) {
      case CyclePhase.menstruation:
        return ['cramps', 'what-is-cycle'];
      case CyclePhase.follicular:
        return ['cycle-phases', 'nutrition'];
      case CyclePhase.ovulation:
        return ['fertility', 'ovulation-pregnancy'];
      case CyclePhase.luteal:
        return ['pms', 'sleep'];
      case null:
        return ['what-is-cycle'];
    }
  }

  Future<Article?> _findArticleById(ArticlesData data, String articleId) async {
    for (final category in data.categories) {
      for (final article in category.articles) {
        if (article.id == articleId) return article;
      }
    }
    return null;
  }
}
