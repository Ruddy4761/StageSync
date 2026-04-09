import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated shimmer skeleton card for loading states.
class SkeletonCard extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.height = 160,
    this.width,
    this.borderRadius = 16,
  });

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surfaceCard,
                Color.lerp(AppColors.surfaceCard,
                    AppColors.surfaceElevated, _animation.value)!,
                AppColors.surfaceCard,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonLine(60, 10),
                const SizedBox(height: 14),
                _skeletonLine(double.infinity, 14),
                const SizedBox(height: 8),
                _skeletonLine(120, 11),
                const SizedBox(height: 6),
                _skeletonLine(100, 11),
                const Spacer(),
                const Divider(color: AppColors.surfaceElevated),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _skeletonLine(40, 12),
                    _skeletonLine(40, 12),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _skeletonLine(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
