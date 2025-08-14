import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetroHeader extends StatelessWidget implements PreferredSizeWidget {
final String title;
final List<String> boards;
final void Function(String board) onBoardTap;
final void Function(String query)? onSearch;

const RetroHeader({
super.key,
required this.title,
required this.boards,
required this.onBoardTap,
this.onSearch,
});

@override
Size get preferredSize => const Size.fromHeight(96);

@override
Widget build(BuildContext context) {
final silver = const Color(0xFFC0C0C0);
final black = Colors.black;
return AppBar(
  elevation: 0,
  backgroundColor: silver,
  titleSpacing: 12,
  title: Text(
    title,
    style: GoogleFonts.vt323(fontSize: 24, color: black),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.info_outline, color: Colors.black),
      tooltip: 'About',
      onPressed: () {},
    ),
  ],
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(56),
    child: Container(
      height: 56,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black26, width: 1),
          bottom: BorderSide(color: Colors.black38, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          RetroButtonBar(items: boards, onPressed: onBoardTap),
          const Spacer(),
          SizedBox(
            width: 240,
            child: RetroSearchField(onSubmitted: onSearch),
          ),
        ],
      ),
    ),
  ),
);
}
}

class RetroButtonBar extends StatelessWidget {
final List<String> items;
final void Function(String) onPressed;
const RetroButtonBar({super.key, required this.items, required this.onPressed});

@override
Widget build(BuildContext context) {
return Wrap(
spacing: 8,
children: items
.map((label) => RetroButton(
label: label,
onPressed: () => onPressed(label),
))
.toList(),
);
}
}

class RetroButton extends StatelessWidget {
final String label;
final VoidCallback onPressed;
const RetroButton({super.key, required this.label, required this.onPressed});

@override
Widget build(BuildContext context) {
return InkWell(
onTap: onPressed,
borderRadius: BorderRadius.zero,
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
decoration: BoxDecoration(
color: const Color(0xFFE0E0E0),
border: Border.all(color: Colors.black, width: 1),
),
child: Text(
label,
style: GoogleFonts.vt323(fontSize: 18, color: Colors.black),
),
),
);
}
}

class RetroSearchField extends StatelessWidget {
final void Function(String)? onSubmitted;
const RetroSearchField({super.key, this.onSubmitted});

@override
Widget build(BuildContext context) {
return TextField(
style: GoogleFonts.vt323(fontSize: 18, color: Colors.black),
cursorColor: Colors.black,
decoration: InputDecoration(
isDense: true,
hintText: 'Search',
hintStyle: GoogleFonts.vt323(fontSize: 18, color: Colors.black54),
contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
filled: true,
fillColor: const Color(0xFFE0E0E0),
enabledBorder: const OutlineInputBorder(
borderSide: BorderSide(color: Colors.black, width: 1),
),
focusedBorder: const OutlineInputBorder(
borderSide: BorderSide(color: Colors.black, width: 2),
),
),
onSubmitted: (q) {
final t = q.trim();
if (onSubmitted != null && t.isNotEmpty) onSubmitted!(t);
},
textInputAction: TextInputAction.search,
);
}
}