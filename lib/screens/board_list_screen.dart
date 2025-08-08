import 'package:flutter/material.dart';
import '../services/dummy_data.dart';
import '../models/board.dart';
import 'thread_list_screen.dart';
import '../widgets/retro_button.dart'; // Import custom button

class BoardListScreen extends StatelessWidget {
  const BoardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final boards = DummyDataService().getBoards();

    return Scaffold(
      appBar: AppBar(title: Text('Boards')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: boards.length,
        itemBuilder: (context, index) {
          final board = boards[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: RetroButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThreadListScreen(board: board),
                  ),
                );
              },
              child: Text('${board.title} - ${board.description}', style: TextStyle(fontSize: 18)),
            ),
          );
        },
      ),
    );
  }
}
