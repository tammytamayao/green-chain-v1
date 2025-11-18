import 'dart:math'; // <-- keep this

import 'package:flutter/material.dart';

// Shared UI
import 'ui/green_theme.dart';
import 'widgets/banner_header.dart';
import 'widgets/bottom_nav.dart';

// Pages
import 'driver_home.dart';
import 'account_page.dart';
import 'driver_driving_page.dart'; // <-- use the extracted driving screen

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
  // Sample data — replace with API data later
  final List<_PickupRow> _pickups = const [
    _PickupRow(
      from: 'Abatan, Buguias',
      farmer: 'Farmer D',
      weightKg: 12,
      to: 'BAPTC',
    ),
    _PickupRow(
      from: 'Abatan, Buguias',
      farmer: 'Farmer A',
      weightKg: 11,
      to: 'BAPTC',
    ),
    _PickupRow(
      from: 'Abatan, Buguias',
      farmer: 'Farmer B',
      weightKg: 3,
      to: 'BAPTC',
    ),
  ];

  // All possible deliveries; UI will filter this list
  final List<_DeliveryRow> _allDeliveries = const [
    _DeliveryRow(fromFarmer: 'Farmer A', toStall: 'STALL C', weightKg: 12),
    _DeliveryRow(fromFarmer: 'Farmer B', toStall: 'STALL A', weightKg: 9),
    _DeliveryRow(fromFarmer: 'Farmer C', toStall: 'STALL B', weightKg: 7),
    _DeliveryRow(fromFarmer: 'Farmer D', toStall: 'STALL D', weightKg: 5),
  ];

  /// Indices of selected pickups in [_pickups]
  final Set<int> _selectedPickupIndices = <int>{};

  /// Indices of selected deliveries in [_allDeliveries]
  final Set<int> _selectedDeliveryIndices = <int>{};

  /// Whether ITS mode is enabled (vs Manual).
  bool _itsMode = false;

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

  /// Deliveries visible for the currently selected pickups, with their index
  /// into [_allDeliveries] preserved for selection.
  List<_IndexedDelivery> get _visibleDeliveries {
    if (_selectedPickupIndices.isEmpty) return const [];

    // Get the farmers from the selected pickups
    final selectedFarmers = _selectedPickupIndices
        .map((i) => _pickups[i].farmer)
        .toSet();

    // Only show deliveries whose "fromFarmer" is in selectedFarmers
    return _allDeliveries
        .asMap()
        .entries
        .where((entry) => selectedFarmers.contains(entry.value.fromFarmer))
        .map((entry) => _IndexedDelivery(index: entry.key, row: entry.value))
        .toList();
  }

  void _togglePickupSelection(int index) {
    setState(() {
      if (_selectedPickupIndices.contains(index)) {
        _selectedPickupIndices.remove(index);
        // Optionally clear delivery selections that no longer match
        final remainingFarmers = _selectedPickupIndices
            .map((i) => _pickups[i].farmer)
            .toSet();
        _selectedDeliveryIndices.removeWhere((deliveryIndex) {
          final d = _allDeliveries[deliveryIndex];
          return !remainingFarmers.contains(d.fromFarmer);
        });
      } else {
        _selectedPickupIndices.add(index);
      }
    });
  }

  void _toggleDeliverySelection(int index) {
    setState(() {
      if (_selectedDeliveryIndices.contains(index)) {
        _selectedDeliveryIndices.remove(index);
      } else {
        _selectedDeliveryIndices.add(index);
      }
    });
  }

  /// "ITS" button logic: randomly selects some pickups and matching deliveries.
  void _autoSelectIts() {
    if (_pickups.isEmpty) return;

    final rand = Random();

    _selectedPickupIndices.clear();
    _selectedDeliveryIndices.clear();

    // --- Randomly choose at least 1 pickup ---
    final pickupIndices = List<int>.generate(_pickups.length, (i) => i);
    pickupIndices.shuffle(rand);
    final pickupCount = rand.nextInt(_pickups.length) + 1; // 1..length
    _selectedPickupIndices.addAll(pickupIndices.take(pickupCount));

    // Farmers from chosen pickups
    final chosenFarmers = _selectedPickupIndices
        .map((i) => _pickups[i].farmer)
        .toSet();

    // Delivery indices whose fromFarmer is in chosenFarmers
    final deliveryIndices = <int>[];
    _allDeliveries.asMap().forEach((i, d) {
      if (chosenFarmers.contains(d.fromFarmer)) {
        deliveryIndices.add(i);
      }
    });

    if (deliveryIndices.isNotEmpty) {
      deliveryIndices.shuffle(rand);
      final deliveryCount =
          rand.nextInt(deliveryIndices.length) + 1; // 1..available
      _selectedDeliveryIndices.addAll(deliveryIndices.take(deliveryCount));
    }
  }

  /// Switch between Manual and ITS mode.
  void _setItsMode(bool enabled) {
    setState(() {
      _itsMode = enabled;
      if (_itsMode) {
        // When turning ITS ON, auto-generate a suggestion
        _autoSelectIts();
      }
      // When turning OFF, keep current selections so driver can tweak.
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleDeliveries = _visibleDeliveries;
    final bool canStartDriving =
        _selectedPickupIndices.isNotEmpty &&
        _selectedDeliveryIndices.isNotEmpty;

    return Scaffold(
      backgroundColor: GreenTheme.softBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const BannerHeaderSliver(),

            // Header + ITS/Manual toggle on the right
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side: title + vehicle + location
                    Expanded(
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
                            'Location: ${widget.currentLocation}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Right side: ITS / Manual toggle
                    _ModeToggle(itsEnabled: _itsMode, onChanged: _setItsMode),
                  ],
                ),
              ),
            ),

            // --- STEP 1: Pick-up Requests (multi-select) ---
            const _SectionTitle('Step 1 · Pick-up Requests'),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _itsMode
                          ? 'ITS is ON — route suggestions generated for you. You can still adjust the picks below.'
                          : 'Tap one or more pick-ups to accept them.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
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
                itemBuilder: (_, i) {
                  final row = _pickups[i];
                  final isSelected = _selectedPickupIndices.contains(i);
                  return _PickupTile(
                    row: row,
                    isSelected: isSelected,
                    onTap: () => _togglePickupSelection(i),
                  );
                },
              ),
            ),

            // --- STEP 2: Delivery Requests (based on selected pick-ups) ---
            const _SectionTitle('Step 2 · Delivery Requests'),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _MiniHeader(cols: const ['farmer', 'weight', 'stall']),
              ),
            ),

            if (visibleDeliveries.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12, width: 0.8),
                    ),
                    child: Text(
                      _selectedPickupIndices.isEmpty
                          ? 'Select at least one pick-up above to see matching delivery requests.'
                          : 'No delivery requests yet for the selected farmers.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                sliver: SliverList.separated(
                  itemCount: visibleDeliveries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final item = visibleDeliveries[i];
                    final isSelected = _selectedDeliveryIndices.contains(
                      item.index,
                    );
                    return _DeliveryTile(
                      row: item.row,
                      isSelected: isSelected,
                      onTap: () => _toggleDeliverySelection(item.index),
                    );
                  },
                ),
              ),

            // --- ACTION BUTTON: Start Driving ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canStartDriving
                        ? () {
                            // Map internal rows to external models used by DriverDrivingPage
                            final selectedPickups = _selectedPickupIndices.map((
                              i,
                            ) {
                              final p = _pickups[i];
                              return PickupInfo(
                                from: p.from,
                                farmer: p.farmer,
                                weightKg: p.weightKg,
                                to: p.to,
                              );
                            }).toList();

                            final selectedDeliveries = _selectedDeliveryIndices
                                .map((i) {
                                  final d = _allDeliveries[i];
                                  return DeliveryInfo(
                                    fromFarmer: d.fromFarmer,
                                    toStall: d.toStall,
                                    weightKg: d.weightKg,
                                  );
                                })
                                .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DriverDrivingPage(
                                  currentLocation: widget.currentLocation,
                                  vehicle: widget.selectedVehicle,
                                  pickups: selectedPickups,
                                  deliveries: selectedDeliveries,
                                ),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.route),
                    label: const Text('Start driving'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GreenTheme.primary,
                      foregroundColor:
                          Colors.white, // 👈 makes text & icon white
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.25),
                    ),
                  ),
                ),
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
  const _PickupTile({
    required this.row,
    required this.isSelected,
    required this.onTap,
  });

  final _PickupRow row;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _RowCard(
        leftBand: isSelected ? GreenTheme.primary : const Color(0xFF5E8C61),
        cells: [row.from, row.farmer, '${row.weightKg} kg', row.to],
        isSelected: isSelected,
      ),
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

class _IndexedDelivery {
  const _IndexedDelivery({required this.index, required this.row});
  final int index;
  final _DeliveryRow row;
}

class _DeliveryTile extends StatelessWidget {
  const _DeliveryTile({
    required this.row,
    required this.isSelected,
    required this.onTap,
  });

  final _DeliveryRow row;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _RowCard(
        leftBand: isSelected ? GreenTheme.primary : const Color(0xFF5E8C61),
        cells: [row.fromFarmer, '${row.weightKg} kg', row.toStall],
        isSelected: isSelected,
      ),
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({
    required this.leftBand,
    required this.cells,
    this.isSelected = false,
  });

  final Color leftBand;
  final List<String> cells;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isSelected ? GreenTheme.softBg.withOpacity(0.7) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? GreenTheme.primary : Colors.black26,
          width: isSelected ? 1.4 : 0.8,
        ),
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
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small pill-style toggle for Manual / ITS
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.itsEnabled, required this.onChanged});

  final bool itsEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GreenTheme.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeChip(
            label: 'Manual',
            selected: !itsEnabled,
            onTap: () => onChanged(false),
          ),
          _ModeChip(
            label: 'ITS',
            selected: itsEnabled,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? GreenTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : GreenTheme.primary,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
