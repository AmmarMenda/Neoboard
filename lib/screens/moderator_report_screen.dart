// lib/screens/moderator_reports_screen.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../models/report.dart';
import '../models/thread.dart';
import '../models/post.dart';
import '../widgets/report_card.dart';
import '../widgets/delete_report_dialog.dart';
import '../utils/responsive_helper.dart';

class ModeratorReportsScreen extends StatefulWidget {
  const ModeratorReportsScreen({super.key});

  @override
  State<ModeratorReportsScreen> createState() => _ModeratorReportsScreenState();
}

class _ModeratorReportsScreenState extends State<ModeratorReportsScreen> {
  static const String baseUrl = 'http://127.0.0.1:3441/';
  static const String apiUrl = '${baseUrl}api/';

  final List<String> statuses = ['all', 'pending', 'reviewed', 'dismissed'];
  String selectedStatus = 'pending';

  List<Report> reports = [];
  bool loading = false;
  bool error = false;
  String errorMessage = 'Failed to load reports';

  Map<int, dynamic> targetContents = {};
  Map<int, bool> loadingTargets = {};

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    // ... (This function remains the same)
  }

  Future<void> fetchReportedContent(Report report) async {
    // ... (This function remains the same)
  }

  // The method is named 'updateStatus' here
  Future<void> updateStatus(Report report, String newStatus) async {
    try {
      final res = await http.post(Uri.parse('${apiUrl}report_update.php'), body: {
        'id': (report.id ?? 0).toString(),
        'status': newStatus,
      });
      final data = json.decode(res.body);

      if (data['success'] == true) {
        fetchReports();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Report marked as $newStatus'), backgroundColor: Colors.green),
          );
        }
      } else {
        throw Exception(data['error'] ?? 'Update failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating report: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> deleteReport(Report report) async {
    // ... (This function remains the same)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Management', style: GoogleFonts.vt323(fontSize: 20)),
        backgroundColor: const Color(0xFFC0C0C0),
      ),
      body: Column(
        children: [
          // ... (Filter controls remain the same)
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error
                    ? Center(child: Text(errorMessage, style: GoogleFonts.vt323(fontSize: 18, color: Colors.red)))
                    : reports.isEmpty
                        ? Center(child: Text('No reports with status "$selectedStatus"', style: GoogleFonts.vt323(fontSize: 18, color: Colors.grey)))
                        : ListView.separated(
                            padding: const EdgeInsets.all(10),
                            itemCount: reports.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black26),
                            itemBuilder: (context, index) {
                              final report = reports[index];
                              final reportId = report.id ?? 0;
                              final content = targetContents[reportId];
                              final isLoadingContent = loadingTargets[reportId] ?? true;
                              return ReportCard(
                                report: report,
                                targetContent: content,
                                loadingContent: isLoadingContent,
                                // **THE FIX IS HERE**: Use the correct method name 'updateStatus'
                                onStatusChange: (status) => updateStatus(report, status),
                                onDelete: () => deleteReport(report),
                                baseUrl: baseUrl,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
