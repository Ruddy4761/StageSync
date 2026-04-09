import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../data/app_state.dart';
import '../../models/concert.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _filter = 'All';
  bool _isGridView = true;

  List<Concert> get _filteredConcerts {
    var concerts = widget.appState.concerts;
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      concerts = concerts
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              c.venue.toLowerCase().contains(query))
          .toList();
    }
    if (_filter == 'Upcoming') {
      concerts = concerts.where((c) => c.isUpcoming).toList();
    } else if (_filter == 'Past') {
      concerts = concerts.where((c) => c.isPast).toList();
    }
    return concerts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.appState.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(
                    context, AppRoutes.login);
              }
            },
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.neonRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.appState,
          builder: (context, _) {
            final concerts = _filteredConcerts;
            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    AppColors.primaryGradient.createShader(bounds),
                                child: const Text('StageSync',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ),
                              Text(
                                '${concerts.length} concert${concerts.length != 1 ? 's' : ''}',
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        // Join concert button
                        IconButton(
                          onPressed: () => Navigator.pushNamed(
                              context, AppRoutes.joinConcert),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.tertiary.withValues(alpha: 0.3)),
                            ),
                            child: const Icon(Icons.qr_code_scanner_rounded,
                                color: AppColors.tertiary, size: 20),
                          ),
                        ),
                        // View toggle
                        IconButton(
                          onPressed: () =>
                              setState(() => _isGridView = !_isGridView),
                          icon: Icon(
                            _isGridView
                                ? Icons.view_list_rounded
                                : Icons.grid_view_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        // Profile button
                        IconButton(
                          onPressed: () => Navigator.pushNamed(
                              context, AppRoutes.profile),
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: const Icon(Icons.person_rounded,
                                color: AppColors.primaryLight, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search concerts...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded,
                                    size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                // Filter chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Row(
                      children: ['All', 'Upcoming', 'Past'].map((filter) {
                        final isSelected = _filter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _filter = filter),
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
                // Concert list/grid
                if (concerts.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(),
                  )
                else if (_isGridView)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildConcertCard(concerts[index]),
                        childCount: concerts.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.78,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildConcertListTile(concerts[index]),
                        childCount: concerts.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.createConcert),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('New Concert',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceLight,
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Icon(Icons.music_off_rounded,
                size: 44, color: AppColors.textMuted.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No concerts yet',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first concert or join one\nwith a code',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildConcertCard(Concert concert) {
    final staffCount =
        widget.appState.getStaffForConcert(concert.id).length;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.concertDetail,
          arguments: concert.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: concert.isUpcoming
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surfaceElevated,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: concert.isUpcoming
                      ? AppColors.neonGreen.withValues(alpha: 0.15)
                      : AppColors.textMuted.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  concert.isUpcoming ? 'Upcoming' : 'Past',
                  style: TextStyle(
                    fontSize: 10,
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
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(concert.dateTime),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      concert.venue,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Divider(height: 1, color: AppColors.surfaceElevated),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_outlined,
                          size: 14, color: AppColors.primaryLight),
                      const SizedBox(width: 4),
                      Text('$staffCount',
                          style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.chair_outlined,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text('${concert.capacity}',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConcertListTile(Concert concert) {
    final staffCount =
        widget.appState.getStaffForConcert(concert.id).length;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.concertDetail,
          arguments: concert.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: concert.isUpcoming
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surfaceElevated,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: concert.isUpcoming
                    ? AppColors.primaryGradient
                    : null,
                color: concert.isUpcoming ? null : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('d').format(concert.dateTime),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: concert.isUpcoming
                          ? Colors.white
                          : AppColors.textMuted,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(concert.dateTime),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: concert.isUpcoming
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(concert.name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(concert.venue,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: concert.isUpcoming
                        ? AppColors.neonGreen.withValues(alpha: 0.15)
                        : AppColors.textMuted.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    concert.isUpcoming
                        ? '${concert.daysUntilEvent}d'
                        : 'Done',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: concert.isUpcoming
                          ? AppColors.neonGreen
                          : AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_outlined,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text('$staffCount',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
