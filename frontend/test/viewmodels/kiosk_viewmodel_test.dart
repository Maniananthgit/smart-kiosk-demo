import 'package:flutter_test/flutter_test.dart';
import 'package:smart_kiosk/viewmodels/kiosk_viewmodel.dart';

void main() {
  group('KioskViewModel Tests', () {
    late KioskViewModel kioskVM;

    setUp(() {
      kioskVM = KioskViewModel();
    });

    test('Initial table number is 12 and language is en', () {
      expect(kioskVM.tableNumber, 12);
      expect(kioskVM.selectedLanguage, 'en');
      expect(kioskVM.isVegOnly, false);
    });

    test('Updating table number updates state', () {
      kioskVM.setTableNumber(6);
      expect(kioskVM.tableNumber, 6);
    });

    test('Updating language updates state', () {
      kioskVM.setLanguage('ta');
      expect(kioskVM.selectedLanguage, 'ta');
    });

    test('Toggle veg only flag', () {
      expect(kioskVM.isVegOnly, false);
      kioskVM.toggleVegOnly();
      expect(kioskVM.isVegOnly, true);
    });
  });
}

