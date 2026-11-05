class Combo {
  final String id;
  final String title;
  final String? titleTamil;
  final String? description;
  final double discountAmount;
  final String badgeText;
  final List<String> itemIds;
  final bool isActive;

  Combo({
    required this.id,
    required this.title,
    this.titleTamil,
    this.description,
    this.discountAmount = 40.0,
    this.badgeText = 'Save ₹40',
    this.itemIds = const [],
    this.isActive = true,
  });

  factory Combo.fromJson(Map<String, dynamic> json) {
    return Combo(
      id: json['id'] as String,
      title: json['title'] as String,
      titleTamil: json['title_tamil'] as String?,
      description: json['description'] as String?,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 40.0,
      badgeText: json['badge_text'] as String? ?? 'Save ₹40',
      itemIds: (json['item_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

