import 'dart:io'; // Required for File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import '../widgets/retro_button.dart';
import '../widgets/retro_panel.dart';

class CreateThreadScreen extends StatefulWidget {
  const CreateThreadScreen({super.key});

  @override
  _CreateThreadScreenState createState() => _CreateThreadScreenState();
}

class _CreateThreadScreenState extends State<CreateThreadScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  XFile? _imageFile; // To hold the selected image file

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  void _submit() {
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      Navigator.of(context).pop({
        'title': _titleController.text,
        'content': _contentController.text,
        'imagePath': _imageFile?.path, // Pass the image path back
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Thread')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Image.file(
                  File(_imageFile!.path),
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            RetroButton(
              onTap: _pickImage,
              child: Text(_imageFile == null ? 'Attach Image' : 'Change Image'),
            ),
            SizedBox(height: 12),
            RetroPanel(
              type: RetroPanelType.sunken,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Thread Title...',
                ),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: RetroPanel(
                type: RetroPanelType.sunken,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Your content here...',
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            RetroButton(
              onTap: _submit,
              child: Text('Create Thread'),
            ),
          ],
        ),
      ),
    );
  }
}
