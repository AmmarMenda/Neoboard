// models/report.dart
class Report {
  final int? id;
  final String reportType; // 'thread' or 'reply'
  final int targetId; // ID of the thread or post being reported
  final String reason; // Predefined reason category
  final String? description; // Optional additional description
  final DateTime createdAt;
  final String status; // 'pending', 'reviewed', 'dismissed'

  Report({
    this.id,
    required this.reportType,
    required this.targetId,
    required this.reason,
    this.description,
    DateTime? createdAt,
    this.status = 'pending',
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reportType': reportType,
      'targetId': targetId,
      'reason': reason,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'status': status,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      reportType: map['reportType'],
      targetId: map['targetId'],
      reason: map['reason'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      status: map['status'] ?? 'pending',
    );
  }

  Report copyWith({
    int? id,
    String? reportType,
    int? targetId,
    String? reason,
    String? description,
    DateTime? createdAt,
    String? status,
  }) {
    return Report(
      id: id ?? this.id,
      reportType: reportType ?? this.reportType,
      targetId: targetId ?? this.targetId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
