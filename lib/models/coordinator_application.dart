// lib/models/coordinator_application.dart
class CoordinatorApplication {
  final String id;
  final String name;
  final String enrollmentNo;
  final String division;
  final String department;
  final String? idCardUrl;
  final CoordinatorStatus status;
  final DateTime createdAt;

  CoordinatorApplication({
    required this.id,
    required this.name,
    required this.enrollmentNo,
    required this.division,
    required this.department,
    this.idCardUrl,
    required this.status,
    required this.createdAt,
  });

  factory CoordinatorApplication.fromJson(Map<String, dynamic> json) {
    return CoordinatorApplication(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      enrollmentNo: json['enrollment_no'] ?? '',
      division: json['division'] ?? '',
      department: json['department'] ?? '',
      idCardUrl: json['id_card_url'],
      status: _statusFromString(json['status'] ?? 'pending'),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static CoordinatorStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return CoordinatorStatus.approved;
      case 'rejected':
        return CoordinatorStatus.rejected;
      default:
        return CoordinatorStatus.pending;
    }
  }

  CoordinatorApplication copyWith({
    String? id,
    String? name,
    String? enrollmentNo,
    String? division,
    String? department,
    String? idCardUrl,
    CoordinatorStatus? status,
    DateTime? createdAt,
  }) {
    return CoordinatorApplication(
      id: id ?? this.id,
      name: name ?? this.name,
      enrollmentNo: enrollmentNo ?? this.enrollmentNo,
      division: division ?? this.division,
      department: department ?? this.department,
      idCardUrl: idCardUrl ?? this.idCardUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum CoordinatorStatus { pending, approved, rejected }
