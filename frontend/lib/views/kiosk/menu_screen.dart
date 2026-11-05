import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_kiosk/core/constants/app_constants.dart';
import 'package:smart_kiosk/core/theme/app_theme.dart';
import 'package:smart_kiosk/models/menu_item.dart';
import 'package:smart_kiosk/viewmodels/cart_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/kiosk_viewmodel.dart';
import 'package:smart_kiosk/views/kiosk/widgets/cart_drawer.dart';
import 'package:smart_kiosk/views/kiosk/widgets/item_customizer_dialog.dart';
import 'package:smart_kiosk/views/kiosk/widgets/waiter_call_dialog.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KioskViewModel>().loadCatalog();
    });
  }

  void _openCustomizer(MenuItem item) {
    final kioskVM = context.read<KioskViewModel>();
    final cartVM = context.read<CartViewModel>();

    showDialog(
      context: context,
      builder: (context) => ItemCustomizerDialog(
        item: item,
        languageCode: kioskVM.selectedLanguage,
        onAddToCart: ({
          required int quantity,
          required String spiceLevel,
          required List<String> customizations,
          required String specialInstructions,
        }) {
          cartVM.addToCart(
            item,
            quantity: quantity,
            spiceLevel: spiceLevel,
            customizations: customizations,
            specialInstructions: specialInstructions,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${item.name} to order'),
              backgroundColor: AppTheme.accent,
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  void _openWaiterDialog() {
    final kioskVM = context.read<KioskViewModel>();
    showDialog(
      context: context,
      builder: (context) => WaiterCallDialog(
        tableNumber: kioskVM.tableNumber,
        onCallWaiter: (type) => kioskVM.sendWaiterCall(type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kioskVM = context.watch<KioskViewModel>();
    final cartVM = context.watch<CartViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.darkBg,
      endDrawer: const CartDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            InkWell(
              onTap: () => context.go('/'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primary),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.table_restaurant, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Table ${kioskVM.tableNumber}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'OrderEase',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          // Waiter Call
          TextButton.icon(
            onPressed: _openWaiterDialog,
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.primary, size: 18),
            label: const Text('Call Waiter', style: TextStyle(color: AppTheme.primary)),
          ),
          const SizedBox(width: 8),
          // Language Badge
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white70),
            tooltip: 'Change Language',
            onSelected: (code) => kioskVM.setLanguage(code),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text('🇬🇧 English')),
              const PopupMenuItem(value: 'ta', child: Text('🇮🇳 தமிழ்')),
              const PopupMenuItem(value: 'hi', child: Text('🇮🇳 हिंदी')),
              const PopupMenuItem(value: 'te', child: Text('🇮🇳 తెలుగు')),
              const PopupMenuItem(value: 'es', child: Text('🇪🇸 Español')),
            ],
          ),
          // Staff Portal Link
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white70),
            tooltip: 'Staff / KDS Portal',
            onPressed: () => context.push('/login'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppTheme.darkCard,
              border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => kioskVM.setSearchQuery(val),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search delicious dishes...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, size: 20, color: Colors.white60),
                      filled: true,
                      fillColor: AppTheme.darkBg,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppTheme.darkBorder),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Veg Switch
                FilterChip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🌱 Veg Only'),
                    ],
                  ),
                  selected: kioskVM.isVegOnly,
                  selectedColor: AppTheme.accent.withOpacity(0.2),
                  checkmarkColor: AppTheme.accent,
                  backgroundColor: AppTheme.darkBg,
                  labelStyle: TextStyle(
                    color: kioskVM.isVegOnly ? AppTheme.accent : Colors.white70,
                    fontWeight: kioskVM.isVegOnly ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  onSelected: (_) => kioskVM.toggleVegOnly(),
                ),
              ],
            ),
          ),

          // Category Horizontal Tabs
          if (kioskVM.categories.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: AppTheme.darkCard,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: kioskVM.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final cat = kioskVM.categories[idx];
                  final isSelected = kioskVM.selectedCategoryId == cat.id;
                  return ChoiceChip(
                    label: Text(cat.getLocalizedName(kioskVM.selectedLanguage)),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.darkBg,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    onSelected: (val) {
                      if (val) kioskVM.selectCategory(cat.id);
                    },
                  );
                },
              ),
            ),

          // Menu Items Grid
          Expanded(
            child: kioskVM.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : kioskVM.filteredItems.isEmpty
                    ? const Center(
                        child: Text('No dishes match your filter', style: TextStyle(color: Colors.white60)),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          // Adaptive columns: 1 for mobile, 2 for tablet, 3-4 for large tablet/desktop
                          final crossAxisCount = constraints.maxWidth > 900
                              ? 3
                              : (constraints.maxWidth > 600 ? 2 : 1);

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: kioskVM.filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = kioskVM.filteredItems[index];
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: item.isAvailable ? () => _openCustomizer(item) : null,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Image & Badges
                                      Stack(
                                        children: [
                                          item.imageUrl != null
                                              ? Image.network(
                                                  item.imageUrl!,
                                                  height: 140,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => Container(
                                                    height: 140,
                                                    color: AppTheme.darkBg,
                                                    child: const Center(
                                                      child: Icon(Icons.fastfood, size: 48, color: Colors.white24),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  height: 140,
                                                  color: AppTheme.darkBg,
                                                  child: const Center(
                                                    child: Icon(Icons.fastfood, size: 48, color: Colors.white24),
                                                  ),
                                                ),
                                          // Availability Overlay
                                          if (!item.isAvailable)
                                            Container(
                                              height: 140,
                                              color: Colors.black.withOpacity(0.7),
                                              child: const Center(
                                                child: Text(
                                                  'SOLD OUT',
                                                  style: TextStyle(
                                                    color: Colors.redAccent,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          // Veg / NonVeg Tag
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.black87,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item.isVeg ? '🌱 Veg' : '🍗 Non-Veg',
                                                style: TextStyle(
                                                  color: item.isVeg ? AppTheme.accent : Colors.orangeAccent,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Prep Time
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.black87,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '⏱ ${item.prepTimeMinutes}m',
                                                style: const TextStyle(color: Colors.white, fontSize: 11),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Details
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.getLocalizedName(kioskVM.selectedLanguage),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.getLocalizedDescription(kioskVM.selectedLanguage),
                                              style: const TextStyle(fontSize: 12, color: Colors.white60),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '${AppConstants.currencySymbol}${item.price.toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.primary,
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: item.isAvailable ? () => _openCustomizer(item) : null,
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                    backgroundColor: item.isAvailable ? AppTheme.primary : Colors.grey,
                                                  ),
                                                  child: const Text('Add', style: TextStyle(fontSize: 13)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),

      // Floating Cart Button
      bottomNavigationBar: cartVM.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.darkCard,
                border: Border(top: BorderSide(color: AppTheme.darkBorder)),
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${cartVM.itemCount} items',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text('View Cart & Split Bill', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        Text(
                          '${AppConstants.currencySymbol}${cartVM.total.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

