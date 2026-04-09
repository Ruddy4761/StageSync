import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../models/incident.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/loading_button.dart';

/// Edit an existing incident — update status and add resolution notes.
class EditIncidentScreen extends StatefulWidget {
  final AppState appState;
  final Incident incident;

  const EditIncidentScreen({
    super.key,
    required this.appState,
    required this.incident,
  });

  @override
  State<EditIncidentScreen> createState() => _EditIncidentScreenState();
}

class _EditIncidentScreenState extends State<EditIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descController;
  late final TextEditingController _resolutionController;
  late IncidentStatus _status;
  late IncidentSeverity _severity;
  late IncidentType _type;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final i = widget.incident;
    _descController = TextEditingController(text: i.description);
    _resolutionController =
        TextEditingController(text: i.resolutionNotes ?? '');
    _status = i.status;
    _severity = i.severity;
    _type = i.type;
  }

  @override
  void dispose() {
    _descController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      widget.incident.description = _descController.text.trim();
      widget.incident.status = _status;
      widget.incident.severity = _severity;
      widget.incident.type = _type;
      widget.incident.resolutionNotes =
          _resolutionController.text.trim().isEmpty
              ? null
              : _resolutionController.text.trim();

      await widget.appState.updateIncident(widget.incident);
      if (!mounted) return;

      final msg = _status == IncidentStatus.resolved
          ? 'Incident marked as resolved!'
          : 'Incident updated!';
      AppSnackbar.success(context, msg);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to update incident. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Incident')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Description'),
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'What happened?',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 16),

              _label('Type'),
              Wrap(
                spacing: 8,
                children: IncidentType.values.map((t) {
                  final isSelected = _type == t;
                  return ChoiceChip(
                    label: Text(t.name[0].toUpperCase() + t.name.substring(1)),
                    selected: isSelected,
                    selectedColor: AppColors.neonRed.withValues(alpha: 0.2),
                    side: BorderSide(
                        color: isSelected
                            ? AppColors.neonRed
                            : AppColors.surfaceElevated),
                    labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.neonRed
                            : AppColors.textSecondary),
                    onSelected: (_) => setState(() => _type = t),
                  );
                }).toList(),
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
                          color: isSelected ? color : AppColors.surfaceElevated),
                      labelStyle: TextStyle(
                          color: isSelected ? color : AppColors.textSecondary),
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
                          child: Text(s.name[0].toUpperCase() +
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
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'How was this resolved?',
                ),
              ),
              const SizedBox(height: 28),

              LoadingButton(
                label: _status == IncidentStatus.resolved
                    ? 'Mark Resolved'
                    : 'Update Incident',
                icon: _status == IncidentStatus.resolved
                    ? Icons.check_circle_rounded
                    : Icons.save_rounded,
                isLoading: _loading,
                onPressed: _save,
                gradientColors: _status == IncidentStatus.resolved
                    ? [AppColors.neonGreen, AppColors.tertiary]
                    : null,
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
