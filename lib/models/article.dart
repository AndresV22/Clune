/// Estadística verificada mostrada en artículos educativos.
class ArticleStat {
  final String label;
  final String value;
  final String source;

  const ArticleStat({
    required this.label,
    required this.value,
    required this.source,
  });

  factory ArticleStat.fromJson(Map<String, dynamic> json) {
    return ArticleStat(
      label: json['label'] as String,
      value: json['value'] as String,
      source: json['source'] as String,
    );
  }
}

/// Sección estructurada dentro de un artículo.
class ArticleSection {
  final String title;
  final String content;

  const ArticleSection({
    required this.title,
    required this.content,
  });

  factory ArticleSection.fromJson(Map<String, dynamic> json) {
    return ArticleSection(
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}

/// Referencia bibliográfica de un artículo.
class ArticleSource {
  final String name;
  final String url;

  const ArticleSource({
    required this.name,
    required this.url,
  });

  factory ArticleSource.fromJson(Map<String, dynamic> json) {
    return ArticleSource(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}

/// Modelo de artículo educativo (cargado desde JSON local).
class Article {
  final String id;
  final String title;
  final String subtitle;
  final String body;
  final List<ArticleSection> sections;
  final List<ArticleStat> stats;
  final List<ArticleSource> sources;
  final int readingTimeMinutes;

  const Article({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.body,
    this.sections = const [],
    this.stats = const [],
    this.sources = const [],
    this.readingTimeMinutes = 0,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      body: json['body'] as String? ?? '',
      sections: (json['sections'] as List<dynamic>?)
              ?.map((s) => ArticleSection.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      stats: (json['stats'] as List<dynamic>?)
              ?.map((s) => ArticleStat.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      sources: (json['sources'] as List<dynamic>?)
              ?.map((s) => ArticleSource.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      readingTimeMinutes: json['readingTimeMinutes'] as int? ?? 0,
    );
  }
}

/// Categoría de artículos educativos.
class ArticleCategory {
  final String id;
  final String title;
  final List<Article> articles;

  const ArticleCategory({
    required this.id,
    required this.title,
    required this.articles,
  });

  factory ArticleCategory.fromJson(Map<String, dynamic> json) {
    return ArticleCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      articles: (json['articles'] as List<dynamic>)
          .map((a) => Article.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Contenedor raíz del JSON de artículos.
class ArticlesData {
  final List<ArticleCategory> categories;

  const ArticlesData({required this.categories});

  factory ArticlesData.fromJson(Map<String, dynamic> json) {
    return ArticlesData(
      categories: (json['categories'] as List<dynamic>)
          .map((c) => ArticleCategory.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
