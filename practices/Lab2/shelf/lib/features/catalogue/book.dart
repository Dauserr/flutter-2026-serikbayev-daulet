class BookAuthor {
  const BookAuthor({required this.name, this.key});

  final String name;
  final String? key;

  factory BookAuthor.fromJson(Map<String, dynamic> json) {
    return BookAuthor(
      name: json['name'] as String? ?? 'Unknown author',
      key: json['key'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'key': key};
}

class Book {
  const Book({
    required this.key,
    required this.title,
    required this.authors,
    required this.coverId,
    required this.firstPublishYear,
    required this.editionCount,
    required this.ebookAccess,
    required this.languages,
  });

  final String key;
  final String title;
  final List<BookAuthor> authors;
  final int? coverId;
  final int? firstPublishYear;
  final int editionCount;
  final String ebookAccess;
  final List<String> languages;

  String? get coverUrl {
    final id = coverId;
    if (id == null) return null;
    return 'https://covers.openlibrary.org/b/id/$id-M.jpg';
  }

  String get openLibraryUrl => 'https://openlibrary.org$key';

  factory Book.fromJson(Map<String, dynamic> json) {
    final names = json['author_name'] as List<dynamic>? ?? const [];
    final keys = json['author_key'] as List<dynamic>? ?? const [];
    final languageValues = json['language'] as List<dynamic>? ?? const [];

    return Book(
      key: json['key'] as String,
      title: json['title'] as String,
      authors: [
        for (var index = 0; index < names.length; index++)
          BookAuthor.fromJson({
            'name': names[index],
            'key': index < keys.length ? keys[index] : null,
          }),
      ],
      coverId: json['cover_i'] as int?,
      firstPublishYear: json['first_publish_year'] as int?,
      editionCount: (json['edition_count'] as num?)?.toInt() ?? 0,
      ebookAccess: json['ebook_access'] as String? ?? 'unknown',
      languages: languageValues.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'author_name': [for (final author in authors) author.name],
      'author_key': [
        for (final author in authors)
          if (author.key != null) author.key,
      ],
      'cover_i': coverId,
      'first_publish_year': firstPublishYear,
      'edition_count': editionCount,
      'ebook_access': ebookAccess,
      'language': languages,
    };
  }

  Book copyWith({
    String? key,
    String? title,
    List<BookAuthor>? authors,
    int? coverId,
    int? firstPublishYear,
    int? editionCount,
    String? ebookAccess,
    List<String>? languages,
  }) {
    return Book(
      key: key ?? this.key,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      coverId: coverId ?? this.coverId,
      firstPublishYear: firstPublishYear ?? this.firstPublishYear,
      editionCount: editionCount ?? this.editionCount,
      ebookAccess: ebookAccess ?? this.ebookAccess,
      languages: languages ?? this.languages,
    );
  }
}
