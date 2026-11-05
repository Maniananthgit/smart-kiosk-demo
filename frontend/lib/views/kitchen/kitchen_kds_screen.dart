import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_kiosk/models/order.dart';
import 'package:smart_kiosk/viewmodels/kitchen_viewmodel.dart';
import 'package:smart_kiosk/views/common/demo_navigation_bar.dart';

class KitchenKdsScreen extends StatefulWidget {
  const KitchenKdsScreen({super.key});

  @override
  State<KitchenKdsScreen> createState() => _KitchenKdsScreenState();
}

class _KitchenKdsScreenState extends State<KitchenKdsScreen> {
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KitchenViewModel>().loadKDS();
    });
  }

  void _showInventoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<KitchenViewModel>(
          builder: (context, vm, _) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF1E293B)),
              ),
              title: const Row(
                children: [
                  Icon(Icons.inventory_2_rounded, color: Color(0xFFF59E0B)),
                  SizedBox(width: 8),
                  Text('Manage 86 / Sold-Out Dishes', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
              content: SizedBox(
                width: 480,
                height: 420,
                child: ListView.separated(
                  itemCount: vm.menuItems.length,
                  separatorBuilder: (_, __) => const Divider(color: Color(0xFF1E293B)),
                  itemBuilder: (context, idx) {
                    final item = vm.menuItems[idx];
                    return SwitchListTile(
                      title: Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        item.isAvailable ? 'In Stock (Available)' : '86ed / Sold Out',
                        style: TextStyle(
                          color: item.isAvailable ? const Color(0xFF10B981) : Colors.redAccent,
                          fontSize: 11,
                        ),
                      ),
                      value: item.isAvailable,
                      activeThumbColor: const Color(0xFF10B981),
                      onChanged: (_) => vm.toggleItemStock(item.id),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
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
      backgroundColor: const Color(0xFF020617),
      appBar: const DemoNavigationBar(currentRoute: '/kitchen'),
      body: Column(
        children: [
          // Sub-Bar: KDS Status Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.soup_kitchen_rounded, color: Color(0xFFF59E0B), size: 20),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kitchen Display System (KDS)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Real-time order fulfillment & expediter station',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),

                const Spacer(),

                // Audio Alerts Toggle
                InkWell(
                  onTap: () {
                    setState(() => _soundEnabled = !_soundEnabled);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_soundEnabled ? 'Kitchen chime sound enabled' : 'Kitchen chime muted')),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          size: 14,
                          color: _soundEnabled ? const Color(0xFF10B981) : Colors.redAccent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _soundEnabled ? 'Chime ON' : 'Muted',
                          style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 86 / Sold Out Button
                OutlinedButton.icon(
                  onPressed: _showInventoryDialog,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEA580C)),
                    foregroundColor: const Color(0xFFEA580C),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.inventory_2_outlined, size: 14),
                  label: const Text('86 / Sold Out', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),

                // Refresh Button
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.white70),
                  onPressed: () => kitchenVM.loadKDS(),
                  tooltip: 'Refresh Tickets',
                ),
              ],
            ),
          ),

          // Main KDS 3-Column Board
          Expanded(
            child: kitchenVM.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
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
                            color: const Color(0xFFF59E0B),
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
                            color: const Color(0xFF38BDF8),
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
                            color: const Color(0xFF10B981),
                            orders: kitchenVM.readyOrders,
                            actionLabel: 'Complete Ticket',
                            nextStatus: 'COMPLETED',
                            onAction: (id) => kitchenVM.bumpOrderStatus(id, 'COMPLETED'),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
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
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: const Border(bottom: BorderSide(color: Color(0xFF1E293B))),
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
          ),

          // Tickets List
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Text(
                      'No orders in this stage',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF020617),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order ID & Table
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEA580C).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFEA580C)),
                                  ),
                                  child: Text(
                                    'Table ${order.tableNumber}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFB923C),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Text(
                                  '#${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Color(0xFF1E293B), height: 20),

                            // Items List
                            for (final itm in order.items) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${itm.quantity}x',
                                        style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        itm.name,
                                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),

                            // Action Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => onAction(order.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color,
                                  foregroundColor: const Color(0xFF020617),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  actionLabel,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
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
