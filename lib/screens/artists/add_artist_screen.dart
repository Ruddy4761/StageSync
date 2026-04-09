import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../models/artist.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/loading_button.dart';

/// Create/Edit artist screen. Pass [artist] to edit existing.
class AddArtistScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  final Artist? artist; // null = create mode

  const AddArtistScreen({
    super.key,
    required this.appState,
    required this.concertId,
    this.artist,
  });

  @override
  State<AddArtistScreen> createState() => _AddArtistScreenState();
}

class _AddArtistScreenState extends State<AddArtistScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _genreController;
  late final TextEditingController _durationController;
  late final TextEditingController _requirementsController;
  late TimeOfDay _startTime;
  bool _loading = false;

  bool get _isEditing => widget.artist != null;

  @override
  void initState() {
    super.initState();
    final a = widget.artist;
    _nameController = TextEditingController(text: a?.name ?? '');
    _genreController = TextEditingController(text: a?.genre ?? '');
    _durationController =
        TextEditingController(text: a?.durationMinutes.toString() ?? '');
    _requirementsController =
        TextEditingController(text: a?.specialRequirements ?? '');
    _startTime = a?.performanceTime != null
        ? TimeOfDay(
            hour: a!.performanceTime!.hour,
            minute: a.performanceTime!.minute)
        : const TimeOfDay(hour: 19, minute: 0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genreController.dispose();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final duration = int.tryParse(_durationController.text);
    if (duration == null || duration <= 0) {
      AppSnackbar.error(context, 'Duration must be a positive number');
      return;
    }

    setState(() => _loading = true);
    try {
      final now = DateTime.now();
      final performanceTime = DateTime(
          now.year, now.month, now.day, _startTime.hour, _startTime.minute);

      if (_isEditing) {
        widget.artist!.name = _nameController.text.trim();
        widget.artist!.genre = _genreController.text.trim();
        widget.artist!.performanceTime = performanceTime;
        widget.artist!.durationMinutes = duration;
        widget.artist!.specialRequirements =
            _requirementsController.text.trim().isEmpty
                ? null
                : _requirementsController.text.trim();
        await widget.appState.updateArtist(widget.artist!);
        if (!mounted) return;
        AppSnackbar.success(context, 'Artist updated!');
      } else {
        final existing =
            widget.appState.getArtistsForConcert(widget.concertId);
        final artist = Artist(
          name: _nameController.text.trim(),
          genre: _genreController.text.trim(),
          performanceTime: performanceTime,
          durationMinutes: duration,
          specialRequirements: _requirementsController.text.trim().isEmpty
              ? null
              : _requirementsController.text.trim(),
          order: existing.length + 1,
          concertId: widget.concertId,
        );
        await widget.appState.addArtist(artist);
        if (!mounted) return;
        AppSnackbar.success(context, 'Artist added!');
      }
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to save artist. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Artist' : 'Add Artist')),
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
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Artist name is required'
                    : null,
              ),
              const SizedBox(height: 16),

              _label('Genre (optional)'),
              TextFormField(
                controller: _genreController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g., Bollywood, Rock, EDM',
                  prefixIcon: Icon(Icons.music_note_outlined),
                ),
              ),
              const SizedBox(height: 16),

              _label('Start Time'),
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
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Duration is required';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Must be a positive number';
                  return null;
                },
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

              LoadingButton(
                label: _isEditing ? 'Update Artist' : 'Add Artist',
                icon: _isEditing ? Icons.save_rounded : Icons.music_note_rounded,
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
