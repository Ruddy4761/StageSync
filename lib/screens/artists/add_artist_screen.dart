import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../models/artist.dart';

class AddArtistScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  const AddArtistScreen(
      {super.key, required this.appState, required this.concertId});

  @override
  State<AddArtistScreen> createState() => _AddArtistScreenState();
}

class _AddArtistScreenState extends State<AddArtistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _requirementsController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 19, minute: 0);

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
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
    if (picked != null) setState(() => _startTime = picked);
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final existingArtists =
          widget.appState.getArtistsForConcert(widget.concertId);
      final artist = Artist(
        name: _nameController.text.trim(),
        performanceTime: DateTime(
            now.year, now.month, now.day, _startTime.hour, _startTime.minute),
        durationMinutes: int.tryParse(_durationController.text) ?? 30,
        specialRequirements: _requirementsController.text.trim().isEmpty
            ? null
            : _requirementsController.text.trim(),
        order: existingArtists.length + 1,
        concertId: widget.concertId,
      );
      widget.appState.addArtist(artist);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Artist')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Artist Name'),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g., Arijit Singh',
                  prefixIcon: Icon(Icons.mic_rounded),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _label('Start Time'),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                      Text(_startTime.format(context),
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _label('Duration (minutes)'),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g., 45',
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _label('Special Requirements (optional)'),
              TextFormField(
                controller: _requirementsController,
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g., Acoustic guitar amp on stage left',
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
                    icon: const Icon(Icons.music_note_rounded,
                        color: Colors.white),
                    label: const Text('Add Artist',
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      );
}
