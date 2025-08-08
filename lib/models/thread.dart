import 'reply.dart';

class Thread {
  final String id;
  final String boardId;
  final String title;
  final String content;
  final String? imagePath; // <-- ADD THIS
  final List<Reply> replies;

  Thread({
    required this.id,
    required this.boardId,
    required this.title,
    required this.content,
    this.imagePath, // <-- ADD THIS
    required this.replies,
  });
}
