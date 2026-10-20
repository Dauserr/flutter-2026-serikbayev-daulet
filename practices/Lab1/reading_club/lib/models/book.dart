import 'package:flutter/material.dart';

enum Genre {
  fantasy('Fantasy', Icons.auto_awesome),
  scienceFiction('Sci-fi', Icons.rocket_launch),
  mystery('Mystery', Icons.search),
  nonfiction('Non-fiction', Icons.lightbulb_outline),
  classics('Classics', Icons.history_edu);

  const Genre(this.label, this.icon);
  final String label;
  final IconData icon;

  Color color(ColorScheme colors) => switch (this) {
    Genre.fantasy => colors.primaryContainer,
    Genre.scienceFiction => colors.secondaryContainer,
    Genre.mystery => colors.tertiaryContainer,
    Genre.nonfiction => colors.surfaceContainerHighest,
    Genre.classics => colors.errorContainer,
  };
}

sealed class Countdown {
  const Countdown();
}

class Upcoming extends Countdown {
  const Upcoming(this.duration);
  final Duration duration;
}

class Started extends Countdown {
  const Started(this.duration);
  final Duration duration;
}

class Ended extends Countdown {
  const Ended();
}

class Book {
  const Book._({
    required this.id,
    required this.title,
    required this.genre,
    required this.when,
    required this.limit,
    required this.place,
    required this._readers,
    required this.online,
    required this.description,
    required this.favourite,
  });

  factory Book({
    required String id,
    required String title,
    required Genre genre,
    required DateTime when,
    required int limit,
    required String place,
    List<String> readers = const [],
    bool online = false,
    String? description,
    bool favourite = false,
  }) => Book._(
    id: id,
    title: title,
    genre: genre,
    when: when,
    limit: limit,
    place: place,
    readers: List<String>.unmodifiable(readers),
    online: online,
    description: description,
    favourite: favourite,
  );

  factory Book.empty() {
    final now = DateTime.now();
    return Book(
      id: now.microsecondsSinceEpoch.toString(),
      title: '',
      genre: Genre.fantasy,
      when: now.add(const Duration(days: 1)),
      limit: 10,
      place: '',
    );
  }

  final String id;
  final String title;
  final Genre genre;
  final DateTime when;
  final int limit;
  final String place;
  final List<String> _readers;
  final bool online;
  final String? description;
  final bool favourite;

  List<String> get readers => _readers;
  int get count => _readers.length;
  int get freePlaces => limit - count;
  bool get isFull => count >= limit;
  bool get isPast => when.isBefore(DateTime.now());
  bool contains(String name) => _readers.any((reader) => reader == name);
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Countdown get countdown {
    final now = DateTime.now();
    if (now.isBefore(when)) return Upcoming(when.difference(now));
    final elapsed = now.difference(when);
    if (elapsed < const Duration(hours: 2)) return Started(elapsed);
    return const Ended();
  }

  Book copyWith({
    String? title,
    Genre? genre,
    DateTime? when,
    int? limit,
    String? place,
    List<String>? readers,
    bool? online,
    String? description,
    bool clearDescription = false,
    bool? favourite,
  }) => Book(
    id: id,
    title: title ?? this.title,
    genre: genre ?? this.genre,
    when: when ?? this.when,
    limit: limit ?? this.limit,
    place: place ?? this.place,
    readers: readers ?? _readers,
    online: online ?? this.online,
    description: clearDescription ? null : description ?? this.description,
    favourite: favourite ?? this.favourite,
  );
}
