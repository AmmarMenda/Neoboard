// lib/screens/coordinator_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/responsive_helper.dart';
import '../widgets/retro_button.dart' as retro;
import '../widgets/leopard_app_bar.dart';
import '../widgets/retro_panel.dart';
import '../backend/coordinator_form_service.dart';

class CoordinatorFormScreen extends StatefulWidget {
  const CoordinatorFormScreen({super.key});

  @override
  State<CoordinatorFormScreen> createState() => _CoordinatorFormScreenState();
}

class _CoordinatorFormScreenState extends State<CoordinatorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _enrollmentController = TextEditingController();
  final _divisionController = TextEditingController();
  final _departmentController = TextEditingController();

  XFile? _selectedIdCard;
  final ImagePicker _picker = ImagePicker();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _enrollmentController.dispose();
    _divisionController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _pickIdCard() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _selectedIdCard = picked);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedIdCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an ID card image')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final result = await CoordinatorFormService.submitCoordinatorForm(
        name: _nameController.text.trim(),
        enrollmentNo: _enrollmentController.text.trim(),
        division: _divisionController.text.trim(),
        department: _departmentController.text.trim(),
        idCardImage: _selectedIdCard!,
      );

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Application submitted successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _clearForm();
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to submit application'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting form: $e'),
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

  void _clearForm() {
    _nameController.clear();
    _enrollmentController.clear();
    _divisionController.clear();
    _departmentController.clear();
    setState(() => _selectedIdCard = null);
  }

  void _removeIdCard() {
    setState(() => _selectedIdCard = null);
  }

  Future<void> _showImageSourceDialog() async {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // *** THE FIX: Dialog uses themed styling ***
          backgroundColor: theme.dialogTheme.backgroundColor,
          shape: theme.dialogTheme.shape,
          title: Text('Select Image Source', style: theme.textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('Camera', style: theme.textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('Gallery', style: theme.textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _selectedIdCard = picked);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    final theme = Theme.of(context); // Get theme for styling

    return Scaffold(
      // *** THE FIX: Use themed AppBar ***
      appBar: LeopardAppBar(
        title: const Text('Co-ordinator Registration'),
        actions: [
          if (_nameController.text.isNotEmpty ||
              _enrollmentController.text.isNotEmpty ||
              _divisionController.text.isNotEmpty ||
              _departmentController.text.isNotEmpty ||
              _selectedIdCard != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: theme.dialogTheme.backgroundColor,
                    shape: theme.dialogTheme.shape,
                    title: Text(
                      'Clear Form',
                      style: theme.textTheme.titleLarge,
                    ),
                    content: Text(
                      'Are you sure you want to clear all form data?',
                      style: theme.textTheme.bodyMedium,
                    ),
                    actions: [
                      retro.RetroButton(
                        onTap: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      retro.RetroButton(
                        onTap: () {
                          Navigator.pop(context);
                          _clearForm();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Clear Form',
            ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: ResponsiveHelper.getResponsivePadding(context, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // *** THE FIX: Description text uses themed styling ***
              Text(
                'Fill out the form to register as a co-ordinator:',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 20),

              // *** THE FIX: All TextFormFields now use theme styling ***
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  helperText: 'Enter your complete name as per ID',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _enrollmentController,
                decoration: const InputDecoration(
                  labelText: 'Enrollment Number',
                  prefixIcon: Icon(Icons.numbers),
                  helperText: 'Enter your student enrollment number',
                ),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter enrollment number';
                  }
                  if (value.trim().length < 3) {
                    return 'Enrollment number is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _divisionController,
                decoration: const InputDecoration(
                  labelText: 'Division',
                  prefixIcon: Icon(Icons.class_),
                  helperText: 'e.g., A, B, C',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter division';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  prefixIcon: Icon(Icons.school),
                  helperText: 'e.g., Computer Science, Electronics',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter department';
                  }
                  if (value.trim().length < 3) {
                    return 'Department name is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // *** THE FIX: Section headers use themed typography ***
              Text(
                'ID Card Image:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // *** THE FIX: Image preview uses themed styling ***
              if (_selectedIdCard != null)
                RetroPanel(
                  padding: EdgeInsets.zero,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: isSmallScreen ? 200 : 300,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_selectedIdCard!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: _removeIdCard,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // *** THE FIX: Image picker button uses themed RetroButton ***
              retro.RetroButton(
                onTap: _showImageSourceDialog,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _selectedIdCard != null
                          ? Icons.refresh
                          : Icons.camera_alt,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedIdCard != null
                          ? 'Change ID Card'
                          : 'Upload ID Card',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // *** THE FIX: Submit button uses themed RetroButton ***
              SizedBox(
                width: double.infinity,
                child: retro.RetroButton(
                  onTap: _submitting ? null : _submitForm,
                  child: _submitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Submitting...'),
                          ],
                        )
                      : const Text('Submit Application'),
                ),
              ),

              const SizedBox(height: 20),

              // *** THE FIX: Info panel uses themed styling ***
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your application will be reviewed by moderators. You will be notified of the status.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
