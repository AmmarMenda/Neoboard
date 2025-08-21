// lib/widgets/retro_header.dart
import 'package:flutter/material.dart';

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
  Size get preferredSize => const Size.fromHeight(110);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEFEFEF), Color(0xFFDCDCDC)],
            ),
            border: Border(
              bottom: BorderSide(color: Color(0xFFBDBDBD), width: 0.5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (showHome)
                    SizedBox(
                      width: 48,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => onBoardTap?.call('/'),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      // *** THE FIX ***
                      // This line is restored to prevent the widget from disappearing.
                      // It explicitly applies styling from the theme, ensuring the
                      // Text widget renders correctly.
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.appBarTheme.foregroundColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showSearch)
                    SizedBox(
                      width: 48,
                      child: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {},
                      ),
                    ), // Placeholder action
                ],
              ),
              const SizedBox(height: 8),
              // Segmented Control for boards (This section is correct)
              Container(
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA9A9A9)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: boards.length,
                    separatorBuilder: (_, __) => const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Color(0xFFA9A9A9),
                    ),
                    itemBuilder: (ctx, index) {
                      final board = boards[index];
                      final selected = board == selectedBoard;
                      return GestureDetector(
                        onTap: () => onBoardTap?.call(board),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: selected
                              ? Colors.white.withOpacity(0.8)
                              : Colors.transparent,
                          alignment: Alignment.center,
                          child: Text(
                            board,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: selected
                                  ? theme.colorScheme.primary
                                  : theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(0.8),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // The dialog logic remains unchanged
  Future<void> _showSearchDialog(BuildContext context) async {
    // ...
  }
}
