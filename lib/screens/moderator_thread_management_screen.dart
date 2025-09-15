// lib/screens/moderator_thread_management_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // This import will now work correctly
import '../models/thread.dart';
import '../models/post.dart';
import '../widgets/imageboard_text.dart';
import '../widgets/retro_button.dart' as retro;
import '../utils/responsive_helper.dart';
import 'moderator_thread_view_screen.dart';
import '../widgets/delete_thread_dialog.dart';
import '../widgets/leopard_app_bar.dart';
import '../widgets/retro_panel.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const LeopardAppBar(title: Text('Thread Management')),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            padding: ResponsiveHelper.defaultPadding,
            decoration: BoxDecoration(
              color: theme.canvasColor,
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                const Icon(Icons.list_alt_outlined),
                const SizedBox(width: 8),
                Text('Filter by board:', style: theme.textTheme.bodyMedium),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: selectedBoard,
                  items: boards
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
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
                Text(
                  'Threads: ${threads.length}',
                  style: theme.textTheme.bodyMedium,
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
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
    );
  }
}

Widget _pill(BuildContext context, String text, {Color? color}) {
  final theme = Theme.of(context);
  final effectiveColor = color ?? theme.colorScheme.primary;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: effectiveColor.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: effectiveColor.withOpacity(0.5)),
    ),
    child: Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: effectiveColor,
        fontWeight: FontWeight.bold,
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
  String formatDate(DateTime dt) => DateFormat('dd/MM/yy HH:mm').format(dt);

  @override
  Widget build(BuildContext context) {
    final bool smallScreen = ResponsiveHelper.isSmallScreen(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: RetroPanel(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _pill(context, widget.thread.board),
                  const SizedBox(width: 6),
                  _pill(
                    context,
                    widget.thread.formattedId,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Replies: ${widget.replies.length} • ${formatDate(widget.thread.createdAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.thread.imagePath != null)
                  Container(
                    width: smallScreen ? 60 : 80,
                    height: smallScreen ? 60 : 80,
                    margin: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        'http://127.0.0.1:3441/${widget.thread.imagePath!}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.thread.title,
                        style: theme.textTheme.titleMedium?.copyWith(
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
            const Divider(height: 24),
            smallScreen ? _buildMobileButtons() : _buildDesktopButtons(),
            if (showReplies && widget.replies.isNotEmpty)
              _buildRepliesPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopButtons() {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (widget.replies.isNotEmpty) ...[
          retro.RetroButton(
            onTap: () => setState(() => showReplies = !showReplies),
            child: Text(showReplies ? 'HIDE' : 'SHOW'),
          ),
          const SizedBox(width: 10),
        ],
        retro.RetroButton(onTap: widget.onOpen, child: const Text('OPEN')),
        const Spacer(),
        retro.RetroButton(
          onTap: widget.onDelete,
          child: Text(
            'DELETE',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileButtons() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.replies.isNotEmpty) ...[
          retro.RetroButton(
            onTap: () => setState(() => showReplies = !showReplies),
            child: Text(showReplies ? 'HIDE REPLIES' : 'SHOW REPLies'),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: retro.RetroButton(
                onTap: widget.onOpen,
                child: const Text('OPEN'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: retro.RetroButton(
                onTap: widget.onDelete,
                child: Text(
                  'DELETE',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRepliesPreview() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
              child: Text(
                'REPLIES (${widget.replies.length})',
                style: theme.textTheme.labelLarge,
              ),
            ),
            ...widget.replies.take(5).map((r) => ReplyPreview(reply: r)),
            if (widget.replies.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                child: Text(
                  '...and ${widget.replies.length - 5} more',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ReplyPreview extends StatelessWidget {
  final Post reply;
  const ReplyPreview({super.key, required this.reply});

  String formatDate(DateTime dt) {
    return DateFormat('dd/MM/yy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reply.formattedId,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(reply.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                ImageboardText(text: reply.content, fontSize: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
