// screens/moderator_thread_management_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/retro_button.dart' as retro;
import '../database/database_helper.dart';
import '../models/thread.dart';
import '../models/post.dart';
import '../widgets/imageboard_text.dart';
import 'moderator_thread_view_screen.dart';

class ModeratorThreadManagementScreen extends StatefulWidget {
  const ModeratorThreadManagementScreen({super.key});

  @override
  _ModeratorThreadManagementScreenState createState() => _ModeratorThreadManagementScreenState();
}

class _ModeratorThreadManagementScreenState extends State<ModeratorThreadManagementScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Thread> _threads = [];
  Map<int, List<Post>> _threadReplies = {}; // Store replies for each thread
  bool _isLoading = true;
  String _selectedBoard = 'All';
  final List<String> _boards = ['All', '/b/', '/g/', '/v/', '/a/'];

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Thread> threads;
      if (_selectedBoard == 'All') {
        threads = await _dbHelper.getAllThreads();
      } else {
        threads = await _dbHelper.getThreadsByBoard(_selectedBoard);
      }
      
      // Load replies for each thread
      Map<int, List<Post>> repliesMap = {};
      for (Thread thread in threads) {
        final replies = await _dbHelper.getPostsByThread(thread.id!);
        repliesMap[thread.id!] = replies;
      }
      
      setState(() {
        _threads = threads;
        _threadReplies = repliesMap;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading threads: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteThread(Thread thread) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return _DeleteThreadConfirmationDialog(thread: thread);
      },
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteThread(thread.id!);
        await _loadThreads();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thread "${thread.title}" deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting thread: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openThread(Thread thread) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ModeratorThreadViewScreen(threadId: thread.id!),
      ),
    ).then((_) {
      // Reload threads when returning from thread view (in case replies were deleted)
      _loadThreads();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thread Management',
          style: GoogleFonts.vt323(fontSize: 20),
        ),
        backgroundColor: const Color(0xFFC0C0C0),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE0E0E0),
        ),
        child: Column(
          children: [
            // Header and Controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFC0C0C0),
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.manage_accounts, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        'THREAD & REPLY MANAGEMENT',
                        style: GoogleFonts.vt323(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Filter by Board:',
                        style: GoogleFonts.vt323(fontSize: 14),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedBoard,
                            style: GoogleFonts.vt323(fontSize: 14, color: Colors.black),
                            items: _boards.map((String board) {
                              return DropdownMenuItem<String>(
                                value: board,
                                child: Text(board),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedBoard = newValue;
                                });
                                _loadThreads();
                              }
                            },
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDDDD),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Text(
                          '${_threads.length} threads',
                          style: GoogleFonts.vt323(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Threads List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _threads.isEmpty
                      ? Center(
                          child: Text(
                            'No threads found',
                            style: GoogleFonts.vt323(fontSize: 18, color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _threads.length,
                          itemBuilder: (context, index) {
                            final thread = _threads[index];
                            final replies = _threadReplies[thread.id!] ?? [];
                            return _ModeratorThreadCard(
                              thread: thread,
                              replies: replies,
                              onDelete: () => _deleteThread(thread),
                              onOpen: () => _openThread(thread),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeratorThreadCard extends StatefulWidget {
  final Thread thread;
  final List<Post> replies;
  final VoidCallback onDelete;
  final VoidCallback onOpen;

  const _ModeratorThreadCard({
    required this.thread,
    required this.replies,
    required this.onDelete,
    required this.onOpen,
  });

  @override
  _ModeratorThreadCardState createState() => _ModeratorThreadCardState();
}

class _ModeratorThreadCardState extends State<_ModeratorThreadCard> {
  bool _showReplies = false;

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thread Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F0F0),
              border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0C0C0),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Text(
                    widget.thread.board,
                    style: GoogleFonts.vt323(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDDDD),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Text(
                    widget.thread.formattedId,
                    style: GoogleFonts.vt323(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.replies.length} replies',
                  style: GoogleFonts.vt323(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(widget.thread.createdAt),
                  style: GoogleFonts.vt323(fontSize: 12, color: Colors.black54),
                ),
                const Spacer(),
                // Toggle replies button
                if (widget.replies.isNotEmpty)
                  retro.RetroButton(
                    onTap: () {
                      setState(() {
                        _showReplies = !_showReplies;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showReplies ? Icons.expand_less : Icons.expand_more,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _showReplies ? 'HIDE' : 'SHOW',
                          style: GoogleFonts.vt323(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                // Open thread button
                retro.RetroButton(
                  onTap: widget.onOpen,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.open_in_new, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        'OPEN',
                        style: GoogleFonts.vt323(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Delete thread button
                retro.RetroButton(
                  onTap: widget.onDelete,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
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
          ),
          // Thread Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thread Image
                if (widget.thread.imagePath != null)
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    child: Image.file(
                      File(widget.thread.imagePath!),
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9EC1C1),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        'NO IMG',
                        style: GoogleFonts.vt323(fontSize: 10, color: Colors.black54),
                      ),
                    ),
                  ),
                // Thread Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.thread.title,
                        style: GoogleFonts.vt323(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 60),
                        child: ImageboardText(
                          text: widget.thread.content,
                          fontSize: 14,
                          defaultColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Replies Section (collapsible)
          if (_showReplies && widget.replies.isNotEmpty)
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8F8),
                border: Border(top: BorderSide(color: Colors.black, width: 1)),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8E8E8),
                      border: Border(bottom: BorderSide(color: Colors.black54, width: 1)),
                    ),
                    child: Text(
                      'REPLIES (${widget.replies.length})',
                      style: GoogleFonts.vt323(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...widget.replies.take(5).map((reply) => _ReplyPreview(reply: reply)),
                  if (widget.replies.length > 5)
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '... and ${widget.replies.length - 5} more replies',
                        style: GoogleFonts.vt323(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  final Post reply;

  const _ReplyPreview({required this.reply});

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
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              border: Border.all(color: Colors.black54, width: 1),
            ),
            child: Text(
              reply.formattedId,
              style: GoogleFonts.vt323(fontSize: 10),
            ),
          ),
          const SizedBox(width: 8),
          if (reply.imagePath != null)
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 8),
              child: Image.file(
                File(reply.imagePath!),
                fit: BoxFit.cover,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTime(reply.createdAt),
                  style: GoogleFonts.vt323(fontSize: 10, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Container(
                  constraints: const BoxConstraints(maxHeight: 30),
                  child: ImageboardText(
                    text: reply.content,
                    fontSize: 12,
                    defaultColor: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteThreadConfirmationDialog extends StatelessWidget {
  final Thread thread;

  const _DeleteThreadConfirmationDialog({required this.thread});

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
              'CONFIRM DELETE THREAD',
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
            'Are you sure you want to delete this thread?',
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
                Row(
                  children: [
                    Text(
                      'Board: ',
                      style: GoogleFonts.vt323(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      thread.board,
                      style: GoogleFonts.vt323(fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'ID: ',
                      style: GoogleFonts.vt323(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      thread.formattedId,
                      style: GoogleFonts.vt323(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Title: ',
                  style: GoogleFonts.vt323(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  thread.title,
                  style: GoogleFonts.vt323(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
              'This action cannot be undone! All replies to this thread will also be deleted.',
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
            'DELETE THREAD',
            style: GoogleFonts.vt323(fontSize: 14, color: Colors.red),
          ),
        ),
      ],
    );
  }
}
