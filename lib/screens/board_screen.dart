// screens/board_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/retro_header.dart';
import '../widgets/retro_button.dart' as retro;
import '../database/database_helper.dart';
import '../models/thread.dart';
import 'create_thread_screen.dart';
import 'thread_screen.dart';
import '../widgets/imageboard_text.dart';

class BoardScreen extends StatefulWidget {
  final String boardName;
  
  const BoardScreen({super.key, required this.boardName});

  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Thread> _boardThreads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBoardThreads();
  }

  Future<void> _loadBoardThreads() async {
    try {
      final threads = await _dbHelper.getThreadsByBoard(widget.boardName);
      setState(() {
        _boardThreads = threads;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading board threads: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewThread() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateThreadScreen(),
      ),
    );

    if (result != null) {
      try {
        final newThread = Thread(
          title: result['title'],
          content: result['content'],
          imagePath: result['imagePath'],
          board: widget.boardName,
        );

        await _dbHelper.insertThread(newThread);
        await _loadBoardThreads(); // Reload threads

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thread created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating thread: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RetroHeader(
        title: 'Board ${widget.boardName}',
        boards: const ['/b/', '/g/', '/v/', '/a/'],
        onBoardTap: (board) {
          if (board != widget.boardName) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BoardScreen(boardName: board),
              ),
            );
          }
        },
        onSearch: (q) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Searching ${widget.boardName} for: $q')),
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: retro.RetroButton(
                    onTap: _createNewThread,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Create New Thread',
                          style: GoogleFonts.vt323(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFE0E0E0),
              border: Border(
                top: BorderSide(color: Colors.black, width: 1),
                bottom: BorderSide(color: Colors.black, width: 1),
              ),
            ),
            child: Text(
              'Board ${widget.boardName} - ${_boardThreads.length} threads',
              style: GoogleFonts.vt323(fontSize: 16, color: Colors.black),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _boardThreads.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No threads yet',
                              style: GoogleFonts.vt323(fontSize: 24, color: Colors.black54),
                            ),
                            const SizedBox(height: 16),
                            retro.RetroButton(
                              onTap: _createNewThread,
                              child: Text(
                                'Create First Thread',
                                style: GoogleFonts.vt323(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _boardThreads.length,
                        itemBuilder: (context, index) {
                          final thread = _boardThreads[index];
                          return _ThreadListItem(
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
          ),
        ],
      ),
    );
  }
}

class _ThreadListItem extends StatelessWidget {
  final Thread thread;
  final VoidCallback onTap;

  const _ThreadListItem({
    required this.thread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const silver = Color(0xFFC0C0C0);
    const chrome = Color(0xFFE0E0E0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: chrome,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (thread.imagePath != null)
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  child: Image.file(
                    File(thread.imagePath!),
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9EC1C1),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      'IMG',
                      style: GoogleFonts.vt323(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.title,
                      style: GoogleFonts.vt323(fontSize: 18, color: Colors.black),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    ImageboardText(
  text: thread.content,
  fontSize: 14,
  defaultColor: Colors.black87,
),

                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: silver,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Text(
                        '${thread.replies} replies',
                        style: GoogleFonts.vt323(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
