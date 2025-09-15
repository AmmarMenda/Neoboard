// lib/models/board.dart
class Board {
  final String path; // The board identifier, e.g., '/b/'
  final String name;
  final String description;
  final String imageUrl;

  const Board({
    required this.path,
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}
