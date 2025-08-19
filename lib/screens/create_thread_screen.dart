// lib/screens/create_thread_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/responsive_helper.dart';
import '../widgets/retro_button.dart' as retro;

class CreateThreadScreen extends StatefulWidget {
  final String board;

  const CreateThreadScreen({super.key, required this.board});

  @override
  State<CreateThreadScreen> createState() => _CreateThreadScreenState();
}

class _CreateThreadScreenState extends State<CreateThreadScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _selectedImage = picked);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image pick error: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      Uri uri = Uri.parse('http://127.0.0.1:3441/thread_create.php'); // change to your API url
      var request = http.MultipartRequest('POST', uri);

      request.fields['title'] = _titleController.text.trim();
      request.fields['content'] = _contentController.text.trim();
      request.fields['board'] = widget.board;

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thread created successfully!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop({
            'title': _titleController.text.trim(),
            'content': _contentController.text.trim(),
            'image': _selectedImage != null ? File(_selectedImage!.path) : null,
          });
        }
      } else {
        String errorMsg = jsonResponse['error'] ?? 'Failed to create thread.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting thread: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _removeSelectedImage() {
    setState(() => _selectedImage = null);
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Thread on ${widget.board}', style: GoogleFonts.vt323()),
        backgroundColor: const Color(0xFFC0C0C0),
      ),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.getResponsivePadding(context),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 6,
                maxLength: 1000,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter content' : null,
              ),
              const SizedBox(height: 12),
              if (_selectedImage != null)
                Stack(
                  children: [
                    Image.file(
                      File(_selectedImage!.path),
                      height: isSmallScreen ? 150 : 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: _removeSelectedImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              retro.RetroButton(
                onTap: () async {
                  await _pickImage();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image),
                    const SizedBox(width: 8),
                    Text('Pick Image', style: GoogleFonts.vt323()),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: retro.RetroButton(
                  onTap: _submitting
    ? null
    : () async {
        await _submit();
      },
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Create Thread', style: GoogleFonts.vt323()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
