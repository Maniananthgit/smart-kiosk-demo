import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_kiosk/core/constants/app_constants.dart';
import 'package:smart_kiosk/core/routes/app_router.dart';
import 'package:smart_kiosk/core/theme/app_theme.dart';
import 'package:smart_kiosk/viewmodels/auth_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/cart_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/dashboard_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/kiosk_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/kitchen_viewmodel.dart';
import 'package:smart_kiosk/viewmodels/order_tracker_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartKioskApp());
}

class SmartKioskApp extends StatelessWidget {
  const SmartKioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => KioskViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => OrderTrackerViewModel()),
        ChangeNotifierProvider(create: (_) => KitchenViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
