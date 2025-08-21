// lib/screens/create_thread_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/responsive_helper.dart';
import '../widgets/retro_button.dart' as retro;
import '../widgets/leopard_app_bar.dart'; // Use the themed AppBar

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image pick error: $e')));
      }
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);

    try {
      Uri uri = Uri.parse('http://127.0.0.1:3441/thread_create.php');
      var request = http.MultipartRequest('POST', uri);
      request.fields['title'] = _titleController.text.trim();
      request.fields['content'] = _contentController.text.trim();
      request.fields['board'] = widget.board;

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _selectedImage!.path),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thread created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Pop with a success indicator
        }
      } else {
        throw Exception(jsonResponse['error'] ?? 'Failed to create thread.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting thread: $e'),
            backgroundColor: Colors.red,
          ),
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
      // *** THE FIX: Use the themed LeopardAppBar ***
      appBar: LeopardAppBar(title: Text('Create Thread on ${widget.board}')),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.getResponsivePadding(context, 24, 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Ensure buttons stretch
            children: [
              // *** THE FIX: Use the themed InputDecoration ***
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Title'),
                maxLength: 100,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Content (optional)',
                ),
                maxLines: 8,
                maxLength: 1000,
              ),
              const SizedBox(height: 20),
              if (_selectedImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_selectedImage!.path),
                        height: isSmallScreen ? 150 : 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black.withOpacity(0.6),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: _removeSelectedImage,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              retro.RetroButton(
                onTap: _pickImage,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image_outlined),
                    const SizedBox(width: 8),
                    // *** THE FIX: Text inherits font from button ***
                    Text(_selectedImage == null ? 'Add Image' : 'Change Image'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              retro.RetroButton(
                onTap: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    // *** THE FIX: Text inherits font from button ***
                    : const Text('Create Thread'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
