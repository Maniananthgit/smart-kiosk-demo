class Category {
  final String id;
  final String slug;
  final String name;
  final String? nameTamil;
  final String? nameHindi;
  final String? nameTelugu;
  final String? nameSpanish;
  final int displayOrder;
  final String icon;
  final bool isActive;

  Category({
    required this.id,
    required this.slug,
    required this.name,
    this.nameTamil,
    this.nameHindi,
    this.nameTelugu,
    this.nameSpanish,
    this.displayOrder = 0,
    this.icon = 'restaurant',
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      nameTamil: json['name_tamil'] as String?,
      nameHindi: json['name_hindi'] as String?,
      nameTelugu: json['name_telugu'] as String?,
      nameSpanish: json['name_spanish'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      icon: json['icon'] as String? ?? 'restaurant',
      isActive: json['is_active'] as bool? ?? true,
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
}

