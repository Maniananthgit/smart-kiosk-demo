import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_kiosk/core/constants/app_constants.dart';
import 'package:smart_kiosk/viewmodels/auth_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/cart_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/dashboard_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/kiosk_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/kitchen_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/order_tracker_viewmodel.dart';
import 'package:smart_kiosk/views/kiosk/welcome_screen.dart';

void main() {
  testWidgets('WelcomeScreen renders app name, tables, and CTA button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => KioskViewModel()),
          ChangeNotifierProvider(create: (_) => CartViewModel()),
          ChangeNotifierProvider(create: (_) => OrderTrackerViewModel()),
          ChangeNotifierProvider(create: (_) => KitchenViewModel()),
          ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ],
        child: const MaterialApp(
          home: WelcomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Brand title is rendered
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('Select Table Number'), findsOneWidget);
    expect(find.text('Table 12'), findsOneWidget);
    expect(find.text('Explore Menu & Order'), findsOneWidget);
  });
}
