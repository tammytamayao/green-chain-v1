import 'package:flutter/material.dart';
import '../ui/green_theme.dart';

/// A minimalist banner header showing the Green Chain logo and a notifications icon.
class BannerHeaderSliver extends StatelessWidget {
  const BannerHeaderSliver({
    super.key,
    this.assetPath = 'assets/banner.png',
    this.height = 64,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 8),
    this.onNotifications,
  });

  final String assetPath;
  final double height;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onNotifications;

  @override
  Widget build(BuildContext context) {
    final logoHeight =
        height * 0.65; // slightly smaller — about 42px if height=64

    return SliverToBoxAdapter(
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  height: logoHeight,
                  errorBuilder: (_, __, ___) => Text(
                    'Green Chain',
                    style: TextStyle(
                      color: GreenTheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: logoHeight * 0.5,
                    ),
                  ),
                ),
              ),
            ),
            // Notifications icon
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              color: Colors.grey.shade700,
              tooltip: 'Notifications',
              onPressed: onNotifications ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}
