// lib/widgets/retro_header.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetroHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<String> boards;
  final String? selectedBoard;
  final ValueChanged<String>? onBoardTap;
  final ValueChanged<String>? onSearch;
  final bool showHome;
  final bool showSearch;

  const RetroHeader({
    super.key,
    required this.title,
    required this.boards,
    this.selectedBoard,
    this.onBoardTap,
    this.onSearch,
    this.showHome = true,
    this.showSearch = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120);
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFC0C0C0),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (showHome)
                    IconButton(
                      icon: const Icon(Icons.home),
                      tooltip: 'Home',
                      onPressed: () => onBoardTap?.call('/'),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.vt323(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showSearch)
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Search',
                      onPressed: () async {
                        if (onSearch != null) {
                          final query = await _showSearchDialog(context);
                          if (query != null && query.trim().isNotEmpty) {
                            onSearch!(query.trim());
                          }
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: boards.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (ctx, index) {
                    final board = boards[index];
                    final selected = board == selectedBoard;
                    return GestureDetector(
                      onTap: () => onBoardTap?.call(board),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? Colors.black : Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          board,
                          style: GoogleFonts.vt323(
                            fontSize: 16,
                            color: selected ? Colors.white : Colors.black,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showSearchDialog(BuildContext context) async {
    String? query;
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Search'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter search query'),
            onChanged: (val) => query = val,
            onSubmitted: (val) => Navigator.of(ctx).pop(val),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}
