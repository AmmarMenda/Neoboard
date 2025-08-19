// lib/models/report.dart

class Report {
  final int? id;
  final String reportType; // 'thread' or 'reply'
  final int targetId;
  final String reason;
  final String? description;
  final String status;  // 'pending', 'reviewed', 'dismissed'
  final DateTime createdAt;

  Report({
    this.id,
    required this.reportType,
    required this.targetId,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      reportType: json['report_type'] ?? '',
      targetId: int.parse(json['target_id'].toString()),
      reason: json['reason'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_type': reportType,
      'target_id': targetId,
      'reason': reason,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
