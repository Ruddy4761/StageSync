import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../data/app_state.dart';
import '../../models/concert.dart';
import '../../models/task.dart';
import '../../models/artist.dart';
import '../../models/staff.dart';
import '../../services/permission_service.dart';
import '../../widgets/app_snackbar.dart';
import '../tasks/create_task_screen.dart';
import '../artists/add_artist_screen.dart';
import '../staff/add_staff_screen.dart';

class ConcertDetailScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  const ConcertDetailScreen(
      {super.key, required this.appState, required this.concertId});

  @override
  State<ConcertDetailScreen> createState() => _ConcertDetailScreenState();
}

class _ConcertDetailScreenState extends State<ConcertDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Concert? get _concert {
    try {
      return widget.appState.concerts
          .firstWhere((c) => c.id == widget.concertId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        final concert = _concert;
        if (concert == null) {
          return const Scaffold(
              body: Center(child: Text('Concert not found')));
        }

        final staffCount =
            widget.appState.getStaffForConcert(widget.concertId).length;
        final taskCount =
            widget.appState.getTasksForConcert(widget.concertId).length;
        final doneTaskCount = widget.appState
            .getTasksForConcert(widget.concertId)
            .where((t) => t.status.name == 'done')
            .length;

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: AppColors.background,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_vert_rounded,
                            color: Colors.white, size: 20),
                      ),
                      onPressed: () => _showOptionsMenu(concert),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF2D1B69),
                            Color(0xFF1A0A2E),
                            AppColors.background,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: concert.isUpcoming
                                      ? AppColors.neonGreen.withValues(alpha: 0.2)
                                      : AppColors.textMuted.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  concert.isUpcoming ? '● Live in ${concert.daysUntilEvent} days' : '● Completed',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: concert.isUpcoming
                                        ? AppColors.neonGreen
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                concert.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(concert.venue,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 12, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('MMM d, yyyy • h:mm a')
                                        .format(concert.dateTime),
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Stats row
                              Row(
                                children: [
                                  _miniStat(Icons.people_outlined,
                                      '$staffCount', 'Team'),
                                  const SizedBox(width: 16),
                                  _miniStat(Icons.task_alt_rounded,
                                      '$doneTaskCount/$taskCount', 'Tasks'),
                                  const SizedBox(width: 16),
                                  _miniStat(Icons.chair_outlined,
                                      '${concert.capacity}', 'Capacity'),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(
                                          ClipboardData(text: concert.joinCode));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Code copied!')),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.copy_rounded,
                                              size: 14,
                                              color: AppColors.primaryLight),
                                          const SizedBox(width: 6),
                                          Text(concert.joinCode,
                                              style: const TextStyle(
                                                  color: AppColors.primaryLight,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                  letterSpacing: 2)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Tasks'),
                        Tab(text: 'Artists'),
                        Tab(text: 'Staff'),
                        Tab(text: 'More'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(
                    appState: widget.appState, concertId: widget.concertId),
                _TasksTab(
                    appState: widget.appState, concertId: widget.concertId),
                _ArtistsTab(
                    appState: widget.appState, concertId: widget.concertId),
                _StaffTab(
                    appState: widget.appState, concertId: widget.concertId),
                _MoreTab(
                    appState: widget.appState, concertId: widget.concertId),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _miniStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryLight),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  void _showOptionsMenu(Concert concert) {
    final canEdit = widget.appState
        .hasPermission(widget.concertId, AppPermission.editConcert);
    final canDelete = widget.appState
        .hasPermission(widget.concertId, AppPermission.deleteConcert);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canEdit)
              ListTile(
                leading: const Icon(Icons.edit_rounded,
                    color: AppColors.primaryLight),
                title: const Text('Edit Concert'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.editConcert,
                      arguments: concert);
                },
              ),
            ListTile(
              leading: const Icon(Icons.share_rounded,
                  color: AppColors.primaryLight),
              title: const Text('Share Join Code'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: concert.joinCode));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code copied!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.summarize_rounded,
                  color: AppColors.tertiary),
              title: const Text('View Summary'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.summary,
                    arguments: widget.concertId);
              },
            ),
            if (canDelete)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.neonRed),
                title: const Text('Delete Concert',
                    style: TextStyle(color: AppColors.neonRed)),
                onTap: () {
                  widget.appState.deleteConcert(widget.concertId);
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

// ===== OVERVIEW TAB =====
class _OverviewTab extends StatelessWidget {
  final AppState appState;
  final String concertId;
  const _OverviewTab({required this.appState, required this.concertId});

  @override
  Widget build(BuildContext context) {
    final tasks = appState.getTasksForConcert(concertId);
    final staff = appState.getStaffForConcert(concertId);
    final artists = appState.getArtistsForConcert(concertId);
    final expenses = appState.getExpensesForConcert(concertId);
    final totalSpent = appState.getTotalSpent(concertId);
    final concert = appState.concerts.firstWhere((c) => c.id == concertId);

    final doneTasks = tasks.where((t) => t.status.name == 'done').length;
    final taskPercent = tasks.isEmpty ? 0.0 : doneTasks / tasks.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick stats grid
        Row(
          children: [
            Expanded(
              child: _statCard(
                Icons.task_alt_rounded,
                '${(taskPercent * 100).toInt()}%',
                'Tasks Done',
                AppColors.neonGreen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                Icons.people_rounded,
                '${staff.length}',
                'Team Members',
                AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statCard(
                Icons.mic_rounded,
                '${artists.length}',
                'Artists',
                AppColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                Icons.account_balance_wallet_rounded,
                '₹${totalSpent.toStringAsFixed(0)}',
                concert.totalBudget > 0
                    ? 'of ₹${concert.totalBudget.toStringAsFixed(0)}'
                    : 'Total Spent',
                AppColors.neonOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Recent activity
        const Text('Quick Actions',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _actionChip(context, Icons.add_task_rounded, 'Add Task', () {
              Navigator.pushNamed(context, AppRoutes.createTask,
                  arguments: concertId);
            }),
            _actionChip(context, Icons.person_add_rounded, 'Add Staff', () {
              Navigator.pushNamed(context, AppRoutes.addStaff,
                  arguments: concertId);
            }),
            _actionChip(context, Icons.music_note_rounded, 'Add Artist', () {
              Navigator.pushNamed(context, AppRoutes.addArtist,
                  arguments: concertId);
            }),
            _actionChip(context, Icons.warning_amber_rounded, 'Log Incident',
                () {
              Navigator.pushNamed(context, AppRoutes.logIncident,
                  arguments: concertId);
            }),
          ],
        ),
      ],
    );
  }

  Widget _statCard(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _actionChip(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceElevated),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primaryLight),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ===== TASKS TAB =====
class _TasksTab extends StatefulWidget {
  final AppState appState;
  final String concertId;
  const _TasksTab({required this.appState, required this.concertId});

  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<_TasksTab> {
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        var tasks = widget.appState.getTasksForConcert(widget.concertId);
        if (_statusFilter != 'All') {
          tasks = tasks.where((t) => t.statusLabel == _statusFilter).toList();
        }

        return Stack(
          children: [
            Column(
              children: [
                // Filter chips
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'All',
                        'Not Started',
                        'In Progress',
                        'Done',
                        'Delayed'
                      ].map((filter) {
                        final isSelected = _statusFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter, style: const TextStyle(fontSize: 12)),
                            selected: isSelected,
                            onSelected: (_) =>
                                setState(() => _statusFilter = filter),
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.primary,
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceElevated,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: tasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.task_outlined,
                                  size: 48,
                                  color: AppColors.textMuted.withValues(alpha: 0.3)),
                              const SizedBox(height: 12),
                              const Text('No tasks yet',
                                  style: TextStyle(
                                      color: AppColors.textMuted, fontSize: 16)),
                              const SizedBox(height: 4),
                              const Text('Add your first task to get started',
                                  style: TextStyle(
                                      color: AppColors.textMuted, fontSize: 12)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            final statusColor = _getStatusColor(task.statusLabel);
                            return Dismissible(
                              key: Key(task.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.neonRed.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.delete_rounded,
                                    color: AppColors.neonRed),
                              ),
                              onDismissed: (_) {
                                if (widget.appState.hasPermission(
                                    widget.concertId,
                                    AppPermission.deleteTask)) {
                                  widget.appState
                                      .deleteTask(widget.concertId, task.id);
                                } else {
                                  // Can't delete — rebuild to restore item
                                  AppSnackbar.warning(context,
                                      'You don\'t have permission to delete tasks');
                                  (context as Element).markNeedsBuild();
                                }
                              },
                              child: GestureDetector(
                                onTap: () => _showTaskDetail(task),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceCard,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border(
                                      left: BorderSide(
                                          color: statusColor, width: 3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(task.title,
                                                style: const TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14)),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.access_time_rounded,
                                                    size: 12,
                                                    color: AppColors.textMuted),
                                                const SizedBox(width: 4),
                                                Text(
                                                  DateFormat('h:mm a')
                                                      .format(task.time),
                                                  style: const TextStyle(
                                                      color: AppColors.textMuted,
                                                      fontSize: 11),
                                                ),
                                                const SizedBox(width: 10),
                                                Icon(Icons.person_outline,
                                                    size: 12,
                                                    color: AppColors.textMuted),
                                                const SizedBox(width: 4),
                                                Text(task.assignedTo,
                                                    style: const TextStyle(
                                                        color:
                                                            AppColors.textMuted,
                                                        fontSize: 11)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              statusColor.withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          task.statusLabel,
                                          style: TextStyle(
                                              color: statusColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: widget.appState.hasPermission(
                      widget.concertId, AppPermission.addTask)
                  ? FloatingActionButton(
                      heroTag: 'addTask',
                      onPressed: () => Navigator.pushNamed(
                          context, AppRoutes.createTask,
                          arguments: widget.concertId),
                      child: const Icon(Icons.add_rounded),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Not Started':
        return AppColors.statusNotStarted;
      case 'In Progress':
        return AppColors.statusInProgress;
      case 'Done':
        return AppColors.statusDone;
      case 'Delayed':
        return AppColors.statusDelayed;
      default:
        return AppColors.textMuted;
    }
  }

  void _showTaskDetail(ConcertTask task) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(task.title,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded,
                      color: AppColors.primaryLight, size: 20),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateTaskScreen(
                          appState: widget.appState,
                          concertId: widget.concertId,
                          task: task,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _detailRow(Icons.person_outline, 'Assigned to', task.assignedTo),
            _detailRow(Icons.access_time_rounded, 'Time',
                DateFormat('h:mm a').format(task.time)),
            _detailRow(Icons.flag_rounded, 'Priority', task.priorityLabel),
            _detailRow(Icons.info_outline, 'Status', task.statusLabel),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _detailRow(Icons.notes_rounded, 'Notes', task.description!),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: task.statusLabel == 'Done'
                    ? null
                    : () {
                        task.status = TaskStatus.done;
                        widget.appState.updateTask(task);
                        Navigator.pop(ctx);
                      },
                icon: const Icon(Icons.check_rounded),
                label: Text(task.statusLabel == 'Done'
                    ? 'Already Done'
                    : 'Mark as Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text('$label: ',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ===== ARTISTS TAB =====
class _ArtistsTab extends StatelessWidget {
  final AppState appState;
  final String concertId;
  const _ArtistsTab({required this.appState, required this.concertId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final artists = appState.getArtistsForConcert(concertId);
        final totalMins =
            artists.fold(0, (sum, a) => sum + a.durationMinutes);

        return Stack(
          children: [
            artists.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic_off_rounded,
                            size: 48,
                            color: AppColors.textMuted.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        const Text('No artists yet',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 16)),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: artists.length + 1,
                    onReorder: (oldIdx, newIdx) {
                      if (oldIdx < artists.length && newIdx <= artists.length) {
                        appState.reorderArtists(concertId, oldIdx, newIdx);
                      }
                    },
                    itemBuilder: (context, index) {
                      if (index == artists.length) {
                        return Container(
                          key: const ValueKey('total'),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer_outlined,
                                  size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text(
                                'Total: ${totalMins ~/ 60}h ${totalMins % 60}m',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }
                      final artist = artists[index];
                      return GestureDetector(
                        key: ValueKey(artist.id),
                        onLongPress: () => _showArtistMenu(context, artist),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              // Order number
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${artist.order}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceCard,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(artist.name,
                                                style: const TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15)),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.access_time_rounded,
                                                    size: 12,
                                                    color: AppColors.textMuted),
                                                const SizedBox(width: 4),
                                                Text(
                                                  artist.performanceTime != null
                                                      ? DateFormat('h:mm a').format(
                                                          artist.performanceTime!)
                                                      : '--:--',
                                                  style: const TextStyle(
                                                      color: AppColors.textMuted,
                                                      fontSize: 11),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                    Icons.timer_outlined,
                                                    size: 12,
                                                    color: AppColors.textMuted),
                                                const SizedBox(width: 4),
                                                Text(artist.durationFormatted,
                                                    style: const TextStyle(
                                                        color:
                                                            AppColors.textMuted,
                                                        fontSize: 11)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.drag_handle_rounded,
                                          color: AppColors.textMuted, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            Positioned(
              right: 16,
              bottom: 16,
              child: appState.hasPermission(
                      concertId, AppPermission.addArtist)
                  ? FloatingActionButton(
                      heroTag: 'addArtist',
                      onPressed: () => Navigator.pushNamed(
                          context, AppRoutes.addArtist,
                          arguments: concertId),
                      child: const Icon(Icons.add_rounded),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  void _showArtistMenu(BuildContext context, Artist artist) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: AppColors.primaryLight),
              title: const Text('Edit Artist'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddArtistScreen(
                      appState: appState,
                      concertId: concertId,
                      artist: artist,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.neonRed),
              title: const Text('Delete Artist',
                  style: TextStyle(color: AppColors.neonRed)),
              onTap: () {
                Navigator.pop(ctx);
                appState.deleteArtist(concertId, artist.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ===== STAFF TAB =====
class _StaffTab extends StatelessWidget {
  final AppState appState;
  final String concertId;
  const _StaffTab({required this.appState, required this.concertId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final staff = appState.getStaffForConcert(concertId);
        final grouped = <String, List<Staff>>{};
        for (final s in staff) {
          grouped.putIfAbsent(s.role, () => []).add(s);
        }

        return Stack(
          children: [
            staff.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.group_off_rounded,
                            size: 48,
                            color: AppColors.textMuted.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        const Text('No team members yet',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    children: grouped.entries.map((entry) {
                      final roleColor =
                          AppColors.roleColors[entry.key] ?? AppColors.primary;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: roleColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${entry.key} (${entry.value.length})',
                                  style: TextStyle(
                                    color: roleColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...entry.value.map((member) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceCard,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor:
                                          roleColor.withValues(alpha: 0.2),
                                      child: Text(member.initials,
                                          style: TextStyle(
                                              color: roleColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(member.name,
                                                  style: const TextStyle(
                                                      color:
                                                          AppColors.textPrimary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14)),
                                              if (member.isCreator) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.neonOrange
                                                        .withValues(alpha: 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: const Text('Creator',
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .neonOrange,
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(member.shiftFormatted,
                                              style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    if (member.contactNumber != null)
                                      IconButton(
                                        icon: const Icon(Icons.phone_rounded,
                                            size: 18,
                                            color: AppColors.neonGreen),
                                        onPressed: () {},
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_rounded,
                                          size: 17,
                                          color: AppColors.textMuted),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddStaffScreen(
                                            appState: appState,
                                            concertId: concertId,
                                            staff: member,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      );
                    }).toList(),
                  ),
            Positioned(
              right: 16,
              bottom: 16,
              child: appState.hasPermission(
                      concertId, AppPermission.addStaff)
                  ? FloatingActionButton(
                      heroTag: 'addStaff',
                      onPressed: () => Navigator.pushNamed(
                          context, AppRoutes.addStaff,
                          arguments: concertId),
                      child: const Icon(Icons.person_add_rounded),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

// ===== MORE TAB =====
class _MoreTab extends StatelessWidget {
  final AppState appState;
  final String concertId;
  const _MoreTab({required this.appState, required this.concertId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _moreItem(context, Icons.dashboard_rounded, 'Status Board',
            'Real-time event tracking', AppColors.tertiary, () {
          Navigator.pushNamed(context, AppRoutes.statusBoard,
              arguments: concertId);
        }),
        _moreItem(context, Icons.warning_amber_rounded, 'Incident Log',
            'Track and manage incidents', AppColors.neonRed, () {
          Navigator.pushNamed(context, AppRoutes.incidents,
              arguments: concertId);
        }),
        _moreItem(context, Icons.chat_bubble_outline_rounded, 'Team Notes',
            'Communicate with your team', AppColors.neonBlue, () {
          Navigator.pushNamed(context, AppRoutes.notes,
              arguments: concertId);
        }),
        _moreItem(context, Icons.account_balance_wallet_rounded,
            'Budget Tracker', 'Manage expenses', AppColors.neonOrange, () {
          Navigator.pushNamed(context, AppRoutes.budget,
              arguments: concertId);
        }),
        _moreItem(context, Icons.emergency_rounded, 'Emergency Contacts',
            'Quick access numbers', AppColors.neonRed, () {
          Navigator.pushNamed(context, AppRoutes.emergencyContacts,
              arguments: concertId);
        }),
        _moreItem(context, Icons.summarize_rounded, 'Post-Concert Summary',
            'Event report & analysis', AppColors.primary, () {
          Navigator.pushNamed(context, AppRoutes.summary,
              arguments: concertId);
        }),
      ],
    );
  }

  Widget _moreItem(BuildContext context, IconData icon, String title,
      String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
