// lib/screens/board_list.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../models/thread.dart';
import '../widgets/retro_button.dart' as retro;
import '../widgets/retro_header.dart';
import '../utils/responsive_helper.dart';
import 'moderator_login_screen.dart';
import 'thread_screen.dart';
import 'create_thread_screen.dart';

class BoardListScreen extends StatefulWidget {
  const BoardListScreen({super.key});

  @override
  State<BoardListScreen> createState() => _BoardListScreenState();
}

class _BoardListScreenState extends State<BoardListScreen> {
  static const String baseUrl = 'http://127.0.0.1:3441';
  final List<Thread> _threads = [];
  bool _loading = false;
  bool _error = false;

  final List<String> _boards = ['/', '/b/', '/g/', '/v/', '/a/'];
  String _selectedBoard = '/';

  @override
  void initState() {
    super.initState();
    _fetchThreads();
  }

  Future<void> _fetchThreads() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      // This part dynamically creates the URL. If a board like '/b/' is selected,
      // it becomes '.../threads.php?board=b', filtering the results.
      final uri = Uri.parse(
        '$baseUrl/threads.php${_selectedBoard == '/' ? '' : '?board=${_selectedBoard.replaceAll('/', '')}'}',
      );
      final resp = await http.get(uri);

      if (resp.statusCode != 200) throw Exception('Failed to load threads');

      final List data = jsonDecode(resp.body);
      final threads = data.map((json) => Thread.fromJson(json)).toList();

      setState(() {
        _threads.clear();
        _threads.addAll(threads);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _loading = false;
      });
      if (kDebugMode) print('Error fetching threads: $e');
    }
  }

  // This method is called when a board is tapped in the header.
  // It updates the state and re-fetches the threads for the selected board.
  void _onBoardSelected(String board) {
    setState(() {
      _selectedBoard = board;
    });
    _fetchThreads();
  }

  void _openThread(Thread thread) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ThreadScreen(threadId: thread.id)),
    );
  }

  void _openModeratorLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ModeratorLoginScreen()),
    );
  }

  void _createNewThread() async {
    // When creating a new thread, it defaults to the currently selected board.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateThreadScreen(board: _selectedBoard),
      ),
    );

    if (result != null) {
      _fetchThreads(); // Refresh the list to show the new thread.
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmall = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      appBar: RetroHeader(
        title: 'NeoBoard',
        boards: _boards,
        selectedBoard: _selectedBoard,
        onBoardTap: _onBoardSelected, // Correctly wired to filter threads.
        onSearch: (q) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Search not implemented yet. Query: $q')),
          );
        },
        showHome: false,
        showSearch: true,
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFE0E0E0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: ResponsiveHelper.getResponsivePadding(context),
                  color: const Color(0xFFFFE6E6),
                  child: isSmall
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.security,
                                  size: 16,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Staff Access:',
                                  style: GoogleFonts.vt323(
                                    fontSize: ResponsiveHelper.getFontSize(
                                      context,
                                      14,
                                    ),
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: retro.RetroButton(
                                onTap: _openModeratorLogin,
                                child: Text(
                                  'Moderator Login',
                                  style: GoogleFonts.vt323(
                                    fontSize: ResponsiveHelper.getFontSize(
                                      context,
                                      16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Demo: batman/ammar007',
                              style: GoogleFonts.vt323(
                                fontSize: ResponsiveHelper.getFontSize(
                                  context,
                                  12,
                                ),
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(
                              Icons.security,
                              size: 20,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Staff Access:',
                              style: GoogleFonts.vt323(
                                fontSize: ResponsiveHelper.getFontSize(
                                  context,
                                  14,
                                ),
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 12),
                            retro.RetroButton(
                              onTap: _openModeratorLogin,
                              child: Text(
                                'Moderator Login',
                                style: GoogleFonts.vt323(
                                  fontSize: ResponsiveHelper.getFontSize(
                                    context,
                                    16,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Demo: batman/ammar007',
                              style: GoogleFonts.vt323(
                                fontSize: ResponsiveHelper.getFontSize(
                                  context,
                                  12,
                                ),
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error
                      ? Center(
                          child: Text(
                            "Failed to load threads",
                            style: GoogleFonts.vt323(
                              fontSize: ResponsiveHelper.getFontSize(
                                context,
                                18,
                              ),
                              color: Colors.red,
                            ),
                          ),
                        )
                      : _threads.isEmpty
                      ? Center(
                          child: Text(
                            "No threads found on $_selectedBoard",
                            style: GoogleFonts.vt323(
                              fontSize: ResponsiveHelper.getFontSize(
                                context,
                                20,
                              ),
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            ResponsiveHelper.getResponsivePadding(context).left,
                            ResponsiveHelper.getResponsivePadding(context).top,
                            ResponsiveHelper.getResponsivePadding(
                              context,
                            ).right,
                            80, // Padding at the bottom for the button
                          ),
                          itemCount: _threads.length,
                          itemBuilder: (_, i) {
                            final t = _threads[i];
                            return ThreadListItem(
                              thread: t,
                              onTap: () => _openThread(t),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          if (!_loading && !_error)
            Positioned(
              bottom: 16,
              left: 16,
              child: retro.RetroButton(
                onTap: _createNewThread,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'New Thread',
                    style: GoogleFonts.vt323(
                      fontSize: ResponsiveHelper.getFontSize(context, 16),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ThreadListItem extends StatelessWidget {
  final Thread thread;
  final VoidCallback onTap;

  const ThreadListItem({super.key, required this.thread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          bottom: ResponsiveHelper.getFontSize(context, 12),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Row(
          children: [
            _threadImage(),
            Expanded(child: _threadInfo(context)),
          ],
        ),
      ),
    );
  }

  Widget _threadImage() {
    if (thread.imagePath == null || thread.imagePath!.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        color: const Color(0xFF9EC1C1),
        alignment: Alignment.center,
        child: Text(
          "NO IMG",
          style: GoogleFonts.vt323(fontSize: 10, color: Colors.black54),
        ),
      );
    }
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage("http://127.0.0.1:3441/${thread.imagePath}"),
        ),
      ),
    );
  }

  Widget _threadInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pill(thread.board, const Color(0xFFC0C0C0)),
          const SizedBox(height: 4),
          Text(
            thread.title,
            style: GoogleFonts.vt323(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getFontSize(context, 16),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "${thread.replies} replies",
            style: GoogleFonts.vt323(
              fontSize: ResponsiveHelper.getFontSize(context, 13),
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          if (thread.content.isNotEmpty)
            SizedBox(
              height: 40,
              child: SingleChildScrollView(
                child: Text(
                  thread.content,
                  style: GoogleFonts.vt323(
                    fontSize: ResponsiveHelper.getFontSize(context, 13),
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        text,
        style: GoogleFonts.vt323(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
