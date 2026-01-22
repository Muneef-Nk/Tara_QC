import 'package:flutter/material.dart';
import 'app_routes.dart';
import 'app_theme.dart';

class TaraQcApp extends StatelessWidget {
  const TaraQcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TARA QC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
