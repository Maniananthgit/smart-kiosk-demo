class MenuItem {
  final String id;
  final String categoryId;
  final String name;
  final String? nameTamil;
  final String? nameHindi;
  final String? nameTelugu;
  final String? nameSpanish;
  final String? description;
  final String? descriptionTamil;
  final double price;
  final double costPrice;
  final int marginPercent;
  final int prepTimeMinutes;
  final String? imageUrl;
  final bool isVeg;
  final bool isSpicy;
  final bool isSignature;
  final bool isAvailable;
  final double rating;
  final int calories;
  final List<String> allergens;
  final List<String> customizationOptions;
  final int popularityCount;

  MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    this.nameTamil,
    this.nameHindi,
    this.nameTelugu,
    this.nameSpanish,
    this.description,
    this.descriptionTamil,
    required this.price,
    this.costPrice = 0.0,
    this.marginPercent = 40,
    this.prepTimeMinutes = 12,
    this.imageUrl,
    this.isVeg = true,
    this.isSpicy = false,
    this.isSignature = false,
    this.isAvailable = true,
    this.rating = 4.8,
    this.calories = 350,
    this.allergens = const [],
    this.customizationOptions = const [],
    this.popularityCount = 0,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      nameTamil: json['name_tamil'] as String?,
      nameHindi: json['name_hindi'] as String?,
      nameTelugu: json['name_telugu'] as String?,
      nameSpanish: json['name_spanish'] as String?,
      description: json['description'] as String?,
      descriptionTamil: json['description_tamil'] as String?,
      price: (json['price'] as num).toDouble(),
      costPrice: (json['cost_price'] as num?)?.toDouble() ?? 0.0,
      marginPercent: json['margin_percent'] as int? ?? 40,
      prepTimeMinutes: json['prep_time_minutes'] as int? ?? 12,
      imageUrl: json['image_url'] as String?,
      isVeg: json['is_veg'] as bool? ?? true,
      isSpicy: json['is_spicy'] as bool? ?? false,
      isSignature: json['is_signature'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      calories: json['calories'] as int? ?? 350,
      allergens: (json['allergens'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      customizationOptions: (json['customization_options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      popularityCount: json['popularity_count'] as int? ?? 0,
    );
  }

  String getLocalizedName(String langCode) {
    switch (langCode) {
      case 'ta':
        return nameTamil ?? name;
      case 'hi':
        return nameHindi ?? name;
      case 'te':
        return nameTelugu ?? name;
      case 'es':
        return nameSpanish ?? name;
      default:
        return name;
    }
  }

  String getLocalizedDescription(String langCode) {
    if (langCode == 'ta' && descriptionTamil != null && descriptionTamil!.isNotEmpty) {
      return descriptionTamil!;
    }
    return description ?? '';
  }
}

