import 'package:flutter/material.dart';
import 'package:green_chain_v1/ui/green_theme.dart';
import 'package:green_chain_v1/widgets/banner_header.dart';
import 'package:green_chain_v1/widgets/bottom_nav.dart';
import 'package:green_chain_v1/account_page.dart';
import 'package:green_chain_v1/features/consumer/consumer_orders_page.dart';

class ConsumerHomePage extends StatelessWidget {
  const ConsumerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GreenTheme.softBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const BannerHeaderSliver(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome, Consumer',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browse stalls, discover fresh products, and place your orders.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _ConsumerCard(
                      icon: Icons.store_mall_directory_outlined,
                      title: 'Browse stalls',
                      subtitle: 'Find nearby stalls and see what they offer.',
                      onTap: () {
                        // TODO: navigate to stalls browsing screen
                      },
                    ),
                    _ConsumerCard(
                      icon: Icons.shopping_bag_outlined,
                      title: 'My orders',
                      subtitle: 'View your previous and active orders.',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ConsumerOrdersPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        // reuse farmer-style visuals for consumer
        role: UserRole.farmer,
        current: AppTab.home,
        onHome: () {
          // already here
        },
        onMiddle: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ConsumerOrdersPage()),
          );
        },
        onAccount: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AccountPage()),
          );
        },
      ),
    );
  }
}

class _ConsumerCard extends StatelessWidget {
  const _ConsumerCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: GreenTheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
