class OrderItemModel {
  final String id;
  final String? menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String spiceLevel;
  final List<String> customizations;
  final String specialInstructions;
  final String? imageUrl;
  final bool isVeg;

  OrderItemModel({
    required this.id,
    this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.spiceLevel,
    this.customizations = const [],
    this.specialInstructions = '',
    this.imageUrl,
    this.isVeg = true,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      menuItemId: json['menu_item_id'] as String?,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      spiceLevel: json['spice_level'] as String? ?? 'Medium',
      customizations: (json['customizations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      specialInstructions: json['special_instructions'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      isVeg: json['is_veg'] as bool? ?? true,
    );
  }
}

class OrderModel {
  final String id;
  final int orderNumber;
  final int tableNumber;
  final double subtotal;
  final double tax;
  final double tip;
  final double total;
  final String status; // NEW, PREPARING, READY, COMPLETED, CANCELLED
  final String paymentStatus;
  final String paymentMethod;
  final Map<String, dynamic>? splitBillDetails;
  final String createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.tableNumber,
    required this.subtotal,
    required this.tax,
    required this.tip,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.splitBillDetails,
    required this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['order_number'] as int? ?? 0,
      tableNumber: json['table_number'] as int? ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      tip: (json['tip'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'NEW',
      paymentStatus: json['payment_status'] as String? ?? 'PAID',
      paymentMethod: json['payment_method'] as String? ?? 'UPI',
      splitBillDetails: json['split_bill_details'] as Map<String, dynamic>?,
      createdAt: json['created_at'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

