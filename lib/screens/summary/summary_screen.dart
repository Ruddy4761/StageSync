import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../services/pdf_service.dart';

class SummaryScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  const SummaryScreen(
      {super.key, required this.appState, required this.concertId});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _exporting = false;

  Future<void> _exportPdf() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final concert =
          widget.appState.concerts.firstWhere((c) => c.id == widget.concertId);
      final bytes = await PdfService.generateConcertReport(
        concert: concert,
        tasks: widget.appState.getTasksForConcert(widget.concertId),
        artists: widget.appState.getArtistsForConcert(widget.concertId),
        staff: widget.appState.getStaffForConcert(widget.concertId),
        incidents: widget.appState.getIncidentsForConcert(widget.concertId),
        expenses: widget.appState.getExpensesForConcert(widget.concertId),
        contacts: widget.appState.getContactsForConcert(widget.concertId),
      );
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        final concert = widget.appState.concerts
            .firstWhere((c) => c.id == widget.concertId);
        final tasks = widget.appState.getTasksForConcert(widget.concertId);
        final artists = widget.appState.getArtistsForConcert(widget.concertId);
        final staff = widget.appState.getStaffForConcert(widget.concertId);
        final incidents =
            widget.appState.getIncidentsForConcert(widget.concertId);
        final totalSpent = widget.appState.getTotalSpent(widget.concertId);

        final doneTasks = tasks.where((t) => t.status.name == 'done').length;
        final taskPercent =
            tasks.isEmpty ? 0 : (doneTasks / tasks.length * 100).toInt();

        // Incident summary
        final incidentsByType = <String, int>{};
        for (final i in incidents) {
          incidentsByType[i.typeLabel] =
              (incidentsByType[i.typeLabel] ?? 0) + 1;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Concert Summary')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D1B69), Color(0xFF1A0A2E)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(concert.name,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(
                      '${DateFormat('MMM d, yyyy').format(concert.dateTime)} • ${concert.venue}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: concert.isUpcoming
                            ? AppColors.neonOrange.withValues(alpha: 0.2)
                            : AppColors.neonGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        concert.isUpcoming ? 'Upcoming' : 'Completed',
                        style: TextStyle(
                          color: concert.isUpcoming
                              ? AppColors.neonOrange
                              : AppColors.neonGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tasks summary
              _expandableCard(
                icon: Icons.task_alt_rounded,
                color: AppColors.neonGreen,
                title: 'Tasks Completed',
                value: '$taskPercent%',
                subtitle: '$doneTasks of ${tasks.length} tasks done',
                children: tasks
                    .map<Widget>((t) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Icon(
                                t.status.name == 'done'
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: 16,
                                color: t.status.name == 'done'
                                    ? AppColors.neonGreen
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(t.title,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13)),
                            ],
                          ),
                        ))
                    .toList(),
              ),

              // Team summary
              _expandableCard(
                icon: Icons.people_rounded,
                color: AppColors.primary,
                title: 'Team',
                value: '${staff.length}',
                subtitle: '${staff.length} members, ${artists.length} artists',
                children: [],
              ),

              // Incidents summary
              _expandableCard(
                icon: Icons.warning_amber_rounded,
                color: AppColors.neonRed,
                title: 'Incidents',
                value: '${incidents.length}',
                subtitle: incidents.isEmpty
                    ? 'No incidents reported'
                    : incidentsByType.entries
                        .map((e) => '${e.key}: ${e.value}')
                        .join(', '),
                children: [],
              ),

              // Budget summary
              _expandableCard(
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.neonOrange,
                title: 'Budget',
                value: '₹${totalSpent.toStringAsFixed(0)}',
                subtitle: concert.totalBudget > 0
                    ? 'of ₹${concert.totalBudget.toStringAsFixed(0)} budget'
                    : 'Total spent',
                children: [],
              ),

              const SizedBox(height: 20),

              // Export button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _exporting ? null : _exportPdf,
                  icon: _exporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryLight,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf_rounded),
                  label: Text(_exporting ? 'Generating...' : 'Export as PDF'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _expandableCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
          ],
        ),
        subtitle: Text(subtitle,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 11)),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        children: children.isEmpty
            ? []
            : [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(children: children),
                ),
              ],
      ),
    );
  }
}
