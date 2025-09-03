// lib/services/coordinator_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coordinator_application.dart';

class CoordinatorService {
  // Replace with your actual server URL
  static const String baseUrl = 'http://0.0.0.0';
  static Future<List<CoordinatorApplication>>
  getCoordinatorApplications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_coordinator_applications.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final List<dynamic> applicationsJson = data['data'] ?? [];
          return applicationsJson
              .map((json) => CoordinatorApplication.fromJson(json))
              .toList();
        } else {
          throw Exception(data['error'] ?? 'Failed to fetch applications');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<bool> updateApplicationStatus(
    String applicationId,
    CoordinatorStatus status,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_coordinator_status.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': applicationId, 'status': status.name}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
