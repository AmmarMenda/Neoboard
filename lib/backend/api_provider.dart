// lib/backend/api_provider.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/thread.dart';
import '../models/post.dart';
import '../models/report.dart';

class ApiProvider {
  final String baseUrl;

  ApiProvider({required this.baseUrl});

  // Fetch threads for a board, or all if board is null/empty
  Future<List<Thread>> fetchThreads({String? board}) async {
    final uri = board == null || board.isEmpty
        ? Uri.parse('$baseUrl/threads.php')
        : Uri.parse('$baseUrl/threads.php?board=$board');

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch threads');
    }

    final data = json.decode(res.body) as List<dynamic>;
    return data.map((json) => Thread.fromJson(json)).toList();
  }

  // Create a new thread, with optional image file
  Future<int> createThread({
    required String title,
    required String content,
    required String board,
    File? image,
  }) async {
    final uri = Uri.parse('$baseUrl/thread_create.php');
    final req = http.MultipartRequest('POST', uri);

    req.fields['title'] = title;
    req.fields['content'] = content;
    req.fields['board'] = board;

    if (image != null) {
      final multipartFile = await http.MultipartFile.fromPath('image', image.path);
      req.files.add(multipartFile);
    }

    final streamedRes = await req.send();
    final res = await http.Response.fromStream(streamedRes);

    if (res.statusCode != 200) {
      throw Exception('Failed to create thread');
    }

    final jsonData = json.decode(res.body);
    if (jsonData['success'] != true) {
      throw Exception(jsonData['error'] ?? 'Unknown error');
    }

    return int.parse(jsonData['thread_id'].toString());
  }

  // Fetch replies for a given thread
  Future<List<Post>> fetchReplies(int threadId) async {
    final uri = Uri.parse('$baseUrl/replies.php?thread_id=$threadId');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch replies');
    }

    final data = json.decode(res.body) as List<dynamic>;
    return data.map((json) => Post.fromJson(json)).toList();
  }

  // Post a reply to a thread, optional image
  Future<int> createReply({
    required int threadId,
    required String content,
    File? image,
  }) async {
    final uri = Uri.parse('$baseUrl/reply_create.php');
    final req = http.MultipartRequest('POST', uri);

    req.fields['thread_id'] = threadId.toString();
    req.fields['content'] = content;

    if (image != null) {
      final multipartFile = await http.MultipartFile.fromPath('image', image.path);
      req.files.add(multipartFile);
    }

    final streamedRes = await req.send();
    final res = await http.Response.fromStream(streamedRes);

    if (res.statusCode != 200) {
      throw Exception('Failed to create reply');
    }

    final jsonData = json.decode(res.body);
    if (jsonData['success'] != true) {
      throw Exception(jsonData['error'] ?? 'Unknown error');
    }

    return int.parse(jsonData['reply_id'].toString());
  }

  // Fetch reports, optional filter by status
  Future<List<Report>> fetchReports({String? status}) async {
    final uri = (status == null || status.isEmpty || status == 'all')
        ? Uri.parse('$baseUrl/reports.php')
        : Uri.parse('$baseUrl/reports.php?status=$status');

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch reports');
    }

    final data = json.decode(res.body) as List<dynamic>;
    return data.map((json) => Report.fromJson(json)).toList();
  }

  // Update report status
  Future<void> updateReportStatus(int reportId, String status) async {
    final uri = Uri.parse('$baseUrl/report_update.php');
    final res = await http.post(uri, body: {
      'id': reportId.toString(),
      'status': status,
    });

    if (res.statusCode != 200) {
      throw Exception('Failed to update report');
    }

    final jsonData = json.decode(res.body);
    if (jsonData['success'] != true) {
      throw Exception(jsonData['error'] ?? 'Unknown error');
    }
  }

  // Delete report
  Future<void> deleteReport(int reportId) async {
    final uri = Uri.parse('$baseUrl/report_delete.php');
    final res = await http.post(uri, body: {
      'id': reportId.toString(),
    });

    if (res.statusCode != 200) {
      throw Exception('Failed to delete report');
    }

    final jsonData = json.decode(res.body);
    if (jsonData['success'] != true) {
      throw Exception(jsonData['error'] ?? 'Unknown error');
    }
  }

  // Delete thread
  Future<void> deleteThread(int threadId) async {
    final uri = Uri.parse('$baseUrl/thread_delete.php');
    final res = await http.post(uri, body: {
      'id': threadId.toString(),
    });

    if (res.statusCode != 200) {
      throw Exception('Failed to delete thread');
    }

    final jsonData = json.decode(res.body);
    if (jsonData['success'] != true) {
      throw Exception(jsonData['error'] ?? 'Unknown error');
    }
  }

  // Simple login example, returns token string or throws
  Future<String> login(String username, String password) async {
    final uri = Uri.parse('$baseUrl/login.php');
    final res = await http.post(uri, body: {
      'username': username,
      'password': password,
    });

    if (res.statusCode != 200) {
      throw Exception('Login request failed');
    }

    final jsonData = json.decode(res.body);
    if (jsonData['success'] != true) {
      throw Exception(jsonData['error'] ?? 'Wrong credentials');
    }

    return jsonData['token'] as String;
  }
}
