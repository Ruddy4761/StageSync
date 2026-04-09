import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../models/concert.dart';
import '../../models/staff.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/loading_button.dart';

/// Edit concert screen — pre-filled with existing concert data.
/// Only accessible to the concert creator.
class EditConcertScreen extends StatefulWidget {
  final AppState appState;
  final Concert concert;
  const EditConcertScreen(
      {super.key, required this.appState, required this.concert});

  @override
  State<EditConcertScreen> createState() => _EditConcertScreenState();
}

class _EditConcertScreenState extends State<EditConcertScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _venueController;
  late final TextEditingController _capacityController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.concert.name);
    _venueController =
        TextEditingController(text: widget.concert.venue);
    _capacityController =
        TextEditingController(text: widget.concert.capacity.toString());
    _selectedDate = widget.concert.dateTime;
    _selectedTime = TimeOfDay(
      hour: widget.concert.dateTime.hour,
      minute: widget.concert.dateTime.minute,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(DateTime.now())
          ? _selectedDate
          : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
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
    if (picked != null) setState(() => _selectedDate = picked);
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

    final capacity = int.tryParse(_capacityController.text);
    if (capacity == null || capacity <= 0) {
      AppSnackbar.error(context, 'Capacity must be a positive number');
      return;
    }

    setState(() => _loading = true);
    try {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      widget.concert.name = _nameController.text.trim();
      widget.concert.venue = _venueController.text.trim();
      widget.concert.capacity = capacity;
      widget.concert.dateTime = dateTime;

      await widget.appState.updateConcert(widget.concert);

      if (!mounted) return;
      AppSnackbar.success(context, 'Concert updated successfully!');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to update concert. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Concert')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Concert Name'),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Concert name',
                  prefixIcon: Icon(Icons.music_note_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter concert name' : null,
              ),
              const SizedBox(height: 20),

              _label('Date & Time'),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppColors.surfaceElevated),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 18, color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('MMM d, yyyy')
                                  .format(_selectedDate),
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppColors.surfaceElevated),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 18, color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _label('Venue'),
              TextFormField(
                controller: _venueController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Venue name and location',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter venue' : null,
              ),
              const SizedBox(height: 20),

              _label('Capacity'),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Max attendees',
                  prefixIcon: Icon(Icons.people_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter capacity';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Must be a positive number';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Join code info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_rounded,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Join Code',
                              style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11)),
                          Text(widget.concert.joinCode,
                              style: const TextStyle(
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded,
                          color: AppColors.textMuted, size: 18),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: widget.concert.joinCode));
                        AppSnackbar.success(context, 'Join code copied!');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              LoadingButton(
                label: 'Save Changes',
                icon: Icons.save_rounded,
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
