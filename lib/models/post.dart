// models/post.dart
class Post {
  final int? id; // This will now be a Unix timestamp
  final int threadId;
  final String content;
  final String? imagePath;
  final DateTime createdAt;

  Post({
    int? id,
    required this.threadId,
    required this.content,
    this.imagePath,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unix timestamp in seconds
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'threadId': threadId,
      'content': content,
      'imagePath': imagePath,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      threadId: map['threadId'],
      content: map['content'],
      imagePath: map['imagePath'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Helper method to get formatted ID
  String get formattedId => 'No.$id';
}
