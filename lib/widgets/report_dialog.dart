// lib/widgets/report_dialog.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import './retro_button.dart' as retro;

class ReportDialog extends StatefulWidget {
  final int targetId;
  final String targetType; // 'thread' or 'reply'
  final String baseUrl;  // The base URL for your API (e.g., http://.../api/)

  const ReportDialog({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.baseUrl,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // A list of valid reasons for reporting
  final List<String> _reasons = [
    'Spam',
    'Hate Speech',
    'Illegal Content',
    'Harassment',
    'Other',
  ];
  // The currently selected reason, defaulting to the first item
  late String _selectedReason;
  
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize the selected reason
    _selectedReason = _reasons.first;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // **FIXED**: Implemented the actual API call
  Future<void> _submitReport() async {
    // Validate the form before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Set loading state to disable the button and show an indicator
    setState(() => _isSubmitting = true);

    try {
      final uri = Uri.parse('${widget.baseUrl}report_create.php');
      final response = await http.post(
        uri,
        body: {
          'target_id': widget.targetId.toString(),
          'type': widget.targetType,
          'reason': _selectedReason,
          'description': _descriptionController.text.trim(),
        },
      );

      // Check if the widget is still in the tree after the async operation
      if (!mounted) return;

      // The PHP script returns 201 on successful creation
      if (response.statusCode == 201) {
        Navigator.of(context).pop(); // Close the dialog on success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!'), backgroundColor: Colors.green),
        );
      } else {
        // If the server returned an error, try to decode it from the response body
        final error = json.decode(response.body)['error'] ?? 'An unknown error occurred';
        throw Exception(error);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Always reset the submitting state, even if an error occurs
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using AlertDialog for a standard, responsive layout
    return AlertDialog(
      title: Text(
        'Report Content',
        style: GoogleFonts.vt323(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView( // Prevents overflow if the keyboard appears
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedReason,
                items: _reasons.map((reason) => DropdownMenuItem(value: reason, child: Text(reason))).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedReason = value);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Please select a reason' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Optional Description',
                  hintText: 'Provide more details here...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
      actions: [
        retro.RetroButton(
          onTap: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        retro.RetroButton(
          onTap: _isSubmitting ? null : _submitReport, // Disable button while submitting
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
