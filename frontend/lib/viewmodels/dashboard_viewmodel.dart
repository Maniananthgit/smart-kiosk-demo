import 'package:flutter/foundation.dart';
import 'package:smart_kiosk/models/user.dart';
import 'package:smart_kiosk/services/api_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final ApiService _apiService;
  KPISummaryModel? _kpiSummary;
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

