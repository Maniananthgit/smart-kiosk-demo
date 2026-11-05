import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:smart_kiosk/core/constants/app_constants.dart';
import 'package:smart_kiosk/core/security/rsa_crypto_service.dart';
import 'package:smart_kiosk/core/security/secure_storage_service.dart';
import 'package:smart_kiosk/models/category.dart';
import 'package:smart_kiosk/models/menu_item.dart';
import 'package:smart_kiosk/models/combo.dart';
import 'package:smart_kiosk/models/order.dart';
import 'package:smart_kiosk/models/user.dart';

class ApiService {
  final String baseUrl;
  final SecureStorageService storage;
  final http.Client client;

  ApiService({
    String? baseUrl,
    SecureStorageService? storage,
    http.Client? client,
  })  : baseUrl = baseUrl ?? AppConstants.apiBaseUrl,
        storage = storage ?? SecureStorageService(),
        client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await storage.getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ==================== AUTH & RSA ====================
  Future<String> fetchRSAPublicKey() async {
    final response = await client.get(
      Uri.parse('$baseUrl/auth/rsa-public-key'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['public_key'] as String;
    }
    throw Exception('Failed to fetch RSA public key: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _getHeaders(),
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.saveAuthToken(
        data['access_token'] as String,
        data['role'] as String,
        data['username'] as String,
      );
      return data;
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Login failed');
  }

  Future<Map<String, dynamic>> secureLogin(String username, String password) async {
    // 1. Fetch server RSA 2048-bit Public Key
    final publicKeyPem = await fetchRSAPublicKey();

    // 2. Encrypt credentials payload using RSA
    final rawJson = jsonEncode({'username': username, 'password': password});
    final encryptedBase64 = RSACryptoService.encryptPayload(rawJson, publicKeyPem);

    // 3. Post RSA ciphertext to backend
    final response = await client.post(
      Uri.parse('$baseUrl/auth/secure-login'),
      headers: await _getHeaders(),
      body: jsonEncode({'encrypted_payload': encryptedBase64}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.saveAuthToken(
        data['access_token'] as String,
        data['role'] as String,
        data['username'] as String,
      );
      return data;
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Secure login failed');
  }

  // ==================== MENU & CATEGORIES ====================
  Future<List<Category>> getCategories() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/menu/categories'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((json) => Category.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    // Fallback seed categories
    return [
      Category(id: 'c1', slug: 'starters', name: 'Starters', nameTamil: 'தொடக்க உணவு', displayOrder: 1, icon: 'flame'),
      Category(id: 'c2', slug: 'biryani', name: 'Biryani & Rice', nameTamil: 'பிரியாணி & சாதம்', displayOrder: 2, icon: 'soup'),
      Category(id: 'c3', slug: 'mains', name: 'Main Course', nameTamil: 'முக்கிய உணவு', displayOrder: 3, icon: 'restaurant'),
      Category(id: 'c4', slug: 'tandoor', name: 'Tandoor & Breads', nameTamil: 'தந்தூரி ரொட்டி', displayOrder: 4, icon: 'bakery_dining'),
      Category(id: 'c5', slug: 'desserts', name: 'Desserts & Drinks', nameTamil: 'இனிப்பு & பானங்கள்', displayOrder: 5, icon: 'local_cafe'),
    ];
  }

  Future<List<MenuItem>> getMenuItems({String? categoryId, bool? isVeg, String? search}) async {
    try {
      var uri = Uri.parse('$baseUrl/menu/items');
      final queryParams = <String, String>{};
      if (categoryId != null && categoryId.isNotEmpty) queryParams['category_id'] = categoryId;
      if (isVeg != null) queryParams['is_veg'] = isVeg.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await client.get(uri, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    // Fallback seed menu items
    return [
      MenuItem(
        id: 'm1',
        categoryId: 'c3',
        name: 'Butter Chicken',
        nameTamil: 'பட்டர் சிக்கன்',
        description: 'Tender tandoori chicken simmered in a silky, rich makhani gravy infused with butter and kasuri methi.',
        descriptionTamil: 'வெண்ணெய் மற்றும் மென்மையான தக்காளி கிரேவியில் சமைக்கப்பட்ட தந்தூரி சிக்கன்.',
        price: 320.0,
        imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80',
        isVeg: false,
        isSpicy: true,
        isSignature: true,
        popularityCount: 148,
        customizationOptions: ['Extra Gravy', 'Boneless Only', 'Butter Drizzle'],
      ),
      MenuItem(
        id: 'm2',
        categoryId: 'c1',
        name: 'Paneer Tikka',
        nameTamil: 'பன்னீர் டிக்கா',
        description: 'Fresh cottage cheese cubes marinated in spiced yogurt and grilled in traditional clay tandoor.',
        descriptionTamil: 'தயிர் மசாலா கலவையில் ஊறிய சுவையான தந்தூரி பன்னீர் மற்றும் குடைமிளகாய்.',
        price: 280.0,
        imageUrl: 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?auto=format&fit=crop&w=800&q=80',
        isVeg: true,
        isSpicy: true,
        isSignature: true,
        popularityCount: 112,
        customizationOptions: ['Mint Chutney Extra', 'Less Spicy', 'Well Roasted'],
      ),
      MenuItem(
        id: 'm3',
        categoryId: 'c2',
        name: 'Hyderabadi Mutton Biryani',
        nameTamil: 'ஹைதராபாதி மட்டன் பிரியாணி',
        description: 'Fragrant aged basmati rice layered with succulent goat meat, slow-cooked on dum with royal saffron.',
        descriptionTamil: 'நறுமண பாசுமதி அரிசியுடன் மென்மையான ஆட்டிறைச்சி சேர்த்து தம் முறையில் சமைக்கப்பட்ட ராஜ பிரியாணி.',
        price: 420.0,
        imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80',
        isVeg: false,
        isSpicy: true,
        isSignature: true,
        popularityCount: 180,
        customizationOptions: ['Mirchi Ka Salan', 'Extra Raita', 'Double Egg'],
      ),
      MenuItem(
        id: 'm4',
        categoryId: 'c4',
        name: 'Garlic Butter Naan',
        nameTamil: 'பூண்டு வெண்ணெய் நான்',
        description: 'Soft leavened clay oven bread topped with crushed minced garlic and glazed with melted artisan butter.',
        descriptionTamil: 'தந்தூரி அடுப்பில் சுடப்பட்டு நறுக்கிய பூண்டு மற்றும் வெண்ணெய் பூசப்பட்ட மென்மையான நான்.',
        price: 75.0,
        imageUrl: 'https://images.unsplash.com/photo-1626074353765-517a681e40be?auto=format&fit=crop&w=800&q=80',
        isVeg: true,
        isSpicy: false,
        isSignature: false,
        popularityCount: 210,
        customizationOptions: ['Crispy', 'Extra Butter', 'Without Coriander'],
      ),
      MenuItem(
        id: 'm5',
        categoryId: 'c5',
        name: 'Royal Mango Kulfi',
        nameTamil: 'ராயல் மாம்பழ குல்பி',
        description: 'Slow-reduced thickened milk infused with Alphonso mango pulp, saffron, cardamom, and sliced pistachios.',
        descriptionTamil: 'அல்போன்சா மாம்பழக்கூழ், குங்குமப்பூ மற்றும் பிஸ்தா கலந்த பாரம்பரிய சுவையான குல்பி ஐஸ்கிரீம்.',
        price: 160.0,
        imageUrl: 'https://images.unsplash.com/photo-1579954115545-a95591f28bfc?auto=format&fit=crop&w=800&q=80',
        isVeg: true,
        isSpicy: false,
        isSignature: true,
        popularityCount: 95,
        customizationOptions: ['Extra Dryfruits', 'Rose Syrup'],
      ),
    ];
  }

  Future<List<Combo>> getCombos() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/menu/combos'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((json) => Combo.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    return [
      Combo(
        id: 'combo1',
        title: 'Royal Biryani Feast',
        titleTamil: 'ராஜ பிரியாணி விருந்து',
        description: 'Pair Hyderabadi Mutton Biryani with Garlic Butter Naan & Mango Kulfi',
        discountAmount: 55.0,
        badgeText: 'Save ₹55',
        itemIds: ['m3', 'm4', 'm5'],
      ),
    ];
  }

  Future<bool> toggleItemAvailability(String itemId) async {
    final response = await client.patch(
      Uri.parse('$baseUrl/menu/items/$itemId/toggle-availability'),
      headers: await _getHeaders(auth: true),
    );
    return response.statusCode == 200;
  }

  // ==================== ORDERS ====================
  Future<OrderModel> createOrder(Map<String, dynamic> orderPayload) async {
    final response = await client.post(
      Uri.parse('$baseUrl/orders/'),
      headers: await _getHeaders(),
      body: jsonEncode(orderPayload),
    );
    if (response.statusCode == 200) {
      return OrderModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to place order: ${response.statusCode}');
  }

  Future<List<OrderModel>> getOrders({String? status, int? tableNumber}) async {
    var uri = Uri.parse('$baseUrl/orders/');
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (tableNumber != null) queryParams['table_number'] = tableNumber.toString();
    if (queryParams.isNotEmpty) uri = uri.replace(queryParameters: queryParams);

    final response = await client.get(uri, headers: await _getHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((item) => OrderModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<OrderModel> getOrderById(String orderId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return OrderModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Order not found');
  }

  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    final response = await client.patch(
      Uri.parse('$baseUrl/orders/$orderId/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode == 200) {
      return OrderModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update order status');
  }

  // ==================== WAITER CALLS ====================
  Future<WaiterCallModel> callWaiter(int tableNumber, String callType) async {
    final response = await client.post(
      Uri.parse('$baseUrl/waiter/call'),
      headers: await _getHeaders(),
      body: jsonEncode({'table_number': tableNumber, 'call_type': callType}),
    );
    if (response.statusCode == 200) {
      return WaiterCallModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to alert waiter');
  }

  Future<List<WaiterCallModel>> getWaiterCalls({String? status}) async {
    var uri = Uri.parse('$baseUrl/waiter/calls');
    if (status != null) uri = uri.replace(queryParameters: {'status': status});
    final response = await client.get(uri, headers: await _getHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((json) => WaiterCallModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<bool> resolveWaiterCall(String callId) async {
    final response = await client.patch(
      Uri.parse('$baseUrl/waiter/calls/$callId/resolve'),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200;
  }

  // ==================== FEEDBACK ====================
  Future<bool> submitFeedback({
    required int orderNumber,
    required int tableNumber,
    required int rating,
    List<String> tags = const [],
    String? comment,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/feedback/'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'order_number': orderNumber,
        'table_number': tableNumber,
        'rating': rating,
        'tags': tags,
        'comment': comment,
      }),
    );
    return response.statusCode == 200;
  }

  // ==================== ANALYTICS ====================
  Future<KPISummaryModel> getKPIs() async {
    final response = await client.get(
      Uri.parse('$baseUrl/analytics/kpis'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return KPISummaryModel.fromJson(jsonDecode(response.body));
    }
    return KPISummaryModel(
      todaysSales: 48620.0,
      totalOrders: 148,
      averageOrderValue: 328.0,
      averageRating: 4.8,
      bestSellingDishes: [
        BestSellingDishModel(name: 'Butter Chicken', orders: 48, revenue: 15360, margin: '38%'),
        BestSellingDishModel(name: 'Paneer Tikka', orders: 42, revenue: 11760, margin: '42%'),
        BestSellingDishModel(name: 'Hyderabadi Mutton Biryani', orders: 51, revenue: 21420, margin: '41%'),
      ],
    );
  }
}

