import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Generic confirmation dialog shown before any destructive delete action.
/// Returns true if user confirms, false/null if they cancel.
Future<bool?> showConfirmDeleteDialog({
  required BuildContext context,
  required String title,
  required String itemName,
  String? subtitle,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.neonRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_outline_rounded,
                color: AppColors.neonRed, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              children: [
                const TextSpan(text: 'Are you sure you want to delete '),
                TextSpan(
                  text: '"$itemName"',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: '?'),
              ],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(
                    color: AppColors.neonRed, fontSize: 12)),
          ],
          const SizedBox(height: 4),
          const Text('This action cannot be undone.',
              style:
                  TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text('Delete',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}
