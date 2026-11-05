class UserModel {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      role: json['role'] as String? ?? 'STAFF',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class WaiterCallModel {
  final String id;
  final int tableNumber;
  final String callType;
  final String status; // PENDING, ACKNOWLEDGED, RESOLVED
  final String createdAt;

  WaiterCallModel({
    required this.id,
    required this.tableNumber,
    required this.callType,
    required this.status,
    required this.createdAt,
  });

  factory WaiterCallModel.fromJson(Map<String, dynamic> json) {
    return WaiterCallModel(
      id: json['id'] as String? ?? '',
      tableNumber: json['table_number'] as int? ?? 0,
      callType: json['call_type'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class FeedbackModel {
  final String id;
  final int orderNumber;
  final int tableNumber;
  final int rating;
  final List<String> tags;
  final String? comment;
  final String createdAt;

  FeedbackModel({
    required this.id,
    required this.orderNumber,
    required this.tableNumber,
    required this.rating,
    this.tags = const [],
    this.comment,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['order_number'] as int? ?? 0,
      tableNumber: json['table_number'] as int? ?? 0,
      rating: json['rating'] as int? ?? 5,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      comment: json['comment'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class BestSellingDishModel {
  final String name;
  final int orders;
  final double revenue;
  final String margin;

  BestSellingDishModel({
    required this.name,
    required this.orders,
    required this.revenue,
    required this.margin,
  });

  factory BestSellingDishModel.fromJson(Map<String, dynamic> json) {
    return BestSellingDishModel(
      name: json['name'] as String? ?? '',
      orders: json['orders'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      margin: json['margin'] as String? ?? '40%',
    );
  }
}

class KPISummaryModel {
  final double todaysSales;
  final int totalOrders;
  final double averageOrderValue;
  final double averageRating;
  final List<BestSellingDishModel> bestSellingDishes;

  KPISummaryModel({
    required this.todaysSales,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.averageRating,
    required this.bestSellingDishes,
  });

  factory KPISummaryModel.fromJson(Map<String, dynamic> json) {
    return KPISummaryModel(
      todaysSales: (json['todays_sales'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['total_orders'] as int? ?? 0,
      averageOrderValue: (json['average_order_value'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 4.8,
      bestSellingDishes: (json['best_selling_dishes'] as List<dynamic>?)
              ?.map((d) => BestSellingDishModel.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

