import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_kiosk/core/constants/app_constants.dart';
import 'package:smart_kiosk/core/theme/app_theme.dart';
import 'package:smart_kiosk/viewmodels/dashboard_viewmodel.dart';
import 'package:smart_kiosk/views/common/demo_navigation_bar.dart';

class ManagementDashboardScreen extends StatefulWidget {
  const ManagementDashboardScreen({super.key});

  @override
  State<ManagementDashboardScreen> createState() => _ManagementDashboardScreenState();
}

class _ManagementDashboardScreenState extends State<ManagementDashboardScreen> {
  String _activeTab = 'overview';

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
      backgroundColor: const Color(0xFF020617),
      appBar: const DemoNavigationBar(currentRoute: '/dashboard'),
      body: Column(
        children: [
          // Sub-Bar: Management Portal Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF818CF8), size: 20),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Executive Management Portal',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Indiranagar Flagship • Real-time restaurant intelligence',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.white70),
                  onPressed: () => dashVM.loadDashboard(),
                  tooltip: 'Refresh Analytics',
                ),
              ],
            ),
          ),

          // Main Dashboard Body with Sidebar & Content
          Expanded(
            child: dashVM.isLoading || kpi == null
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Navigation Sidebar
                      Container(
                        width: 200,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F172A),
                          border: Border(right: BorderSide(color: Color(0xFF1E293B))),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: Column(
                          children: [
                            _buildSidebarTab('overview', 'Overview', Icons.dashboard_rounded),
                            _buildSidebarTab('orders', 'Live Orders', Icons.receipt_long_rounded),
                            _buildSidebarTab('menu', 'Menu Analytics', Icons.restaurant_menu_rounded),
                            _buildSidebarTab('tables', 'Tables & Kiosks', Icons.table_bar_rounded),
                            _buildSidebarTab('staff', 'Staff & Waiters', Icons.people_alt_rounded),
                          ],
                        ),
                      ),

                      // Right Analytics Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // KPI Stat Cards Row
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isMobile = constraints.maxWidth < 700;
                                  return GridView.count(
                                    crossAxisCount: isMobile ? 2 : 4,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.5,
                                    children: [
                                      _buildKpiCard(
                                        title: "Today's Gross Sales",
                                        value: '${AppConstants.currencySymbol}${kpi.todaysSales.toStringAsFixed(0)}',
                                        trend: '+14.2% vs yesterday',
                                        icon: Icons.payments_rounded,
                                        color: const Color(0xFF10B981),
                                      ),
                                      _buildKpiCard(
                                        title: 'Total Orders',
                                        value: '${kpi.totalOrders}',
                                        trend: 'Avg prep: 12.4m',
                                        icon: Icons.receipt_long_rounded,
                                        color: const Color(0xFF38BDF8),
                                      ),
                                      _buildKpiCard(
                                        title: 'Average Order Value',
                                        value: '${AppConstants.currencySymbol}${kpi.averageOrderValue.toStringAsFixed(0)}',
                                        trend: 'Per-table ticket',
                                        icon: Icons.trending_up_rounded,
                                        color: const Color(0xFFF59E0B),
                                      ),
                                      _buildKpiCard(
                                        title: 'Diner Satisfaction',
                                        value: '⭐ ${kpi.averageRating.toStringAsFixed(1)} / 5',
                                        trend: '98% Positive',
                                        icon: Icons.star_rounded,
                                        color: const Color(0xFFA855F7),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 28),

                              // Best Selling Dishes & Profitability Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF1E293B)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '🔥 Best-Selling Dishes & Margin Profitability',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        Text(
                                          'Sorted by contribution margin',
                                          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), fontSize: 12),
                                        dataTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
                                        columns: const [
                                          DataColumn(label: Text('Dish Name')),
                                          DataColumn(label: Text('Orders Placed')),
                                          DataColumn(label: Text('Gross Revenue')),
                                          DataColumn(label: Text('Contribution Margin')),
                                        ],
                                        rows: kpi.bestSellingDishes.map((dish) {
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(dish.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                                              DataCell(Text('${dish.orders}')),
                                              DataCell(Text('${AppConstants.currencySymbol}${dish.revenue.toStringAsFixed(0)}')),
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.accent.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: AppTheme.accent),
                                                  ),
                                                  child: Text(
                                                    '${dish.margin.contains('%') ? dish.margin : '${dish.margin}%'} Margin',
                                                    style: const TextStyle(
                                                      color: AppTheme.accent,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                    ),
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarTab(String key, String label, IconData icon) {
    final isActive = _activeTab == key;
    return InkWell(
      onTap: () => setState(() => _activeTab = key),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6366F1).withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF6366F1) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? const Color(0xFF818CF8) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
    required String trend,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
