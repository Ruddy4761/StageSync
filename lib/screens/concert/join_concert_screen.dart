import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../models/staff.dart';

class JoinConcertScreen extends StatefulWidget {
  final AppState appState;
  const JoinConcertScreen({super.key, required this.appState});

  @override
  State<JoinConcertScreen> createState() => _JoinConcertScreenState();
}

class _JoinConcertScreenState extends State<JoinConcertScreen> {
  final _codeController = TextEditingController();
  String _selectedRole = Staff.availableRoles.first;
  bool _concertFound = false;
  bool _isLoading = false;
  String? _concertName;
  String? _concertId;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _searchConcert() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);

    // First check local cache
    var concert = widget.appState.findConcertByJoinCode(code);

    // If not found locally, search Firestore
    if (concert == null) {
      final result = await widget.appState.joinConcertByCode(code);
      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Joined "${result.concert?.name}" successfully! 🎉'),
              backgroundColor: AppColors.neonGreen,
            ),
          );
          Navigator.pop(context);
          return;
        } else if (result.concert != null) {
          // Already a member
          setState(() {
            _isLoading = false;
            _concertFound = true;
            _concertName = result.concert!.name;
            _concertId = result.concert!.id;
            _errorMessage = result.error;
          });
          return;
        } else {
          setState(() {
            _isLoading = false;
            _concertFound = false;
            _concertName = null;
            _concertId = null;
            _errorMessage = result.error ?? 'No concert found with this code';
          });
          return;
        }
      }
    }

    // Found locally (already a member)
    if (mounted) {
      setState(() {
        _isLoading = false;
        _concertFound = true;
        _concertName = concert!.name;
        _concertId = concert.id;
        _errorMessage = 'You are already a member of this concert';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Concert'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Illustration
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.secondaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.tertiary.withValues(alpha: 0.3),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(Icons.group_add_rounded,
                    size: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Enter Join Code',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Ask the concert creator for the code',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),

            // Code input
            TextField(
              controller: _codeController,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 8,
              ),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: 'XXXXXX',
                hintStyle: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.3),
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                counterText: '',
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.surfaceElevated),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.tertiary, width: 2),
                ),
              ),
              onChanged: (_) {
                if (_codeController.text.length == 6) {
                  _searchConcert();
                } else {
                  setState(() {
                    _concertFound = false;
                    _errorMessage = null;
                    _isLoading = false;
                  });
                }
              },
            ),
            if (_isLoading) ...[
              const SizedBox(height: 20),
              const Center(
                child: CircularProgressIndicator(color: AppColors.tertiary),
              ),
            ],
            if (_errorMessage != null && !_isLoading) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(_errorMessage!,
                    style: const TextStyle(color: AppColors.neonRed, fontSize: 13)),
              ),
            ],

            if (_concertFound && !_isLoading) ...[
              const SizedBox(height: 20),
              // Concert found card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.neonGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.neonGreen, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Concert Found!',
                              style: TextStyle(
                                  color: AppColors.neonGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                          Text(_concertName ?? '',
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
