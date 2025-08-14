// screens/moderator_thread_view_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import '../models/thread.dart';
import '../models/post.dart';
import '../widgets/retro_button.dart' as retro;
import '../widgets/imageboard_text.dart';

class ModeratorThreadViewScreen extends StatefulWidget {
  final int threadId;
  
  const ModeratorThreadViewScreen({super.key, required this.threadId});

  @override
  _ModeratorThreadViewScreenState createState() => _ModeratorThreadViewScreenState();
}

class _ModeratorThreadViewScreenState extends State<ModeratorThreadViewScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Thread? _thread;
  List<Post> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThreadData();
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

  Future<void> _deleteReply(Post post) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return _DeleteReplyConfirmationDialog(post: post);
      },
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deletePost(post.id!);
        await _loadThreadData(); // Reload to update reply count
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reply ${post.formattedId} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting reply: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          'Moderator: ${_thread!.title}',
          style: GoogleFonts.vt323(),
        ),
        backgroundColor: const Color(0xFFC0C0C0),
      ),
      body: Column(
        children: [
          // Moderator Notice
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFE6E6),
              border: Border(bottom: BorderSide(color: Colors.red, width: 1)),
            ),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'MODERATOR MODE - You can delete individual replies',
                  style: GoogleFonts.vt323(fontSize: 14, color: Colors.red),
                ),
              ],
            ),
          ),
          // Original thread post
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
          // Posts list with delete options
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return _ModeratorPostCard(
                  post: post,
                  onDelete: () => _deleteReply(post),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeratorPostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onDelete;

  const _ModeratorPostCard({required this.post, required this.onDelete});

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
          // Post header with ID, timestamp, and delete button
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
              // Delete reply button
              retro.RetroButton(
                onTap: onDelete,
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
          const SizedBox(height: 8),
          // Post image if available
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
}

class _DeleteReplyConfirmationDialog extends StatelessWidget {
  final Post post;

  const _DeleteReplyConfirmationDialog({required this.post});

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
              'CONFIRM DELETE REPLY',
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
            'Are you sure you want to delete this reply?',
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
                  'Reply ID: ${post.formattedId}',
                  style: GoogleFonts.vt323(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Content Preview:',
                  style: GoogleFonts.vt323(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Container(
                  constraints: const BoxConstraints(maxHeight: 60),
                  child: ImageboardText(
                    text: post.content.length > 100 
                        ? '${post.content.substring(0, 100)}...' 
                        : post.content,
                    fontSize: 12,
                    defaultColor: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDDDD),
              border: Border.all(color: Colors.red, width: 1),
            ),
            child: Text(
              'This action cannot be undone!',
              style: GoogleFonts.vt323(fontSize: 12, color: Colors.red),
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
            'DELETE REPLY',
            style: GoogleFonts.vt323(fontSize: 14, color: Colors.red),
          ),
        ),
      ],
    );
  }
}
