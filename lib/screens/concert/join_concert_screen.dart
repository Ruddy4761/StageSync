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
  bool _isJoining = false;
  String? _concertName;
  String? _errorMessage;
  String? _foundCode;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // ── Step 1: look up concert by code (no join yet) ────────────────
  Future<void> _lookupConcert() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length < 6) return;

    setState(() {
      _isLoading = true;
      _concertFound = false;
      _errorMessage = null;
      _foundCode = null;
    });

    // Check local cache first (already a member)
    final cached = widget.appState.findConcertByJoinCode(code);
    if (cached != null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'You are already a member of "${cached.name}"';
        });
      }
      return;
    }

    // Look up in Firestore without joining
    final name = await widget.appState.lookupConcertByCode(code);
    if (mounted) {
      if (name != null) {
        setState(() {
          _isLoading = false;
          _concertFound = true;
          _concertName = name;
          _foundCode = code;
        });
      } else {
        setState(() {
          _isLoading = false;
          _concertFound = false;
          _errorMessage = 'No concert found with this code';
        });
      }
    }
  }

  // ── Step 2: join with chosen role ────────────────────────────────
  Future<void> _joinWithRole() async {
    if (_foundCode == null) return;
    setState(() => _isJoining = true);

    final result = await widget.appState
        .joinConcertByCode(_foundCode!, role: _selectedRole);

    if (mounted) {
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Joined "${result.concert?.name}" as $_selectedRole 🎉'),
          backgroundColor: AppColors.neonGreen,
        ));
        Navigator.pop(context);
      } else {
        setState(() => _isJoining = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.error ?? 'Could not join concert'),
          backgroundColor: AppColors.neonRed,
        ));
      }
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
            // Icon
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
                'Ask the concert creator for the 6-letter code',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),

            // ── Step 1: Code input ───────────────────────────────
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
              enabled: !_concertFound,
              decoration: InputDecoration(
                hintText: 'XXXXXX',
                hintStyle: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.3),
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                counterText: '',
                filled: true,
                fillColor: _concertFound
                    ? AppColors.surfaceElevated
                    : AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.surfaceElevated),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: AppColors.tertiary, width: 2),
                ),
              ),
              onChanged: (val) {
                if (val.length == 6) {
                  _lookupConcert();
                } else {
                  setState(() {
                    _concertFound = false;
                    _errorMessage = null;
                    _foundCode = null;
                  });
                }
              },
            ),

            if (_isLoading) ...[
              const SizedBox(height: 20),
              const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.tertiary)),
            ],

            if (_errorMessage != null && !_isLoading) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(_errorMessage!,
                    style: const TextStyle(
                        color: AppColors.neonRed, fontSize: 13)),
              ),
            ],

            // ── Step 2: Concert found → role picker ──────────────
            if (_concertFound && !_isLoading) ...[
              const SizedBox(height: 20),

              // Concert found banner
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
                    // Change code button
                    TextButton(
                      onPressed: () => setState(() {
                        _concertFound = false;
                        _foundCode = null;
                        _codeController.clear();
                      }),
                      child: const Text('Change',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Select Your Role',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your role determines what you can do in this concert',
                style:
                    TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 14),

              // Role grid chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Staff.availableRoles.map((role) {
                  final isSelected = _selectedRole == role;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedRole = role),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.tertiary.withValues(alpha: 0.15)
                            : AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.tertiary
                              : AppColors.surfaceElevated,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(Icons.check_rounded,
                                  size: 14,
                                  color: AppColors.tertiary),
                            ),
                          Text(
                            role,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.tertiary
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              // Role description hint
              _RoleHint(role: _selectedRole),

              const SizedBox(height: 24),

              // Join button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isJoining ? null : _joinWithRole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _isJoining
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white))
                      : const Icon(Icons.login_rounded,
                          color: Colors.white),
                  label: Text(
                    _isJoining
                        ? 'Joining...'
                        : 'Join as $_selectedRole',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small hint card describing what the selected role can do.
class _RoleHint extends StatelessWidget {
  final String role;
  const _RoleHint({required this.role});

  static const _hints = <String, String>{
    'Event Manager':
        'Full access except deleting the concert. Can manage all content.',
    'Sound':
        'Can add/edit tasks, log & resolve incidents, and post team notes.',
    'Lighting':
        'Can add/edit tasks, log & resolve incidents, and post team notes.',
    'Security':
        'Can log & resolve incidents, add emergency contacts, and post notes.',
    'Stage Crew':
        'Can add/edit tasks, manage artists lineup, and post team notes.',
    'Volunteers': 'Can view everything and post team notes.',
    'Artist Manager':
        'Can manage artists, add/edit tasks, view budget, and post notes.',
  };

  @override
  Widget build(BuildContext context) {
    final hint = _hints[role] ?? '';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(hint,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
