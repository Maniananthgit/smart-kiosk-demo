import 'package:flutter/foundation.dart';
import 'package:smart_kiosk/core/security/secure_storage_service.dart';
import 'package:smart_kiosk/services/api_service.dart';

class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final SecureStorageService _storage;

  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  String? _role;
  String? _username;

  AuthViewModel({ApiService? apiService, SecureStorageService? storage})
      : _apiService = apiService ?? ApiService(),
        _storage = storage ?? SecureStorageService() {
    _initAuth();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  String? get role => _role;
  String? get username => _username;
  bool get isAdmin => _role == 'ADMIN';
  bool get isKitchen => _role == 'KITCHEN' || _role == 'ADMIN';

  Future<void> _initAuth() async {
    _token = await _storage.getAuthToken();
    _role = await _storage.getUserRole();
    _username = await _storage.getUsername();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.login(username, password);
      _token = res['access_token'];
      _role = res['role'];
      _username = res['username'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return false;
    }
  }

  Future<bool> secureLoginWithRSA(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.secureLogin(username, password);
      _token = res['access_token'];
      _role = res['role'];
      _username = res['username'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearAuthToken();
    _token = null;
    _role = null;
    _username = null;
    notifyListeners();
  }
}

