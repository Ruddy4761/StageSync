import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../theme/app_colors.dart';

/// Animated banner that appears at the top when the device is offline.
/// Uses connectivity_plus to detect network status and shows last synced time.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  bool _isOffline = false;
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  DateTime? _lastOnline;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Check initial connectivity and listen to changes
    Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
    _checkInitial();
  }

  Future<void> _checkInitial() async {
    final result = await Connectivity().checkConnectivity();
    _onConnectivityChanged(result);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    // Consider offline if no wifi, mobile, or ethernet connection
    final offline = results.isEmpty ||
        results.every((r) =>
            r == ConnectivityResult.none ||
            r == ConnectivityResult.bluetooth);

    if (!mounted) return;

    if (!offline && _isOffline) {
      // Just came back online
      _lastOnline = DateTime.now();
    }

    setState(() => _isOffline = offline);

    if (offline) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _slideAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: const Color(0xFF1A1020),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonOrange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'You\'re offline',
                    style: TextStyle(
                      color: AppColors.neonOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (_lastOnline != null)
                    Text(
                      'Last synced: ${_formatTime(_lastOnline!)}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11),
                    )
                  else
                    const Text(
                      'Changes will sync when you reconnect',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 11),
                    ),
                ],
              ),
            ),
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.neonOrange, size: 18),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
