// lib/screens/thread_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/post.dart';
import '../models/thread.dart';
import '../widgets/imageboard_text.dart';
import '../widgets/report_dialog.dart';
import '../widgets/retro_button.dart' as retro;
import '../widgets/retro_panel.dart';
import '../widgets/leopard_app_bar.dart';
import './image_preview_screen.dart';

class ThreadScreen extends StatefulWidget {
  final int threadId;
  const ThreadScreen({super.key, required this.threadId});
  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  // --- State Variables ---
  static const String baseUrl = 'http://0.0.0.0:3441/';
  final ImagePicker _picker = ImagePicker();
  Thread? thread;
  List<Post> replies = [];
  bool loading = true;
  bool error = false;
  String errorMessage = 'Failed to load thread.';
  final TextEditingController replyController = TextEditingController();
  XFile? selectedImage;

  // --- Lifecycle Method ---
  @override
  void initState() {
    super.initState();
    fetchThreadAndReplies();
  }

  // --- Backend and State Logic ---

  Future<void> fetchThreadAndReplies() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      error = false;
    });
    try {
      final threadUri = Uri.parse(
        '${baseUrl}get_thread.php?thread_id=${widget.threadId}',
      );
      final threadResp = await http
          .get(threadUri)
          .timeout(const Duration(seconds: 10));
      if (threadResp.statusCode != 200) {
        throw Exception('Server error: ${threadResp.statusCode}');
      }
      final threadJson = jsonDecode(threadResp.body);
      if (threadJson['success'] == true && threadJson['thread'] != null) {
        final threadData = Thread.fromJson(threadJson['thread']);
        final repliesUri = Uri.parse(
          '${baseUrl}replies.php?thread_id=${widget.threadId}',
        );
        final repliesResp = await http
            .get(repliesUri)
            .timeout(const Duration(seconds: 10));
        if (repliesResp.statusCode != 200) {
          throw Exception(
            'Server error loading replies: ${repliesResp.statusCode}',
          );
        }
        final repliesJson = jsonDecode(repliesResp.body) as List;
        final repliesData = repliesJson.map((e) => Post.fromJson(e)).toList();
        if (mounted) {
          setState(() {
            thread = threadData;
            replies = repliesData;
            loading = false;
          });
        }
      } else {
        throw Exception(threadJson['error'] ?? 'Failed to parse thread.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = true;
          errorMessage = e.toString();
          loading = false;
        });
        if (kDebugMode) print('Error fetching thread or replies: $e');
      }
    }
  }

  Future<void> pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          selectedImage = picked;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image pick error: $e')));
      }
    }
  }

  void removeSelectedImage() {
    setState(() {
      selectedImage = null;
    });
  }

  Future<void> postReply() async {
    final content = replyController.text.trim();
    if (content.isEmpty && selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter text or select an image')),
      );
      return;
    }
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}reply_create.php'),
      );
      request.fields['thread_id'] = widget.threadId.toString();
      request.fields['content'] = content;
      if (selectedImage != null) {
        final imageBytes = await selectedImage!.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: selectedImage!.name,
        );
        request.files.add(multipartFile);
      }
      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(body);
        if (jsonBody['success'] == true) {
          replyController.clear();
          removeSelectedImage();
          fetchThreadAndReplies();
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Reply posted!')));
          }
        } else {
          throw Exception(jsonBody['error'] ?? 'Unknown API error');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Post error: $e')));
      }
    }
  }

  void _showReportDialog({required int targetId, required String targetType}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ReportDialog(
          targetId: targetId,
          targetType: targetType,
          baseUrl: 'http://0.0.0.0:3441/',
        );
      },
    );
  }

  String formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // --- UI Build Method ---

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

    return Scaffold(
      appBar: LeopardAppBar(
        title: Text(thread!.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Report Thread',
            onPressed: () =>
                _showReportDialog(targetId: thread!.id, targetType: 'thread'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: theme.canvasColor,
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
                              isHighlighted: true,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${thread!.replies} replies',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (thread!.imagePath != null &&
                            thread!.imagePath!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ImagePreviewScreen(
                                      imageUrl: '$baseUrl${thread!.imagePath!}',
                                    ),
                                  ),
                                );
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 200,
                                      maxWidth: 200,
                                    ),
                                    child: Image.network(
                                      '$baseUrl${thread!.imagePath!}',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Text(
                          thread!.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ImageboardText(text: thread!.content, fontSize: 16),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Divider(height: 1)),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _replyItem(context, replies[index]),
                    );
                  }, childCount: replies.length),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(
              8.0,
            ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 8.0),
            decoration: BoxDecoration(
              color: theme.canvasColor,
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedImage != null) _buildSelectedImagePreview(),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    retro.RetroButton(
                      onTap: pickImage,
                      child: const Icon(Icons.image_outlined, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: replyController,
                        decoration: const InputDecoration(
                          hintText: 'Write a reply...',
                        ),
                        maxLines: 5,
                        minLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    retro.RetroButton(
                      onTap: postReply,
                      child: const Text('Reply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildSelectedImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: kIsWeb
              ? Image.network(selectedImage!.path, height: 100)
              : Image.file(File(selectedImage!.path), height: 100),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Colors.black.withOpacity(0.6),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.close, size: 16, color: Colors.white),
              onPressed: removeSelectedImage,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pill(
    BuildContext context,
    String text, {
    bool isHighlighted = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isHighlighted
            ? theme.colorScheme.primary.withOpacity(0.2)
            : theme.dividerColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: isHighlighted
              ? theme.colorScheme.primary
              : theme.textTheme.labelSmall?.color,
        ),
      ),
    );
  }

  Widget _replyItem(BuildContext context, Post reply) {
    final theme = Theme.of(context);
    return RetroPanel(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _pill(context, reply.formattedId),
              const SizedBox(width: 8),
              Text(
                formatTime(reply.createdAt),
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              SizedBox(
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  tooltip: 'Report Reply',
                  onPressed: () => _showReportDialog(
                    targetId: reply.id,
                    targetType: 'reply',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (reply.imagePath != null && reply.imagePath!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ImagePreviewScreen(
                        imageUrl: '$baseUrl${reply.imagePath!}',
                      ),
                    ),
                  );
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                        maxWidth: 200,
                      ),
                      child: Image.network(
                        '$baseUrl${reply.imagePath!}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ImageboardText(text: reply.content, fontSize: 14),
        ],
      ),
    );
  }
}
