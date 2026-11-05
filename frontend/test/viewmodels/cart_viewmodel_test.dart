import 'package:flutter_test/flutter_test.dart';
import 'package:smart_kiosk/models/menu_item.dart';
import 'package:smart_kiosk/viewmodels/cart_viewmodel.dart';

void main() {
  group('CartViewModel Tests', () {
    late CartViewModel cartVM;
    late MenuItem sampleItem1;
    late MenuItem sampleItem2;

    setUp(() {
      cartVM = CartViewModel();
      sampleItem1 = MenuItem(
        id: 'm1',
        categoryId: 'c1',
        name: 'Butter Chicken',
        price: 320.0,
        isVeg: false,
      );
      sampleItem2 = MenuItem(
        id: 'm2',
        categoryId: 'c2',
        name: 'Garlic Naan',
        price: 80.0,
        isVeg: true,
      );
    });

    test('Initial cart is empty', () {
      expect(cartVM.isEmpty, true);
      expect(cartVM.itemCount, 0);
      expect(cartVM.subtotal, 0.0);
      expect(cartVM.total, 0.0);
    });

    test('Add item to cart updates quantity and totals', () {
      cartVM.addToCart(sampleItem1, quantity: 2, spiceLevel: 'Hot');

      expect(cartVM.isEmpty, false);
      expect(cartVM.itemCount, 2);
      expect(cartVM.subtotal, 640.0);
      expect(cartVM.tax, 32.0); // 5% GST
      expect(cartVM.total, 672.0);
    });

    test('Increment and decrement quantity', () {
      cartVM.addToCart(sampleItem1, quantity: 1);
      final cartItemId = cartVM.items.first.id;

      cartVM.incrementQuantity(cartItemId);
      expect(cartVM.items.first.quantity, 2);
      expect(cartVM.subtotal, 640.0);

      cartVM.decrementQuantity(cartItemId);
      expect(cartVM.items.first.quantity, 1);
      expect(cartVM.subtotal, 320.0);

      // Decrementing when quantity is 1 removes the item
      cartVM.decrementQuantity(cartItemId);
      expect(cartVM.isEmpty, true);
    });

    test('Split bill calculates per-diner share accurately', () {
      cartVM.addToCart(sampleItem1, quantity: 1); // 320
      cartVM.addToCart(sampleItem2, quantity: 1); // 80 -> subtotal 400
      expect(cartVM.subtotal, 400.0);
      expect(cartVM.tax, 20.0); // 5%
      expect(cartVM.total, 420.0);

      cartVM.setSplitDinerCount(2);
      expect(cartVM.splitAmountPerDiner, 210.0);

      cartVM.setSplitDinerCount(4);
      expect(cartVM.splitAmountPerDiner, 105.0);
    });

    test('Tip calculation updates total', () {
      cartVM.addToCart(sampleItem1, quantity: 1); // 320, tax 16
      cartVM.setTipPercent(10.0); // 10% of 320 = 32

      expect(cartVM.tipAmount, 32.0);
      expect(cartVM.total, 320.0 + 16.0 + 32.0);
    });

    test('Clear cart resets all values', () {
      cartVM.addToCart(sampleItem1, quantity: 3);
      cartVM.setTipPercent(15.0);
      cartVM.setSplitDinerCount(3);

      cartVM.clearCart();

      expect(cartVM.isEmpty, true);
      expect(cartVM.itemCount, 0);
      expect(cartVM.tipPercent, 0.0);
      expect(cartVM.splitDinerCount, 1);
    });
  });
}

