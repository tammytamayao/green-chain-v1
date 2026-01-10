import 'package:flutter/material.dart';
import 'package:green_chain_v1/ui/green_theme.dart';
import 'package:green_chain_v1/widgets/banner_header.dart';

class ConsumerOrderConfirmationPage extends StatelessWidget {
  const ConsumerOrderConfirmationPage({
    super.key,
    required this.productName,
    required this.stallName,
    required this.qtyKg,
    required this.totalAmount,
    required this.arrivalText,
    required this.deliveryLocation,
    required this.buttonText,
    this.deliveryApproachLabel,
    this.paymentMethodLabel,
  });

  final String productName;
  final String stallName;

  final int qtyKg;
  final double totalAmount;

  final String arrivalText;
  final String deliveryLocation;

  final String buttonText;

  final String? deliveryApproachLabel;
  final String? paymentMethodLabel;

  static const primaryGreen = GreenTheme.primary;

  @override
  Widget build(BuildContext context) {
    final amountText = '₱${totalAmount.toStringAsFixed(2)}';

    return Scaffold(
      backgroundColor: GreenTheme.softBg,

      // Back to home / orders button at the bottom
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: _PrimaryButton(
          text: buttonText,
          onTap: () {
            // Go back to the first route (likely your home / consumer orders page)
            Navigator.of(context).popUntil((route) => route.isFirst);

            // If you have a dedicated consumer orders route, you can instead do:
            // Navigator.of(context).pushNamedAndRemoveUntil(
            //   '/consumer-orders',
            //   (route) => false,
            // );
          },
        ),
      ),

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
                    const _StatusBanner(
                      icon: Icons.check_circle_outline,
                      title: 'Order Placed',
                      background: Color(0xFFDDEFD9),
                      borderFactor: 0.30,
                      textColor: primaryGreen,
                    ),
                    const SizedBox(height: 16),

                    _Header(
                      productName: productName,
                      stallName: stallName,
                      qtyKg: qtyKg,
                      amountText: amountText,
                    ),

                    const SizedBox(height: 14),

                    _AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Order details'),
                          const SizedBox(height: 2),
                          _InfoTileNoIcon(
                            title: 'Quantity',
                            value: '$qtyKg kg',
                          ),
                          const SizedBox(height: 2),
                          _InfoTileNoIcon(
                            title: 'Total amount',
                            value: amountText,
                          ),
                          if (paymentMethodLabel != null) ...[
                            const SizedBox(height: 2),
                            _InfoTileNoIcon(
                              title: 'Payment method',
                              value: paymentMethodLabel!,
                            ),
                          ],
                          if (deliveryApproachLabel != null) ...[
                            const SizedBox(height: 2),
                            _InfoTileNoIcon(
                              title: 'Delivery method',
                              value: deliveryApproachLabel!,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    _AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Delivery details'),
                          const SizedBox(height: 10),
                          _InfoTileWithIcon(
                            icon: Icons.access_time,
                            title: 'Estimated arrival',
                            value: arrivalText,
                          ),
                          const SizedBox(height: 12),
                          _InfoTileWithIcon(
                            icon: Icons.place,
                            title: 'Delivery / pick-up location',
                            value: deliveryLocation,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
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
    required this.productName,
    required this.stallName,
    required this.qtyKg,
    required this.amountText,
  });

  final String productName;
  final String stallName;
  final int qtyKg;
  final String amountText;

  static const primaryGreen = GreenTheme.primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productName,
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
                            text: '$qtyKg kg',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: primaryGreen,
                            ),
                          ),
                          const TextSpan(text: ' • '),
                          TextSpan(
                            text: amountText,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
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

/// ORDER DETAILS (NO ICONS)
class _InfoTileNoIcon extends StatelessWidget {
  const _InfoTileNoIcon({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// DELIVERY DETAILS (WITH ICONS)
class _InfoTileWithIcon extends StatelessWidget {
  const _InfoTileWithIcon({
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
    required this.borderFactor,
    required this.textColor,
  });

  final IconData icon;
  final String title;
  final Color background;
  final double borderFactor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: textColor.withAlpha((borderFactor * 255).round()),
          width: 1.4,
        ),
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
