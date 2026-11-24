class ShelfEntry {
  const ShelfEntry({
    required this.id,
    required this.bookKey,
    required this.title,
    required this.authors,
    required this.status,
    required this.rating,
    required this.pagesRead,
    required this.notes,
    required this.targetDate,
    required this.finished,
  });

  final String? id;
  final String bookKey;
  final String title;
  final String authors;
  final String status;
  final double? rating;
  final int pagesRead;
  final String notes;
  final DateTime targetDate;
  final bool finished;

  factory ShelfEntry.fromApi(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return ShelfEntry(
      id: json['id'] as String?,
      bookKey: data['bookKey'] as String,
      title: data['title'] as String,
      authors: data['authors'] as String,
      status: data['status'] as String,
      rating: (data['rating'] as num?)?.toDouble(),
      pagesRead: (data['pagesRead'] as num).toInt(),
      notes: data['notes'] as String? ?? '',
      targetDate: DateTime.parse(data['targetDate'] as String),
      finished: data['finished'] as bool? ?? false,
    );
  }

  factory ShelfEntry.fromJson(Map<String, dynamic> json) {
    return ShelfEntry(
      id: json['id'] as String?,
      bookKey: json['bookKey'] as String,
      title: json['title'] as String,
      authors: json['authors'] as String,
      status: json['status'] as String,
      rating: (json['rating'] as num?)?.toDouble(),
      pagesRead: (json['pagesRead'] as num).toInt(),
      notes: json['notes'] as String? ?? '',
      targetDate: DateTime.parse(json['targetDate'] as String),
      finished: json['finished'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookKey': bookKey,
      'title': title,
      'authors': authors,
      'status': status,
      'rating': rating,
      'pagesRead': pagesRead,
      'notes': notes,
      'targetDate': targetDate.toIso8601String(),
      'finished': finished,
    };
  }

  Map<String, dynamic> toApiJson() {
    return {'name': title, 'data': toJson()};
  }

  ShelfEntry copyWith({
    String? id,
    String? bookKey,
    String? title,
    String? authors,
    String? status,
    double? rating,
    int? pagesRead,
    String? notes,
    DateTime? targetDate,
    bool? finished,
  }) {
    return ShelfEntry(
      id: id ?? this.id,
      bookKey: bookKey ?? this.bookKey,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      pagesRead: pagesRead ?? this.pagesRead,
      notes: notes ?? this.notes,
      targetDate: targetDate ?? this.targetDate,
      finished: finished ?? this.finished,
    );
  }
}
