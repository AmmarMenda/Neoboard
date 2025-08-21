// lib/screens/board_list.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// *** THE FIX: We no longer need to import google_fonts here. ***
// import 'package:google_fonts/google_fonts.dart';

import '../models/thread.dart';
import '../widgets/retro_button.dart' as retro;
import '../widgets/retro_header.dart';
import '../widgets/retro_panel.dart'; // Import the panel widget
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateThreadScreen(board: _selectedBoard),
      ),
    );
    if (result != null) {
      _fetchThreads();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmall = ResponsiveHelper.isSmallScreen(context);
    final theme = Theme.of(context); // Get the theme for styling

    return Scaffold(
      appBar: RetroHeader(
        title: 'NeoBoard',
        boards: _boards,
        selectedBoard: _selectedBoard,
        onBoardTap: _onBoardSelected,
        onSearch: (q) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Search not implemented yet. Query: $q')),
          );
        },
        showHome: false,
        showSearch: true,
      ),
      // *** THE FIX: Use the theme's background color directly on the Scaffold. ***
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // *** THE FIX: The staff access banner now uses theme colors. ***
              Container(
                width: double.infinity,
                padding: ResponsiveHelper.getResponsivePadding(context, 16, 12),
                color: theme.colorScheme.primary.withOpacity(0.05),
                child: isSmall
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStaffAccessRow(isSmall, theme),
                          const SizedBox(height: 8),
                          _buildModeratorLogin(isSmall, theme),
                        ],
                      )
                    : _buildModeratorLogin(isSmall, theme),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error
                    ? Center(
                        // *** THE FIX: Use theme font and color for error message. ***
                        child: Text(
                          "Failed to load threads",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      )
                    : _threads.isEmpty
                    ? Center(
                        // *** THE FIX: Use theme font and color for empty message. ***
                        child: Text(
                          "No threads found on $_selectedBoard",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          80, // Consistent padding
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
                  // *** THE FIX: Text now correctly inherits font from button. ***
                  child: Text('New Thread'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper widgets for cleanliness
  Widget _buildStaffAccessRow(bool isSmall, ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.security,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Text(
          'Staff Access:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildModeratorLogin(bool isSmall, ThemeData theme) {
    final moderatorButton = retro.RetroButton(
      onTap: _openModeratorLogin,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      // *** THE FIX: Text now correctly inherits font from button. ***
      child: Text('Moderator Login'),
    );
    final demoText = Text(
      'Demo: batman/ammar007',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ),
    );

    if (isSmall) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: double.infinity, child: moderatorButton),
          const SizedBox(height: 4),
          demoText,
        ],
      );
    } else {
      return Row(
        children: [
          _buildStaffAccessRow(isSmall, theme),
          const SizedBox(width: 12),
          moderatorButton,
          const Spacer(),
          demoText,
        ],
      );
    }
  }
}

class ThreadListItem extends StatelessWidget {
  final Thread thread;
  final VoidCallback onTap;
  const ThreadListItem({super.key, required this.thread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // *** THE FIX: Use GestureDetector + RetroPanel for consistent styling. ***
    return GestureDetector(
      onTap: onTap,
      child: RetroPanel(
        padding: EdgeInsets.zero, // Padding is handled internally
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _threadImage(context),
              Expanded(child: _threadInfo(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _threadImage(BuildContext context) {
    final theme = Theme.of(context);
    if (thread.imagePath == null || thread.imagePath!.isEmpty) {
      // *** THE FIX: Themed "NO IMG" placeholder. ***
      return Container(
        width: 80,
        height: 80,
        color: theme.dividerColor.withOpacity(0.5),
        alignment: Alignment.center,
        child: Text(
          "NO IMG",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }
    return SizedBox(
      width: 80,
      height: 80,
      child: Image.network(
        "http://127.0.0.1:3441/${thread.imagePath}",
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _threadInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pill(context, thread.board), // Pass context to pill for theming
          const SizedBox(height: 4),
          // *** THE FIX: Use theme font for title. ***
          Text(
            thread.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // *** THE FIX: Use theme font for replies. ***
          Text("${thread.replies} replies", style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          if (thread.content.isNotEmpty)
            Text(
              thread.content,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  // *** THE FIX: Pill widget is now themed correctly. ***
  Widget _pill(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
