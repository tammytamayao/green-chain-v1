import 'package:flutter/material.dart';

// Shared UI
import 'ui/green_theme.dart';
import 'widgets/banner_header.dart';
import 'widgets/bottom_nav.dart';

// Pages
import 'driver_home.dart';
import 'account_page.dart';

class DriverDrivePage extends StatefulWidget {
  const DriverDrivePage({
    super.key,
    required this.currentLocation,
    this.selectedVehicle,
  });

  final String currentLocation;
  final Map<String, dynamic>? selectedVehicle;

  @override
  State<DriverDrivePage> createState() => _DriverDrivePageState();
}

class _DriverDrivePageState extends State<DriverDrivePage> {
  // Sample data — replace with API calls later
  final List<_PickupRow> _pickups = const [
    _PickupRow(
      from: 'Abatan, Buguias',
      farmer: 'Farmer D',
      weightKg: 12,
      to: 'Warehouse',
    ),
    _PickupRow(
      from: 'Abatan, Buguias',
      farmer: 'Farmer A',
      weightKg: 11,
      to: 'Warehouse',
    ),
    _PickupRow(
      from: 'Abatan, Buguias',
      farmer: 'Farmer B',
      weightKg: 3,
      to: 'Warehouse',
    ),
  ];

  final List<_DeliveryRow> _deliveries = const [
    _DeliveryRow(fromFarmer: 'Farmer A', toStall: 'STALL C', weightKg: 12),
    _DeliveryRow(fromFarmer: 'Farmer B', toStall: 'STALL A', weightKg: 9),
    _DeliveryRow(fromFarmer: 'Farmer C', toStall: 'STALL B', weightKg: 7),
  ];

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
    return Scaffold(
      backgroundColor: GreenTheme.softBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const BannerHeaderSliver(),

            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DRIVE',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: GreenTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _vehicleLabel(widget.selectedVehicle),
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Current location: ${widget.currentLocation}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),

            // Pick-up Requests
            _SectionTitle('Pick-up Requests'),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _MiniHeader(
                  cols: const ['from', 'farmer', 'weight', 'to'],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              sliver: SliverList.separated(
                itemCount: _pickups.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, i) => _PickupTile(row: _pickups[i]),
              ),
            ),

            // Delivery Requests
            _SectionTitle('Delivery Requests'),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _MiniHeader(cols: const ['farmer', 'weight', 'stall']),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              sliver: SliverList.separated(
                itemCount: _deliveries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, i) => _DeliveryTile(row: _deliveries[i]),
              ),
            ),
          ],
        ),
      ),

      // Bottom nav: role-aware (Home / Drive / Account)
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

/* ---------------- small components & models ---------------- */

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: GreenTheme.primary,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _MiniHeader extends StatelessWidget {
  const _MiniHeader({required this.cols});
  final List<String> cols;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF778A77),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          for (final c in cols)
            Expanded(
              child: Center(
                child: Text(
                  c.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PickupRow {
  const _PickupRow({
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

class _PickupTile extends StatelessWidget {
  const _PickupTile({required this.row});
  final _PickupRow row;
  @override
  Widget build(BuildContext context) {
    return _RowCard(
      leftBand: const Color(0xFF5E8C61),
      cells: [row.from, row.farmer, '${row.weightKg} kg', row.to],
    );
  }
}

class _DeliveryRow {
  const _DeliveryRow({
    required this.fromFarmer,
    required this.toStall,
    required this.weightKg,
  });
  final String fromFarmer;
  final String toStall;
  final int weightKg;
}

class _DeliveryTile extends StatelessWidget {
  const _DeliveryTile({required this.row});
  final _DeliveryRow row;
  @override
  Widget build(BuildContext context) {
    return _RowCard(
      leftBand: const Color(0xFF5E8C61),
      cells: [row.fromFarmer, '${row.weightKg} kg', row.toStall],
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({required this.leftBand, required this.cells});
  final Color leftBand;
  final List<String> cells;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            decoration: BoxDecoration(
              color: leftBand,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
          for (final cell in cells)
            Expanded(
              child: Center(
                child: Text(
                  cell,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
