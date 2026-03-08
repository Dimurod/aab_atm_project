// lib/widgets/status_badge.dart
import 'package:flutter/material.dart';
import '../theme.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color  color;

  const StatusBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.15),
        border:       Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color, fontSize: 11, fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}


// lib/widgets/stat_card.dart

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color  accent;
  final String? sub;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.accent = AppColors.gold,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        AppColors.navyMid,
          border:       Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
              style: TextStyle(
                color: accent, fontSize: 26, fontWeight: FontWeight.w800,
              )),
            const SizedBox(height: 4),
            Text(label,
              style: const TextStyle(
                color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w600,
              )),
            if (sub != null) ...[
              const SizedBox(height: 2),
              Text(sub!,
                style: const TextStyle(color: AppColors.textDim, fontSize: 10)),
            ],
          ],
        ),
      ),
    );
  }
}


// lib/widgets/section_title.dart

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.gold, fontSize: 11,
          fontWeight: FontWeight.w700, letterSpacing: 1.2,
        ),
      ),
    );
  }
}
