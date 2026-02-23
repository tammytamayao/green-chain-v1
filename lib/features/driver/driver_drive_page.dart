// ✅ keep this
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:green_chain_v1/api/delivery_api.dart';
import 'package:green_chain_v1/features/driver/driver_home.dart';

// Shared UI
import '../../ui/green_theme.dart';
import '../../widgets/banner_header.dart';
import '../../widgets/bottom_nav.dart';

// Pages
import '../../account_page.dart';
import 'driver_driving_page.dart'; // uses PickupInfo / DeliveryInfo

import 'package:green_chain_v1/models/delivery.dart';

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
  // ✅ Always unassigned list
  List<Delivery> _unassigned = [];

  bool _loading = true;
  bool _starting = false;
  String? _error;

  /// Selected delivery IDs
  final Set<int> _selectedIds = <int>{};

  /// Whether ITS mode is enabled (vs Manual).
  bool _itsMode = false;

  int? get _vehicleId {
    final v = widget.selectedVehicle;
    if (v == null) return null;
    final raw = v['id'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  bool get _hasVehicle => _vehicleId != null;

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
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // ✅ ALWAYS unassigned (backend filters d.status='unassigned')
      final unassigned = await fetchDeliveries(scope: 'unassigned');

      if (!mounted) return;
      setState(() {
        _unassigned = unassigned;
        _loading = false;

        // Clear selections that no longer exist
        final ids = unassigned.map((d) => d.id).toSet();
        _selectedIds.removeWhere((id) => !ids.contains(id));

        // ✅ If no vehicle, keep selections empty to avoid confusion
        if (!_hasVehicle) _selectedIds.clear();
      });

      // If ITS is ON, re-suggest after load (only if vehicle exists)
      if (_itsMode && _hasVehicle) _autoSelectIts();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load deliveries: $e';
      });
    }
  }

  void _toggleSelected(int id) {
    // ✅ prevent selection when no vehicle
    if (!_hasVehicle) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle first.')),
      );
      return;
    }

    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _autoSelectIts() {
    // ✅ only makes sense if vehicle exists
    if (!_hasVehicle) return;

    final rand = Random();
    final list = _unassigned;

    setState(() {
      _selectedIds.clear();
      if (list.isEmpty) return;

      final ids = list.map((d) => d.id).toList()..shuffle(rand);
      final count = rand.nextInt(ids.length) + 1; // at least 1
      _selectedIds.addAll(ids.take(count));
    });
  }

  void _setItsMode(bool enabled) {
    // ✅ block ITS when no vehicle
    if (enabled && !_hasVehicle) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a vehicle first to use ITS mode.'),
        ),
      );
      return;
    }

    setState(() {
      _itsMode = enabled;
    });

    if (enabled) _autoSelectIts();
  }

  Future<void> _assignAndSetInTransitForSelected() async {
    final vehicleId = _vehicleId;
    if (vehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle first.')),
      );
      throw Exception('No vehicle selected');
    }
    if (_selectedIds.isEmpty) throw Exception('No deliveries selected');

    for (final id in _selectedIds.toList()) {
      try {
        await assignDelivery(deliveryId: id, vehicleId: vehicleId);
      } catch (e) {
        throw Exception(
          'Delivery #$id cannot be assigned (maybe already claimed). $e',
        );
      }

      await updateDeliveryStatus(deliveryId: id, status: 'in_transit');
    }
  }

  Future<void> _startDriving() async {
    if (!_hasVehicle) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle first.')),
      );
      return;
    }

    final selected = _unassigned
        .where((d) => _selectedIds.contains(d.id))
        .toList();
    if (selected.isEmpty) return;

    setState(() => _starting = true);

    try {
      await _assignAndSetInTransitForSelected();

      if (!mounted) return;
      await _load(); // refresh
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to start driving: $e')));
      setState(() => _starting = false);

      await _load();
      return;
    }

    // ✅ Build driving payload + navigate
    // IMPORTANT: DriverDrivingPage now expects deliveryId + pricePhp and origin/destination mapping.
    final pickups = <PickupInfo>[];
    final deliveries = <DeliveryInfo>[];

    for (final d in selected) {
      final origin = d.origin.isEmpty ? 'Unknown origin' : d.origin;
      final destination = d.destination.isEmpty
          ? 'Unknown destination'
          : d.destination;

      final weightKgInt = (d.weight ?? 0).round();
      final label = d.kindLabel;
      final price = d.price; // double? (can be null)

      pickups.add(
        PickupInfo(
          deliveryId: d.id,
          from: origin, // ✅ origin
          farmer: label,
          weightKg: weightKgInt,
          to: destination, // ✅ destination
          pricePhp: price,
        ),
      );

      deliveries.add(
        DeliveryInfo(
          deliveryId: d.id,
          origin: origin,
          destination: destination,
          weightKg: weightKgInt,
          pricePhp: price,
        ),
      );
    }

    if (!mounted) return;
    setState(() => _starting = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverDrivingPage(
          currentLocation: widget.currentLocation,
          vehicle: widget.selectedVehicle,
          pickups: pickups,
          deliveries: deliveries,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = _unassigned;

    // ✅ must have vehicle + selections + not starting
    final canStart = _hasVehicle && _selectedIds.isNotEmpty && !_starting;

    return Scaffold(
      backgroundColor: GreenTheme.softBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const BannerHeaderSliver(),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            if (!_hasVehicle) ...[
                              const SizedBox(height: 8),
                              const _InfoBox(
                                text:
                                    'No vehicle selected. Go back to Home and select a vehicle.',
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              _itsMode
                                  ? 'ITS is ON. Tap to adjust.'
                                  : (_hasVehicle
                                        ? 'Tap deliveries to select/unselect.'
                                        : 'Select a vehicle to enable selection.'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ModeToggle(itsEnabled: _itsMode, onChanged: _setItsMode),
                    ],
                  ),
                ),
              ),

              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: GreenTheme.primary),
                  ),
                )
              else ...[
                if (active.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      child: const _InfoBox(
                        text: 'No unassigned deliveries right now.',
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    sliver: SliverList.separated(
                      itemCount: active.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final d = active[i];
                        final selected = _selectedIds.contains(d.id);

                        return _CompactDeliveryCard(
                          delivery: d,
                          isSelected: selected,
                          onTap: () => _toggleSelected(d.id),
                        );
                      },
                    ),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: canStart ? _startDriving : null,
                        icon: _starting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.route),
                        label: Text(
                          _starting
                              ? 'Starting…'
                              : (canStart
                                    ? 'Start driving (${_selectedIds.length})'
                                    : 'Start driving'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GreenTheme.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNav(
        role: UserRole.driver,
        current: AppTab.middle,
        onHome: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DriverHomePage()),
          );
        },
        onMiddle: () {},
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

/* ---------------- UI bits ---------------- */

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12, width: 0.8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}

class _CompactDeliveryCard extends StatelessWidget {
  const _CompactDeliveryCard({
    required this.delivery,
    required this.isSelected,
    required this.onTap,
  });

  final Delivery delivery;
  final bool isSelected;
  final VoidCallback onTap;

  String get _kindLabel =>
      delivery.kind?.toUpperCase() ??
      (delivery.requestId != null ? 'REQUEST' : 'ORDER');

  String get _origin =>
      delivery.origin.isEmpty ? 'Unknown origin' : delivery.origin;

  String get _destination => delivery.destination.isEmpty
      ? 'Unknown destination'
      : delivery.destination;

  String get _weightLabel {
    final w = delivery.weight;
    if (w == null) return '-';
    return '${w.toStringAsFixed(1)} kg';
  }

  String get _priceLabel {
    final p = delivery.price;
    if (p == null) return '-';
    return '₱${p.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? GreenTheme.primary : Colors.black12;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 1.6 : 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.03 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? GreenTheme.primary
                    : const Color(0xFF5E8C61),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _origin,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _destination,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _MiniText(_kindLabel),
                      const _Dot(),
                      _MiniText(_weightLabel),
                      const _Dot(),
                      Expanded(
                        child: Text(
                          _priceLabel,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? GreenTheme.primary : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniText extends StatelessWidget {
  const _MiniText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade800,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '•',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

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
        border: Border.all(
          color: GreenTheme.primary.withAlpha((0.3 * 255).round()),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
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
