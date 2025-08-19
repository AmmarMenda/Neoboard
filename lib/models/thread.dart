// lib/models/thread.dart

class Thread {
  final int id;
  final String title;
  final String content;
  final String board;
  final String? imagePath;
  final int replies;
  final DateTime createdAt;

  Thread({
    required this.id,
    required this.title,
    required this.content,
    required this.board,
    this.imagePath,
    required this.replies,
    required this.createdAt,
  });

  // Parsing from JSON
  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      board: json['board'] ?? '',
      imagePath: json['image_path'],
      replies: json['replies'] != null ? int.parse(json['replies'].toString()) : 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // To JSON (for sending data if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'board': board,
      'image_path': imagePath,
      'replies': replies,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get formattedId => 'No.$id';
}
