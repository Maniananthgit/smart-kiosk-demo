import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_kiosk/core/theme/app_theme.dart';
import 'package:smart_kiosk/models/order.dart';
import 'package:smart_kiosk/viewmodels/kitchen_viewmodel.dart';

class KitchenKdsScreen extends StatefulWidget {
  const KitchenKdsScreen({super.key});

  @override
  State<KitchenKdsScreen> createState() => _KitchenKdsScreenState();
}

class _KitchenKdsScreenState extends State<KitchenKdsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KitchenViewModel>().loadKDS();
    });
  }

  void _showInventoryDialog() {
    final kitchenVM = context.read<KitchenViewModel>();
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<KitchenViewModel>(
          builder: (context, vm, _) {
            return AlertDialog(
              backgroundColor: AppTheme.darkCard,
              title: const Text('Manage 86 / Sold-Out Dishes', style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: 450,
                height: 400,
                child: ListView.separated(
                  itemCount: vm.menuItems.length,
                  separatorBuilder: (_, __) => const Divider(color: AppTheme.darkBorder),
                  itemBuilder: (context, idx) {
                    final item = vm.menuItems[idx];
                    return SwitchListTile(
                      title: Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: Text(
                        item.isAvailable ? 'In Stock (Available)' : '86ed / Sold Out',
                        style: TextStyle(
                          color: item.isAvailable ? AppTheme.accent : Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                      value: item.isAvailable,
                      activeColor: AppTheme.accent,
                      onChanged: (_) => vm.toggleItemStock(item.id),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done', style: TextStyle(color: AppTheme.primary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final kitchenVM = context.watch<KitchenViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.soup_kitchen, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Kitchen Display System (KDS)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: _showInventoryDialog,
            icon: const Icon(Icons.inventory_2_outlined, size: 16, color: Colors.orangeAccent),
            label: const Text('86 / Sold Out', style: TextStyle(color: Colors.orangeAccent)),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => kitchenVM.loadKDS(),
            tooltip: 'Refresh Tickets',
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/'),
            tooltip: 'Home',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: kitchenVM.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Column 1: New Orders
                  Expanded(
                    child: _buildColumn(
                      title: '🟡 New Tickets',
                      count: kitchenVM.newOrders.length,
                      color: Colors.amber,
                      orders: kitchenVM.newOrders,
                      actionLabel: 'Start Cooking',
                      nextStatus: 'PREPARING',
                      onAction: (id) => kitchenVM.bumpOrderStatus(id, 'PREPARING'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Column 2: In Preparation
                  Expanded(
                    child: _buildColumn(
                      title: '🔵 In Preparation',
                      count: kitchenVM.preparingOrders.length,
                      color: Colors.lightBlue,
                      orders: kitchenVM.preparingOrders,
                      actionLabel: 'Mark Ready',
                      nextStatus: 'READY',
                      onAction: (id) => kitchenVM.bumpOrderStatus(id, 'READY'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Column 3: Ready for Serving
                  Expanded(
                    child: _buildColumn(
                      title: '🟢 Ready for Service',
                      count: kitchenVM.readyOrders.length,
                      color: AppTheme.accent,
                      orders: kitchenVM.readyOrders,
                      actionLabel: 'Complete Ticket',
                      nextStatus: 'COMPLETED',
                      onAction: (id) => kitchenVM.bumpOrderStatus(id, 'COMPLETED'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildColumn({
    required String title,
    required int count,
    required Color color,
    required List<OrderModel> orders,
    required String actionLabel,
    required String nextStatus,
    required Function(String orderId) onAction,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: const Border(bottom: BorderSide(color: AppTheme.darkBorder)),
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: orders.isEmpty
                ? const Center(
                    child: Text('No active orders', style: TextStyle(color: Colors.white38)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: orders.length,
                    itemBuilder: (context, idx) {
                      final order = orders[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: AppTheme.darkBg,
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '#${order.orderNumber}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Table ${order.tableNumber}',
                                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: AppTheme.darkBorder, height: 16),
                              ...order.items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item.quantity}x ${item.name}',
                                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
                                      ),
                                      if (item.spiceLevel.isNotEmpty)
                                        Text('🌶 Spice: ${item.spiceLevel}',
                                            style: const TextStyle(color: Colors.orangeAccent, fontSize: 11)),
                                      if (item.customizations.isNotEmpty)
                                        Text('Custom: ${item.customizations.join(', ')}',
                                            style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                      if (item.specialInstructions.isNotEmpty)
                                        Text('Note: "${item.specialInstructions}"',
                                            style: const TextStyle(color: Colors.amber, fontSize: 11, fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  onPressed: () => onAction(order.id),
                                  child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

