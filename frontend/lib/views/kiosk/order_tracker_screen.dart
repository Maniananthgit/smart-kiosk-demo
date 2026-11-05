import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_kiosk/core/constants/app_constants.dart';
import 'package:smart_kiosk/core/theme/app_theme.dart';
import 'package:smart_kiosk/viewmodels/order_tracker_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/kitchen_viewmodel.dart';

class OrderTrackerScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackerScreen({super.key, required this.orderId});

  @override
  State<OrderTrackerScreen> createState() => _OrderTrackerScreenState();
}

class _OrderTrackerScreenState extends State<OrderTrackerScreen> {
  int _rating = 5;
  final List<String> _selectedTags = [];
  final TextEditingController _commentController = TextEditingController();

  final List<String> _feedbackTags = [
    'Delicious Food',
    'Lightning Fast Service',
    'Accurate Customization',
    'Clean Kiosk Experience',
    'Great Ambience'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderTrackerViewModel>().loadOrder(widget.orderId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  int _getStatusStep(String status) {
    switch (status.toUpperCase()) {
      case 'NEW':
        return 0;
      case 'PREPARING':
        return 1;
      case 'READY':
        return 2;
      case 'COMPLETED':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackerVM = context.watch<OrderTrackerViewModel>();
    final order = trackerVM.order;

    if (trackerVM.isLoading || order == null) {
      if (!trackerVM.isLoading && order == null) {
        return Scaffold(
          backgroundColor: AppTheme.darkBg,
          appBar: AppBar(
            title: const Text('Order Status'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/kiosk'),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long, size: 64, color: Colors.white38),
                const SizedBox(height: 16),
                const Text('Order not found', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.go('/kiosk'),
                  child: const Text('Back to Menu'),
                ),
              ],
            ),
          ),
        );
      }
      return Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final currentStep = _getStatusStep(order.status);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text('Order #${order.orderNumber} Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => trackerVM.refresh(),
            tooltip: 'Refresh Status',
          ),
          TextButton(
            onPressed: () => context.go('/kiosk'),
            child: const Text('Order More', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              children: [
                // Live Stepper Tracker Card
                Card(
                  color: AppTheme.darkCard,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Table ${order.tableNumber}',
                                  style: const TextStyle(fontSize: 14, color: Colors.white60),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Order #${order.orderNumber}',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.primary),
                              ),
                              child: Text(
                                order.status,
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Progress Stepper Indicators
                        Row(
                          children: [
                            _buildStep(0, 'Order Placed', currentStep >= 0, Icons.check_circle_outline),
                            _buildStepLine(currentStep >= 1),
                            _buildStep(1, 'Kitchen Preparing', currentStep >= 1, Icons.soup_kitchen_outlined),
                            _buildStepLine(currentStep >= 2),
                            _buildStep(2, 'Ready to Serve', currentStep >= 2, Icons.room_service_outlined),
                            _buildStepLine(currentStep >= 3),
                            _buildStep(3, 'Completed', currentStep >= 3, Icons.done_all),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Demo Simulator Action
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.accent,
                              side: const BorderSide(color: AppTheme.accent),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () async {
                              final nextStatus = currentStep == 0
                                  ? 'PREPARING'
                                  : currentStep == 1
                                      ? 'READY'
                                      : currentStep == 2
                                          ? 'COMPLETED'
                                          : 'NEW';
                              await context.read<KitchenViewModel>().bumpOrderStatus(order.id, nextStatus);
                              await trackerVM.refresh();
                            },
                            icon: const Icon(Icons.fast_forward_rounded, size: 16),
                            label: Text(
                              currentStep == 0
                                  ? 'Simulate Kitchen: Start Preparing →'
                                  : currentStep == 1
                                      ? 'Simulate Kitchen: Mark Ready →'
                                      : currentStep == 2
                                          ? 'Simulate Kitchen: Mark Completed →'
                                          : 'Reset to New Order',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Digital Itemized Receipt Card
                Card(
                  color: AppTheme.darkCard,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.receipt_long, color: AppTheme.primary),
                            SizedBox(width: 8),
                            Text(
                              'Digital Receipt',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        const Divider(color: AppTheme.darkBorder, height: 24),
                        ...order.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item.quantity}x ${item.name}',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                      if (item.spiceLevel.isNotEmpty)
                                        Text('Spice: ${item.spiceLevel}',
                                            style: const TextStyle(color: Colors.white60, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${AppConstants.currencySymbol}${(item.price * item.quantity).toStringAsFixed(0)}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(color: AppTheme.darkBorder, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal', style: TextStyle(color: Colors.white60)),
                            Text('${AppConstants.currencySymbol}${order.subtotal.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('GST (5%)', style: TextStyle(color: Colors.white60)),
                            Text('${AppConstants.currencySymbol}${order.tax.toStringAsFixed(1)}',
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        if (order.tip > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tip', style: TextStyle(color: Colors.white60)),
                              Text('${AppConstants.currencySymbol}${order.tip.toStringAsFixed(1)}',
                                  style: const TextStyle(color: AppTheme.primary)),
                            ],
                          ),
                        ],
                        const Divider(color: AppTheme.darkBorder, height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Paid (UPI)',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text(
                              '${AppConstants.currencySymbol}${order.total.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Post-Meal Feedback Form
                Card(
                  color: AppTheme.darkCard,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: trackerVM.feedbackSubmitted
                        ? const Center(
                            child: Column(
                              children: [
                                Icon(Icons.check_circle, color: AppTheme.accent, size: 48),
                                SizedBox(height: 12),
                                Text(
                                  'Thank You For Your Feedback!',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Your review helps our culinary team provide exceptional dining.',
                                  style: TextStyle(fontSize: 13, color: Colors.white60),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rate Your Dining Experience',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [1, 2, 3, 4, 5].map((star) {
                                  return IconButton(
                                    icon: Icon(
                                      star <= _rating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 32,
                                    ),
                                    onPressed: () => setState(() => _rating = star),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _feedbackTags.map((tag) {
                                  final isSelected = _selectedTags.contains(tag);
                                  return FilterChip(
                                    label: Text(tag),
                                    selected: isSelected,
                                    selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                                    backgroundColor: AppTheme.darkBg,
                                    labelStyle: TextStyle(
                                      color: isSelected ? AppTheme.primary : Colors.white70,
                                      fontSize: 12,
                                    ),
                                    onSelected: (val) {
                                      setState(() {
                                        if (val) {
                                          _selectedTags.add(tag);
                                        } else {
                                          _selectedTags.remove(tag);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _commentController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Share a quick compliment or suggestion for Chef...',
                                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                                  filled: true,
                                  fillColor: AppTheme.darkBg,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: AppTheme.darkBorder),
                                  ),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    trackerVM.submitFeedback(
                                      rating: _rating,
                                      tags: _selectedTags,
                                      comment: _commentController.text.trim(),
                                    );
                                  },
                                  child: const Text('Submit Dining Feedback'),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int stepIndex, String title, bool isDone, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDone ? AppTheme.primary : AppTheme.darkBg,
            shape: BoxShape.circle,
            border: Border.all(color: isDone ? AppTheme.primary : AppTheme.darkBorder),
          ),
          child: Icon(icon, size: 20, color: isDone ? Colors.white : Colors.white38),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: isDone ? Colors.white : Colors.white38,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? AppTheme.primary : AppTheme.darkBorder,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}

