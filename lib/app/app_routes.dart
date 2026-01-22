import 'package:flutter/material.dart';
import '../features/auth/view/login_view.dart';
import '../features/dashboard/view/dashboard_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginView(),
    dashboard: (context) => const DashboardView(),
  };
}
