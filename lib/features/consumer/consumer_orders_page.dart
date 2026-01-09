import 'package:flutter/material.dart';
import 'package:green_chain_v1/ui/green_theme.dart';
import 'package:green_chain_v1/widgets/banner_header.dart';
import 'package:green_chain_v1/widgets/bottom_nav.dart';
import 'package:green_chain_v1/account_page.dart';
import 'package:green_chain_v1/features/consumer/consumer_home_page.dart';

class ConsumerOrdersPage extends StatelessWidget {
  const ConsumerOrdersPage({super.key});

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
                      'My Orders',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here you can later list all orders placed by this consumer.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No orders yet.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        role: UserRole.farmer,
        current: AppTab.middle, // orders tab
        onHome: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ConsumerHomePage()),
          );
        },
        onMiddle: () {
          // already here
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
