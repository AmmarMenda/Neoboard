// lib/screens/thread_screen.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/post.dart';
import '../models/thread.dart';
import '../utils/responsive_helper.dart';
import '../widgets/imageboard_text.dart';
import '../widgets/report_dialog.dart'; // Make sure this import is correct
import '../widgets/retro_button.dart' as retro;

class ThreadScreen extends StatefulWidget {
  final int threadId;

  const ThreadScreen({super.key, required this.threadId});

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  // Use /api/ subfolder for all endpoints
  static const String baseUrl = 'http://127.0.0.1:3441/';
  final ImagePicker _picker = ImagePicker();

  Thread? thread;
  List<Post> replies = [];

  bool loading = true;
  bool error = false;
  String errorMessage = 'Failed to load thread.';

  final TextEditingController replyController = TextEditingController();
  XFile? selectedImage;

  @override
  void initState() {
    super.initState();
    fetchThreadAndReplies();
  }

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
        if (kDebugMode) {
          print('Error fetching thread or replies: $e');
        }
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
          // IMPORTANT: The URL must point to the api directory
          baseUrl: 'http://127.0.0.1:3441/',
        );
      },
    );
  }

  String formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: const Color(0xFFC0C0C0),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error || thread == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: const Color(0xFFC0C0C0),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.vt323(fontSize: 18, color: Colors.red),
            ),
          ),
        ),
      );
    }

    final isSmall = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(thread!.title, style: GoogleFonts.vt323(fontSize: 20)),
        backgroundColor: const Color(0xFFC0C0C0),
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
          Container(
            padding: ResponsiveHelper.defaultPadding,
            constraints: BoxConstraints(maxHeight: isSmall ? 250 : 300),
            color: const Color(0xFFE0E0E0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _pill(thread!.board),
                      const SizedBox(width: 6),
                      _pill(thread!.formattedId, color: Colors.redAccent),
                      const SizedBox(width: 10),
                      Text(
                        '${thread!.replies} replies',
                        style: GoogleFonts.vt323(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (thread!.imagePath != null)
                    Image.network(
                      '$baseUrl${thread!.imagePath!}',
                      height: isSmall ? 150 : 200,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    thread!.title,
                    style: GoogleFonts.vt323(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ImageboardText(text: thread!.content, fontSize: 16),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: replies.length,
              itemBuilder: (_, i) => _replyItem(replies[i]),
            ),
          ),
          Container(
            padding: ResponsiveHelper.defaultPadding,
            decoration: const BoxDecoration(
              color: Color(0xFFE0E0E0),
              border: Border(top: BorderSide(color: Colors.black)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedImage != null)
                  Stack(
                    children: [
                      if (kIsWeb)
                        Image.network(selectedImage!.path, height: 100)
                      else
                        Image.file(File(selectedImage!.path), height: 100),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: removeSelectedImage,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    retro.RetroButton(
                      onTap: pickImage,
                      child: const Icon(Icons.image),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: replyController,
                        decoration: const InputDecoration(
                          hintText: 'Write a reply...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                        ),
                        maxLines: 3,
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

  Widget _pill(String text, {Color color = const Color(0xFFC0C0C0)}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(text, style: GoogleFonts.vt323(fontSize: 14)),
    );
  }

  Widget _replyItem(Post reply) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pill(reply.formattedId, color: const Color(0xFFD0D0D0)),
          const SizedBox(width: 8),
          if (reply.imagePath != null)
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTime(reply.createdAt),
                      style: GoogleFonts.vt323(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.flag_outlined,
                          size: 16,
                          color: Colors.grey,
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
