import 'package:flutter/foundation.dart';
import 'package:smart_kiosk/models/user.dart';
import 'package:smart_kiosk/services/api_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final ApiService _apiService;
  KPISummaryModel? _kpiSummary = KPISummaryModel(
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
  List<WaiterCallModel> _waiterCalls = [];
  bool _isLoading = false;
  String? _errorMessage;

  DashboardViewModel({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  KPISummaryModel? get kpiSummary => _kpiSummary;
  List<WaiterCallModel> get waiterCalls => _waiterCalls;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final kpi = await _apiService.getKPIs();
      final calls = await _apiService.getWaiterCalls();
      _kpiSummary = kpi;
      _waiterCalls = calls;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> resolveWaiterCall(String callId) async {
    try {
      final success = await _apiService.resolveWaiterCall(callId);
      if (success) {
        _waiterCalls.removeWhere((c) => c.id == callId);
        notifyListeners();
      }
      return success;
    } catch (_) {
      return false;
    }
  }
}

