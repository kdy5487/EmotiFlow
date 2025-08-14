import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/core/services/firebase_service.dart';
import 'package:emoti_flow/core/providers/auth_provider.dart';
import 'package:emoti_flow/routes/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase 초기화 성공!');
    
    // Firebase 서비스 초기화
    await FirebaseService.instance.initialize();
    print('✅ Firebase 서비스 초기화 성공!');
  } catch (e) {
    print('❌ Firebase 초기화 실패: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const EmotiFlowApp(),
    ),
  );
}

class EmotiFlowApp extends StatelessWidget {
  const EmotiFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.createRouter(context);

    return MaterialApp.router(
      title: 'EmotiFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
