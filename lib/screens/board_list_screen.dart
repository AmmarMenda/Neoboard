// lib/screens/board_list.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/thread.dart';
import '../widgets/retro_button.dart' as retro;
import '../widgets/retro_header.dart';
import '../widgets/retro_panel.dart';
import '../utils/responsive_helper.dart';
import 'moderator_login_screen.dart';
import 'thread_screen.dart';
import 'create_thread_screen.dart';
import 'coordinator_form_screen.dart';
import 'board_grid_screen.dart'; // Add this import

class BoardListScreen extends StatefulWidget {
  final String? initialBoard; // Add this parameter

  const BoardListScreen({super.key, this.initialBoard});
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
    if (widget.initialBoard != null) {
      _selectedBoard = widget.initialBoard!;
    }
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

      if (mounted) {
        setState(() {
          _threads.clear();
          _threads.addAll(threads);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
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

  void _openCoordinatorForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CoordinatorFormScreen()),
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
    final theme = Theme.of(context); // Get theme for styling

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
        onHome: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BoardGridScreen()),
          );
        },
        showHome: true, // Changed from false to true
        showSearch: true,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // *** THE FIX: Staff access panel is now themed ***
              Container(
                width: double.infinity,
                padding: ResponsiveHelper.getResponsivePadding(context, 16, 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  border: Border(bottom: BorderSide(color: theme.dividerColor)),
                ),
                child: isSmall
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.security,
                                size: 16,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Staff Access:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: retro.RetroButton(
                              onTap: _openModeratorLogin,
                              child: const Text('Moderator Login'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: retro.RetroButton(
                              onTap: _openCoordinatorForm,
                              child: const Text('Co-ordinator Form'),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Demo: batman/ammar007',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(
                            Icons.security,
                            size: 20,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Staff Access:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          retro.RetroButton(
                            onTap: _openModeratorLogin,
                            child: const Text('Moderator Login'),
                          ),
                          const SizedBox(width: 12),
                          retro.RetroButton(
                            onTap: _openCoordinatorForm,
                            child: const Text('Co-ordinator Form'),
                          ),
                          const Spacer(),
                          Text(
                            'Demo: batman/ammar007',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              // *** THE FIX: Main content area with themed states ***
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error
                    ? Center(
                        child: Text(
                          "Failed to load threads",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      )
                    : _threads.isEmpty
                    ? Center(
                        child: Text(
                          "No threads found on $_selectedBoard",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          ResponsiveHelper.getResponsivePadding(
                            context,
                            16,
                            12,
                          ).left,
                          ResponsiveHelper.getResponsivePadding(
                            context,
                            16,
                            12,
                          ).top,
                          ResponsiveHelper.getResponsivePadding(
                            context,
                            16,
                            12,
                          ).right,
                          80, // Padding at the bottom for the floating button
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
          // *** THE FIX: Floating action button is now themed ***
          if (!_loading && !_error)
            Positioned(
              bottom: 16,
              left: 16,
              child: retro.RetroButton(
                onTap: _createNewThread,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 6),
                    Text('New Thread'),
                  ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RetroPanel(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          child: Row(
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
      return Container(
        width: 80,
        height: 80,
        color: theme.colorScheme.surfaceVariant,
        alignment: Alignment.center,
        child: Text(
          "NO IMG",
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage("http://127.0.0.1:3441/${thread.imagePath}"),
        ),
      ),
    );
  }

  Widget _threadInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pill(context, thread.board),
          const SizedBox(height: 6),
          Text(
            thread.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "${thread.replies} replies",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          if (thread.content.isNotEmpty) ...[
            const SizedBox(height: 6),
            SizedBox(
              height: 40,
              child: SingleChildScrollView(
                child: Text(
                  thread.content,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
