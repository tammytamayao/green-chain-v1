import 'package:flutter/material.dart';
import 'ui/green_theme.dart';
import 'widgets/banner_header.dart';

class SupplyConfirmationPage extends StatelessWidget {
  const SupplyConfirmationPage({
    super.key,
    required this.produceName,
    required this.stallName,
    required this.demandKg,
    required this.suppliedKg,
    required this.arrivalText,
    required this.pickupLocation,
    required this.noteTitle,
    required this.noteBody,
    required this.buttonText,
    required this.onButtonTap,
  });

  final String produceName;
  final String stallName;

  final int demandKg;
  final int suppliedKg;

  final String arrivalText;
  final String pickupLocation;

  final String noteTitle;
  final String noteBody;

  final String buttonText;
  final VoidCallback onButtonTap;

  static const primaryGreen = GreenTheme.primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GreenTheme.softBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const BannerHeaderSliver(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusBanner(
                      icon: Icons.check_circle_outline,
                      title: 'Confirmed',
                      background: const Color(0xFFDDEFD9),
                      border: primaryGreen.withAlpha((0.30 * 255).round()),
                      textColor: primaryGreen,
                    ),
                    const SizedBox(height: 16),

                    _Header(
                      produceName: produceName,
                      stallName: stallName,
                      suppliedKg: suppliedKg,
                      demandKg: demandKg,
                    ),

                    const SizedBox(height: 14),

                    _AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Delivery Details'),
                          const SizedBox(height: 10),
                          _InfoTile(
                            icon: Icons.access_time,
                            title: 'Date and Time of Arrival',
                            value: arrivalText,
                          ),
                          const SizedBox(height: 12),
                          _InfoTile(
                            icon: Icons.place,
                            title: 'Pick-up Location',
                            value: pickupLocation,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    _AppCard(
                      child: _NoteBlock(title: noteTitle, body: noteBody),
                    ),

                    const Spacer(),

                    _PrimaryButton(text: buttonText, onTap: onButtonTap),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- UI pieces ---------------- */

class _Header extends StatelessWidget {
  const _Header({
    required this.produceName,
    required this.stallName,
    required this.suppliedKg,
    required this.demandKg,
  });

  final String produceName;
  final String stallName;
  final int suppliedKg;
  final int demandKg;

  static const primaryGreen = GreenTheme.primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          produceName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 32,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: primaryGreen,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          stallName,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: primaryGreen.withAlpha((0.06 * 255).round()),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: primaryGreen.withAlpha((0.20 * 255).round()),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.grey.shade900,
                          fontSize: 18,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(
                            text: '$suppliedKg kg',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: primaryGreen,
                            ),
                          ),
                          const TextSpan(text: ' to be supplied out of '),
                          TextSpan(
                            text: '$demandKg kg',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const TextSpan(text: ' demand'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withAlpha((0.05 * 255).round())),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  static const chipGreen = Color(0xFF4F7652);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: chipGreen.withAlpha((0.12 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: chipGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoteBlock extends StatelessWidget {
  const _NoteBlock({required this.title, required this.body});

  final String title;
  final String body;

  static const primaryGreen = GreenTheme.primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: primaryGreen.withAlpha((0.06 * 255).round()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryGreen.withAlpha((0.18 * 255).round()),
            ),
          ),
          child: Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  static const primaryGreen = GreenTheme.primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.4),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 44),
          const SizedBox(width: 14),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
