import 'package:flutter/material.dart';
import 'auth_api.dart';
import 'home_farmer.dart';
import 'account_page.dart';

// Adjust paths as needed:
import 'ui/green_theme.dart';
import 'widgets/banner_header.dart';
import 'widgets/bottom_nav.dart';

class StallsPage extends StatefulWidget {
  const StallsPage({super.key});

  static const primaryGreen = GreenTheme.primary;
  static const softBg = GreenTheme.softBg;
  static const chipBg = Color(0xFF4F7652);

  @override
  State<StallsPage> createState() => _StallsPageState();
}

class _StallsPageState extends State<StallsPage> {
  Map<String, dynamic>? _profile; // null = loading
  String? _error;

  final sections = <_ProduceDemand>[
    const _ProduceDemand(
      title: 'Green Ice Lettuce',
      asset: 'assets/green_ice.jpg',
      stalls: [
        _StallDemand('Stall A', 25),
        _StallDemand('Stall B', 36),
        _StallDemand('Stall C', 48),
      ],
    ),
    const _ProduceDemand(
      title: 'Iceberg Lettuce',
      asset: 'assets/iceberg.jpg',
      stalls: [
        _StallDemand('Stall A', 66),
        _StallDemand('Stall B', 65),
        _StallDemand('Stall C', 23),
      ],
    ),
    const _ProduceDemand(
      title: 'Romaine Lettuce',
      asset: 'assets/romaine.jpg',
      stalls: [
        _StallDemand('Stall A', 43),
        _StallDemand('Stall B', 30),
        _StallDemand('Stall C', 96),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await me().timeout(const Duration(seconds: 8));
      if (!mounted) return;
      setState(() {
        _profile = p ?? {};
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _profile = {};
        _error = 'Could not load profile';
      });
    }
  }

  String _niceNow() {
    final now = DateTime.now();
    const m = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final h = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final mm = now.minute.toString().padLeft(2, '0');
    return '${m[now.month - 1]} ${now.day}, ${now.year} | $h:$mm $ampm';
  }

  void _goHome() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const FarmerHomePage()),
  );
  void _goStalls() {}
  void _goAccount() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const AccountPage()),
  );

  @override
  Widget build(BuildContext context) {
    final loading = _profile == null;

    return Scaffold(
      backgroundColor: StallsPage.softBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const BannerHeaderSliver(), // <— banner header here

            if (loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: StallsPage.primaryGreen,
                  ),
                ),
              )
            else ...[
              if (_error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ),

              // SECTION TITLE — “Current Demand”
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Demand',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: StallsPage.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _niceNow(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // SECTIONS
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList.separated(
                  itemCount: sections.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (context, i) =>
                      _DemandSection(data: sections[i]),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        role: UserRole.farmer,
        current: AppTab.middle, // ✅ highlight "Stalls" as the active tab
        onHome: _goHome,
        onMiddle: _goStalls, // middle = Stalls for farmers
        onAccount: _goAccount,
      ),
    );
  }
}

/* ==================== MODELS ==================== */

class _ProduceDemand {
  const _ProduceDemand({
    required this.title,
    required this.asset,
    required this.stalls,
  });
  final String title;
  final String asset;
  final List<_StallDemand> stalls;
}

class _StallDemand {
  const _StallDemand(this.stall, this.kg);
  final String stall;
  final int kg;
}

/* ==================== WIDGETS ==================== */

class _DemandSection extends StatelessWidget {
  const _DemandSection({required this.data});
  final _ProduceDemand data;

  @override
  Widget build(BuildContext context) {
    const primaryGreen = StallsPage.primaryGreen;
    const chipBg = StallsPage.chipBg;

    final titleStyle = const TextStyle(
      color: primaryGreen,
      fontWeight: FontWeight.w700,
      fontSize: 16,
      letterSpacing: 0.2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: primaryGreen.withOpacity(0.25)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(child: Text(data.title, style: titleStyle)),
        ),
        const SizedBox(height: 12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stalls + kg list
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  for (final s in data.stalls)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${s.stall}: ${s.kg}kg',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Circular image preview
            Expanded(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: primaryGreen.withOpacity(0.25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipOval(
                      child: Image.asset(
                        data.asset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/romaine.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
