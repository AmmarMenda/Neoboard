// lib/screens/moderator_reports_screen.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/report.dart';
import '../models/thread.dart';
import '../models/post.dart';
import '../widgets/imageboard_text.dart';
import '../widgets/retro_button.dart' as retro;
import '../utils/responsive_helper.dart';

class ModeratorReportsScreen extends StatefulWidget {
  const ModeratorReportsScreen({super.key});

  @override
  State<ModeratorReportsScreen> createState() => _ModeratorReportsScreenState();
}

class _ModeratorReportsScreenState extends State<ModeratorReportsScreen> {
  static const String baseUrl = 'http://127.0.0.1:3441';

  final List<String> statuses = ['all', 'pending', 'reviewed', 'dismissed'];
  String selectedStatus = 'pending';

  List<Report> reports = [];
  bool loading = false;
  bool error = false;
  Map<int, dynamic> targetContents = {}; // Map<reportId, String> or cached targets
  Map<int, bool> loadingTargets = {};

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    setState(() {
      loading = true;
      error = false;
      targetContents.clear();
      loadingTargets.clear();
    });
    try {
      final uri = selectedStatus == 'all'
          ? Uri.parse('${baseUrl}reports.php')
          : Uri.parse('${baseUrl}reports.php?status=$selectedStatus');

      final res = await http.get(uri);
      if (res.statusCode != 200) {
        throw Exception('Failed to load reports');
      }

      final data = json.decode(res.body) as List;
      final loadedReports = data.map((json) => Report.fromJson(json)).toList();

      setState(() {
        reports = loadedReports;
        loading = false;
      });

      for (var report in loadedReports) {
        fetchReportedContent(report);
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching reports: $e');
      setState(() {
        loading = false;
        error = true;
      });
    }
  }

  Future<void> fetchReportedContent(Report report) async {
    setState(() {
      loadingTargets[report.id ?? 0] = true;
    });

    try {
      if (report.reportType == 'thread') {
        final res = await http.get(Uri.parse('${baseUrl}thread.php?id=${report.targetId}'));
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          final thread = Thread.fromJson(data);
          setState(() {
            targetContents[report.id ?? 0] = thread.title;
          });
        } else {
          setState(() {
            targetContents[report.id ?? 0] = '[Thread not found]';
          });
        }
      } else if (report.reportType == 'reply') {
        final res = await http.get(Uri.parse('${baseUrl}reply.php?id=${report.targetId}'));
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          final post = Post.fromJson(data);
          setState(() {
            targetContents[report.id ?? 0] = post.content.length > 100
                ? post.content.substring(0, 100) + '...'
                : post.content;
          });
        } else {
          setState(() {
            targetContents[report.id ?? 0] = '[Reply not found]';
          });
        }
      } else {
        setState(() {
          targetContents[report.id ?? 0] = '[Unknown report type]';
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching reported content: $e');
      setState(() {
        targetContents[report.id ?? 0] = '[Error loading content]';
      });
    } finally {
      setState(() {
        loadingTargets[report.id ?? 0] = false;
      });
    }
  }

  Future<void> updateReportStatus(Report report, String newStatus) async {
    try {
      final res = await http.post(Uri.parse('${baseUrl}report_update.php'), body: {
        'id': report.id.toString(),
        'status': newStatus,
      });
      final data = json.decode(res.body);

      if (data['success'] == true) {
        fetchReports();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report marked as $newStatus'), backgroundColor: Colors.green),
        );
      } else {
        throw Exception(data['error'] ?? 'Update failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating report: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> deleteReport(Report report) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => DeleteReportDialog(report: report),
        ) ??
        false;

    if (!ok) return;

    try {
      final res = await http.post(Uri.parse('${baseUrl}report_delete.php'), body: {
        'id': report.id.toString(),
      });
      final data = json.decode(res.body);

      if (data['success'] == true) {
        fetchReports();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report deleted'), backgroundColor: Colors.green));
      } else {
        throw Exception(data['error'] ?? 'Delete failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting report: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final small = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Report Management', style: GoogleFonts.vt323(fontSize: 20)),
        backgroundColor: const Color(0xFFC0C0C0),
      ),
      body: Column(
        children: [
          Container(
            padding: ResponsiveHelper.defaultPadding,
            decoration: const BoxDecoration(
              color: Color(0xFFC0C0C0),
              border: Border(bottom: BorderSide(color: Colors.black)),
            ),
            child: Row(
              children: [
                Text('Filter by status:', style: GoogleFonts.vt323(fontSize: 14)),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: selectedStatus,
                  items: statuses
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedStatus = val;
                      });
                      fetchReports();
                    }
                  },
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: Text(
                    'Reports: ${reports.length}',
                    style: GoogleFonts.vt323(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error
                    ? Center(
                        child: Text('Failed to load reports',
                            style: GoogleFonts.vt323(fontSize: 18, color: Colors.red)))
                    : reports.isEmpty
                        ? Center(
                            child: Text('No reports available',
                                style:
                                    GoogleFonts.vt323(fontSize: 18, color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: reports.length,
                            itemBuilder: (_, i) {
                              final report = reports[i];
                              final content = targetContents[report.id] ?? 'Loading...';
                              final isLoadingContent = loadingTargets[report.id] ?? true;
                              return ReportCard(
                                report: report,
                                targetContent: content,
                                loadingContent: isLoadingContent,
                                onStatusChange: (status) => updateReportStatus(report, status),
                                onDelete: () => deleteReport(report),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final Report report;
  final String targetContent;
  final bool loadingContent;
  final Function(String) onStatusChange;
  final VoidCallback onDelete;

  const ReportCard({
    super.key,
    required this.report,
    required this.targetContent,
    required this.loadingContent,
    required this.onStatusChange,
    required this.onDelete,
  });

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'reviewed':
        return Colors.green;
      case 'dismissed':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.of(context).size.width < 400;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with info and buttons
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info row
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    label(report.reportType.toUpperCase(), Colors.blue.shade100, Colors.blue),
                    label(report.status.toUpperCase(),
                        getStatusColor(report.status).withOpacity(0.2),
                        getStatusColor(report.status)),
                    Text(
                      report.createdAt.toLocal().toString().split('.')[0],
                      style: GoogleFonts.vt323(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Buttons (responsive)
                small
                    ? Column(
                        children: [
                          if (report.status == 'pending')
                            Row(
                              children: [
                                Expanded(
                                  child: retro.RetroButton(
                                    onTap: () => onStatusChange('reviewed'),
                                    child: const Text('REVIEWED',
                                        style: TextStyle(color: Colors.green)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: retro.RetroButton(
                                    onTap: () => onStatusChange('dismissed'),
                                    child: const Text('DISMISS',
                                        style: TextStyle(color: Colors.grey)),
                                  ),
                                ),
                              ],
                            ),
                          if (report.status == 'pending') const SizedBox(height: 8),
                          retro.RetroButton(
                            onTap: onDelete,
                            child: const Text('DELETE',
                                style: TextStyle(color: Colors.red)),
                          )
                        ],
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (report.status == 'pending') ...[
                              retro.RetroButton(
                                onTap: () => onStatusChange('reviewed'),
                                child: const Text('REVIEWED',
                                    style: TextStyle(color: Colors.green)),
                              ),
                              const SizedBox(width: 10),
                              retro.RetroButton(
                                onTap: () => onStatusChange('dismissed'),
                                child: const Text('DISMISS',
                                    style: TextStyle(color: Colors.grey)),
                              ),
                              const SizedBox(width: 10),
                            ],
                            retro.RetroButton(
                              onTap: onDelete,
                              child: const Text('DELETE',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
          // Report details
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label('Reason: ${report.reason}', Colors.orange.shade100, Colors.orange),
                const SizedBox(height: 6),
                if (report.description != null && report.description!.isNotEmpty)
                  Text('Details: ${report.description}',
                      style: GoogleFonts.vt323(fontSize: 14)),
                const SizedBox(height: 12),
                Text('Reported Content:', style: GoogleFonts.vt323(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                loadingContent
                    ? const Center(child: CircularProgressIndicator())
                    : Text(targetContent, style: GoogleFonts.vt323(fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget label(String text, Color backgroundColor, Color textColor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: textColor),
        ),
        child: Text(
          text,
          style: GoogleFonts.vt323(fontSize: 12, color: textColor, fontWeight: FontWeight.bold),
        ),
      );
}

class DeleteReportDialog extends StatelessWidget {
  final Report report;

  const DeleteReportDialog({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFE0E0E0),
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(8)),
      title: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Delete Report',
                style: GoogleFonts.vt323(
                    fontWeight: FontWeight.bold, fontSize: 20)),
          )
        ],
      ),
      content: Text(
        'Are you sure you want to delete this report? This action cannot be undone.',
        style: GoogleFonts.vt323(fontSize: 16),
      ),
      actions: [
        retro.RetroButton(
          onTap: () => Navigator.of(context).pop(false),
          child: Text('Cancel',
              style: GoogleFonts.vt323(
                fontSize: 16,
              )),
        ),
        retro.RetroButton(
          onTap: () => Navigator.of(context).pop(true),
          child: Text('Delete',
              style: GoogleFonts.vt323(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
