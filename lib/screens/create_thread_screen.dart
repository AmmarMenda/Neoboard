// lib/screens/create_thread_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show File; // Only import File, same as your thread_screen.dart
import '../utils/responsive_helper.dart';
import '../widgets/retro_button.dart' as retro;
import '../widgets/leopard_app_bar.dart';

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

  // **FIXED: Use the exact same pattern as your working postReply() method**
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.12:3441/thread_create.php'),
      );

      request.fields['title'] = _titleController.text.trim();
      request.fields['content'] = _contentController.text.trim();
      request.fields['board'] = widget.board;

      // **FIXED: Use the exact same image handling as your replies**
      if (_selectedImage != null) {
        final imageBytes = await _selectedImage!.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: _selectedImage!.name,
        );
        request.files.add(multipartFile);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thread created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
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

  // **FIXED: Use the exact same image preview as your thread_screen.dart**
  Widget _buildSelectedImagePreview() {
    if (_selectedImage == null) return const SizedBox.shrink();

    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: kIsWeb
              ? Image.network(
                  _selectedImage!.path,
                  height: isSmallScreen ? 150 : 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.file(
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
              icon: const Icon(Icons.close, color: Colors.white, size: 18),
              onPressed: _removeSelectedImage,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LeopardAppBar(title: Text('Create Thread on ${widget.board}')),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.getResponsivePadding(context, 24, 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              _buildSelectedImagePreview(), // **FIXED: Use working image preview**
              const SizedBox(height: 16),
              retro.RetroButton(
                onTap: _pickImage,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image_outlined),
                    const SizedBox(width: 8),
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
                    : const Text('Create Thread'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
