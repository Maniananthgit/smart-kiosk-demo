import 'package:flutter/foundation.dart' hide Category;
import 'package:smart_kiosk/models/category.dart';
import 'package:smart_kiosk/models/menu_item.dart';
import 'package:smart_kiosk/models/combo.dart';
import 'package:smart_kiosk/services/api_service.dart';

class KioskViewModel extends ChangeNotifier {
  final ApiService _apiService;

  List<Category> _categories = [];
  String? _selectedCategoryId;
  List<MenuItem> _menuItems = [];
  List<Combo> _combos = [];

  int _tableNumber = 12;
  String _selectedLanguage = 'en'; // en, ta, hi, te, es
  bool _isVegOnly = false;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  KioskViewModel({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  List<Category> get categories => _categories;
  String? get selectedCategoryId => _selectedCategoryId;
  List<Combo> get combos => _combos;
  int get tableNumber => _tableNumber;
  String get selectedLanguage => _selectedLanguage;
  bool get isVegOnly => _isVegOnly;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<MenuItem> get filteredItems {
    return _menuItems.where((item) {
      if (_selectedCategoryId != null && item.categoryId != _selectedCategoryId) {
        return false;
      }
      if (_isVegOnly && !item.isVeg) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatches = item.name.toLowerCase().contains(q) ||
            (item.nameTamil != null && item.nameTamil!.contains(q));
        if (!nameMatches) return false;
      }
      return true;
    }).toList();
  }

  void setTableNumber(int number) {
    _tableNumber = number;
    notifyListeners();
  }

  void setLanguage(String langCode) {
    _selectedLanguage = langCode;
    notifyListeners();
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void toggleVegOnly() {
    _isVegOnly = !_isVegOnly;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedCategories = await _apiService.getCategories();
      final fetchedItems = await _apiService.getMenuItems();
      final fetchedCombos = await _apiService.getCombos();

      _categories = fetchedCategories;
      _menuItems = fetchedItems;
      _combos = fetchedCombos;

      if (_categories.isNotEmpty && _selectedCategoryId == null) {
        _selectedCategoryId = _categories.first.id;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> sendWaiterCall(String callType) async {
    try {
      await _apiService.callWaiter(_tableNumber, callType);
      return true;
    } catch (_) {
      return false;
    }
  }
}
