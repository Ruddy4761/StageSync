import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../models/contact.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/loading_button.dart';

/// Create/Edit emergency contact. Pass [contact] to edit existing.
class EditContactScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  final EmergencyContact? contact; // null = create mode

  const EditContactScreen({
    super.key,
    required this.appState,
    required this.concertId,
    this.contact,
  });

  @override
  State<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _roleController;
  late final TextEditingController _phoneController;
  late String _selectedType;
  bool _loading = false;

  bool get _isEditing => widget.contact != null;

  static const _types = [
    'medical', 'fire', 'police', 'venue', 'security', 'custom'
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _nameController = TextEditingController(text: c?.name ?? '');
    _roleController = TextEditingController(text: c?.role ?? '');
    _phoneController = TextEditingController(text: c?.phoneNumber ?? '');
    _selectedType = c?.type ?? 'custom';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (_isEditing) {
        widget.contact!.name = _nameController.text.trim();
        widget.contact!.role = _roleController.text.trim();
        widget.contact!.phoneNumber = _phoneController.text.trim();
        widget.contact!.type = _selectedType;
        await widget.appState.updateContact(widget.contact!);
        if (!mounted) return;
        AppSnackbar.success(context, 'Contact updated!');
      } else {
        final contact = EmergencyContact(
          name: _nameController.text.trim(),
          role: _roleController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          type: _selectedType,
          concertId: widget.concertId,
        );
        await widget.appState.addContact(contact);
        if (!mounted) return;
        AppSnackbar.success(context, 'Emergency contact added!');
      }
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to save contact. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(_isEditing ? 'Edit Contact' : 'Add Emergency Contact')),
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
                  hintText: 'Contact name or service',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              _label('Role / Description'),
              TextFormField(
                controller: _roleController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g., Medical/Ambulance',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Role is required' : null,
              ),
              const SizedBox(height: 16),

              _label('Phone Number'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: '+91 98765 43210',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (!RegExp(r'^\+?[\d\s\-]{6,15}$').hasMatch(v.trim())) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _label('Category'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _types.map((type) {
                  final isSelected = _selectedType == type;
                  final color = _typeColor(type);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.2)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : AppColors.surfaceElevated,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_typeIcon(type), color: color, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            type[0].toUpperCase() + type.substring(1),
                            style: TextStyle(
                              color: isSelected
                                  ? color
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              LoadingButton(
                label: _isEditing ? 'Update Contact' : 'Add Contact',
                icon:
                    _isEditing ? Icons.save_rounded : Icons.add_rounded,
                isLoading: _loading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'medical':
        return AppColors.emergencyMedical;
      case 'fire':
        return AppColors.emergencyFire;
      case 'police':
        return AppColors.emergencyPolice;
      case 'venue':
        return AppColors.emergencyVenue;
      case 'security':
        return AppColors.emergencySecurity;
      default:
        return AppColors.textMuted;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'medical':
        return Icons.medical_services_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'police':
        return Icons.local_police_rounded;
      case 'venue':
        return Icons.location_city_rounded;
      case 'security':
        return Icons.security_rounded;
      default:
        return Icons.contacts_rounded;
    }
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
