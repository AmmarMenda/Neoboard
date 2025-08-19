// lib/models/post.dart

class Post {
  final int id;
  final int threadId;
  final String content;
  final String? imagePath;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.threadId,
    required this.content,
    this.imagePath,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: int.parse(json['id'].toString()),
      threadId: int.parse(json['thread_id'].toString()),
      content: json['content'] ?? '',
      imagePath: json['image_path'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thread_id': threadId,
      'content': content,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get formattedId => 'No.$id';
}
