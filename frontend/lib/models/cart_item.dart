import 'package:smart_kiosk/models/menu_item.dart';

class CartItem {
  final String id;
  final MenuItem item;
  int quantity;
  String spiceLevel; // Mild, Medium, Hot, Extra Hot
  List<String> customizations;
  String specialInstructions;

  CartItem({
    required this.id,
    required this.item,
    this.quantity = 1,
    this.spiceLevel = 'Medium',
    this.customizations = const [],
    this.specialInstructions = '',
  });

  double get subtotal => item.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'menu_item_id': item.id,
      'name': item.name,
      'price': item.price,
      'quantity': quantity,
      'spice_level': spiceLevel,
      'customizations': customizations,
      'special_instructions': specialInstructions,
      'image_url': item.imageUrl,
      'is_veg': item.isVeg,
    };
  }
}

