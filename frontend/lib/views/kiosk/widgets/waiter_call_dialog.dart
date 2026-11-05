import 'package:flutter/material.dart';
import 'package:smart_kiosk/core/theme/app_theme.dart';

class WaiterCallDialog extends StatelessWidget {
  final int tableNumber;
  final Function(String callType) onCallWaiter;

  const WaiterCallDialog({
    super.key,
    required this.tableNumber,
    required this.onCallWaiter,
  });

  @override
  Widget build(BuildContext context) {
    final callOptions = [
      {'title': 'Need Water', 'icon': Icons.water_drop_outlined, 'desc': 'Complimentary fresh water'},
      {'title': 'Need Assistance', 'icon': Icons.help_outline, 'desc': 'Questions on menu or ordering'},
      {'title': 'Need Bill', 'icon': Icons.receipt_long_outlined, 'desc': 'Request physical invoice/settlement'},
      {'title': 'Table Cleaning', 'icon': Icons.cleaning_services_outlined, 'desc': 'Clear empty plates & napkins'},
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.darkCard,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Call Waiter (Table $tableNumber)',
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
              const SizedBox(height: 8),
              const Text(
                'Select the reason for service. Staff will arrive at your table immediately.',
                style: TextStyle(fontSize: 13, color: Colors.white60),
              ),
              const SizedBox(height: 16),
              ...callOptions.map((opt) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () {
                      onCallWaiter(opt['title'] as String);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Waiter notified: ${opt['title']} for Table $tableNumber'),
                          backgroundColor: AppTheme.primary,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.darkBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.darkBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(opt['icon'] as IconData, color: AppTheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt['title'] as String,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text(
                                  opt['desc'] as String,
                                  style: const TextStyle(fontSize: 12, color: Colors.white60),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white38),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

