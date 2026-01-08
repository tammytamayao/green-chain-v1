import 'package:flutter/material.dart';
import '../ui/green_theme.dart';

/// Three fixed slots across all roles.
enum AppTab { home, middle, account }

/// Map backend profile['type'] to this.
enum UserRole { farmer, driver, disposer }

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.role,
    required this.current,
    required this.onHome,
    required this.onMiddle,
    required this.onAccount,
  });

  final UserRole role;
  final AppTab current;
  final VoidCallback onHome;
  final VoidCallback onMiddle;
  final VoidCallback onAccount;

  Color _color(bool active) => active ? GreenTheme.primary : Colors.grey;

  (IconData, String) _middleForRole() {
    switch (role) {
      case UserRole.driver:
        return (Icons.directions_car_filled_rounded, 'Drive');
      case UserRole.disposer:
        return (Icons.shopping_cart_outlined, 'Disposals');
      case UserRole.farmer:
        return (Icons.inventory_2_rounded, 'Stalls');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (middleIcon, middleTip) = _middleForRole();

    return Container(
      height: 58,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home_rounded, size: 26),
            color: _color(current == AppTab.home),
            tooltip: 'Home',
            onPressed: onHome,
          ),
          IconButton(
            icon: Icon(middleIcon, size: 26),
            color: _color(current == AppTab.middle),
            tooltip: middleTip,
            onPressed: onMiddle,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, size: 26),
            color: _color(current == AppTab.account),
            tooltip: 'Account',
            onPressed: onAccount,
          ),
        ],
      ),
    );
  }
}
