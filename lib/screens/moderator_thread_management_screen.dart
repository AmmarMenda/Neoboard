// screens/moderator_thread_management_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/retro_button.dart' as retro;
import '../database/database_helper.dart';
import '../models/thread.dart';
import '../models/post.dart';
import '../widgets/imageboard_text.dart';
import '../utils/responsive_helper.dart';
import 'moderator_thread_view_screen.dart';

class ModeratorThreadManagementScreen extends StatefulWidget {
  const ModeratorThreadManagementScreen({super.key});

  @override
  State<ModeratorThreadManagementScreen> createState() =>
      _ModeratorThreadManagementScreenState();
}

class _ModeratorThreadManagementScreenState
    extends State<ModeratorThreadManagementScreen> {
  final _db = DatabaseHelper();

  final _boards = ['All', '/b/', '/g/', '/v/', '/a/'];
  String _selectedBoard = 'All';

  bool _loading = true;
  List<Thread> _threads = [];
  final Map<int, List<Post>> _replies = {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);

    try {
      _threads = _selectedBoard == 'All'
          ? await _db.getAllThreads()
          : await _db.getThreadsByBoard(_selectedBoard);

      _replies.clear();
      for (final t in _threads) {
        _replies[t.id!] = await _db.getPostsByThread(t.id!);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteThread(Thread t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteThreadDialog(thread: t),
    );
    if (ok == true) {
      await _db.deleteThread(t.id!);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thread deleted'), backgroundColor: Colors.green),
        );
      }
    }
  }

  void _openThread(Thread t) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ModeratorThreadViewScreen(threadId: t.id!)),
    ).then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    final small = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thread Management',
          style: GoogleFonts.vt323(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
          ),
        ),
        backgroundColor: const Color(0xFFC0C0C0),
      ),
      body: Container(
        color: const Color(0xFFE0E0E0),
        child: Column(
          children: [
            // ── header & filter ───────────────────────────────────────────────
            Container(
              padding: ResponsiveHelper.getResponsivePadding(context),
              decoration: const BoxDecoration(
                color: Color(0xFFC0C0C0),
                border: Border(bottom: BorderSide(color: Colors.black)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.manage_search),
                      SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                      Text(
                        'THREAD & REPLY MANAGEMENT',
                        style: GoogleFonts.vt323(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                  small
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Filter by board:',
                                style: GoogleFonts.vt323(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                )),
                            SizedBox(height: 6),
                            _boardDropdown(fullWidth: true),
                            SizedBox(height: 8),
                            Text('${_threads.length} threads',
                                style: GoogleFonts.vt323(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                                  color: Colors.black54,
                                )),
                          ],
                        )
                      : Row(
                          children: [
                            Text('Filter by board:',
                                style: GoogleFonts.vt323(fontSize: 14)),
                            const SizedBox(width: 12),
                            _boardDropdown(),
                            const Spacer(),
                            Text('${_threads.length} threads',
                                style: GoogleFonts.vt323(fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                ],
              ),
            ),
            // ── list ───────────────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _threads.isEmpty
                      ? Center(
                          child: Text(
                            'No threads found',
                            style: GoogleFonts.vt323(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: ResponsiveHelper.getResponsivePadding(context),
                          itemCount: _threads.length,
                          itemBuilder: (_, i) => _ThreadCard(
                            thread: _threads[i],
                            replies: _replies[_threads[i].id] ?? const [],
                            onOpen: () => _openThread(_threads[i]),
                            onDelete: () => _deleteThread(_threads[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boardDropdown({bool fullWidth = false}) {
    final drop = DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedBoard,
        isExpanded: fullWidth,
        style: GoogleFonts.vt323(fontSize: 14, color: Colors.black),
        items: _boards
            .map((b) => DropdownMenuItem(value: b, child: Text(b)))
            .toList(),
        onChanged: (v) {
          if (v != null) {
            setState(() => _selectedBoard = v);
            _refresh();
          }
        },
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
      ),
      child: drop,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Thread card
// ─────────────────────────────────────────────────────────────────────────────
class _ThreadCard extends StatefulWidget {
  final Thread thread;
  final List<Post> replies;
  final VoidCallback onDelete;
  final VoidCallback onOpen;

  const _ThreadCard({
    required this.thread,
    required this.replies,
    required this.onDelete,
    required this.onOpen,
  });

  @override
  State<_ThreadCard> createState() => _ThreadCardState();
}

class _ThreadCardState extends State<_ThreadCard> {
  bool _showReplies = false;

  String _fmt(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final small = ResponsiveHelper.isSmallScreen(context);

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── header ────────────────────────────────────────────────────────
          Padding(
            padding: ResponsiveHelper.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // info row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _pill(widget.thread.board, const Color(0xFFC0C0C0)),
                      const SizedBox(width: 8),
                      _pill(widget.thread.formattedId, const Color(0xFFFFDDDD)),
                      const SizedBox(width: 8),
                      Text('${widget.replies.length} replies • ${_fmt(widget.thread.createdAt)}',
                          style: GoogleFonts.vt323(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                            color: Colors.black54,
                          )),
                    ],
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                // action buttons
                small ? _buttonsColumn(context) : _buttonsRow(context),
              ],
            ),
          ),
          // ── content ───────────────────────────────────────────────────────
          Padding(
            padding: ResponsiveHelper.getResponsivePadding(context),
            child: small ? _verticalContent() : _horizontalContent(),
          ),
          // ── replies preview ──────────────────────────────────────────────
          if (_showReplies && widget.replies.isNotEmpty) _RepliesPreview(replies: widget.replies),
        ],
      ),
    );
  }

  // horizontal on >500 px
  Widget _buttonsRow(BuildContext ctx) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (widget.replies.isNotEmpty) ...[
              retro.RetroButton(
                onTap: () => setState(() => _showReplies = !_showReplies),
                child: Text(_showReplies ? 'HIDE' : 'SHOW',
                    style: GoogleFonts.vt323(fontSize: 12)),
              ),
              const SizedBox(width: 8),
            ],
            retro.RetroButton(
              onTap: widget.onOpen,
              child: Row(
                children: [
                  const Icon(Icons.open_in_new, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('OPEN',
                      style: GoogleFonts.vt323(fontSize: 12, color: Colors.blue)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            retro.RetroButton(
              onTap: widget.onDelete,
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Text('DELETE',
                      style: GoogleFonts.vt323(fontSize: 12, color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      );

  // stacked vertically on small screens
  Widget _buttonsColumn(BuildContext ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.replies.isNotEmpty)
            retro.RetroButton(
              onTap: () => setState(() => _showReplies = !_showReplies),
              child: Text(_showReplies ? 'HIDE REPLIES' : 'SHOW REPLIES',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vt323(fontSize: 12)),
            ),
          if (widget.replies.isNotEmpty)
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(ctx, 8)),
          Row(
            children: [
              Expanded(
                child: retro.RetroButton(
                  onTap: widget.onOpen,
                  child: Text('OPEN',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vt323(fontSize: 12, color: Colors.blue)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: retro.RetroButton(
                  onTap: widget.onDelete,
                  child: Text('DELETE',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vt323(fontSize: 12, color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _verticalContent() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.thread.imagePath != null)
            Container(
              width: double.infinity,
              height: 120,
              margin: const EdgeInsets.only(bottom: 8),
              child: Image.file(File(widget.thread.imagePath!), fit: BoxFit.contain),
            ),
          Text(widget.thread.title,
              style: GoogleFonts.vt323(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          ImageboardText(
            text: widget.thread.content,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            defaultColor: Colors.black87,
          ),
        ],
      );

  Widget _horizontalContent() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image
          if (widget.thread.imagePath != null)
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 12),
              child: Image.file(File(widget.thread.imagePath!), fit: BoxFit.cover),
            ),
          // text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.thread.title,
                    style: GoogleFonts.vt323(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                ImageboardText(
                  text: widget.thread.content,
                  fontSize: 14,
                  defaultColor: Colors.black87,
                ),
              ],
            ),
          ),
        ],
      );

  Widget _pill(String txt, Color clr) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: clr, border: Border.all(color: Colors.black)),
        child: Text(txt,
            style: GoogleFonts.vt323(fontSize: 12, fontWeight: FontWeight.bold)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Replies preview (first 5)
// ─────────────────────────────────────────────────────────────────────────────
class _RepliesPreview extends StatelessWidget {
  final List<Post> replies;
  const _RepliesPreview({required this.replies});

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays > 0) return '${d.inDays}d ago';
    if (d.inHours > 0) return '${d.inHours}h ago';
    if (d.inMinutes > 0) return '${d.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: double.infinity,
            padding: ResponsiveHelper.getResponsivePadding(context),
            decoration: const BoxDecoration(
              color: Color(0xFFE8E8E8),
              border: Border(top: BorderSide(color: Colors.black54)),
            ),
            child: Text('REPLIES (${replies.length})',
                style: GoogleFonts.vt323(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                    fontWeight: FontWeight.bold)),
          ),
          ...replies.take(5).map((p) => Container(
                padding: ResponsiveHelper.getResponsivePadding(context),
                decoration:
                    const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _idBox(p.formattedId),
                    const SizedBox(width: 8),
                    if (p.imagePath != null)
                      Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 8),
                        child: Image.file(File(p.imagePath!), fit: BoxFit.cover),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_ago(p.createdAt),
                              style: GoogleFonts.vt323(
                                  fontSize: 10, color: Colors.black54)),
                          const SizedBox(height: 2),
                          ImageboardText(
                            text: p.content,
                            fontSize: 12,
                            defaultColor: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          if (replies.length > 5)
            Padding(
              padding: ResponsiveHelper.getResponsivePadding(context),
              child: Text('... and ${replies.length - 5} more',
                  style: GoogleFonts.vt323(fontSize: 12, color: Colors.black54)),
            ),
        ],
      );

  Widget _idBox(String id) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFDDDDDD),
          border: Border.all(color: Colors.black54),
        ),
        child: Text(id, style: GoogleFonts.vt323(fontSize: 10)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Delete confirmation dialog
// ─────────────────────────────────────────────────────────────────────────────
class _DeleteThreadDialog extends StatelessWidget {
  final Thread thread;
  const _DeleteThreadDialog({required this.thread});

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFFE0E0E0),
        shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 2)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text('DELETE THREAD',
                  style: GoogleFonts.vt323(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Text(
          'Delete "${thread.title}"?\nThis cannot be undone.',
          style: GoogleFonts.vt323(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16)),
        ),
        actions: [
          retro.RetroButton(
            onTap: () => Navigator.pop(context, false),
            child: Text('CANCEL',
                style: GoogleFonts.vt323(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14))),
          ),
          const SizedBox(width: 8),
          retro.RetroButton(
            onTap: () => Navigator.pop(context, true),
            child: Text('DELETE',
                style: GoogleFonts.vt323(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                    color: Colors.red)),
          ),
        ],
      );
}
