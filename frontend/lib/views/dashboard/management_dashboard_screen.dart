import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_kiosk/core/constants/app_constants.dart';
import 'package:smart_kiosk/core/theme/app_theme.dart';
import 'package:smart_kiosk/models/user.dart';
import 'package:smart_kiosk/viewmodels/dashboard_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/kitchen_viewmodel.dart';
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
      context.read<KitchenViewModel>().loadKDS();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashVM = context.watch<DashboardViewModel>();
    final kitchenVM = context.watch<KitchenViewModel>();
    final kpi = dashVM.kpiSummary ??
        KPISummaryModel(
          todaysSales: 48820.0,
          totalOrders: 148,
          averageOrderValue: 329.0,
          averageRating: 4.8,
          bestSellingDishes: [
            BestSellingDishModel(name: 'Butter Chicken', orders: 48, revenue: 15360, margin: '38%'),
            BestSellingDishModel(name: 'Paneer Tikka', orders: 42, revenue: 11760, margin: '42%'),
            BestSellingDishModel(name: 'Hyderabadi Mutton Biryani', orders: 51, revenue: 21420, margin: '41%'),
            BestSellingDishModel(name: 'Garlic Butter Naan', orders: 92, revenue: 6900, margin: '63%'),
            BestSellingDishModel(name: 'Cold Coffee Frappé', orders: 58, revenue: 8120, margin: '58%'),
            BestSellingDishModel(name: 'Gulab Jamun with Ice Cream', orders: 41, revenue: 5330, margin: '62%'),
          ],
        );

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                      SizedBox(width: 6),
                      Text(
                        'Live Cloud Sync',
                        style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.white70),
                  onPressed: () {
                    dashVM.loadDashboard();
                    kitchenVM.loadKDS();
                  },
                  tooltip: 'Refresh Analytics',
                ),
              ],
            ),
          ),

          // Main Dashboard Body with Sidebar & Content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Navigation Sidebar
                Container(
                  width: 210,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    border: Border(right: BorderSide(color: Color(0xFF1E293B))),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Column(
                    children: [
                      _buildSidebarTab('overview', 'Overview', Icons.dashboard_rounded),
                      _buildSidebarTab('orders', 'Live Orders (${kitchenVM.orders.length})', Icons.receipt_long_rounded),
                      _buildSidebarTab('menu', 'Menu Analytics', Icons.restaurant_menu_rounded),
                      _buildSidebarTab('tables', 'Tables & Kiosks', Icons.table_bar_rounded),
                      _buildSidebarTab('staff', 'Staff & Waiters (${dashVM.waiterCalls.length})', Icons.people_alt_rounded),
                    ],
                  ),
                ),

                // Right Analytics Content (Switches Based on Selected Tab)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildActiveTabContent(dashVM, kitchenVM, kpi),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent(DashboardViewModel dashVM, KitchenViewModel kitchenVM, KPISummaryModel kpi) {
    switch (_activeTab) {
      case 'orders':
        return _buildLiveOrdersTab(kitchenVM);
      case 'menu':
        return _buildMenuAnalyticsTab(kpi);
      case 'tables':
        return _buildTablesAndKiosksTab();
      case 'staff':
        return _buildStaffAndWaitersTab(dashVM);
      case 'overview':
      default:
        return _buildOverviewTab(kpi, kitchenVM);
    }
  }

  // 1. OVERVIEW TAB
  Widget _buildOverviewTab(KPISummaryModel kpi, KitchenViewModel kitchenVM) {
    return Column(
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
                  title: 'Customer Satisfaction',
                  value: '${kpi.averageRating.toStringAsFixed(1)} ★',
                  trend: 'Based on 94 reviews',
                  icon: Icons.star_rounded,
                  color: const Color(0xFFA855F7),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 28),

        // Best Selling Dishes Profitability Table
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Best-Selling Dishes & Profit Margin Performance',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'High-margin contributor ranking across contemporary menu items',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  Chip(
                    label: Text('Top Performers', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                    backgroundColor: Color(0xFF020617),
                    side: BorderSide(color: Color(0xFF10B981)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 12),
                  dataTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
                  columns: const [
                    DataColumn(label: Text('Dish Name')),
                    DataColumn(label: Text('Units Sold')),
                    DataColumn(label: Text('Gross Revenue')),
                    DataColumn(label: Text('Profit Margin')),
                  ],
                  rows: kpi.bestSellingDishes.map((dish) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(dish.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        DataCell(Text('${dish.orders} orders')),
                        DataCell(
                          Text(
                            '${AppConstants.currencySymbol}${dish.revenue.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                          ),
                        ),
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

        const SizedBox(height: 28),

        // Hourly Sales & Capacity Planning Strip
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
                  Text('Peak-Hour Dining Rush Distribution', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('Occupancy: 82% Peak', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildRushBar('12 PM', 0.45, '₹6,400'),
                  _buildRushBar('1 PM', 0.90, '₹14,200'),
                  _buildRushBar('2 PM', 0.75, '₹10,800'),
                  _buildRushBar('3 PM', 0.30, '₹4,100'),
                  _buildRushBar('7 PM', 0.65, '₹9,800'),
                  _buildRushBar('8 PM', 1.00, '₹18,500'),
                  _buildRushBar('9 PM', 0.85, '₹12,600'),
                  _buildRushBar('10 PM', 0.50, '₹7,200'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. LIVE ORDERS TAB
  Widget _buildLiveOrdersTab(KitchenViewModel kitchenVM) {
    final orders = kitchenVM.orders;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Live Dining Orders Stream', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Real-time table tickets automatically routed to kitchen (${orders.length} active)', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => kitchenVM.loadKDS(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh Orders'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (orders.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16)),
            child: const Text('No active orders right now', style: TextStyle(color: Color(0xFF94A3B8))),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final o = orders[idx];
              final isReady = o.status == 'READY';
              final isPrep = o.status == 'PREPARING';
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isReady ? const Color(0xFF10B981) : (isPrep ? const Color(0xFFF59E0B) : const Color(0xFF1E293B)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA580C).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Table ${o.tableNumber}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFFB923C))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order #${o.id.substring(0, o.id.length > 8 ? 8 : o.id.length).toUpperCase()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('${o.items.length} dishes • ${o.items.map((i) => i.name).join(", ")}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isReady ? const Color(0xFF10B981) : (isPrep ? const Color(0xFFF59E0B) : const Color(0xFF6366F1))).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        o.status,
                        style: TextStyle(
                          color: isReady ? const Color(0xFF10B981) : (isPrep ? const Color(0xFFF59E0B) : const Color(0xFF818CF8)),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '${AppConstants.currencySymbol}${o.total.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // 3. MENU ANALYTICS TAB
  Widget _buildMenuAnalyticsTab(KPISummaryModel kpi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Menu Performance & Food Cost Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Contribution margins, cost prices, and sales popularity', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          padding: const EdgeInsets.all(20),
          child: DataTable(
            headingTextStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 12),
            dataTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
            columns: const [
              DataColumn(label: Text('Menu Item')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Selling Price')),
              DataColumn(label: Text('Food Cost')),
              DataColumn(label: Text('Profit Margin')),
              DataColumn(label: Text('Status')),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('Butter Chicken', style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('Main Course')),
                DataCell(Text('₹320')),
                DataCell(Text('₹198')),
                DataCell(Text('38%', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
                DataCell(Text('Active', style: TextStyle(color: Color(0xFF10B981)))),
              ]),
              DataRow(cells: [
                DataCell(Text('Paneer Tikka', style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('Starters')),
                DataCell(Text('₹280')),
                DataCell(Text('₹162')),
                DataCell(Text('42%', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
                DataCell(Text('Active', style: TextStyle(color: Color(0xFF10B981)))),
              ]),
              DataRow(cells: [
                DataCell(Text('Hyderabadi Mutton Biryani', style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('Biryani & Rice')),
                DataCell(Text('₹420')),
                DataCell(Text('₹248')),
                DataCell(Text('41%', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
                DataCell(Text('Active', style: TextStyle(color: Color(0xFF10B981)))),
              ]),
              DataRow(cells: [
                DataCell(Text('Garlic Butter Naan', style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('Tandoor & Breads')),
                DataCell(Text('₹75')),
                DataCell(Text('₹28')),
                DataCell(Text('63%', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
                DataCell(Text('Active', style: TextStyle(color: Color(0xFF10B981)))),
              ]),
              DataRow(cells: [
                DataCell(Text('Cold Coffee Frappé', style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('Beverages')),
                DataCell(Text('₹140')),
                DataCell(Text('₹58')),
                DataCell(Text('58%', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
                DataCell(Text('Active', style: TextStyle(color: Color(0xFF10B981)))),
              ]),
              DataRow(cells: [
                DataCell(Text('Gulab Jamun with Ice Cream', style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('Desserts')),
                DataCell(Text('₹130')),
                DataCell(Text('₹50')),
                DataCell(Text('62%', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
                DataCell(Text('Active', style: TextStyle(color: Color(0xFF10B981)))),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  // 4. TABLES & KIOSKS TAB
  Widget _buildTablesAndKiosksTab() {
    final tables = [
      {'id': 1, 'status': 'OCCUPIED', 'diners': 4, 'waiter': 'Rajesh', 'zone': 'Zone A'},
      {'id': 2, 'status': 'AVAILABLE', 'diners': 0, 'waiter': 'Rajesh', 'zone': 'Zone A'},
      {'id': 4, 'status': 'OCCUPIED', 'diners': 2, 'waiter': 'Rajesh', 'zone': 'Zone A'},
      {'id': 6, 'status': 'AVAILABLE', 'diners': 0, 'waiter': 'Priya', 'zone': 'Zone B'},
      {'id': 8, 'status': 'OCCUPIED', 'diners': 6, 'waiter': 'Priya', 'zone': 'Zone B'},
      {'id': 12, 'status': 'OCCUPIED', 'diners': 3, 'waiter': 'Rajesh', 'zone': 'Zone A'},
      {'id': 14, 'status': 'AVAILABLE', 'diners': 0, 'waiter': 'Suresh', 'zone': 'Zone C'},
      {'id': 16, 'status': 'BILL_REQUESTED', 'diners': 4, 'waiter': 'Suresh', 'zone': 'Zone C'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Floor Plan & Table Kiosk Fleet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Real-time occupancy and assigned waiter zones', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.3,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: tables.length,
          itemBuilder: (context, idx) {
            final t = tables[idx];
            final isOcc = t['status'] == 'OCCUPIED';
            final isBill = t['status'] == 'BILL_REQUESTED';
            final color = isBill ? const Color(0xFFF59E0B) : (isOcc ? const Color(0xFF10B981) : const Color(0xFF64748B));

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Table ${t['id']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('${t['status']}', style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Server: ${t['waiter']} • ${t['zone']}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(isOcc ? '${t['diners']} guests seated' : 'Ready for guests', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 5. STAFF & WAITERS TAB
  Widget _buildStaffAndWaitersTab(DashboardViewModel dashVM) {
    final calls = dashVM.waiterCalls;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Staff Rosters & Live Assistance Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Pending diner call requests and waiter assignments', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        const SizedBox(height: 20),

        // Live Alerts
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 8),
                  Text('Active Service Requests (${calls.length})', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 14),
              if (calls.isEmpty)
                const Text('All diner requests attended to.', style: TextStyle(color: Color(0xFF94A3B8)))
              else
                ...calls.map((c) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF020617),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.room_service_rounded, color: Color(0xFFF59E0B), size: 16),
                          const SizedBox(width: 10),
                          Text('Table ${c.tableNumber}: ${c.callType}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          const Spacer(),
                          TextButton(
                            onPressed: () => dashVM.resolveWaiterCall(c.id),
                            child: const Text('Mark Resolved', style: TextStyle(color: Color(0xFF10B981))),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Waiter Roster
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Waiter Roster & Zone Allocations', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: Color(0xFF6366F1), child: Text('RK', style: TextStyle(color: Colors.white))),
                title: Text('Rajesh Kumar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('Zone A (Tables 1-5, 12) • 4 orders served • Avg response: 1.8 mins', style: TextStyle(color: Color(0xFF94A3B8))),
                trailing: Chip(label: Text('On Duty', style: TextStyle(color: Color(0xFF10B981))), backgroundColor: Color(0xFF020617)),
              ),
              Divider(color: Color(0xFF1E293B)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: Color(0xFFEC4899), child: Text('PS', style: TextStyle(color: Colors.white))),
                title: Text('Priya Sharma', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('Zone B (Tables 6-10) • 6 orders served • Avg response: 2.1 mins', style: TextStyle(color: Color(0xFF94A3B8))),
                trailing: Chip(label: Text('On Duty', style: TextStyle(color: Color(0xFF10B981))), backgroundColor: Color(0xFF020617)),
              ),
              Divider(color: Color(0xFF1E293B)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: Color(0xFF10B981), child: Text('SM', style: TextStyle(color: Colors.white))),
                title: Text('Suresh Menon', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('Zone C (Tables 11-16) • 5 orders served • Avg response: 1.5 mins', style: TextStyle(color: Color(0xFF10B981))),
                trailing: Chip(label: Text('On Duty', style: TextStyle(color: Color(0xFF10B981))), backgroundColor: Color(0xFF020617)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRushBar(String hour, double fraction, String revenue) {
    return Expanded(
      child: Column(
        children: [
          Text(revenue, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          const SizedBox(height: 6),
          Container(
            height: 90,
            width: 24,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Container(
              height: 90 * fraction,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(hour, style: const TextStyle(fontSize: 11, color: Colors.white70)),
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
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
