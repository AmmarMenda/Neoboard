// screens/thread_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import '../models/thread.dart';
import '../models/post.dart';
import '../widgets/retro_button.dart' as retro;
import '../widgets/imageboard_text.dart';
import '../widgets/report_dialog.dart';

class ThreadScreen extends StatefulWidget {
  final int threadId;
  
  const ThreadScreen({super.key, required this.threadId});

  @override
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _replyController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  Thread? _thread;
  List<Post> _posts = [];
  bool _isLoading = true;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadThreadData();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadThreadData() async {
    try {
      final thread = await _dbHelper.getThreadById(widget.threadId);
      final posts = await _dbHelper.getPostsByThread(widget.threadId);
      
      setState(() {
        _thread = thread;
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading thread: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImageForReply() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _addReply() async {
    if (_replyController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text or attach an image')),
      );
      return;
    }

    try {
      final newPost = Post(
        threadId: widget.threadId,
        content: _replyController.text.trim(),
        imagePath: _selectedImage?.path,
      );

      await _dbHelper.insertPost(newPost);
      _replyController.clear();
      _clearSelectedImage();
      await _loadThreadData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply added!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding reply: $e')),
      );
    }
  }

  Future<void> _reportThread() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ReportDialog(
        reportType: 'thread',
        targetId: _thread!.id!,
        targetTitle: _thread!.title,
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thread reported successfully. Moderators will review it.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _reportReply(Post post) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ReportDialog(
        reportType: 'reply',
        targetId: post.id!,
        targetTitle: post.content.length > 50 
            ? '${post.content.substring(0, 50)}...' 
            : post.content,
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply reported successfully. Moderators will review it.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_thread == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thread Not Found')),
        body: const Center(child: Text('Thread not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _thread!.title,
          style: GoogleFonts.vt323(),
        ),
        backgroundColor: const Color(0xFFC0C0C0),
      ),
      body: Column(
        children: [
          // Original thread post - wrap in flexible container
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC0C0C0),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Text(
                            _thread!.board,
                            style: GoogleFonts.vt323(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDDDD),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Text(
                            _thread!.formattedId,
                            style: GoogleFonts.vt323(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_thread!.replies} replies',
                          style: GoogleFonts.vt323(fontSize: 14, color: Colors.black54),
                        ),
                        const Spacer(),
                        // Add report thread button
                        retro.RetroButton(
                          onTap: () => _reportThread(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.report, size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                'REPORT',
                                style: GoogleFonts.vt323(fontSize: 12, color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _thread!.title,
                      style: GoogleFonts.vt323(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_thread!.imagePath != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Image.file(
                          File(_thread!.imagePath!),
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ImageboardText(
                      text: _thread!.content,
                      fontSize: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Posts list - Use Expanded to take available space
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return _PostCard(
                  post: post,
                  onReport: () => _reportReply(post),
                );
              },
            ),
          ),
          // Reply input section - constrain height and make scrollable
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  border: Border(
                    top: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selected image preview
                    if (_selectedImage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC0C0C0),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                File(_selectedImage!.path),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Image attached',
                                style: GoogleFonts.vt323(fontSize: 14),
                              ),
                            ),
                            IconButton(
                              onPressed: _clearSelectedImage,
                              icon: const Icon(Icons.close, size: 20),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Reply input row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Image picker button
                        retro.RetroButton(
                          onTap: _pickImageForReply,
                          child: const Icon(Icons.image, size: 20),
                        ),
                        const SizedBox(width: 8),
                        // Text input - constrain height
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 100),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: TextField(
                              controller: _replyController,
                              decoration: const InputDecoration(
                                hintText: 'Write a reply...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(12),
                              ),
                              maxLines: 3,
                              minLines: 1,
                              style: GoogleFonts.vt323(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Submit button
                        retro.RetroButton(
                          onTap: _addReply,
                          child: Text(
                            'Reply',
                            style: GoogleFonts.vt323(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Separate widget for post cards to keep code organized
class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onReport;

  const _PostCard({required this.post, required this.onReport});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Post header with ID, timestamp, and report button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFC0C0C0),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Text(
                  post.formattedId,
                  style: GoogleFonts.vt323(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(post.createdAt),
                style: GoogleFonts.vt323(fontSize: 12, color: Colors.black54),
              ),
              const Spacer(),
              // Add report reply button
              retro.RetroButton(
                onTap: onReport,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.report, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      'REPORT',
                      style: GoogleFonts.vt323(fontSize: 10, color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Post image if available - constrain size
          if (post.imagePath != null && post.imagePath!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(
                  File(post.imagePath!),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      color: const Color(0xFF9EC1C1),
                      child: Center(
                        child: Text(
                          'Image Error',
                          style: GoogleFonts.vt323(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          // Post content with formatting
          if (post.content.isNotEmpty)
            ImageboardText(
              text: post.content,
              fontSize: 16,
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
