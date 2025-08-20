// lib/screens/moderator_thread_management_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/thread.dart';
import '../models/post.dart';
import '../widgets/imageboard_text.dart';
import '../widgets/retro_button.dart' as retro;
import '../utils/responsive_helper.dart';
import 'moderator_thread_view_screen.dart';
import '../widgets/delete_thread_dialog.dart';

class ModeratorThreadManagementScreen extends StatefulWidget {
  const ModeratorThreadManagementScreen({super.key});

  @override
  State<ModeratorThreadManagementScreen> createState() =>
      _ModeratorThreadManagementScreenState();
}

class _ModeratorThreadManagementScreenState
    extends State<ModeratorThreadManagementScreen> {
  static const String baseUrl = 'http://127.0.0.1:3441/';

  final List<String> boards = ['All', '/b/', '/g/', '/v/', '/a/'];
  String selectedBoard = 'All';

  List<Thread> threads = [];
  Map<int, List<Post>> replies = {};
  bool isLoading = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchThreads();
  }

  Future<void> fetchThreads() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final url = selectedBoard == 'All'
          ? Uri.parse('${baseUrl}threads.php')
          : Uri.parse('${baseUrl}threads.php?board=$selectedBoard');

      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to load threads');
      }

      final List data = json.decode(response.body);
      final fetchedThreads = data.map((e) => Thread.fromJson(e)).toList();

      Map<int, List<Post>> tempReplies = {};

      for (var thread in fetchedThreads) {
        final replyResponse = await http.get(
          Uri.parse('${baseUrl}replies.php?thread_id=${thread.id}'),
        );

        final List replyData = replyResponse.statusCode == 200
            ? json.decode(replyResponse.body)
            : [];
        tempReplies[thread.id] = replyData
            .map<Post>((e) => Post.fromJson(e))
            .toList();
      }

      setState(() {
        threads = fetchedThreads;
        replies = tempReplies;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) print('Error fetching threads: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> deleteThread(int threadId) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => DeleteThreadDialog(threadId: threadId),
        ) ??
        false;

    if (!confirm) return;

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}thread_delete.php'),
        body: {'id': threadId.toString()},
      );

      final data = json.decode(response.body);
      if (data['success'] == true) {
        fetchThreads();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thread deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(data['error'] ?? 'Unknown error deleting thread');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting thread: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void openThread(int threadId) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => ModeratorThreadViewScreen(threadId: threadId),
          ),
        )
        .then((_) => fetchThreads());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Moderator Thread Management',
          style: GoogleFonts.vt323(
            fontSize: ResponsiveHelper.getFontSize(context, 20),
          ),
        ),
        backgroundColor: const Color(0xFFC0C0C0),
      ),
      body: Container(
        color: const Color(0xFFE0E0E0),
        child: Column(
          children: [
            Container(
              padding: ResponsiveHelper.defaultPadding,
              decoration: const BoxDecoration(
                color: Color(0xFFC0C0C0),
                border: Border(bottom: BorderSide(color: Colors.black)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.list_alt),
                      const SizedBox(width: 6),
                      Text(
                        'Filter by board:',
                        style: GoogleFonts.vt323(
                          fontSize: ResponsiveHelper.getFontSize(context, 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: selectedBoard,
                        items: boards
                            .map(
                              (b) => DropdownMenuItem(
                                value: b,
                                child: Text(b, style: GoogleFonts.vt323()),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedBoard = val;
                            });
                            fetchThreads();
                          }
                        },
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Text(
                          'Threads: ${threads.length}',
                          style: GoogleFonts.vt323(
                            fontSize: ResponsiveHelper.getFontSize(context, 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                  ? Center(
                      child: Text(
                        'Failed to load threads',
                        style: GoogleFonts.vt323(
                          fontSize: ResponsiveHelper.getFontSize(context, 18),
                          color: Colors.red,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: threads.length,
                      itemBuilder: (context, i) => ModeratorThreadCard(
                        thread: threads[i],
                        replies: replies[threads[i].id] ?? [],
                        onOpen: () => openThread(threads[i].id),
                        onDelete: () => deleteThread(threads[i].id),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _pill(String text, {Color color = const Color(0xFFC0C0C0)}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Colors.black,
      ),
    ),
  );
}

class ModeratorThreadCard extends StatefulWidget {
  final Thread thread;
  final List<Post> replies;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const ModeratorThreadCard({
    super.key,
    required this.thread,
    required this.replies,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  State<ModeratorThreadCard> createState() => _ModeratorThreadCardState();
}

class _ModeratorThreadCardState extends State<ModeratorThreadCard> {
  bool showReplies = false;

  String formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, "0")}';

  @override
  Widget build(BuildContext context) {
    final bool smallScreen = ResponsiveHelper.isSmallScreen(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: ResponsiveHelper.defaultPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _pill(
                        widget.thread.board,
                        color: const Color(0xFFC0C0C0),
                      ),
                      const SizedBox(width: 6),
                      _pill(widget.thread.formattedId, color: Colors.redAccent),
                      const SizedBox(width: 10),
                      Text(
                        'Replies: ${widget.replies.length} • ${formatDate(widget.thread.createdAt)}',
                        style: GoogleFonts.vt323(
                          fontSize: ResponsiveHelper.getFontSize(context, 12),
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Action buttons
                smallScreen
                    ? Column(
                        children: [
                          if (widget.replies.isNotEmpty)
                            retro.RetroButton(
                              onTap: () =>
                                  setState(() => showReplies = !showReplies),
                              child: Text(
                                showReplies ? 'HIDE REPLIES' : 'SHOW REPLIES',
                                style: GoogleFonts.vt323(fontSize: 12),
                              ),
                            ),
                          if (widget.replies.isNotEmpty)
                            const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: retro.RetroButton(
                                  onTap: widget.onOpen,
                                  child: const Center(child: Text('OPEN')),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: retro.RetroButton(
                                  onTap: widget.onDelete,
                                  child: const Center(
                                    child: Text(
                                      'DELETE',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (widget.replies.isNotEmpty)
                              retro.RetroButton(
                                onTap: () =>
                                    setState(() => showReplies = !showReplies),
                                child: Text(
                                  showReplies ? 'HIDE' : 'SHOW',
                                  style: GoogleFonts.vt323(fontSize: 12),
                                ),
                              ),
                            if (widget.replies.isNotEmpty)
                              const SizedBox(width: 10),
                            retro.RetroButton(
                              onTap: widget.onOpen,
                              child: Text(
                                'OPEN',
                                style: GoogleFonts.vt323(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            retro.RetroButton(
                              onTap: widget.onDelete,
                              child: Text(
                                'DELETE',
                                style: GoogleFonts.vt323(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: ResponsiveHelper.defaultPadding,
            child: smallScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.thread.imagePath != null)
                        Image.network(
                          '127.0.0.1:3441/${widget.thread.imagePath}',
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        widget.thread.title,
                        style: GoogleFonts.vt323(
                          fontSize: ResponsiveHelper.getFontSize(context, 16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ImageboardText(text: widget.thread.content),
                    ],
                  )
                : Row(
                    children: [
                      if (widget.thread.imagePath != null)
                        Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 10),
                          child: Image.network(
                            'http://127.0.0.1:3441/${widget.thread.imagePath}',
                            fit: BoxFit.cover,
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.thread.title,
                              style: GoogleFonts.vt323(
                                fontSize: ResponsiveHelper.getFontSize(
                                  context,
                                  16,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ImageboardText(text: widget.thread.content),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          // Replies preview
          if (showReplies && widget.replies.isNotEmpty)
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8F8),
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: ResponsiveHelper.defaultPadding,
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black12)),
                    ),
                    child: Text(
                      'REPLIES (${widget.replies.length})',
                      style: GoogleFonts.vt323(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.getFontSize(context, 14),
                      ),
                    ),
                  ),
                  ...widget.replies.take(5).map((r) => ReplyPreview(reply: r)),
                  if (widget.replies.length > 5)
                    Padding(
                      padding: ResponsiveHelper.defaultPadding,
                      child: Text(
                        '...and ${widget.replies.length - 5} more',
                        style: GoogleFonts.vt323(
                          fontSize: ResponsiveHelper.getFontSize(context, 12),
                          color: Colors.black54,
                        ),
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

class ReplyPreview extends StatelessWidget {
  final Post reply;
  const ReplyPreview({super.key, required this.reply});

  String formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = reply.id % 2 == 0 ? Colors.white : Colors.grey[100];

    return Container(
      padding: ResponsiveHelper.defaultPadding,
      color: bgColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              border: Border.all(color: Colors.black),
            ),
            child: Text(
              reply.formattedId,
              style: GoogleFonts.vt323(fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          if (reply.imagePath != null)
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                image: DecorationImage(
                  image: NetworkImage(
                    'http://127.0.0.1:3441/${reply.imagePath}',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(reply.createdAt),
                  style: GoogleFonts.vt323(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                ImageboardText(text: reply.content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
