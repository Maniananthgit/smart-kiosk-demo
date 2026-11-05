import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_kiosk/views/auth/login_screen.dart';
import 'package:smart_kiosk/views/dashboard/management_dashboard_screen.dart';
import 'package:smart_kiosk/views/hub/landing_hub_screen.dart';
import 'package:smart_kiosk/views/kiosk/menu_screen.dart';
import 'package:smart_kiosk/views/kiosk/order_tracker_screen.dart';
import 'package:smart_kiosk/views/kiosk/welcome_screen.dart';
import 'package:smart_kiosk/views/kitchen/kitchen_kds_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LandingHubScreen();
      },
    ),
    GoRoute(
      path: '/welcome',
      builder: (BuildContext context, GoRouterState state) {
        return const WelcomeScreen();
      },
    ),
    GoRoute(
      path: '/kiosk',
      builder: (BuildContext context, GoRouterState state) {
        return const MenuScreen();
      },
    ),
    GoRoute(
      path: '/tracker/:orderId',
      builder: (BuildContext context, GoRouterState state) {
        final orderId = state.pathParameters['orderId'] ?? '';
        return OrderTrackerScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/kitchen',
      builder: (BuildContext context, GoRouterState state) {
        return const KitchenKdsScreen();
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: (BuildContext context, GoRouterState state) {
        return const ManagementDashboardScreen();
      },
    ),
    GoRoute(
      path: '/management',
      builder: (BuildContext context, GoRouterState state) {
        return const ManagementDashboardScreen();
      },
    ),
  ],
);
