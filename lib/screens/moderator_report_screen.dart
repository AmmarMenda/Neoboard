// lib/screens/moderator_reports_screen.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../models/report.dart';
import '../widgets/retro_button.dart' as retro;
import '../utils/responsive_helper.dart';
import '../widgets/delete_report_dialog.dart';
import './thread_screen.dart'; // <-- Import the new screen

class ModeratorReportsScreen extends StatefulWidget {
  const ModeratorReportsScreen({super.key});

  @override
  State<ModeratorReportsScreen> createState() => _ModeratorReportsScreenState();
}

class _ModeratorReportsScreenState extends State<ModeratorReportsScreen> {
  // ... (All of this state class remains exactly the same as before)
  static const String baseUrl = 'http://127.0.0.1:3441/';

  final List<String> statuses = ['all', 'pending', 'reviewed', 'dismissed'];
  String selectedStatus = 'pending';

  List<Report> reports = [];
  bool loading = false;
  bool error = false;
  String errorMessage = 'Failed to load reports';

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      error = false;
      reports.clear();
    });

    try {
      final uri = selectedStatus == 'all'
          ? Uri.parse('${baseUrl}reports.php')
          : Uri.parse('${baseUrl}reports.php?status=$selectedStatus');

      final res = await http.get(uri).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        final errorBody = json.decode(res.body);
        throw Exception(errorBody['error'] ?? 'Failed to load reports');
      }

      final data = json.decode(res.body) as List;
      final loadedReports = data.map((json) => Report.fromJson(json)).toList();

      if (mounted) {
        setState(() {
          reports = loadedReports;
          loading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching reports: $e');
      if (mounted) {
        setState(() {
          loading = false;
          error = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> updateReportStatus(Report report, String newStatus) async {
    try {
      final res = await http.post(Uri.parse('${baseUrl}report_update.php'), body: {
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteReportDialog(report: report),
    ) ?? false;

    if (!ok || !mounted) return;

    try {
      final res = await http.post(Uri.parse('${baseUrl}report_delete.php'), body: {
        'id': (report.id ?? 0).toString(),
      });

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true) {
          fetchReports();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report deleted'), backgroundColor: Colors.green));
          }
        } else {
          throw Exception(data['error'] ?? 'Delete failed');
        }
      } else {
        throw Exception('Server error: ${res.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting report: $e'), backgroundColor: Colors.red));
      }
    }
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
          Container(
            padding: const EdgeInsets.all(12),
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
                  items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
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
                  decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                  child: Text('Reports: ${reports.length}', style: GoogleFonts.vt323(fontSize: 14)),
                ),
              ],
            ),
          ),
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
                              return ReportCard(
                                report: report,
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
  final Function(String) onStatusChange;
  final VoidCallback onDelete;
  final String imageBaseUrl = 'http://127.0.0.1:3441';

  const ReportCard({
    super.key,
    required this.report,
    required this.onStatusChange,
    required this.onDelete,
  });

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'reviewed': return Colors.green;
      case 'dismissed': return Colors.grey;
      default: return Colors.black;
    }
  }

  // --- NEW: Navigation function ---
  void _openThread(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        // Navigate to your ThreadScreen, passing the targetId from the report
        builder: (ctx) => ThreadScreen(threadId: report.targetId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final small = ResponsiveHelper.isSmallScreen(context);
    final hasImage = report.reportedImageUrl != null && report.reportedImageUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    label(report.reportType.toUpperCase(), Colors.blue.shade100, Colors.blue),
                    label(report.status.toUpperCase(), getStatusColor(report.status).withOpacity(0.2), getStatusColor(report.status)),
                    Text(report.createdAt.toLocal().toString().split('.')[0], style: GoogleFonts.vt323(fontSize: 12, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 10),
                small ? _buildMobileButtons(context) : _buildDesktopButtons(context),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black26),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label('Reason: ${report.reason}', Colors.orange.shade100, Colors.orange),
                const SizedBox(height: 6),
                if (report.description != null && report.description!.isNotEmpty)
                  Text('Details: ${report.description}', style: GoogleFonts.vt323(fontSize: 14)),
                const SizedBox(height: 12),
                Text('Reported Content:', style: GoogleFonts.vt323(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                if (hasImage)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: Image.network(
                        '$imageBaseUrl/${report.reportedImageUrl!}',
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Row(children: [
                             const Icon(Icons.broken_image, color: Colors.red, size: 20),
                             const SizedBox(width: 8),
                             Text('Image failed to load', style: GoogleFonts.vt323(color: Colors.red)),
                          ]);
                        },
                      ),
                    ),
                  ),
                Text(report.reportedContent, style: GoogleFonts.vt323(fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- UPDATED: Pass BuildContext ---
  Widget _buildDesktopButtons(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // --- NEW: Conditional "Open Thread" button ---
          if (report.reportType == 'thread') ...[
            retro.RetroButton(onTap: () => _openThread(context), child: const Text('OPEN', style: TextStyle(color: Colors.blue))),
            const SizedBox(width: 10),
          ],
          if (report.status == 'pending') ...[
            retro.RetroButton(onTap: () => onStatusChange('reviewed'), child: const Text('MARK REVIEWED', style: TextStyle(color: Colors.green))),
            const SizedBox(width: 10),
            retro.RetroButton(onTap: () => onStatusChange('dismissed'), child: const Text('DISMISS', style: TextStyle(color: Colors.grey))),
            const SizedBox(width: 10),
          ],
          retro.RetroButton(onTap: onDelete, child: const Text('DELETE', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
  
  // --- UPDATED: Pass BuildContext ---
  Widget _buildMobileButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- NEW: Conditional "Open Thread" button ---
        if (report.reportType == 'thread') ...[
           retro.RetroButton(onTap: () => _openThread(context), child: const Text('OPEN THREAD', style: TextStyle(color: Colors.blue))),
           const SizedBox(height: 8),
        ],
        if (report.status == 'pending')
          Row(
            children: [
              Expanded(child: retro.RetroButton(onTap: () => onStatusChange('reviewed'), child: const Text('REVIEWED', style: TextStyle(color: Colors.green)))),
              const SizedBox(width: 8),
              Expanded(child: retro.RetroButton(onTap: () => onStatusChange('dismissed'), child: const Text('DISMISS', style: TextStyle(color: Colors.grey)))),
            ],
          ),
        if (report.status == 'pending') const SizedBox(height: 8),
        retro.RetroButton(onTap: onDelete, child: const Text('DELETE REPORT', style: TextStyle(color: Colors.red))),
      ],
    );
  }

  Widget label(String text, Color backgroundColor, Color textColor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: textColor),
        ),
        child: Text(text, style: GoogleFonts.vt323(fontSize: 12, color: textColor, fontWeight: FontWeight.bold)),
      );
}
