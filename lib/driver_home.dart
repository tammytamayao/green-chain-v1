import 'package:flutter/material.dart';
import 'auth_api.dart';

// Shared UI
import 'ui/green_theme.dart';
import 'widgets/banner_header.dart';
import 'widgets/bottom_nav.dart'; // role-aware

// Pages
import 'driver_drive_page.dart';
import 'account_page.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  Map<String, dynamic>? _profile; // null = loading
  String? _error;

  // Vehicle selection
  int _selectedVehicleIndex = 0;
  List<Map<String, dynamic>> _vehicles = const []; // from profile['vehicles']

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await me().timeout(const Duration(seconds: 8));
      if (!mounted) return;
      final profile = p ?? {};

      final rawVehicles = (profile['vehicles'] is List)
          ? List<Map<String, dynamic>>.from(profile['vehicles'])
          : <Map<String, dynamic>>[];

      final fallback = <Map<String, dynamic>>[
        {
          'model': 'Ford Ranger',
          'class': 'Pick-up',
          'plate_number': 'EAS 2024',
        },
        {'model': 'HiAce', 'class': 'Van', 'plate_number': 'NFD 5832'},
      ];

      setState(() {
        _profile = profile;
        _vehicles = rawVehicles.isNotEmpty ? rawVehicles : fallback;
        _selectedVehicleIndex = 0;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _profile = {};
        _vehicles = const [];
        _selectedVehicleIndex = 0;
        _error = 'Could not load profile';
      });
    }
  }

  String _niceNow() {
    final now = DateTime.now();
    const months = [
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
    return '${months[now.month - 1]} ${now.day}, ${now.year} | $h:$mm $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final loading = _profile == null;

    final currentLocation =
        (_profile?['current_location'] ?? 'Abatan, Buguias, Benguet') as String;
    final weatherText =
        (_profile?['weather_label'] ?? '16 °C | Thunderstorm') as String;

    // Use a taller map: ~35% of screen height
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * 0.5;

    return Scaffold(
      backgroundColor: GreenTheme.softBg,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content (title, map, vehicle card)
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    const BannerHeaderSliver(),

                    if (loading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: GreenTheme.primary,
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
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),

                      // Title + date/time
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DRIVING DETAILS',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: GreenTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _niceNow(),
                                style: TextStyle(
                                  fontSize: 13,
                                  letterSpacing: 0.2,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Map space + overlaid location & weather cards
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
                                  // Placeholder for Google Map widget
                                  Container(
                                    color: Colors.grey.shade300,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.map_outlined,
                                            size: 48,
                                            color: Colors.black54,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Google Maps preview',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Overlays: current location + weather
                                  Positioned(
                                    left: 10,
                                    right: 10,
                                    bottom: 10,
                                    child: Column(
                                      children: [
                                        _InfoCardRow(
                                          icon: Icons.location_on_outlined,
                                          trailing: IconButton(
                                            icon: const Icon(Icons.my_location),
                                            color: GreenTheme.primary,
                                            tooltip: 'Refresh location',
                                            onPressed: _load,
                                          ),
                                          child: Text(
                                            currentLocation,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _InfoCardRow(
                                          icon: Icons.cloud_queue_outlined,
                                          child: Text(
                                            weatherText,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Vehicle chooser
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: _VehicleCard(
                            vehicles: _vehicles,
                            selectedIndex: _selectedVehicleIndex,
                            onChanged: (i) =>
                                setState(() => _selectedVehicleIndex = i),
                          ),
                        ),
                      ),

                      // Add a bit of breathing room at the bottom of scroll
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    ],
                  ],
                ),
              ),
            ),

            // Fixed button at the bottom of the screen
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.directions_run_rounded),
                  label: const Text('Open Drive Requests'),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DriverDrivePage(
                          currentLocation: currentLocation,
                          selectedVehicle: (_vehicles.isNotEmpty)
                              ? _vehicles[_selectedVehicleIndex]
                              : null,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GreenTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
        current: AppTab.home,
        onHome: () {}, // already here
        onMiddle: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DriverDrivePage(
                currentLocation: currentLocation,
                selectedVehicle: (_vehicles.isNotEmpty)
                    ? _vehicles[_selectedVehicleIndex]
                    : null,
              ),
            ),
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

/* ----------------- helper widgets ----------------- */

class _InfoCardRow extends StatelessWidget {
  const _InfoCardRow({required this.icon, required this.child, this.trailing});
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GreenTheme.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: GreenTheme.primary),
          const SizedBox(width: 10),
          Expanded(child: child),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicles,
    required this.selectedIndex,
    required this.onChanged,
  });
  final List<Map<String, dynamic>> vehicles;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    String labelFor(Map<String, dynamic> v) {
      final model = (v['model'] ?? '').toString();
      final klass = (v['class'] ?? '').toString();
      final plate = (v['plate_number'] ?? '').toString();
      final parts = [
        model,
        klass.isEmpty ? null : '($klass)',
        plate.isEmpty ? null : plate,
      ].whereType<String>().toList();
      return parts.join(' • ');
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GreenTheme.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehicle',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: GreenTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: (vehicles.isEmpty) ? null : selectedIndex,
            items: [
              for (int i = 0; i < vehicles.length; i++)
                DropdownMenuItem<int>(
                  value: i,
                  child: Text(labelFor(vehicles[i])),
                ),
            ],
            onChanged: (i) {
              if (i != null) onChanged(i);
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
