import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../models/task.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/loading_button.dart';

/// Create/Edit task screen. Pass [task] to edit, omit to create new.
class CreateTaskScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  final ConcertTask? task; // null = create mode, non-null = edit mode

  const CreateTaskScreen({
    super.key,
    required this.appState,
    required this.concertId,
    this.task,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late TimeOfDay _selectedTime;
  late String? _assignedTo;
  late TaskStatus _status;
  late TaskPriority _priority;
  bool _loading = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _nameController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _selectedTime = t != null
        ? TimeOfDay(hour: t.time.hour, minute: t.time.minute)
        : const TimeOfDay(hour: 10, minute: 0);
    _assignedTo = t?.assignedTo;
    _status = t?.status ?? TaskStatus.notStarted;
    _priority = t?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final now = DateTime.now();
      if (_isEditing) {
        // Update existing
        widget.task!.title = _nameController.text.trim();
        widget.task!.description = _descController.text.trim();
        widget.task!.time = DateTime(
            now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);
        widget.task!.assignedTo = _assignedTo ?? 'Unassigned';
        widget.task!.status = _status;
        widget.task!.priority = _priority;
        await widget.appState.updateTask(widget.task!);
        if (!mounted) return;
        AppSnackbar.success(context, 'Task updated!');
      } else {
        // Create new
        final task = ConcertTask(
          title: _nameController.text.trim(),
          time: DateTime(now.year, now.month, now.day, _selectedTime.hour,
              _selectedTime.minute),
          assignedTo: _assignedTo ?? 'Unassigned',
          status: _status,
          priority: _priority,
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          concertId: widget.concertId,
        );
        await widget.appState.addTask(task);
        if (!mounted) return;
        AppSnackbar.success(context, 'Task added!');
      }
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to save task. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffNames =
        widget.appState.getStaffNamesForConcert(widget.concertId);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Task' : 'Add Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Task Name'),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g., Sound Check',
                  prefixIcon: Icon(Icons.task_alt_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Task name is required' : null,
              ),
              const SizedBox(height: 16),

              _label('Time'),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceElevated),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Text(_selectedTime.format(context),
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _label('Assign To'),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceElevated),
                ),
                child: DropdownButtonFormField<String>(
                  value: staffNames.contains(_assignedTo) ? _assignedTo : null,
                  dropdownColor: AppColors.surfaceLight,
                  hint: const Text('Select team member',
                      style: TextStyle(color: AppColors.textMuted)),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: staffNames
                      .map((name) => DropdownMenuItem(
                          value: name,
                          child: Text(name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary))))
                      .toList(),
                  onChanged: (val) => setState(() => _assignedTo = val),
                ),
              ),
              const SizedBox(height: 16),

              _label('Priority'),
              Row(
                children: TaskPriority.values.map((p) {
                  final isSelected = _priority == p;
                  final color = p == TaskPriority.high
                      ? AppColors.priorityHigh
                      : p == TaskPriority.medium
                          ? AppColors.priorityMedium
                          : AppColors.priorityLow;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                          p.name[0].toUpperCase() + p.name.substring(1)),
                      selected: isSelected,
                      selectedColor: color.withValues(alpha: 0.2),
                      side: BorderSide(
                          color: isSelected
                              ? color
                              : AppColors.surfaceElevated),
                      labelStyle: TextStyle(
                          color: isSelected
                              ? color
                              : AppColors.textSecondary),
                      onSelected: (_) => setState(() => _priority = p),
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
                child: DropdownButtonFormField<TaskStatus>(
                  value: _status,
                  dropdownColor: AppColors.surfaceLight,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.info_outline),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: TaskStatus.values
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
                  onChanged: (val) =>
                      setState(() => _status = val ?? TaskStatus.notStarted),
                ),
              ),
              const SizedBox(height: 16),

              _label('Description (optional)'),
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add any notes...',
                ),
              ),
              const SizedBox(height: 28),

              LoadingButton(
                label: _isEditing ? 'Update Task' : 'Add Task',
                icon: _isEditing ? Icons.save_rounded : Icons.add_task_rounded,
                isLoading: _loading,
                onPressed: _save,
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
