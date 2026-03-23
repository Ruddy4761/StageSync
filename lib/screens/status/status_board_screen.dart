import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';

class StatusBoardScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  const StatusBoardScreen(
      {super.key, required this.appState, required this.concertId});

  @override
  State<StatusBoardScreen> createState() => _StatusBoardScreenState();
}

class _StatusBoardScreenState extends State<StatusBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.appState,
        builder: (context, _) {
          final tasks = widget.appState.getTasksForConcert(widget.concertId);
          final artists = widget.appState.getArtistsForConcert(widget.concertId);
          final delayedTasks =
              tasks.where((t) => t.status.name == 'delayed').toList();
          final inProgressTasks =
              tasks.where((t) => t.status.name == 'inProgress').toList();
          final upcomingTasks =
              tasks.where((t) => t.status.name == 'notStarted').toList();

          final isEmpty =
              tasks.isEmpty && artists.isEmpty;

          if (isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.dashboard_customize_outlined,
                      size: 56,
                      color: AppColors.textMuted.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text('No activity yet',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 18)),
                  const SizedBox(height: 6),
                  const Text('Add tasks and artists to see the status board',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Timeline bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.neonGreen,
                      AppColors.statusInProgress,
                      AppColors.primary,
                      AppColors.textMuted,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Now Happening
              if (inProgressTasks.isNotEmpty) ...[
                _sectionTitle('🔴  NOW HAPPENING'),
                const SizedBox(height: 8),
                ...inProgressTasks.map((task) => _nowCard(task)),
                const SizedBox(height: 16),
              ],

              // Up Next
              if (upcomingTasks.isNotEmpty) ...[
                _sectionTitle('⏳  UP NEXT'),
                const SizedBox(height: 8),
                ...upcomingTasks.take(3).map((task) => _upNextCard(task)),
                const SizedBox(height: 16),
              ],

              // Delayed
              if (delayedTasks.isNotEmpty) ...[
                _sectionTitle('⚠️  DELAYED'),
                const SizedBox(height: 8),
                ...delayedTasks.map((task) => _delayedCard(task)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(text,
      style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1));

  Widget _nowCard(task) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.2),
              AppColors.secondary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.statusInProgress,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.statusInProgress.withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${task.assignedTo} • ${DateFormat('h:mm a').format(task.time)}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _upNextCard(task) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule_rounded,
                size: 18, color: AppColors.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(task.title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14)),
            ),
            Text(DateFormat('h:mm a').format(task.time),
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      );

  Widget _delayedCard(task) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.neonRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.neonRed.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 18, color: AppColors.neonRed),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14)),
                  Text(task.assignedTo,
                      style: const TextStyle(
                          color: AppColors.neonRed, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      );
}
