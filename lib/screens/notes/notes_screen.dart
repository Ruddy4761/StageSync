import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../models/note.dart';

class NotesScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  const NotesScreen(
      {super.key, required this.appState, required this.concertId});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendNote(String message) {
    if (message.trim().isEmpty) return;
    final note = Note(
      message: message.trim(),
      authorName: widget.appState.currentUserName.isNotEmpty
          ? widget.appState.currentUserName
          : 'You',
      concertId: widget.concertId,
    );
    widget.appState.addNote(note);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Notes')),
      body: ListenableBuilder(
        listenable: widget.appState,
        builder: (context, _) {
          final notes = widget.appState.getNotesForConcert(widget.concertId);
          final pinnedNotes = notes.where((n) => n.isPinned).toList();
          final regularNotes = notes.where((n) => !n.isPinned).toList();

          return Column(
            children: [
              Expanded(
                child: notes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded,
                                size: 48,
                                color:
                                    AppColors.textMuted.withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            const Text('No notes yet',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 16)),
                            const SizedBox(height: 4),
                            const Text(
                                'Start a conversation with your team',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Pinned notes
                          if (pinnedNotes.isNotEmpty) ...[
                            const Text('📌 Pinned',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            ...pinnedNotes.map((n) => _noteCard(n, true)),
                            const SizedBox(height: 12),
                          ],
                          // Regular notes
                          ...regularNotes.map((n) => _noteCard(n, false)),
                        ],
                      ),
              ),
              // Quick templates
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _quickChip('Running late'),
                      _quickChip('All clear'),
                      _quickChip('Issue resolved'),
                      _quickChip('Need backup'),
                    ],
                  ),
                ),
              ),
              // Input bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.surfaceElevated),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Type a note...',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _sendNote(_messageController.text),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Icon(Icons.send_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _noteCard(Note note, bool isPinned) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPinned
            ? AppColors.neonOrange.withValues(alpha: 0.08)
            : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: isPinned
            ? Border.all(
                color: AppColors.neonOrange.withValues(alpha: 0.2))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  note.authorName.isNotEmpty
                      ? note.authorName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Text(note.authorName,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const Spacer(),
              Text(DateFormat('h:mm a').format(note.timestamp),
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 10)),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => widget.appState
                    .toggleNotePin(widget.concertId, note.id),
                child: Icon(
                  note.isPinned ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 18,
                  color: note.isPinned
                      ? AppColors.neonOrange
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(note.message,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _quickChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _sendNote(text),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceElevated),
          ),
          child: Text(text,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ),
      ),
    );
  }
}
