import 'package:uuid/uuid.dart'; // Add a package for unique IDs
import '../models/board.dart';
import '../models/thread.dart';
import '../models/reply.dart';

// Run 'flutter pub add uuid' in your terminal

class DummyDataService {
  static final _uuid = Uuid();

  // Remove 'final' to make the list modifiable
  static List<Board> boards = [
    Board(id: 'b', title: '/b/ - Random', description: 'Anything goes'),
    Board(id: 'g', title: '/g/ - Technology', description: 'Gadgets and code'),
    Board(id: 'v', title: '/v/ - Video Games', description: 'All about gaming'),
  ];

  static List<Thread> threads = [
    Thread(
      id: 't1',
      boardId: 'b',
      title: 'Retro app thread',
      content: 'This is the first post in a retro-style app!',
      replies: [
        Reply(id: 'r1', content: 'Wow, this looks like 1998!'),
        Reply(id: 'r2', content: 'Cool font.'),
      ],
    ),
    // ... other threads
  ];

  List<Board> getBoards() {
    return boards;
  }

  List<Thread> getThreadsForBoard(String boardId) {
    return threads.where((thread) => thread.boardId == boardId).toList();
  }

  // --- NEW METHODS ---

  void addThread(String boardId, String title, String content, String? imagePath) {
    final newThread = Thread(
      id: _uuid.v4(),
      boardId: boardId,
      title: title,
      content: content,
      imagePath: imagePath, // <-- Pass the image path
      replies: [],
    );
    threads.insert(0, newThread);
  }

  void addReply(String threadId, String content, String? imagePath) {
    final newReply = Reply(
      id: _uuid.v4(),
      content: content,
      imagePath: imagePath, // <-- Pass the image path
    );
    final threadIndex = threads.indexWhere((t) => t.id == threadId);
    if (threadIndex != -1) {
      threads[threadIndex].replies.add(newReply);
    }
  }
}
