import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_kiosk/core/theme/app_theme.dart';
import 'package:smart_kiosk/models/menu_item.dart';
import 'package:smart_kiosk/services/api_service.dart';
import 'package:smart_kiosk/viewmodels/cart_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/kiosk_viewmodel.dart';
import 'package:smart_kiosk/views/common/demo_navigation_bar.dart';
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

  void _openOrderTracker(BuildContext context, int tableNumber) async {
    final apiService = ApiService();
    final orders = await apiService.getOrders(tableNumber: tableNumber);
    if (!context.mounted) return;

    if (orders.length > 1) {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF0F172A),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(color: Color(0xFF1E293B)),
        ),
        builder: (ctx) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Table $tableNumber Orders',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...orders.map((o) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: ListTile(
                      title: Text(
                        'Order #${o.orderNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: Text(
                        '${o.items.length} items • ₹${o.total.toStringAsFixed(0)} • ${o.createdAt}',
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF10B981)),
                            ),
                            child: Text(
                              o.status,
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white70),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/tracker/${o.id}');
                      },
                    ),
                  );
                }),
              ],
            ),
          );
        },
      );
    } else if (orders.length == 1) {
      context.push('/tracker/${orders.first.id}');
    } else {
      context.push('/tracker/ORD-1024');
    }
  }

  @override
  Widget build(BuildContext context) {
    final kioskVM = context.watch<KioskViewModel>();
    final cartVM = context.watch<CartViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF020617),
      appBar: const DemoNavigationBar(currentRoute: '/kiosk'),
      endDrawer: const CartDrawer(),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'track_order_fab',
            onPressed: () => _openOrderTracker(context, kioskVM.tableNumber),
            backgroundColor: const Color(0xFF0F172A),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
            ),
            icon: const Icon(Icons.radar_rounded, color: Color(0xFF10B981), size: 18),
            label: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Track Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                SizedBox(width: 6),
                CircleAvatar(
                  radius: 3.5,
                  backgroundColor: Color(0xFF10B981),
                ),
              ],
            ),
          ),
          if (cartVM.itemCount > 0) ...[
            const SizedBox(width: 10),
            FloatingActionButton.extended(
              heroTag: 'cart_fab',
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              elevation: 8,
              icon: const Icon(Icons.shopping_bag_rounded),
              label: Text(
                '${cartVM.itemCount} items • ₹${cartVM.total.toStringAsFixed(0)} | View Order →',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // 1. Top Sub-Header Bar (Table, Waiter, Language, Cart Button)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                // Table Badge
                InkWell(
                  onTap: () => context.go('/welcome'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA580C).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEA580C)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.table_restaurant, size: 16, color: Color(0xFFEA580C)),
                        const SizedBox(width: 6),
                        Text(
                          'Table ${kioskVM.tableNumber}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Assigned Waiter Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_pin_rounded, size: 14, color: Color(0xFFF59E0B)),
                      SizedBox(width: 6),
                      Text(
                        'Waiter: Rajesh • Zone A',
                        style: TextStyle(fontSize: 12, color: Color(0xFFCBD5E1), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Call Waiter Button
                TextButton.icon(
                  onPressed: _openWaiterDialog,
                  icon: const Icon(Icons.notifications_active_rounded, color: Color(0xFFF59E0B), size: 16),
                  label: const Text('Call Waiter', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),

                // Track Order Header Pill
                InkWell(
                  onTap: () => _openOrderTracker(context, kioskVM.tableNumber),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.radar_rounded, size: 14, color: Color(0xFF10B981)),
                        SizedBox(width: 5),
                        Text(
                          'Track Order',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Language Dropdown
                PopupMenuButton<String>(
                  icon: const Icon(Icons.language, color: Colors.white70, size: 18),
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
                const SizedBox(width: 8),

                // Cart Trigger Pill
                InkWell(
                  onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA580C),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEA580C).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_bag_rounded, size: 15, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          '${cartVM.itemCount} items • ₹${cartVM.total.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Luxury Service Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Royal Evening Dinner Service • 7:00 PM – 11:30 PM (Late Night Sizzlers)',
                  style: TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF94A3B8)),
                    SizedBox(width: 4),
                    Text('Time-Synchronized Menu', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          // 3. Search Bar & Diet Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF0F172A),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => kioskVM.setSearchQuery(val),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search for curries, tandoors, biryanis, desserts...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFF020617),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFF1E293B)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFF1E293B)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Veg Only Filter
                FilterChip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco_rounded, size: 14, color: Color(0xFF10B981)),
                      SizedBox(width: 4),
                      Text('Veg Only'),
                    ],
                  ),
                  selected: kioskVM.isVegOnly,
                  selectedColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFF10B981),
                  backgroundColor: const Color(0xFF020617),
                  side: BorderSide(
                    color: kioskVM.isVegOnly ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                  ),
                  labelStyle: TextStyle(
                    color: kioskVM.isVegOnly ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                    fontWeight: kioskVM.isVegOnly ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (_) => kioskVM.toggleVegOnly(),
                ),
              ],
            ),
          ),

          // 4. Categories Horizontal Pills
          if (kioskVM.categories.isNotEmpty)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: const Color(0xFF0F172A),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: kioskVM.categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  if (idx == 0) {
                    final isAllSelected = kioskVM.selectedCategoryId == null;
                    return ChoiceChip(
                      label: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 14, color: Color(0xFFF59E0B)),
                          SizedBox(width: 5),
                          Text('All Dishes'),
                        ],
                      ),
                      selected: isAllSelected,
                      selectedColor: const Color(0xFFEA580C),
                      backgroundColor: const Color(0xFF020617),
                      side: BorderSide(
                        color: isAllSelected ? const Color(0xFFEA580C) : const Color(0xFF1E293B),
                      ),
                      labelStyle: TextStyle(
                        color: isAllSelected ? Colors.white : const Color(0xFF94A3B8),
                        fontWeight: isAllSelected ? FontWeight.w900 : FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        if (val) kioskVM.selectCategory(null);
                      },
                    );
                  }

                  final cat = kioskVM.categories[idx - 1];
                  final isSelected = kioskVM.selectedCategoryId == cat.id;
                  return ChoiceChip(
                    label: Text(cat.getLocalizedName(kioskVM.selectedLanguage)),
                    selected: isSelected,
                    selectedColor: const Color(0xFFEA580C),
                    backgroundColor: const Color(0xFF020617),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFEA580C) : const Color(0xFF1E293B),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) kioskVM.selectCategory(cat.id);
                    },
                  );
                },
              ),
            ),

          const Divider(height: 1, color: Color(0xFF1E293B)),

          // 5. Food Menu Items Grid
          Expanded(
            child: kioskVM.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
                : kioskVM.filteredItems.isEmpty
                    ? const Center(
                        child: Text('No dishes match your filter', style: TextStyle(color: Color(0xFF94A3B8))),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 950
                              ? 3
                              : (constraints.maxWidth > 650 ? 2 : 1);

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.82,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: kioskVM.filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = kioskVM.filteredItems[index];
                              return _buildDishCard(context, item, kioskVM);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishCard(BuildContext context, MenuItem item, KioskViewModel kioskVM) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: item.isAvailable ? () => _openCustomizer(item) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Badges
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.imageUrl != null
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF020617),
                            child: const Icon(Icons.restaurant, color: Color(0xFFF59E0B), size: 40),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF020617),
                          child: const Icon(Icons.restaurant, color: Color(0xFFF59E0B), size: 40),
                        ),
                  // Dark Vignette
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                  // Veg / Non-Veg Tag
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: item.isVeg ? const Color(0xFF10B981) : Colors.redAccent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: item.isVeg ? const Color(0xFF10B981) : Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.isVeg ? 'Veg' : 'Non-Veg',
                            style: TextStyle(
                              color: item.isVeg ? const Color(0xFF10B981) : Colors.redAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Rating & Prep Time
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 3),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.access_time_rounded, size: 11, color: Color(0xFFCBD5E1)),
                          const SizedBox(width: 3),
                          Text(
                            '${item.prepTimeMinutes}m',
                            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!item.isAvailable)
                    Container(
                      color: Colors.black.withValues(alpha: 0.7),
                      child: const Center(
                        child: Text(
                          'SOLD OUT',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.getLocalizedName(kioskVM.selectedLanguage),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.getLocalizedDescription(kioskVM.selectedLanguage),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: item.isAvailable ? () => _openCustomizer(item) : null,
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA580C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
