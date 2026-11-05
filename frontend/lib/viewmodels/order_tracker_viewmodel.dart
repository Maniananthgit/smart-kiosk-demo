import 'package:flutter/foundation.dart';
import 'package:smart_kiosk/models/order.dart';
import 'package:smart_kiosk/services/api_service.dart';

class OrderTrackerViewModel extends ChangeNotifier {
  final ApiService _apiService;
  OrderModel? _order;
  bool _isLoading = false;
  bool _feedbackSubmitted = false;
  String? _errorMessage;

  OrderTrackerViewModel({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  OrderModel? get order => _order;
  bool get isLoading => _isLoading;
  bool get feedbackSubmitted => _feedbackSubmitted;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _order = await _apiService.getOrderById(orderId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_order == null) return;
    try {
      _order = await _apiService.getOrderById(_order!.id);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> submitFeedback({
    required int rating,
    List<String> tags = const [],
    String? comment,
  }) async {
    if (_order == null) return false;

    try {
      final success = await _apiService.submitFeedback(
        orderNumber: _order!.orderNumber,
        tableNumber: _order!.tableNumber,
        rating: rating,
        tags: tags,
        comment: comment,
      );
      if (success) {
        _feedbackSubmitted = true;
        notifyListeners();
      }
      return success;
    } catch (_) {
      return false;
    }
  }
}

