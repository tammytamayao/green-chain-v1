import 'package:flutter/material.dart';
import 'ui/green_theme.dart';

class SupplyRejectedPage extends StatelessWidget {
  const SupplyRejectedPage({
    super.key,
    required this.produceName,
    required this.stallName,
    required this.demandKg,
    required this.noteTitle,
    required this.noteBody,
    required this.onTryAgain,
  });

  final String produceName;
  final String stallName;
  final int demandKg;

  final String noteTitle;
  final String noteBody;

  final VoidCallback onTryAgain;

  static const primaryGreen = GreenTheme.primary;
  static const chipGreen = Color(0xFF4F7652);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GreenTheme.softBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            children: [
              _StatusBanner(
                icon: Icons.cancel_outlined,
                title: 'Rejected',
                background: const Color(0xFFF3DADA),
                border: Colors.redAccent.withAlpha((0.35 * 255).round()),
                textColor: Colors.redAccent,
              ),
              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produceName,
                          style: const TextStyle(
                            fontSize: 34,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stallName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: chipGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${demandKg}kg',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _NoteCard(title: noteTitle, body: noteBody),

              const Spacer(),

              SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: onTryAgain,
                  child: const Text(
                    'Try again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
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
}

/* ---- shared UI ---- */

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.title,
    required this.background,
    required this.border,
    required this.textColor,
  });

  final IconData icon;
  final String title;
  final Color background;
  final Color border;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 34),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.title, required this.body});
  final String title;
  final String body;

  static const primaryGreen = GreenTheme.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.70 * 255).round()),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 16,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
