import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_kiosk/core/constants/app_constants.dart';
import 'package:smart_kiosk/core/theme/app_theme.dart';
import 'package:smart_kiosk/viewmodels/dashboard_viewmodel.dart';

class ManagementDashboardScreen extends StatefulWidget {
  const ManagementDashboardScreen({super.key});

  @override
  State<ManagementDashboardScreen> createState() => _ManagementDashboardScreenState();
}

class _ManagementDashboardScreenState extends State<ManagementDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashVM = context.watch<DashboardViewModel>();
    final kpi = dashVM.kpiSummary;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('Executive Management Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => dashVM.loadDashboard(),
            tooltip: 'Refresh Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/'),
            tooltip: 'Home',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: dashVM.isLoading || kpi == null
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Stat Cards Row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 650;
                      return GridView.count(
                        crossAxisCount: isMobile ? 2 : 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          _buildKpiCard(
                            title: "Today's Sales",
                            value: '${AppConstants.currencySymbol}${kpi.todaysSales.toStringAsFixed(0)}',
                            icon: Icons.payments_outlined,
                            color: AppTheme.primary,
                          ),
                          _buildKpiCard(
                            title: 'Total Orders',
                            value: '${kpi.totalOrders}',
                            icon: Icons.receipt_long_outlined,
                            color: Colors.lightBlue,
                          ),
                          _buildKpiCard(
                            title: 'Average Order Value',
                            value: '${AppConstants.currencySymbol}${kpi.averageOrderValue.toStringAsFixed(0)}',
                            icon: Icons.trending_up,
                            color: AppTheme.accent,
                          ),
                          _buildKpiCard(
                            title: 'Average Diner Rating',
                            value: '⭐ ${kpi.averageRating.toStringAsFixed(1)} / 5',
                            icon: Icons.star_outline,
                            color: Colors.amber,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Best Selling Dishes Breakdown
                  Card(
                    color: AppTheme.darkCard,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🔥 Best-Selling Dishes & Profitability',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
                              dataTextStyle: const TextStyle(color: Colors.white),
                              columns: const [
                                DataColumn(label: Text('Dish Name')),
                                DataColumn(label: Text('Orders Placed')),
                                DataColumn(label: Text('Gross Revenue')),
                                DataColumn(label: Text('Gross Margin')),
                              ],
                              rows: kpi.bestSellingDishes.map((dish) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(dish.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(Text('${dish.orders}')),
                                    DataCell(Text('${AppConstants.currencySymbol}${dish.revenue.toStringAsFixed(0)}')),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accent.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          dish.margin,
                                          style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Waiter Calls Matrix
                  Card(
                    color: AppTheme.darkCard,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '🛎 Live Waiter Service Calls',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${dashVM.waiterCalls.length} Active',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          dashVM.waiterCalls.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text('All table calls resolved. Dining room smooth!', style: TextStyle(color: Colors.white60)),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: dashVM.waiterCalls.length,
                                  separatorBuilder: (_, __) => const Divider(color: AppTheme.darkBorder),
                                  itemBuilder: (context, idx) {
                                    final call = dashVM.waiterCalls[idx];
                                    return ListTile(
                                      leading: const Icon(Icons.notifications_active, color: AppTheme.primary),
                                      title: Text(
                                        'Table ${call.tableNumber}: ${call.callType}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        'Status: ${call.status}',
                                        style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
                                      ),
                                      trailing: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.accent,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        ),
                                        onPressed: () => dashVM.resolveWaiterCall(call.id),
                                        child: const Text('Resolve', style: TextStyle(fontSize: 12)),
                                      ),
                                    );
                                  },
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

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: AppTheme.darkCard,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 13, color: Colors.white60),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

