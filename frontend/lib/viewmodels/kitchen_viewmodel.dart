import 'package:flutter/foundation.dart';
import 'package:smart_kiosk/models/order.dart';
import 'package:smart_kiosk/models/menu_item.dart';
import 'package:smart_kiosk/services/api_service.dart';

class KitchenViewModel extends ChangeNotifier {
  final ApiService _apiService;
  List<OrderModel> _orders = [];
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  KitchenViewModel({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  List<OrderModel> get orders => _orders;
  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<OrderModel> get newOrders => _orders.where((o) => o.status == 'NEW').toList();
  List<OrderModel> get preparingOrders => _orders.where((o) => o.status == 'PREPARING').toList();
  List<OrderModel> get readyOrders => _orders.where((o) => o.status == 'READY').toList();

  Future<void> loadKDS() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedOrders = await _apiService.getOrders();
      final fetchedItems = await _apiService.getMenuItems();
      _orders = fetchedOrders;
      _menuItems = fetchedItems;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> bumpOrderStatus(String orderId, String nextStatus) async {
    try {
      final updated = await _apiService.updateOrderStatus(orderId, nextStatus);
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx >= 0) {
        _orders[idx] = updated;
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleItemStock(String itemId) async {
    try {
      final success = await _apiService.toggleItemAvailability(itemId);
      if (success) {
        final idx = _menuItems.indexWhere((i) => i.id == itemId);
        if (idx >= 0) {
          final cur = _menuItems[idx];
          _menuItems[idx] = MenuItem(
            id: cur.id,
            categoryId: cur.categoryId,
            name: cur.name,
            nameTamil: cur.nameTamil,
            price: cur.price,
            imageUrl: cur.imageUrl,
            isVeg: cur.isVeg,
            isAvailable: !cur.isAvailable,
          );
        }
        notifyListeners();
      }
      return success;
    } catch (_) {
      return false;
    }
  }
}

