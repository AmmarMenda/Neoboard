// lib/backend/coordinator_form_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CoordinatorFormService {
  // Replace with your actual server URL
  static const String baseUrl = 'http://0.0.0.0'; // Update this!
  // For local XAMPP use: 'http://localhost/your-project'
  // For local network use: 'http://192.168.1.100/your-project'

  static Future<Map<String, dynamic>> submitCoordinatorForm({
    required String name,
    required String enrollmentNo,
    required String division,
    required String department,
    required XFile idCardImage,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$baseUrl/coordinator_application.php',
        ), // Your existing PHP file
      );

      // Add form fields
      request.fields['name'] = name;
      request.fields['enrollment_no'] = enrollmentNo;
      request.fields['division'] = division;
      request.fields['department'] = department;

      // Add image file
      var imageFile = await http.MultipartFile.fromPath(
        'id_card', // This matches the $_FILES["id_card"] in your PHP
        idCardImage.path,
        filename: 'id_card_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(imageFile);

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
