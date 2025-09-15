// lib/screens/board_grid_screen.dart
import 'package:flutter/material.dart';
import '../models/board.dart';
import '../widgets/retro_button.dart';
import 'moderator_login_screen.dart';
import 'coordinator_form_screen.dart';
import 'board_list_screen.dart';

class BoardGridScreen extends StatelessWidget {
  const BoardGridScreen({super.key});

  // Board data with paths for navigation
  final List<Board> boards = const [
    Board(
      path: '/b/',
      name: 'Random',
      description: 'General discussion and random topics.',
      imageUrl: 'assets/b.jpeg',
    ),
    Board(
      path: '/g/',
      name: 'Technology',
      description: 'Gadgets, programming, and tech news.',
      imageUrl: 'assets/g.jpg',
    ),
    Board(
      path: '/v/',
      name: 'Video Games',
      description: 'All about video games and gaming culture.',
      imageUrl: 'assets/v.jpg',
    ),
    Board(
      path: '/a/',
      name: 'Anime & Manga',
      description: 'Discussion of Japanese animation and comics.',
      imageUrl: 'assets/a.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Title and Grouped Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Neoboard',
                    style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Grouped buttons on the right
                  Row(
                    children: [
                      RetroButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ModeratorLoginScreen(),
                            ),
                          );
                        },
                        child: const Text('Moderator Login'),
                      ),
                      const SizedBox(width: 8.0), // Spacing between buttons
                      RetroButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CoordinatorFormScreen(),
                            ),
                          );
                        },
                        child: const Text('Co-Ordinator Form'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // GIF from Assets
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'assets/animation.gif',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Grid of Boards (3 columns, smaller cards)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Three cards per row for smaller cards
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: boards.length,
                  itemBuilder: (context, index) {
                    final board = boards[index];
                    return InkWell(
                      onTap: () {
                        // Navigate to BoardListScreen with the selected board path
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BoardListScreen(initialBoard: board.path),
                          ),
                        );
                      },
                      child: BoardCard(board: board),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BoardCard extends StatelessWidget {
  final Board board;
  const BoardCard({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image handling for both network and assets
          Expanded(
            flex: 2,
            child:
                board.imageUrl.startsWith('http://') ||
                    board.imageUrl.startsWith('https://')
                ? Image.network(
                    board.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      );
                    },
                  )
                : Image.asset(
                    board.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      );
                    },
                  ),
          ),
          // Text content area
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    board.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    board.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
