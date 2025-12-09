import 'package:flutter/material.dart';

// Shared UI
import 'ui/green_theme.dart';
import 'widgets/banner_header.dart';
import 'widgets/bottom_nav.dart';

// Pages
import 'driver_home.dart';
import 'account_page.dart';

/// Public models used when driving
class PickupInfo {
  const PickupInfo({
    required this.from,
    required this.farmer,
    required this.weightKg,
    required this.to,
  });

  final String from;
  final String farmer;
  final int weightKg;
  final String to;
}

class DeliveryInfo {
  const DeliveryInfo({
    required this.fromFarmer,
    required this.toStall,
    required this.weightKg,
  });

  final String fromFarmer;
  final String toStall;
  final int weightKg;
}

class DriverDrivingPage extends StatelessWidget {
  const DriverDrivingPage({
    super.key,
    required this.currentLocation,
    this.vehicle,
    required this.pickups,
    required this.deliveries,
  });

  final String currentLocation;
  final Map<String, dynamic>? vehicle;
  final List<PickupInfo> pickups;
  final List<DeliveryInfo> deliveries;

  String _vehicleLabel(Map<String, dynamic>? v) {
    if (v == null) return 'No vehicle selected';
    final model = (v['model'] ?? '').toString();
    final klass = (v['class'] ?? '').toString();
    final plate = (v['plate_number'] ?? '').toString();
    final parts = [
      model,
      klass.isEmpty ? null : '($klass)',
      plate.isEmpty ? null : plate,
    ].whereType<String>().toList();
    return parts.isEmpty ? 'Vehicle' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    // We still compute this in case you want it later, but we don't show it.
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * 0.5;

    return Scaffold(
      backgroundColor: GreenTheme.softBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const BannerHeaderSliver(),

                  // Title bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'DRIVING ROUTE',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: GreenTheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'You are now on an active trip.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Map with overlay (current location + pickup & delivery locations)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: SizedBox(
                        height: mapHeight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Map placeholder
                              Container(
                                color: Colors.grey.shade300,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.alt_route,
                                        size: 48,
                                        color: Colors.black54,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Route map preview',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Overlay pill
                              Positioned(
                                left: 10,
                                right: 10,
                                bottom: 10,
                                child: _RouteOverlay(
                                  currentLocation: currentLocation,
                                  pickups: pickups,
                                  deliveries: deliveries,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Optional note under the map
                  // Navigation notes card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _DetailCard(
                        title: 'Navigation',
                        child: const Text(
                          'This is where turn-by-turn navigation or '
                          'integration with Google Maps can go later.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),
          ],
        ),
      ),

      // Bottom nav: same style as other driver screens
      bottomNavigationBar: BottomNav(
        role: UserRole.driver,
        current: AppTab.middle,
        onHome: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DriverHomePage()),
          );
        },
        onMiddle: () {}, // already here
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

/// Overlay that shows current location + pickup & delivery locations (only)
class _RouteOverlay extends StatelessWidget {
  const _RouteOverlay({
    required this.currentLocation,
    required this.pickups,
    required this.deliveries,
  });

  final String currentLocation;
  final List<PickupInfo> pickups;
  final List<DeliveryInfo> deliveries;

  @override
  Widget build(BuildContext context) {
    // Unique pickup origins
    final pickupLocations = <String>{for (final p in pickups) p.to}.toList();

    // Unique delivery destinations (stall names)
    final deliveryLocations = <String>{
      for (final d in deliveries) d.toStall,
    }.toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: GreenTheme.primary.withAlpha((0.2 * 255).round()),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current location row
          Row(
            children: [
              const Icon(
                Icons.my_location,
                size: 18,
                color: GreenTheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  currentLocation,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // PICK-UP LOCATIONS (one line)
          if (pickupLocations.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _SectionLabel(
                  icon: Icons.agriculture_outlined,
                  text: 'Pick-up:',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _LocationChips(
                    locations: pickupLocations,
                    singleLine: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // DELIVERY LOCATIONS (one line)
          if (deliveryLocations.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _SectionLabel(
                  icon: Icons.local_mall_outlined,
                  text: 'Delivery:',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _LocationChips(
                    locations: deliveryLocations,
                    singleLine: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: GreenTheme.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _LocationChips extends StatelessWidget {
  const _LocationChips({required this.locations, this.singleLine = false});

  final List<String> locations;
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    final chips = locations.map((loc) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: GreenTheme.primary.withAlpha((0.12 * 255).round()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          loc,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: GreenTheme.primary,
          ),
        ),
      );
    }).toList();

    if (singleLine) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      );
    }

    return Wrap(spacing: 6, runSpacing: 6, children: chips);
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GreenTheme.primary.withAlpha((0.15 * 255).round()),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.03 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: GreenTheme.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
