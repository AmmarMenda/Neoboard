// lib/screens/board_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/responsive_helper.dart';
import '../widgets/retro_button.dart' as retro;
import '../widgets/retro_header.dart';
import 'create_thread_screen.dart';

class BoardScreen extends StatefulWidget {
  final String board;

  const BoardScreen({super.key, required this.board});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  List<Map<String, dynamic>> _threads = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchThreads();
  }

  Future<void> _fetchThreads() async {
    // TODO: Implement your actual API call to fetch threads here
    setState(() => _loading = true);

    await Future.delayed(const Duration(seconds: 1)); // simulate network delay

    setState(() {
      _threads = [
        {'id': 1, 'title': 'Welcome to the board!', 'content': 'Introduce yourself here.'},
        {'id': 2, 'title': 'Rules and guidelines', 'content': 'Please read before posting.'},
      ];
      _loading = false;
    });
  }

  Future<void> _openCreateThreadScreen() async {
    final newThread = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => CreateThreadScreen(board: widget.board),
      ),
    );

    if (newThread != null) {
      setState(() {
        _threads.insert(0, newThread); // Add new thread at top
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RetroHeader(
        title: 'NeoBoard',
        boards: ['/b/', '/g/', '/v/', '/a/'],
        selectedBoard: widget.board,
        onBoardTap: (board) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => BoardScreen(board: board)),
          );
        },
        onSearch: (query) {
          // Implement search logic if needed
        },
        showHome: true,
        showSearch: true,
      ),
      body: Padding(
        padding: ResponsiveHelper.defaultPadding,
        child: Column(
          children: [
            retro.RetroButton(
              onTap: _openCreateThreadScreen,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 8),
                  Text(
                    'Create New Thread',
                    style: GoogleFonts.vt323(
                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _threads.isEmpty
                      ? Center(
                          child: Text(
                            'No threads yet.\nBe the first to create one!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.vt323(fontSize: 18),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _threads.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final thread = _threads[index];
                            return ListTile(
                              title: Text(
                                thread['title'] ?? '',
                                style: GoogleFonts.vt323(
                                  fontSize: ResponsiveHelper.getFontSize(context, 20),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                thread['content'] ?? '',
                                style: GoogleFonts.vt323(
                                    fontSize: ResponsiveHelper.getFontSize(context, 16)),
                              ),
                              onTap: () {
                                // Navigate to thread details screen if exists
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
