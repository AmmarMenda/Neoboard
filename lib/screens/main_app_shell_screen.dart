import 'package:flutter/material.dart';
import '../models/board.dart';
import '../services/dummy_data.dart';
import 'create_thread_screen.dart';
import 'thread_list_screen.dart'; // We will modify this file next

class MainAppShellScreen extends StatefulWidget {
  const MainAppShellScreen({super.key});

  @override
  _MainAppShellScreenState createState() => _MainAppShellScreenState();
}

class _MainAppShellScreenState extends State<MainAppShellScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Board> _boards = DummyDataService().getBoards();
  final _dataService = DummyDataService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _boards.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToCreateThread() async {
    // Get the board for the currently active tab
    final currentBoard = _boards[_tabController.index];

    final result = await Navigator.push<Map<String, String?>>(
      context,
      MaterialPageRoute(builder: (context) => const CreateThreadScreen()),
    );

    if (result != null) {
      _dataService.addThread(
        currentBoard.id,
        result['title']!,
        result['content']!,
        result['imagePath'],
      );
      // Call setState to rebuild the UI and show the new thread
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Retro Imageboard'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Allows tabs to scroll if they don't all fit
          tabs: _boards.map((board) => Tab(text: board.title)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // For each board, create a ThreadListScreen view
        children: _boards.map((board) => ThreadListScreen(board: board)).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateThread,
        backgroundColor: Color(0xFFC0C0C0),
        child: Icon(Icons.add, color: Colors.black),
        shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
            side: BorderSide(color: Colors.white, width: 2)),
      ),
    );
  }
}
