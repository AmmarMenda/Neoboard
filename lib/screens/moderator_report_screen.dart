// screens/moderator_reports_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/retro_button.dart' as retro;
import '../database/database_helper.dart';
import '../models/report.dart';
import '../models/thread.dart';
import '../models/post.dart';
import '../widgets/imageboard_text.dart';

class ModeratorReportsScreen extends StatefulWidget {
  const ModeratorReportsScreen({super.key});

  @override
  _ModeratorReportsScreenState createState() => _ModeratorReportsScreenState();
}

class _ModeratorReportsScreenState extends State<ModeratorReportsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Report> _reports = [];
  bool _isLoading = true;
  String _selectedStatus = 'pending';
  final List<String> _statuses = ['all', 'pending', 'reviewed', 'dismissed'];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Report> reports;
      if (_selectedStatus == 'all') {
        reports = await _dbHelper.getAllReports();
      } else {
        reports = await _dbHelper.getReportsByStatus(_selectedStatus);
      }
      
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reports: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateReportStatus(Report report, String newStatus) async {
    try {
      final updatedReport = report.copyWith(status: newStatus);
      await _dbHelper.updateReport(updatedReport);
      await _loadReports();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report marked as $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteReport(Report report) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return _DeleteReportConfirmationDialog(report: report);
      },
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteReport(report.id!);
        await _loadReports();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report Management',
          style: GoogleFonts.vt323(fontSize: 20),
        ),
        backgroundColor: const Color(0xFFC0C0C0),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE0E0E0),
        ),
        child: Column(
          children: [
            // Header and Controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFC0C0C0),
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.report_problem, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'REPORT MANAGEMENT',
                        style: GoogleFonts.vt323(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Filter by Status:',
                        style: GoogleFonts.vt323(fontSize: 14),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            style: GoogleFonts.vt323(fontSize: 14, color: Colors.black),
                            items: _statuses.map((String status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedStatus = newValue;
                                });
                                _loadReports();
                              }
                            },
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDDDD),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Text(
                          '${_reports.length} reports',
                          style: GoogleFonts.vt323(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Reports List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _reports.isEmpty
                      ? Center(
                          child: Text(
                            'No reports found',
                            style: GoogleFonts.vt323(fontSize: 18, color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _reports.length,
                          itemBuilder: (context, index) {
                            final report = _reports[index];
                            return _ReportCard(
                              report: report,
                              onStatusUpdate: (status) => _updateReportStatus(report, status),
                              onDelete: () => _deleteReport(report),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatefulWidget {
  final Report report;
  final Function(String) onStatusUpdate;
  final VoidCallback onDelete;

  const _ReportCard({
    required this.report,
    required this.onStatusUpdate,
    required this.onDelete,
  });

  @override
  _ReportCardState createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _targetContent = 'Loading...';
  bool _isLoadingTarget = true;

  @override
  void initState() {
    super.initState();
    _loadTargetContent();
  }

  Future<void> _loadTargetContent() async {
    try {
      if (widget.report.reportType == 'thread') {
        final thread = await _dbHelper.getThreadById(widget.report.targetId);
        setState(() {
          _targetContent = thread?.title ?? 'Thread not found';
          _isLoadingTarget = false;
        });
      } else {
        final posts = await _dbHelper.getPostsByThread(widget.report.targetId);
        final post = posts.firstWhere(
          (p) => p.id == widget.report.targetId,
          orElse: () => Post(threadId: 0, content: 'Reply not found'),
        );
        setState(() {
          _targetContent = post.content.length > 100 
              ? '${post.content.substring(0, 100)}...' 
              : post.content;
          _isLoadingTarget = false;
        });
      }
    } catch (e) {
      setState(() {
        _targetContent = 'Error loading content';
        _isLoadingTarget = false;
      });
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F0F0),
              border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.report.reportType == 'thread' 
                        ? const Color(0xFFDDEEFF) 
                        : const Color(0xFFEEDDFF),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Text(
                    widget.report.reportType.toUpperCase(),
                    style: GoogleFonts.vt323(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.report.status).withOpacity(0.1),
                    border: Border.all(color: _getStatusColor(widget.report.status), width: 1),
                  ),
                  child: Text(
                    widget.report.status.toUpperCase(),
                    style: GoogleFonts.vt323(
                      fontSize: 12, 
                      color: _getStatusColor(widget.report.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(widget.report.createdAt),
                  style: GoogleFonts.vt323(fontSize: 12, color: Colors.black54),
                ),
                const Spacer(),
                // Action buttons
                if (widget.report.status == 'pending') ...[
                  retro.RetroButton(
                    onTap: () => widget.onStatusUpdate('reviewed'),
                    child: Text(
                      'REVIEWED',
                      style: GoogleFonts.vt323(fontSize: 12, color: Colors.green),
                    ),
                  ),
                  const SizedBox(width: 8),
                  retro.RetroButton(
                    onTap: () => widget.onStatusUpdate('dismissed'),
                    child: Text(
                      'DISMISS',
                      style: GoogleFonts.vt323(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                retro.RetroButton(
                  onTap: widget.onDelete,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete, size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        'DELETE',
                        style: GoogleFonts.vt323(fontSize: 12, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Report Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reason
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    border: Border.all(color: Colors.red.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reason: ${widget.report.reason}',
                        style: GoogleFonts.vt323(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      if (widget.report.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Details: ${widget.report.description}',
                          style: GoogleFonts.vt323(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Target Content
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    border: Border.all(color: Colors.black54, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reported ${widget.report.reportType}:',
                        style: GoogleFonts.vt323(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      _isLoadingTarget
                          ? Text(
                              'Loading...',
                              style: GoogleFonts.vt323(fontSize: 14, color: Colors.black54),
                            )
                          : ImageboardText(
                              text: _targetContent,
                              fontSize: 14,
                              defaultColor: Colors.black87,
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteReportConfirmationDialog extends StatelessWidget {
  final Report report;

  const _DeleteReportConfirmationDialog({required this.report});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFE0E0E0),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.black, width: 2),
      ),
      title: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFC0C0C0),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'CONFIRM DELETE REPORT',
              style: GoogleFonts.vt323(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete this report?',
            style: GoogleFonts.vt323(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type: ${report.reportType}',
                  style: GoogleFonts.vt323(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Reason: ${report.reason}',
                  style: GoogleFonts.vt323(fontSize: 14),
                ),
                Text(
                  'Status: ${report.status}',
                  style: GoogleFonts.vt323(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        retro.RetroButton(
          onTap: () => Navigator.of(context).pop(false),
          child: Text(
            'CANCEL',
            style: GoogleFonts.vt323(fontSize: 14),
          ),
        ),
        const SizedBox(width: 8),
        retro.RetroButton(
          onTap: () => Navigator.of(context).pop(true),
          child: Text(
            'DELETE',
            style: GoogleFonts.vt323(fontSize: 14, color: Colors.red),
          ),
        ),
      ],
    );
  }
}
