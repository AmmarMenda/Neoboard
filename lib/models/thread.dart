// models/thread.dart
class Thread {
  final int? id; // This will now be a Unix timestamp
  final String title;
  final String content;
  final String? imagePath;
  final String board;
  final int replies;
  final DateTime createdAt;

  Thread({
    int? id,
    required this.title,
    required this.content,
    this.imagePath,
    required this.board,
    this.replies = 0,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unix timestamp in seconds
       createdAt = createdAt ?? DateTime.now();

  // Convert Thread to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'board': board,
      'replies': replies,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create Thread from Map
  factory Thread.fromMap(Map<String, dynamic> map) {
    return Thread(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      imagePath: map['imagePath'],
      board: map['board'],
      replies: map['replies'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Create a copy with updated values
  Thread copyWith({
    int? id,
    String? title,
    String? content,
    String? imagePath,
    String? board,
    int? replies,
    DateTime? createdAt,
  }) {
    return Thread(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      board: board ?? this.board,
      replies: replies ?? this.replies,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper method to get formatted ID
  String get formattedId => 'No.$id';
}
