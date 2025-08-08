class Reply {
  final String id;
  final String content;
  final String? imagePath; // <-- ADD THIS

  Reply({
    required this.id,
    required this.content,
    this.imagePath, // <-- ADD THIS
  });
}
