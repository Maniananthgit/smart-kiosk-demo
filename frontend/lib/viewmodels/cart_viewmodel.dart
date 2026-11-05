import 'package:flutter/foundation.dart';
import 'package:smart_kiosk/core/constants/app_constants.dart';
import 'package:smart_kiosk/models/cart_item.dart';
import 'package:smart_kiosk/models/menu_item.dart';
import 'package:smart_kiosk/models/order.dart';
import 'package:smart_kiosk/services/api_service.dart';

class CartViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final List<CartItem> _items = [];

  double _tipPercent = 0.0;
  int _splitDinerCount = 1;
  String _paymentMethod = 'UPI'; // UPI, CARD, CASH
  bool _isSubmitting = false;
  String? _errorMessage;

  CartViewModel({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  bool get isEmpty => _items.isEmpty;

  double get tipPercent => _tipPercent;
  int get splitDinerCount => _splitDinerCount;
  String get paymentMethod => _paymentMethod;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.subtotal);
  double get tax => subtotal * (AppConstants.taxRatePercent / 100.0);
  double get tipAmount => subtotal * (_tipPercent / 100.0);
  double get total => subtotal + tax + tipAmount;
  double get splitAmountPerDiner => _splitDinerCount > 0 ? (total / _splitDinerCount) : total;

  void addToCart(
    MenuItem item, {
    int quantity = 1,
    String spiceLevel = 'Medium',
    List<String> customizations = const [],
    String specialInstructions = '',
  }) {
    // Check if an identical configured item exists
    final existingIndex = _items.indexWhere(
      (i) =>
          i.item.id == item.id &&
          i.spiceLevel == spiceLevel &&
          listEquals(i.customizations, customizations) &&
          i.specialInstructions == specialInstructions,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          id: '${item.id}-${DateTime.now().millisecondsSinceEpoch}',
          item: item,
          quantity: quantity,
          spiceLevel: spiceLevel,
          customizations: List.from(customizations),
          specialInstructions: specialInstructions,
        ),
      );
    }
    notifyListeners();
  }

  void incrementQuantity(String cartItemId) {
    final item = _items.firstWhere((i) => i.id == cartItemId);
    item.quantity++;
    notifyListeners();
  }

  void decrementQuantity(String cartItemId) {
    final index = _items.indexWhere((i) => i.id == cartItemId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((i) => i.id == cartItemId);
    notifyListeners();
  }

  void setTipPercent(double percent) {
    _tipPercent = percent;
    notifyListeners();
  }

  void setSplitDinerCount(int diners) {
    _splitDinerCount = diners.clamp(1, 10);
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _tipPercent = 0.0;
    _splitDinerCount = 1;
    _errorMessage = null;
    notifyListeners();
  }

  Future<OrderModel?> submitOrder(int tableNumber) async {
    if (_items.isEmpty) return null;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final orderPayload = {
        'table_number': tableNumber,
        'items': _items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'tip': tipAmount,
        'total': total,
        'payment_method': _paymentMethod,
        'split_bill_details': {
          'diners': _splitDinerCount,
          'perDiner': splitAmountPerDiner,
        },
      };

      final placedOrder = await _apiService.createOrder(orderPayload);
      clearCart();
      _isSubmitting = false;
      notifyListeners();
      return placedOrder;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return null;
    }
  }
}

