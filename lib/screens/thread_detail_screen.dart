import 'dart:io'; // Required for File
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import '../models/thread.dart';
import '../services/dummy_data.dart';
import '../widgets/retro_panel.dart';
import '../widgets/retro_button.dart';

class ThreadDetailScreen extends StatefulWidget {
  final Thread thread;
  const ThreadDetailScreen({super.key, required this.thread});

  @override
  _ThreadDetailScreenState createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> {
  final _dataService = DummyDataService();

  Future<void> _showReplyDialog() async {
    final replyController = TextEditingController();
    XFile? replyImageFile;

    return showDialog<void>(
      context: context,
      // Use StatefulBuilder to manage state within the dialog
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Color(0xFFC0C0C0),
            title: Text('Post a Reply', style: GoogleFonts.vt323(color: Colors.black)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (replyImageFile != null)
                    Image.file(File(replyImageFile!.path), height: 100),
                  RetroButton(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setDialogState(() {
                          replyImageFile = pickedFile;
                        });
                      }
                    },
                    child: Text('Attach Image'),
                  ),
                  SizedBox(height: 8),
                  RetroPanel(
                    type: RetroPanelType.sunken,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: replyController,
                      decoration: InputDecoration(border: InputBorder.none, hintText: 'Your reply...'),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel', style: GoogleFonts.vt323(color: Colors.black)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              RetroButton(
                onTap: () {
                  if (replyController.text.isNotEmpty) {
                    setState(() {
                      _dataService.addReply(
                        widget.thread.id,
                        replyController.text,
                        replyImageFile?.path,
                      );
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Post'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thread')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // Original Post
                  RetroPanel(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.thread.imagePath != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Image.file(File(widget.thread.imagePath!)),
                          ),
                        Text(widget.thread.title, style: GoogleFonts.vt323(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(widget.thread.content, style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Replies:', style: GoogleFonts.vt323(fontSize: 22, color: Colors.white)),
                  const SizedBox(height: 4),
                  // Replies
                  ...widget.thread.replies.map((reply) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: RetroPanel(
                        type: RetroPanelType.sunken,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (reply.imagePath != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Image.file(File(reply.imagePath!)),
                              ),
                            Text(reply.content, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RetroButton(
                onTap: _showReplyDialog,
                child: Text('Reply to this Thread'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
