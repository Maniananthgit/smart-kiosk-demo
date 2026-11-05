import 'package:flutter/material.dart';
import 'package:smart_kiosk/core/constants/app_constants.dart';
import 'package:smart_kiosk/core/theme/app_theme.dart';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.darkCard,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
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
                        Text(
                          '${AppConstants.currencySymbol}${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              const Divider(color: AppTheme.darkBorder, height: 24),

              Expanded(
                child: ListView(
                  children: [
                    // Description
                    if (item.getLocalizedDescription(widget.languageCode).isNotEmpty) ...[
                      Text(
                        item.getLocalizedDescription(widget.languageCode),
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Spice Level Selector
                    const Text(
                      'Select Spice Level',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _spiceLevels.map((spice) {
                        final isSelected = _selectedSpice == spice;
                        return ChoiceChip(
                          label: Text(spice),
                          selected: isSelected,
                          selectedColor: AppTheme.primary,
                          backgroundColor: AppTheme.darkBg,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedSpice = spice);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Customizations
                    if (item.customizationOptions.isNotEmpty) ...[
                      const Text(
                        'Add-ons & Preferences',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      ...item.customizationOptions.map((opt) {
                        final isChecked = _selectedCustomizations.contains(opt);
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(opt, style: const TextStyle(color: Colors.white)),
                          value: isChecked,
                          activeColor: AppTheme.primary,
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
                      const SizedBox(height: 16),
                    ],

                    // Special Instructions
                    const Text(
                      'Special Chef Instructions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'e.g., Less salt, extra crispy, sauce on the side',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: AppTheme.darkBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.darkBorder),
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const Divider(color: AppTheme.darkBorder, height: 24),

              // Bottom Actions: Quantity & Add Button
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.darkBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white),
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
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
                      child: Text(
                        'Add to Cart • ${AppConstants.currencySymbol}${totalItemPrice.toStringAsFixed(0)}',
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

