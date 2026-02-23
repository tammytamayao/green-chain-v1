import 'package:flutter/material.dart';
import 'package:green_chain_v1/api/delivery_api.dart';
import 'package:green_chain_v1/features/driver/driver_home.dart';

// Shared UI
import '../../ui/green_theme.dart';
import '../../widgets/banner_header.dart';
import '../../widgets/bottom_nav.dart';

// Pages
import '../../account_page.dart';

/// Public models used when driving
/// ✅ Added: deliveryId + pricePhp so we can update status and show price.
class PickupInfo {
  const PickupInfo({
    required this.deliveryId,
    required this.from, // origin
    required this.farmer,
    required this.weightKg,
    required this.to, // destination
    this.pricePhp,
  });

  final int deliveryId;
  final String from;
  final String farmer;
  final int weightKg;
  final String to;
  final double? pricePhp;
}

class DeliveryInfo {
  const DeliveryInfo({
    required this.deliveryId,
    required this.origin,
    required this.destination,
    required this.weightKg,
    this.pricePhp,
  });

  final int deliveryId;
  final String origin; // origin
  final String destination; // destination
  final int weightKg;
  final double? pricePhp;
}

class DriverDrivingPage extends StatefulWidget {
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

  @override
  State<DriverDrivingPage> createState() => _DriverDrivingPageState();
}

class _DriverDrivingPageState extends State<DriverDrivingPage> {
  int _index = 0;
  bool _delivering = false;
  String? _error;

  bool get _hasItems => widget.deliveries.isNotEmpty;

  DeliveryInfo? get _current {
    if (!_hasItems) return null;
    final i = _index.clamp(0, widget.deliveries.length - 1);
    return widget.deliveries[i];
  }

  String _peso(double? p) {
    if (p == null) return '-';
    return '₱${p.toStringAsFixed(2)}';
  }

  Future<void> _markDelivered() async {
    final cur = _current;
    if (cur == null) {
      // nothing to deliver; go home
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DriverHomePage()),
      );
      return;
    }

    setState(() {
      _delivering = true;
      _error = null;
    });

    try {
      // ✅ Update backend status
      await updateDeliveryStatus(
        deliveryId: cur.deliveryId,
        status: 'delivered',
      );

      if (!mounted) return;

      // ✅ Next delivery if any, else go Home
      final isLast = _index >= widget.deliveries.length - 1;
      if (isLast) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DriverHomePage()),
        );
      } else {
        setState(() {
          _index += 1;
          _delivering = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _delivering = false;
        _error = 'Failed to mark delivered: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * 0.5;

    final cur = _current;
    final origin = cur?.origin ?? 'Unknown origin';
    final destination = cur?.destination ?? 'Unknown destination';
    final weightKg = cur?.weightKg ?? 0;
    final priceLabel = _peso(cur?.pricePhp);

    // For overlay: use ORIGIN (pickup) and DESTINATION (delivery)
    final pickupOrigins = <String>{
      for (final p in widget.pickups) p.from, // ✅ origin
    }.toList();

    final deliveryDestinations = <String>{
      for (final d in widget.deliveries) d.destination, // ✅ destination
    }.toList();

    final progressText = widget.deliveries.isEmpty
        ? 'No active deliveries.'
        : 'Delivery ${_index + 1} of ${widget.deliveries.length}';

    return Scaffold(
      backgroundColor: GreenTheme.softBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const BannerHeaderSliver(),

                  // Title bar + progress
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DRIVING ROUTE',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: GreenTheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.deliveries.isEmpty
                                ? 'No active trip.'
                                : 'You are now on an active trip.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _Pill(text: progressText, icon: Icons.flag_outlined),

                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Current delivery details
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: _DetailCard(
                        title: 'Current delivery',
                        child: widget.deliveries.isEmpty
                            ? const Text(
                                'No delivery selected.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _MetricTile(
                                          label: 'Weight',
                                          value: '$weightKg kg',
                                          icon: Icons.scale_outlined,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _MetricTile(
                                          label: 'Price',
                                          value: priceLabel,
                                          icon: Icons.payments_outlined,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                                  currentLocation: widget.currentLocation,
                                  pickupOrigins: pickupOrigins,
                                  deliveryDestinations: deliveryDestinations,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

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

                  // Bottom padding so content doesn’t hide behind the fixed button
                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
              ),
            ),
          ],
        ),
      ),

      // ✅ Fixed "Delivered" button at bottom
      bottomSheet: SafeArea(
        child: Container(
          color: GreenTheme.softBg,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_delivering || widget.deliveries.isEmpty)
                  ? null
                  : _markDelivered,
              icon: _delivering
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _delivering
                    ? 'Updating…'
                    : (widget.deliveries.length > 1
                          ? 'Delivered — Next'
                          : 'Delivered'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: GreenTheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay showing current location + PICKUP origins + DELIVERY destinations
class _RouteOverlay extends StatelessWidget {
  const _RouteOverlay({
    required this.currentLocation,
    required this.pickupOrigins,
    required this.deliveryDestinations,
  });

  final String currentLocation;
  final List<String> pickupOrigins;
  final List<String> deliveryDestinations;

  @override
  Widget build(BuildContext context) {
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
          // Current location
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

          if (pickupOrigins.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _SectionLabel(
                  icon: Icons.agriculture_outlined,
                  text: 'Pick-up (origin):',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _LocationChips(
                    locations: pickupOrigins,
                    singleLine: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          if (deliveryDestinations.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _SectionLabel(
                  icon: Icons.local_mall_outlined,
                  text: 'Delivery (destination):',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _LocationChips(
                    locations: deliveryDestinations,
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

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: GreenTheme.primary.withAlpha((0.08 * 255).round()),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: GreenTheme.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: GreenTheme.primary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: GreenTheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: GreenTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
