// lib/widgets/report_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/report.dart';
import '../models/thread.dart';
import '../models/post.dart';
import '../utils/responsive_helper.dart';
import './retro_button.dart' as retro;
import 'imageboard_text.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final dynamic targetContent;
  final bool loadingContent;
  final Function(String) onStatusChange;
  final VoidCallback onDelete;
  final String baseUrl;

  const ReportCard({
    super.key,
    required this.report,
    required this.targetContent,
    required this.loadingContent,
    required this.onStatusChange,
    required this.onDelete,
    required this.baseUrl,
  });

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'reviewed': return Colors.green;
      case 'dismissed': return Colors.grey;
      default: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    String contentPreview = '';
    String? imagePath;

    if (targetContent is Thread) {
      contentPreview = 'Thread: ${targetContent.title}';
      imagePath = targetContent.imagePath;
    } else if (targetContent is Post) {
      contentPreview = targetContent.content ?? '[No text content]';
      imagePath = targetContent.imagePath;
    } else if (targetContent is String) {
      contentPreview = targetContent;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const Divider(height: 1, color: Colors.black26),
          _buildBody(context, contentPreview, imagePath),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
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
          ResponsiveHelper.isSmallScreen(context) ? _buildMobileButtons() : _buildDesktopButtons(),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, String contentPreview, String? imagePath) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label('Reason: ${report.reason}', Colors.orange.shade100, Colors.orange),
          const SizedBox(height: 6),
          if (report.description != null && report.description!.isNotEmpty)
            ImageboardText(text: 'Details: ${report.description!}', fontSize: 14),
          const SizedBox(height: 12),
          Text('Reported Content Preview:', style: GoogleFonts.vt323(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          if (loadingContent)
            const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          else ...[
            if (imagePath != null && imagePath.isNotEmpty) ...[
              Image.network(
                '$baseUrl$imagePath',
                height: 150,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, st) => const Icon(Icons.error, color: Colors.red),
              ),
              const SizedBox(height: 8),
            ],
            // **THE FIX IS HERE**: The 'isQuote' parameter is removed.
            // The Container provides the visual distinction instead.
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[200]),
              child: ImageboardText(text: contentPreview, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
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
  
  Widget _buildMobileButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

  Widget label(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor),
      ),
      child: Text(text, style: GoogleFonts.vt323(fontSize: 12, color: textColor, fontWeight: FontWeight.bold)),
    );
  }
}
