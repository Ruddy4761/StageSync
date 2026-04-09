import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../models/staff.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/loading_button.dart';

/// Create/Edit staff screen. Pass [staff] to edit existing member.
class AddStaffScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  final Staff? staff; // null = create mode

  const AddStaffScreen({
    super.key,
    required this.appState,
    required this.concertId,
    this.staff,
  });

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late String _selectedRole;
  late TimeOfDay _shiftStart;
  late TimeOfDay _shiftEnd;
  bool _loading = false;

  bool get _isEditing => widget.staff != null;

  @override
  void initState() {
    super.initState();
    final s = widget.staff;
    _nameController = TextEditingController(text: s?.name ?? '');
    _contactController =
        TextEditingController(text: s?.contactNumber ?? '');
    _selectedRole = s?.role ?? Staff.availableRoles.first;
    _shiftStart = s?.shiftStart != null
        ? TimeOfDay(
            hour: s!.shiftStart!.hour, minute: s.shiftStart!.minute)
        : const TimeOfDay(hour: 14, minute: 0);
    _shiftEnd = s?.shiftEnd != null
        ? TimeOfDay(hour: s!.shiftEnd!.hour, minute: s.shiftEnd!.minute)
        : const TimeOfDay(hour: 22, minute: 0);
  }

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Phone validation if provided
    final phone = _contactController.text.trim();
    if (phone.isNotEmpty &&
        !RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(phone)) {
      AppSnackbar.error(context, 'Enter a valid phone number');
      return;
    }

    setState(() => _loading = true);
    try {
      final now = DateTime.now();
      final shiftStart = DateTime(
          now.year, now.month, now.day, _shiftStart.hour, _shiftStart.minute);
      final shiftEnd = DateTime(
          now.year, now.month, now.day, _shiftEnd.hour, _shiftEnd.minute);

      if (_isEditing) {
        widget.staff!.name = _nameController.text.trim();
        widget.staff!.role = _selectedRole;
        widget.staff!.shiftStart = shiftStart;
        widget.staff!.shiftEnd = shiftEnd;
        widget.staff!.contactNumber =
            phone.isEmpty ? null : phone;
        await widget.appState.updateStaff(widget.staff!);
        if (!mounted) return;
        AppSnackbar.success(context, 'Staff member updated!');
      } else {
        final member = Staff(
          name: _nameController.text.trim(),
          role: _selectedRole,
          shiftStart: shiftStart,
          shiftEnd: shiftEnd,
          contactNumber: phone.isEmpty ? null : phone,
          concertId: widget.concertId,
        );
        await widget.appState.addStaff(member);
        if (!mounted) return;
        AppSnackbar.success(context, 'Staff member added!');
      }
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to save staff member. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Staff Member' : 'Add Staff')),
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
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
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
                  value: Staff.availableRoles.contains(_selectedRole)
                      ? _selectedRole
                      : Staff.availableRoles.first,
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

              LoadingButton(
                label: _isEditing ? 'Update Staff Member' : 'Add Staff Member',
                icon: _isEditing ? Icons.save_rounded : Icons.person_add_rounded,
                isLoading: _loading,
                onPressed: _save,
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
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 10)),
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
