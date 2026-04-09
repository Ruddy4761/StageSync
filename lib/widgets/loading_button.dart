import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A gradient button that shows a loading spinner while [isLoading] is true.
/// Disables itself during loading to prevent double-taps.
class LoadingButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onPressed;
  final List<Color>? gradientColors;

  const LoadingButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        [AppColors.primary, AppColors.secondary];

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: AnimatedOpacity(
        opacity: isLoading ? 0.7 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isLoading
                ? []
                : [
                    BoxShadow(
                      color: colors.first.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: Colors.transparent,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
