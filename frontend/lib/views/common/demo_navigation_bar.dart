import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_kiosk/viewmodels/kiosk_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/kitchen_viewmodel.dart';

class DemoNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;

  const DemoNavigationBar({
    super.key,
    required this.currentRoute,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final kioskVM = context.watch<KioskViewModel>();
    final kitchenVM = context.watch<KitchenViewModel>();
    final activeOrdersCount = kitchenVM.orders.length;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF020617).withValues(alpha: 0.96),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 32,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Royal Ember Core Badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => context.go('/'),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.radio_button_checked, size: 12, color: Color(0xFFF59E0B)),
                          SizedBox(width: 6),
                          Text(
                            'ROYAL EMBER CORE',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Enterprise Station Switcher',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Center: Main View Switcher Tabs
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTab(
                      label: 'Station Hub',
                      icon: Icons.home_rounded,
                      isActive: currentRoute == '/',
                      onTap: () => context.go('/'),
                    ),
                    _buildTab(
                      label: 'Table Kiosk',
                      icon: Icons.tablet_mac_rounded,
                      badge: 'T${kioskVM.tableNumber}',
                      isActive: currentRoute == '/kiosk',
                      onTap: () => context.go('/kiosk'),
                    ),
                    _buildTab(
                      label: 'Track Order',
                      icon: Icons.radar_rounded,
                      isActive: currentRoute.startsWith('/tracker'),
                      onTap: () => context.go('/tracker/ORD-1024'),
                    ),
                    _buildTab(
                      label: 'Kitchen KDS',
                      icon: Icons.soup_kitchen_rounded,
                      counter: activeOrdersCount > 0 ? '$activeOrdersCount' : '0',
                      counterColor: Colors.redAccent,
                      isActive: currentRoute == '/kitchen',
                      onTap: () => context.go('/kitchen'),
                    ),
                    _buildTab(
                      label: 'Management',
                      icon: Icons.bar_chart_rounded,
                      isActive: currentRoute == '/dashboard' || currentRoute == '/management',
                      onTap: () => context.go('/dashboard'),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Right Controls: Light/Dark toggle & Reset Demo & Role Switcher
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.light_mode, size: 13, color: Color(0xFFF59E0B)),
                          SizedBox(width: 4),
                          Text('Light', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demo reset to initial state')),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded, size: 13, color: Colors.white70),
                          SizedBox(width: 4),
                          Text('Reset', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  PopupMenuButton<String>(
                    color: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF1E293B)),
                    ),
                    onSelected: (value) {
                      if (value == 'kiosk') context.go('/kiosk');
                      if (value == 'kitchen') context.go('/kitchen');
                      if (value == 'management') context.go('/dashboard');
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'kiosk', child: Text('Customer Kiosk Screen', style: TextStyle(color: Colors.white, fontSize: 12))),
                      const PopupMenuItem(value: 'kitchen', child: Text('Kitchen Display (KDS)', style: TextStyle(color: Colors.white, fontSize: 12))),
                      const PopupMenuItem(value: 'management', child: Text('Management Dashboard', style: TextStyle(color: Colors.white, fontSize: 12))),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Kitchen Screen', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    String? badge,
    String? counter,
    Color? counterColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF59E0B) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                fontSize: 11,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isActive ? const Color(0xFF0F172A) : Colors.white70,
                  ),
                ),
              ),
            ],
            if (counter != null) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: counterColor ?? Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  counter,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
