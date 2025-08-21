import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/core/services/firebase_service.dart';
import 'package:emoti_flow/routes/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // .env 파일 로드
    await dotenv.load(fileName: ".env");
    print('✅ .env 파일 로드 성공! (API 키 사용 여부만 확인)');
    
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
    const ProviderScope(
      child: EmotiFlowApp(),
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),
      routerConfig: router,
    );
  }
}
