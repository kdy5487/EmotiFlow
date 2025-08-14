import 'package:flutter/material.dart';
import 'package:emoti_flow/routes/app_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';

void main() {
  runApp(const EmotiFlowApp());
}

class EmotiFlowApp extends StatelessWidget {
  const EmotiFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EmotiFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // 시스템 테마에 따라 자동 변경
      routerConfig: AppRouter.router,
    );
  }
}
