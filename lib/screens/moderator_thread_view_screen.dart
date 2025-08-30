// lib/screens/moderator_thread_view_screen.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../models/thread.dart';
import '../utils/responsive_helper.dart';
import '../widgets/imageboard_text.dart';
import '../widgets/retro_button.dart' as retro;
import '../widgets/leopard_app_bar.dart';
import '../widgets/retro_panel.dart';

class ModeratorThreadViewScreen extends StatefulWidget {
  final int threadId;
  const ModeratorThreadViewScreen({super.key, required this.threadId});
  @override
  State<ModeratorThreadViewScreen> createState() =>
      _ModeratorThreadViewScreenState();
}

class _ModeratorThreadViewScreenState extends State<ModeratorThreadViewScreen> {
  static const String baseUrl = 'http://192.168.1.12:3441/';
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

  // *** THE FIX: Restored the original, correct data-fetching logic ***
  Future<void> _loadThread() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      error = false;
    });
    try {
      // --- Fetch Thread ---
      final threadUri = Uri.parse(
        '${baseUrl}get_thread.php?thread_id=${widget.threadId}',
      );
      final threadResp = await http
          .get(threadUri)
          .timeout(const Duration(seconds: 10));
      if (threadResp.statusCode != 200) {
        throw Exception(
          'Server error: Failed to load thread with status code ${threadResp.statusCode}',
        );
      }
      final threadJson = json.decode(threadResp.body);
      if (threadJson['success'] == true && threadJson['thread'] != null) {
        final fetchedThread = Thread.fromJson(threadJson['thread']);
        // --- Fetch Replies ---
        final repliesUri = Uri.parse(
          '${baseUrl}replies.php?thread_id=${widget.threadId}',
        );
        final repliesResp = await http
            .get(repliesUri)
            .timeout(const Duration(seconds: 10));
        if (repliesResp.statusCode != 200) {
          throw Exception(
            'Server error: Failed to load replies with status code ${repliesResp.statusCode}',
          );
        }
        final repliesJson = json.decode(repliesResp.body) as List;
        final fetchedReplies = repliesJson
            .map((e) => Post.fromJson(e))
            .toList();
        if (mounted) {
          setState(() {
            thread = fetchedThread;
            replies = fetchedReplies;
            loading = false;
          });
        }
      } else {
        throw Exception(
          threadJson['error'] ??
              'An unknown error occurred while fetching the thread.',
        );
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
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Theme.of(ctx).dialogTheme.backgroundColor,
            shape: Theme.of(ctx).dialogTheme.shape,
            title: Text(
              'Delete Reply',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            content: const Text(
              'Are you sure you want to delete this reply? This action is permanent.',
            ),
            actions: [
              retro.RetroButton(
                onTap: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              retro.RetroButton(
                onTap: () => Navigator.pop(ctx, true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                ),
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
        _loadThread();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reply deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(data['error'] ?? 'Delete failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting reply: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime dt) => DateFormat('dd/MM/yy HH:mm').format(dt);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return const Scaffold(
        appBar: LeopardAppBar(title: Text('Loading...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error || thread == null) {
      return Scaffold(
        appBar: const LeopardAppBar(title: Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
      );
    }

    final small = ResponsiveHelper.isSmallScreen(context);
    return Scaffold(
      appBar: LeopardAppBar(
        title: Text(thread!.title, overflow: TextOverflow.ellipsis),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            padding: ResponsiveHelper.defaultPadding,
            color: theme.canvasColor,
            constraints: BoxConstraints(maxHeight: small ? 250 : 300),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _pill(context, thread!.board),
                      const SizedBox(width: 6),
                      _pill(
                        context,
                        thread!.formattedId,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Replies: ${thread!.replies} • ${_formatTime(thread!.createdAt)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (thread!.imagePath != null &&
                      thread!.imagePath!.isNotEmpty)
                    Image.network(
                      '$baseUrl${thread!.imagePath!}',
                      height: small ? 150 : 200,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Text(
                        'Image failed to load',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    thread!.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ImageboardText(text: thread!.content),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: replies.length,
              separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _replyItem(context, replies[i]),
            ),
          ),
        ],
      ),
    );
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

  Widget _replyItem(BuildContext context, Post reply) {
    final theme = Theme.of(context);
    return RetroPanel(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reply.imagePath != null && reply.imagePath!.isNotEmpty)
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  '$baseUrl${reply.imagePath!}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _pill(context, reply.formattedId),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(reply.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ImageboardText(text: reply.content),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: retro.RetroButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    onTap: () => _deleteReply(reply.id),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 14,
                      ),
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
