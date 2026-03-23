import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../models/task.dart';

class CreateTaskScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  const CreateTaskScreen(
      {super.key, required this.appState, required this.concertId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String? _assignedTo;
  TaskStatus _status = TaskStatus.notStarted;
  TaskPriority _priority = TaskPriority.medium;

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

  void _save() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final task = ConcertTask(
        title: _nameController.text.trim(),
        time: DateTime(
            now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute),
        assignedTo: _assignedTo ?? 'Unassigned',
        status: _status,
        priority: _priority,
        description: _descController.text.trim(),
        concertId: widget.concertId,
      );
      widget.appState.addTask(task);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffNames = widget.appState.getStaffNamesForConcert(widget.concertId);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
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
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _label('Time'),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                  value: _assignedTo,
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
                              style: const TextStyle(color: AppColors.textPrimary))))
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
                      label: Text(p.name[0].toUpperCase() + p.name.substring(1)),
                      selected: isSelected,
                      selectedColor: color.withValues(alpha: 0.2),
                      side: BorderSide(
                          color: isSelected ? color : AppColors.surfaceElevated),
                      labelStyle: TextStyle(
                          color: isSelected ? color : AppColors.textSecondary),
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
                    icon: const Icon(Icons.add_task_rounded, color: Colors.white),
                    label: const Text('Add Task',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
