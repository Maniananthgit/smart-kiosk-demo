import 'package:flutter/material.dart';
import 'package:smart_kiosk/core/constants/app_constants.dart';
import 'package:smart_kiosk/models/menu_item.dart';

class ItemCustomizerDialog extends StatefulWidget {
  final MenuItem item;
  final String languageCode;
  final Function({
    required int quantity,
    required String spiceLevel,
    required List<String> customizations,
    required String specialInstructions,
  }) onAddToCart;

  const ItemCustomizerDialog({
    super.key,
    required this.item,
    required this.languageCode,
    required this.onAddToCart,
  });

  @override
  State<ItemCustomizerDialog> createState() => _ItemCustomizerDialogState();
}

class _ItemCustomizerDialogState extends State<ItemCustomizerDialog> {
  int _quantity = 1;
  String _selectedSpice = 'Medium';
  final List<String> _selectedCustomizations = [];
  final TextEditingController _notesController = TextEditingController();

  final List<String> _spiceLevels = ['Mild', 'Medium', 'Hot', 'Extra Hot'];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final totalItemPrice = item.price * _quantity;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFF0F172A),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Banner (if available)
            if (item.imageUrl != null)
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF020617),
                        child: const Icon(Icons.restaurant, color: Color(0xFFF59E0B), size: 50),
                      ),
                    ),
                  ),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                          const Color(0xFF0F172A).withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.7),
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 18),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: item.isVeg ? const Color(0xFF10B981) : Colors.redAccent,
                            ),
                          ),
                          child: Text(
                            item.isVeg ? '🌱 Pure Veg' : '🍗 Non-Veg',
                            style: TextStyle(
                              color: item.isVeg ? const Color(0xFF10B981) : Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 4),
                              Text(
                                item.rating.toStringAsFixed(1),
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.getLocalizedName(widget.languageCode),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${AppConstants.currencySymbol}${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFEA580C),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.prepTimeMinutes} mins',
                                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_fire_department_rounded, size: 13, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.calories} kcal',
                                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (item.imageUrl == null)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1E293B), height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Description
                  if (item.getLocalizedDescription(widget.languageCode).isNotEmpty) ...[
                    Text(
                      item.getLocalizedDescription(widget.languageCode),
                      style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.45),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Allergens chips
                  if (item.allergens.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 6),
                        const Text(
                          'Contains: ',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        ...item.allergens.map((alg) => Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                alg,
                                style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 11),
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Spice Level Selector
                  const Text(
                    'Select Spice Level',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _spiceLevels.map((spice) {
                      final isSelected = _selectedSpice == spice;
                      return ChoiceChip(
                        label: Text(spice),
                        selected: isSelected,
                        selectedColor: const Color(0xFFEA580C),
                        backgroundColor: const Color(0xFF020617),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFFEA580C) : const Color(0xFF1E293B),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedSpice = spice);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Customizations
                  if (item.customizationOptions.isNotEmpty) ...[
                    const Text(
                      'Chef Add-ons & Customizations',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    ...item.customizationOptions.map((opt) {
                      final isChecked = _selectedCustomizations.contains(opt);
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(opt, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        value: isChecked,
                        activeColor: const Color(0xFFEA580C),
                        checkColor: Colors.white,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedCustomizations.add(opt);
                            } else {
                              _selectedCustomizations.remove(opt);
                            }
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 14),
                  ],

                  // Special Instructions
                  const Text(
                    'Special Kitchen Instructions',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g., Less oil, sauce on side, extra crispy',
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF020617),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF1E293B)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF1E293B)),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            const Divider(color: Color(0xFF1E293B), height: 1),

            // Bottom Actions: Quantity & Add Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF020617),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onAddToCart(
                          quantity: _quantity,
                          spiceLevel: _selectedSpice,
                          customizations: _selectedCustomizations,
                          specialInstructions: _notesController.text.trim(),
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Add to Cart • ${AppConstants.currencySymbol}${totalItemPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

