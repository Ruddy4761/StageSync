import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../models/staff.dart';

class AddStaffScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  const AddStaffScreen(
      {super.key, required this.appState, required this.concertId});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  String _selectedRole = Staff.availableRoles.first;
  TimeOfDay _shiftStart = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _shiftEnd = const TimeOfDay(hour: 22, minute: 0);

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _shiftStart : _shiftEnd,
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
    if (picked != null) {
      setState(() {
        if (isStart) {
          _shiftStart = picked;
        } else {
          _shiftEnd = picked;
        }
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final member = Staff(
        name: _nameController.text.trim(),
        role: _selectedRole,
        shiftStart: DateTime(
            now.year, now.month, now.day, _shiftStart.hour, _shiftStart.minute),
        shiftEnd: DateTime(
            now.year, now.month, now.day, _shiftEnd.hour, _shiftEnd.minute),
        contactNumber: _contactController.text.trim().isEmpty
            ? null
            : _contactController.text.trim(),
        concertId: widget.concertId,
      );
      widget.appState.addStaff(member);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Staff')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Name'),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _label('Role'),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceElevated),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  dropdownColor: AppColors.surfaceLight,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: Staff.availableRoles
                      .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role,
                              style: const TextStyle(
                                  color: AppColors.textPrimary))))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedRole = val ?? _selectedRole),
                ),
              ),
              const SizedBox(height: 16),

              _label('Shift Time'),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(true),
                      child: _timeBox('Start', _shiftStart.format(context)),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('to',
                        style: TextStyle(color: AppColors.textMuted)),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(false),
                      child: _timeBox('End', _shiftEnd.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _label('Contact Number (optional)'),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: '+91 98765 43210',
                  prefixIcon: Icon(Icons.phone_outlined),
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
                    icon: const Icon(Icons.person_add_rounded,
                        color: Colors.white),
                    label: const Text('Add Staff',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
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

  Widget _timeBox(String label, String time) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceElevated),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(time,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14)),
              ],
            ),
          ],
        ),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      );
}
