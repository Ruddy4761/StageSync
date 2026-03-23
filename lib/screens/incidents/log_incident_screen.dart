import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../models/incident.dart';

class LogIncidentScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  const LogIncidentScreen(
      {super.key, required this.appState, required this.concertId});

  @override
  State<LogIncidentScreen> createState() => _LogIncidentScreenState();
}

class _LogIncidentScreenState extends State<LogIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _resolutionController = TextEditingController();
  IncidentType _type = IncidentType.other;
  IncidentSeverity _severity = IncidentSeverity.low;
  IncidentStatus _status = IncidentStatus.open;

  @override
  void dispose() {
    _descController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final incident = Incident(
        type: _type,
        description: _descController.text.trim(),
        severity: _severity,
        status: _status,
        resolutionNotes: _resolutionController.text.trim().isEmpty
            ? null
            : _resolutionController.text.trim(),
        concertId: widget.concertId,
      );
      widget.appState.addIncident(incident);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Incident')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Type'),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceElevated),
                ),
                child: DropdownButtonFormField<IncidentType>(
                  value: _type,
                  dropdownColor: AppColors.surfaceLight,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_rounded),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: IncidentType.values
                      .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                              t.name[0].toUpperCase() + t.name.substring(1),
                              style: const TextStyle(
                                  color: AppColors.textPrimary))))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _type = val ?? IncidentType.other),
                ),
              ),
              const SizedBox(height: 16),

              _label('Description'),
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Describe the incident...',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _label('Severity'),
              Row(
                children: IncidentSeverity.values.map((s) {
                  final isSelected = _severity == s;
                  final color = s == IncidentSeverity.high
                      ? AppColors.severityHigh
                      : s == IncidentSeverity.medium
                          ? AppColors.severityMedium
                          : AppColors.severityLow;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                          s.name[0].toUpperCase() + s.name.substring(1)),
                      selected: isSelected,
                      selectedColor: color.withValues(alpha: 0.2),
                      side: BorderSide(
                          color:
                              isSelected ? color : AppColors.surfaceElevated),
                      labelStyle: TextStyle(
                          color:
                              isSelected ? color : AppColors.textSecondary),
                      onSelected: (_) => setState(() => _severity = s),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              _label('Status'),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceElevated),
                ),
                child: DropdownButtonFormField<IncidentStatus>(
                  value: _status,
                  dropdownColor: AppColors.surfaceLight,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.info_outline),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: IncidentStatus.values
                      .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                              s.name[0].toUpperCase() +
                                  s.name.substring(1).replaceAllMapped(
                                      RegExp(r'[A-Z]'),
                                      (m) => ' ${m.group(0)}'),
                              style: const TextStyle(
                                  color: AppColors.textPrimary))))
                      .toList(),
                  onChanged: (val) => setState(
                      () => _status = val ?? IncidentStatus.open),
                ),
              ),
              const SizedBox(height: 16),

              _label('Resolution Notes (optional)'),
              TextFormField(
                controller: _resolutionController,
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'How was it resolved?',
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.warning_amber_rounded,
                        color: Colors.white),
                    label: const Text('Log Incident',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      );
}
