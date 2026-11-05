import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_kiosk/core/constants/app_constants.dart';
import 'package:smart_kiosk/core/theme/app_theme.dart';
import 'package:smart_kiosk/viewmodels/kiosk_viewmodel.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
      backgroundColor: AppTheme.darkBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              color: AppTheme.darkCard,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Icon & Name
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      AppConstants.appSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Table Selector
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Table Number',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tableNumbers.map((table) {
                        final isSelected = kioskVM.tableNumber == table;
                        return InkWell(
                          onTap: () => kioskVM.setTableNumber(table),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primary : AppTheme.darkBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppTheme.primary : AppTheme.darkBorder,
                              ),
                            ),
                            child: Text(
                              'Table $table',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Language Selector
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose Preferred Language',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primary.withOpacity(0.2) : AppTheme.darkBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppTheme.primary : AppTheme.darkBorder,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(lang['flag']!, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  lang['label']!,
                                  style: TextStyle(
                                    color: isSelected ? AppTheme.primary : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Start Ordering Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          context.go('/kiosk');
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Explore Menu & Order', style: TextStyle(fontSize: 17)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppTheme.darkBorder),
                    const SizedBox(height: 12),

                    // Staff Navigation Links
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        TextButton.icon(
                          onPressed: () => context.push('/kitchen'),
                          icon: const Icon(Icons.soup_kitchen, size: 18, color: Colors.white70),
                          label: const Text('Kitchen Display (KDS)', style: TextStyle(color: Colors.white70)),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/dashboard'),
                          icon: const Icon(Icons.analytics_outlined, size: 18, color: Colors.white70),
                          label: const Text('Analytics Dashboard', style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
