// screens/board_list_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/retro_header.dart';
import '../widgets/retro_button.dart' as retro;
import '../database/database_helper.dart';
import '../models/thread.dart';
import '../widgets/imageboard_text.dart';
import '../utils/responsive_helper.dart';
import 'board_screen.dart';
import 'thread_screen.dart';
import 'moderator_login_screen.dart';

class BoardListScreen extends StatefulWidget {
  const BoardListScreen({super.key});

  @override
  _BoardListScreenState createState() => _BoardListScreenState();
}

class _BoardListScreenState extends State<BoardListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Thread> _recentThreads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentThreads();
  }

  Future<void> _loadRecentThreads() async {
    try {
      final threads = await _dbHelper.getAllThreads();
      setState(() {
        _recentThreads = threads.take(20).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading threads: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchThreads(String query) async {
    if (query.isEmpty) {
      _loadRecentThreads();
      return;
    }

    try {
      final threads = await _dbHelper.searchThreads(query);
      setState(() {
        _recentThreads = threads;
      });
    } catch (e) {
      print('Error searching threads: $e');
    }
  }

  void _openModeratorLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ModeratorLoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RetroHeader(
        title: 'Retro Imageboard',
        boards: const ['/b/', '/g/', '/v/', '/a/'],
        onBoardTap: (board) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BoardScreen(boardName: board),
            ),
          );
        },
        onSearch: _searchThreads,
      ),
      body: Column(
        children: [
          // Moderator Login Section - Responsive
          Container(
            width: double.infinity,
            padding: ResponsiveHelper.getResponsivePadding(context),
            decoration: const BoxDecoration(
              color: Color(0xFFFFE6E6),
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 1),
              ),
            ),
            child: ResponsiveHelper.isSmallScreen(context)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Staff Access:',
                            style: GoogleFonts.vt323(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14), 
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: retro.RetroButton(
                              onTap: _openModeratorLogin,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.login, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Moderator Login',
                                    style: GoogleFonts.vt323(
                                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Demo: batman/ammar007',
                        style: GoogleFonts.vt323(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.security,
                        size: 20,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Staff Access:',
                        style: GoogleFonts.vt323(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(width: 12),
                      retro.RetroButton(
                        onTap: _openModeratorLogin,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.login, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Moderator Login',
                              style: GoogleFonts.vt323(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Demo: batman/ammar007',
                        style: GoogleFonts.vt323(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
          ),
          // Main Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _recentThreads.isEmpty
                    ? _buildEmptyState()
                    : _RecentThreadsGrid(threads: _recentThreads),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: ResponsiveHelper.getResponsivePadding(context) * 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: ResponsiveHelper.getResponsivePadding(context),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: ResponsiveHelper.isSmallScreen(context) ? 48 : 64,
                    color: Colors.black54,
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0C0C0),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Text(
                      'NO CURRENT THREADS',
                      style: GoogleFonts.vt323(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                  Text(
                    'Create the first thread in any board to get started!',
                    style: GoogleFonts.vt323(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentThreadsGrid extends StatelessWidget {
  final List<Thread> threads;

  const _RecentThreadsGrid({required this.threads});

  // FIXED: Removed context usage from this method
  int _computeCrossAxisCount(double width) {
    if (width < 400) return 1;      // Very small screens
    if (width < 600) return 2;      // Small screens  
    if (width < 900) return 3;      // Medium screens
    if (width < 1200) return 4;     // Large screens
    return 5;                       // Very large screens
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header section
        Container(
          width: double.infinity,
          padding: ResponsiveHelper.getResponsivePadding(context),
          decoration: const BoxDecoration(
            color: Color(0xFFE0E0E0),
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 1),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0C0C0),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Text(
                    'RECENT THREADS',
                    style: GoogleFonts.vt323(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16), 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                Text(
                  '${threads.length} threads across all boards',
                  style: GoogleFonts.vt323(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14), 
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Threads grid
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final count = _computeCrossAxisCount(constraints.maxWidth);
              return Padding(
                padding: ResponsiveHelper.getResponsivePadding(context),
                child: GridView.builder(
                  itemCount: threads.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count,
                    crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 12),
                    mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 12),
                    childAspectRatio: ResponsiveHelper.isSmallScreen(context) ? 0.8 : 3 / 4,
                  ),
                  itemBuilder: (context, index) {
                    final thread = threads[index];
                    return _ThreadCard(
                      thread: thread,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ThreadScreen(threadId: thread.id!),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ThreadCard extends StatelessWidget {
  final Thread thread;
  final VoidCallback onTap;

  const _ThreadCard({required this.thread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const silver = Color(0xFFC0C0C0);
    const chrome = Color(0xFFE0E0E0);

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: chrome,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: _ThreadImage(imagePath: thread.imagePath),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                padding: ResponsiveHelper.getResponsivePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Board and ID - Single scrollable row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: silver,
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Text(
                              thread.board,
                              style: GoogleFonts.vt323(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14), 
                                color: Colors.black,
                              ),
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
                              thread.formattedId,
                              style: GoogleFonts.vt323(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12), 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                    Text(
                      '${thread.replies} replies',
                      style: GoogleFonts.vt323(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12), 
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                    // Title with proper overflow handling
                    Expanded(
                      flex: 2,
                      child: Text(
                        thread.title,
                        style: GoogleFonts.vt323(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18), 
                          color: Colors.black,
                        ),
                        maxLines: ResponsiveHelper.isSmallScreen(context) ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Content preview
                    if (thread.content.isNotEmpty)
                      Expanded(
                        flex: 1,
                        child: ImageboardText(
                          text: thread.content,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                          defaultColor: Colors.black54,
                        ),
                      ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                    Container(
                      height: 1,
                      color: Colors.black12,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadImage extends StatelessWidget {
  final String? imagePath;

  const _ThreadImage({this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return Container(
        color: const Color(0xFF9EC1C1),
        child: Center(
          child: Text(
            'NO IMAGE',
            style: GoogleFonts.vt323(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20), 
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    return Image.file(
      File(imagePath!),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFF9EC1C1),
        child: Center(
          child: Text(
            'IMAGE ERROR',
            style: GoogleFonts.vt323(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20), 
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
