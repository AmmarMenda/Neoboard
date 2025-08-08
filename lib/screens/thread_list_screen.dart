import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/board.dart';
import '../models/thread.dart';
import '../services/dummy_data.dart';
import 'thread_detail_screen.dart';
import '../widgets/retro_panel.dart';

// NOTE: This widget no longer needs its own navigation or FAB logic.
// It simply displays the grid for a given board.
class ThreadListScreen extends StatefulWidget {
  final Board board;
  const ThreadListScreen({super.key, required this.board});

  @override
  _ThreadListScreenState createState() => _ThreadListScreenState();
}

class _ThreadListScreenState extends State<ThreadListScreen> {
  @override
  Widget build(BuildContext context) {
    // We fetch the data directly in the build method.
    // This ensures the list is up-to-date when the parent rebuilds.
    final threads = DummyDataService().getThreadsForBoard(widget.board.id);

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: threads.length,
      itemBuilder: (context, index) {
        final thread = threads[index];
        return GestureDetector(
          onTap: () {
            // Navigation to detail screen remains the same,
            // but we call setState here to refresh this screen
            // when we pop back (e.g., to update reply count).
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThreadDetailScreen(thread: thread),
              ),
            ).then((_) => setState(() {}));
          },
          child: RetroPanel(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: thread.imagePath != null
                      ? Image.file(
                          File(thread.imagePath!),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread.title,
                        style: GoogleFonts.vt323(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Replies: ${thread.replies.length}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
