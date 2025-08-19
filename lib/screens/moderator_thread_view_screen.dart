// lib/screens/moderator_thread_view_screen.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../models/post.dart';
import '../models/thread.dart';
import '../utils/responsive_helper.dart';
import '../widgets/imageboard_text.dart';
import '../widgets/retro_button.dart' as retro;

class ModeratorThreadViewScreen extends StatefulWidget {
  final int threadId;

  const ModeratorThreadViewScreen({super.key, required this.threadId});

  @override
  State<ModeratorThreadViewScreen> createState() =>
      _ModeratorThreadViewScreenState();
}

class _ModeratorThreadViewScreenState extends State<ModeratorThreadViewScreen> {
  static const String baseUrl = 'http://127.0.0.1:3441/';
  Thread? thread;
  List<Post> replies = [];
  bool loading = true;
  bool error = false;
  String errorMessage = 'Failed to load thread.';

  @override
  void initState() {
    super.initState();
    _loadThread();
  }

  Future<void> _loadThread() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      error = false;
    });

    try {
      // --- Fetch Thread ---
      final threadUri = Uri.parse('${baseUrl}get_thread.php?thread_id=${widget.threadId}');
      final threadResp = await http.get(threadUri).timeout(const Duration(seconds: 10));

      if (threadResp.statusCode != 200) {
        throw Exception('Server error: Failed to load thread with status code ${threadResp.statusCode}');
      }
      
      final threadJson = json.decode(threadResp.body);

      // **FIXED**: Check for the 'success' flag and parse the nested 'thread' object
      if (threadJson['success'] == true && threadJson['thread'] != null) {
        final fetchedThread = Thread.fromJson(threadJson['thread']);

        // --- Fetch Replies ---
        final repliesUri = Uri.parse('${baseUrl}replies.php?thread_id=${widget.threadId}');
        final repliesResp = await http.get(repliesUri).timeout(const Duration(seconds: 10));

        if (repliesResp.statusCode != 200) {
          throw Exception('Server error: Failed to load replies with status code ${repliesResp.statusCode}');
        }
        
        final repliesJson = json.decode(repliesResp.body) as List;
        final fetchedReplies = repliesJson.map((e) => Post.fromJson(e)).toList();

        if (mounted) {
          setState(() {
            thread = fetchedThread;
            replies = fetchedReplies;
            loading = false;
          });
        }
      } else {
        throw Exception(threadJson['error'] ?? 'An unknown error occurred while fetching the thread.');
      }
    } catch (e) {
      if (kDebugMode) print('Error loading thread or replies: $e');
      if (mounted) {
        setState(() {
          loading = false;
          error = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _deleteReply(int replyId) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Reply'),
            content: const Text('Are you sure you want to delete this reply?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) return;

    try {
      final resp = await http.post(
        Uri.parse('${baseUrl}reply_delete.php'),
        body: {'id': replyId.toString()},
      );
      final data = json.decode(resp.body);
      if (data['success'] == true) {
        _loadThread(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Reply deleted successfully'),
          backgroundColor: Colors.green,
        ));
      } else {
        throw Exception(data['error'] ?? 'Delete failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error deleting reply: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...'), backgroundColor: const Color(0xFFC0C0C0)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error || thread == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error'), backgroundColor: const Color(0xFFC0C0C0)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(errorMessage, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final small = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(thread!.title, style: GoogleFonts.vt323(fontSize: 20)),
        backgroundColor: const Color(0xFFC0C0C0),
      ),
      body: Column(
        children: [
          // Thread display
          Container(
            padding: ResponsiveHelper.defaultPadding,
            constraints: BoxConstraints(maxHeight: small ? 250 : 300),
            decoration: const BoxDecoration(color: Color(0xFFE0E0E0)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _pill(thread!.board),
                    const SizedBox(width: 6),
                    _pill(thread!.formattedId, color: Colors.redAccent),
                    const SizedBox(width: 10),
                    Text(
                      'Replies: ${thread!.replies} • ${_formatTime(thread!.createdAt)}',
                      style: GoogleFonts.vt323(fontSize: 12, color: Colors.black54),
                    )
                  ]),
                  const SizedBox(height: 10),
                  if (thread!.imagePath != null && thread!.imagePath!.isNotEmpty)
                    Image.network(
                      '$baseUrl${thread!.imagePath!}',
                      height: small ? 150 : 200,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  const SizedBox(height: 10),
                  Text(thread!.title, style: GoogleFonts.vt323(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  // **FIXED**: Handle null content safely
                  ImageboardText(text: thread!.content ?? ''),
                ],
              ),
            ),
          ),
          // Replies list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: replies.length,
              itemBuilder: (_, i) => _replyItem(replies[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, {Color color = const Color(0xFFC0C0C0)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color, border: Border.all(color: Colors.black)),
      child: Text(text, style: GoogleFonts.vt323(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _replyItem(Post reply) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: Colors.black), color: Colors.white),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pill(reply.formattedId),
          const SizedBox(width: 8),
          if (reply.imagePath != null && reply.imagePath!.isNotEmpty)
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                image: DecorationImage(
                  image: NetworkImage('$baseUrl${reply.imagePath!}'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_formatTime(reply.createdAt), style: GoogleFonts.vt323(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 6),
              // **FIXED**: Handle null content safely
              ImageboardText(text: reply.content ?? ''),
              const SizedBox(height: 6),
              Row(
                children: [
                  retro.RetroButton(
                    onTap: () => _deleteReply(reply.id),
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              )
            ]),
          )
        ],
      ),
    );
  }
}
