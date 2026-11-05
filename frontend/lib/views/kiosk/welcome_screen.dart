import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_kiosk/core/constants/app_constants.dart';
import 'package:smart_kiosk/viewmodels/kiosk_viewmodel.dart';
import 'package:smart_kiosk/views/common/demo_navigation_bar.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _doorController;
  late Animation<double> _doorAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _doorTimer;

  @override
  void initState() {
    super.initState();
    _doorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _doorAnimation = CurvedAnimation(
      parent: _doorController,
      curve: Curves.easeInOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _doorController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _doorTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _doorController.forward();
      }
    });
  }

  @override
  void dispose() {
    _doorTimer?.cancel();
    _doorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kioskVM = context.watch<KioskViewModel>();

    final languages = [
      {'code': 'en', 'label': 'English', 'flag': '🇬🇧'},
      {'code': 'ta', 'label': 'தமிழ்', 'flag': '🇮🇳'},
      {'code': 'hi', 'label': 'हिंदी', 'flag': '🇮🇳'},
      {'code': 'te', 'label': 'తెలుగు', 'flag': '🇮🇳'},
      {'code': 'es', 'label': 'Español', 'flag': '🇪🇸'},
    ];

    final tableNumbers = [1, 2, 4, 6, 8, 12];

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: const DemoNavigationBar(currentRoute: '/welcome'),
      body: Stack(
        children: [
          // Main Scrollable Luxury Content
          SingleChildScrollView(
            child: Column(
              children: [
                // 1. Hero Restaurant Culinary Banner
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 380,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/restaurant_food_welcome.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF0F172A),
                          child: const Icon(Icons.restaurant_menu, size: 80, color: Color(0xFFF59E0B)),
                        ),
                      ),
                    ),
                    // Ambient golden glow
                    Container(
                      height: 380,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent,
                            const Color(0xFF020617).withValues(alpha: 0.95),
                            const Color(0xFF020617),
                          ],
                        ),
                      ),
                    ),
                    // Floating Badge
                    Positioned(
                      top: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 14, color: Color(0xFFF59E0B)),
                            SizedBox(width: 8),
                            Text(
                              'ROYAL EMBER DINING',
                              style: TextStyle(
                                color: Color(0xFFFDE68A),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. Main Luxury Typography & Content Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Eyebrow
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 30, child: Divider(color: Color(0xFFF59E0B), thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'WELCOME TO',
                                style: TextStyle(
                                  color: Color(0xFFF59E0B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                            SizedBox(width: 30, child: Divider(color: Color(0xFFF59E0B), thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Title
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFB923C), Color(0xFFFDE047), Color(0xFFF59E0B)],
                          ).createShader(bounds),
                          child: const Text(
                            AppConstants.appName,
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'RESTAURANT & GRAND BANQUET',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'Exceptional Food, Delivered Fresh',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Experience gourmet-quality culinary meals prepared with care and delivered faster than ever — straight to your table.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF94A3B8),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Hospitality Badges
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildFeaturePill(Icons.restaurant, "Chef's Artisanal Menu"),
                            _buildFeaturePill(Icons.access_time_filled, 'Fast Table-Side Service'),
                            _buildFeaturePill(Icons.wine_bar, 'Fine Dining Experience'),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Table Selector Container
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF1E293B)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.table_restaurant, color: Color(0xFFF59E0B), size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Select Table Number',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: tableNumbers.map((table) {
                                  final isSelected = kioskVM.tableNumber == table;
                                  return InkWell(
                                    onTap: () => kioskVM.setTableNumber(table),
                                    borderRadius: BorderRadius.circular(10),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFEA580C) : const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF334155),
                                        ),
                                      ),
                                      child: Text(
                                        'Table $table',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),

                              // Language Selector
                              const Text(
                                'Choose Preferred Language',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: languages.map((lang) {
                                  final isSelected = kioskVM.selectedLanguage == lang['code'];
                                  return InkWell(
                                    onTap: () => kioskVM.setLanguage(lang['code']!),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF334155),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(lang['flag']!, style: const TextStyle(fontSize: 14)),
                                          const SizedBox(width: 6),
                                          Text(
                                            lang['label']!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                              color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Grand CTA Pill Button
                        InkWell(
                          onTap: () => context.go('/kiosk'),
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEA580C).withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFEA580C), Color(0xFFF59E0B)],
                                    ),
                                  ),
                                  child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 22),
                                ),
                                const Expanded(
                                  child: Text(
                                    'Explore Menu & Order',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.chevron_right, color: Color(0xFFF59E0B), size: 20),
                                      Icon(Icons.chevron_right, color: Color(0xFFF59E0B), size: 20),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tap Start Ordering to browse our artisanal culinary menu',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Double Door Opening Overlay Animation
          AnimatedBuilder(
            animation: _doorController,
            builder: (context, child) {
              if (_doorAnimation.value >= 1.0) {
                return const SizedBox.shrink();
              }
              final screenWidth = MediaQuery.of(context).size.width;
              final halfWidth = screenWidth / 2;

              return IgnorePointer(
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Stack(
                    children: [
                      // Left Door
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: -_doorAnimation.value * halfWidth,
                        width: halfWidth,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF020617), Color(0xFF0F172A)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            border: Border(
                              right: BorderSide(color: Color(0xFFF59E0B), width: 2),
                            ),
                          ),
                        ),
                      ),
                      // Right Door
                      Positioned(
                        top: 0,
                        bottom: 0,
                        right: -_doorAnimation.value * halfWidth,
                        width: halfWidth,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF020617)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            border: Border(
                              left: BorderSide(color: Color(0xFFF59E0B), width: 2),
                            ),
                          ),
                        ),
                      ),
                      // Center Medallion
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.workspace_premium, color: Colors.white, size: 40),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
