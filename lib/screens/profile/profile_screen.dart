import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../routes/app_routes.dart';
import '../../services/notification_service.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/loading_button.dart';

class ProfileScreen extends StatefulWidget {
  final AppState appState;
  const ProfileScreen({super.key, required this.appState});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _nameFormKey = GlobalKey<FormState>();
  final _passFormKey = GlobalKey<FormState>();

  bool _loadingName = false;
  bool _loadingPass = false;
  bool _notificationsEnabled = true;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.appState.currentUserName;
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveNotificationPref(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', val);
    setState(() => _notificationsEnabled = val);
    if (val) {
      await NotificationService.requestPermissions();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // ─── Update Display Name ─────────────────────────────────────────
  Future<void> _saveName() async {
    if (!_nameFormKey.currentState!.validate()) return;
    setState(() => _loadingName = true);
    try {
      final result =
          await widget.appState.updateDisplayName(_nameController.text.trim());
      if (!mounted) return;
      if (result.success) {
        AppSnackbar.success(context, 'Display name updated!');
      } else {
        AppSnackbar.error(context, result.error ?? 'Failed to update name');
      }
    } finally {
      if (mounted) setState(() => _loadingName = false);
    }
  }

  // ─── Change Password ─────────────────────────────────────────────
  Future<void> _changePassword() async {
    if (!_passFormKey.currentState!.validate()) return;
    setState(() => _loadingPass = true);
    try {
      final result = await widget.appState.updatePassword(
        currentPassword: _currentPassController.text,
        newPassword: _newPassController.text,
      );
      if (!mounted) return;
      if (result.success) {
        AppSnackbar.success(context, 'Password changed successfully!');
        _currentPassController.clear();
        _newPassController.clear();
        _confirmPassController.clear();
      } else {
        AppSnackbar.error(context, result.error ?? 'Failed to change password');
      }
    } finally {
      if (mounted) setState(() => _loadingPass = false);
    }
  }

  // ─── Sign Out ────────────────────────────────────────────────────
  void _signOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.appState.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (_) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.appState.currentUserName;
    final email = widget.appState.currentUserEmail;
    final initials = name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded, color: AppColors.neonRed),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ─── Avatar ─────────────────────────────────
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials.isEmpty ? '?' : initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(name,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(email,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 28),

            // ─── Update Name ─────────────────────────────
            _card(
              title: 'Display Name',
              icon: Icons.person_rounded,
              iconColor: AppColors.primary,
              child: Form(
                key: _nameFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Name cannot be empty' : null,
                    ),
                    const SizedBox(height: 12),
                    LoadingButton(
                      label: 'Update Name',
                      icon: Icons.save_rounded,
                      isLoading: _loadingName,
                      onPressed: _saveName,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ─── Change Password ─────────────────────────
            _card(
              title: 'Change Password',
              icon: Icons.lock_rounded,
              iconColor: AppColors.secondary,
              child: Form(
                key: _passFormKey,
                child: Column(
                  children: [
                    _passField(
                      controller: _currentPassController,
                      hint: 'Current password',
                      obscure: _obscureCurrent,
                      toggle: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Enter current password'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _passField(
                      controller: _newPassController,
                      hint: 'New password',
                      obscure: _obscureNew,
                      toggle: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter new password';
                        if (v.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    _passField(
                      controller: _confirmPassController,
                      hint: 'Confirm new password',
                      obscure: _obscureConfirm,
                      toggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) {
                        if (v != _newPassController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    LoadingButton(
                      label: 'Change Password',
                      icon: Icons.lock_reset_rounded,
                      isLoading: _loadingPass,
                      onPressed: _changePassword,
                      gradientColors: [
                        AppColors.secondary,
                        AppColors.primary
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ─── Preferences ─────────────────────────────
            _card(
              title: 'Preferences',
              icon: Icons.settings_rounded,
              iconColor: AppColors.tertiary,
              child: Column(
                children: [
                  _settingToggle(
                    title: 'Concert Notifications',
                    subtitle: 'Reminders 24h and 1h before events',
                    icon: Icons.notifications_rounded,
                    iconColor: AppColors.neonOrange,
                    value: _notificationsEnabled,
                    onChanged: _saveNotificationPref,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── App Info ─────────────────────────────────
            _card(
              title: 'About',
              icon: Icons.info_rounded,
              iconColor: AppColors.textMuted,
              child: Column(
                children: [
                  _infoRow('App Version', '1.0.0'),
                  _infoRow('Build', '2026.1'),
                  _infoRow('Platform', 'Flutter'),
                  _infoRow('Database', 'Firebase Firestore'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Sign Out Button ──────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.neonRed, size: 20),
                label: const Text('Sign Out',
                    style: TextStyle(
                        color: AppColors.neonRed,
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.neonRed),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceElevated),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _passField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
              size: 18, color: AppColors.textMuted),
          onPressed: toggle,
        ),
      ),
      validator: validator,
    );
  }

  Widget _settingToggle({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              Text(subtitle,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
          inactiveTrackColor: AppColors.surfaceElevated,
          inactiveThumbColor: AppColors.textMuted,
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
