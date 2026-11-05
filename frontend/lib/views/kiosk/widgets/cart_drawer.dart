import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_kiosk/core/constants/app_constants.dart';
import 'package:smart_kiosk/core/theme/app_theme.dart';
import 'package:smart_kiosk/viewmodels/cart_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/kiosk_viewmodel.dart';

class CartDrawer extends StatelessWidget {
  const CartDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final cartVM = context.watch<CartViewModel>();
    final kioskVM = context.watch<KioskViewModel>();

    return Drawer(
      backgroundColor: AppTheme.darkBg,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Your Order (Table ${kioskVM.tableNumber})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),

            // Cart Items
            Expanded(
              child: cartVM.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          const Text(
                            'Your cart is empty',
                            style: TextStyle(fontSize: 16, color: Colors.white60),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Select dishes to begin ordering',
                            style: TextStyle(fontSize: 13, color: Colors.white38),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartVM.items.length,
                      separatorBuilder: (_, __) => const Divider(color: AppTheme.darkBorder, height: 20),
                      itemBuilder: (context, index) {
                        final item = cartVM.items[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Quantity Controls
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.darkCard,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.darkBorder),
                              ),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () => cartVM.incrementQuantity(item.id),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Icon(Icons.add, size: 16, color: Colors.white),
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  InkWell(
                                    onTap: () => cartVM.decrementQuantity(item.id),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Icon(Icons.remove, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.item.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                                  ),
                                  Text(
                                    'Spice: ${item.spiceLevel}',
                                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                                  ),
                                  if (item.customizations.isNotEmpty)
                                    Text(
                                      item.customizations.join(', '),
                                      style: const TextStyle(fontSize: 12, color: AppTheme.primary),
                                    ),
                                  if (item.specialInstructions.isNotEmpty)
                                    Text(
                                      'Note: "${item.specialInstructions}"',
                                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.white38),
                                    ),
                                ],
                              ),
                            ),
                            // Price
                            Text(
                              '${AppConstants.currencySymbol}${item.subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // Checkout Footer
            if (!cartVM.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.darkCard,
                  border: Border(top: BorderSide(color: AppTheme.darkBorder)),
                ),
                child: Column(
                  children: [
                    // Split Bill Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Split Bill Across:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Row(
                          children: [1, 2, 3, 4, 5].map((diners) {
                            final isSelected = cartVM.splitDinerCount == diners;
                            return Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: InkWell(
                                onTap: () => cartVM.setSplitDinerCount(diners),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.primary : AppTheme.darkBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppTheme.darkBorder),
                                  ),
                                  child: Text(
                                    '$diners',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white60,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tip Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tip (Optional):', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Row(
                          children: [0.0, 5.0, 10.0, 15.0].map((tip) {
                            final isSelected = cartVM.tipPercent == tip;
                            return Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: InkWell(
                                onTap: () => cartVM.setTipPercent(tip),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.primary : AppTheme.darkBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppTheme.darkBorder),
                                  ),
                                  child: Text(
                                    '${tip.toInt()}%',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white60,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                    const Divider(color: AppTheme.darkBorder, height: 16),

                    // Pricing breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(color: Colors.white60, fontSize: 13)),
                        Text('${AppConstants.currencySymbol}${cartVM.subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('GST (5%)', style: TextStyle(color: Colors.white60, fontSize: 13)),
                        Text('${AppConstants.currencySymbol}${cartVM.tax.toStringAsFixed(1)}',
                            style: const TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                    if (cartVM.tipAmount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tip', style: TextStyle(color: Colors.white60, fontSize: 13)),
                          Text('${AppConstants.currencySymbol}${cartVM.tipAmount.toStringAsFixed(1)}',
                              style: const TextStyle(color: AppTheme.primary, fontSize: 13)),
                        ],
                      ),
                    ],
                    const Divider(color: AppTheme.darkBorder, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            if (cartVM.splitDinerCount > 1)
                              Text(
                                '${AppConstants.currencySymbol}${cartVM.splitAmountPerDiner.toStringAsFixed(0)} / diner (${cartVM.splitDinerCount} diners)',
                                style: const TextStyle(fontSize: 11, color: AppTheme.primary),
                              ),
                          ],
                        ),
                        Text(
                          '${AppConstants.currencySymbol}${cartVM.total.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Submit Order Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: cartVM.isSubmitting
                            ? null
                            : () async {
                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                final order = await cartVM.submitOrder(kioskVM.tableNumber);
                                if (order != null && context.mounted) {
                                  navigator.pop(); // Close drawer
                                  context.push('/tracker/${order.id}');
                                } else if (cartVM.errorMessage != null && context.mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(cartVM.errorMessage!),
                                      backgroundColor: AppTheme.errorRed,
                                    ),
                                  );
                                }
                              },
                        child: cartVM.isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Place Order & Pay via UPI'),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

