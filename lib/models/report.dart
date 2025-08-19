// lib/models/report.dart

class Report {
  final int? id;
  final String reportType;
  final int targetId;
  final String reason;
  final String? description;
  final String status;
  final DateTime createdAt;
  final String reportedContent;
  
  // --- ADD THIS LINE ---
  // The URL of the image associated with the reported content. It's nullable.
  final String? reportedImageUrl;

  Report({
    this.id,
    required this.reportType,
    required this.targetId,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
    required this.reportedContent,
    // --- AND ADD THIS LINE ---
    this.reportedImageUrl,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int?,
      reportType: json['report_type'] as String,
      targetId: json['target_id'] as int,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at']),
      reportedContent: json['reported_content'] as String,
      // --- AND FINALLY, ADD THIS LINE ---
      // This maps the 'reported_image_path' key from the JSON to our model field.
      reportedImageUrl: json['reported_image_path'] as String?,
    );
  }
}
