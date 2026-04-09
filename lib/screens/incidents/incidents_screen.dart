import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../data/app_state.dart';
import '../../models/incident.dart';
import '../../services/permission_service.dart';
import '../../widgets/app_snackbar.dart';
import 'edit_incident_screen.dart';

class IncidentsScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  const IncidentsScreen(
      {super.key, required this.appState, required this.concertId});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incident Log')),
      body: ListenableBuilder(
        listenable: widget.appState,
        builder: (context, _) {
          var incidents =
              widget.appState.getIncidentsForConcert(widget.concertId);
          if (_filter != 'All') {
            incidents =
                incidents.where((i) => i.typeLabel == _filter).toList();
          }

          return Column(
            children: [
              // Filters
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Sound', 'Crowd', 'Equipment', 'Delay', 'Other']
                        .map((f) {
                      final isSelected = _filter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f, style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _filter = f),
                          selectedColor:
                              AppColors.neonRed.withValues(alpha: 0.15),
                          checkmarkColor: AppColors.neonRed,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.neonRed
                                : AppColors.surfaceElevated,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                child: incidents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded,
                                size: 48,
                                color: AppColors.textMuted.withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            const Text('No incidents logged',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 16)),
                            const SizedBox(height: 4),
                            const Text('All clear! 🎉',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: incidents.length,
                        itemBuilder: (context, index) {
                          final incident = incidents[index];
                          final canDelete = widget.appState.hasPermission(
                              widget.concertId, AppPermission.deleteIncident);
                          return Dismissible(
                            key: Key(incident.id),
                            direction: canDelete
                                ? DismissDirection.endToStart
                                : DismissDirection.none,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: AppColors.neonRed.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.delete_rounded,
                                  color: AppColors.neonRed),
                            ),
                            onDismissed: (_) {
                              widget.appState
                                  .deleteIncident(widget.concertId, incident.id);
                            },
                            child: _incidentCard(context, incident),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'logIncident',
        onPressed: () {
          if (!widget.appState.hasPermission(
              widget.concertId, AppPermission.logIncident)) {
            AppSnackbar.warning(
                context, 'You don\'t have permission to log incidents');
            return;
          }
          Navigator.pushNamed(context, AppRoutes.logIncident,
              arguments: widget.concertId);
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _incidentCard(BuildContext context, Incident incident) {
    final severityColor = incident.severity == IncidentSeverity.high
        ? AppColors.severityHigh
        : incident.severity == IncidentSeverity.medium
            ? AppColors.severityMedium
            : AppColors.severityLow;

    final IconData typeIcon;
    switch (incident.type) {
      case IncidentType.sound:
        typeIcon = Icons.volume_up_rounded;
        break;
      case IncidentType.crowd:
        typeIcon = Icons.groups_rounded;
        break;
      case IncidentType.equipment:
        typeIcon = Icons.build_rounded;
        break;
      case IncidentType.delay:
        typeIcon = Icons.timer_off_rounded;
        break;
      case IncidentType.other:
        typeIcon = Icons.report_outlined;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: severityColor, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(typeIcon, color: severityColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(incident.description,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(incident.severityLabel,
                          style: TextStyle(
                              color: severityColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        if (!widget.appState.hasPermission(
                            widget.concertId,
                            AppPermission.editIncident)) {
                          AppSnackbar.warning(context,
                              'You don\'t have permission to edit incidents');
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditIncidentScreen(
                              appState: widget.appState,
                              incident: incident,
                            ),
                          ),
                        );
                      },
                      child: const Icon(Icons.edit_rounded,
                          size: 16, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(incident.typeLabel,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11)),
                    const SizedBox(width: 8),
                    Text('• ${DateFormat('h:mm a').format(incident.time)}',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: incident.status == IncidentStatus.resolved
                            ? AppColors.neonGreen.withValues(alpha: 0.15)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        incident.statusLabel,
                        style: TextStyle(
                          color: incident.status == IncidentStatus.resolved
                              ? AppColors.neonGreen
                              : AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
