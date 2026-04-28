import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:emoti_flow/routes/app_router.dart';
import 'package:emoti_flow/theme/theme_provider.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'core/services/ad_service.dart';
import 'firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. .env 파일 로드 (다른 위젯들이 환경 변수를 쓰기 때문에 반드시 필요합니다)
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("⚠️ .env 파일을 찾을 수 없습니다. 기본값을 사용합니다.");
    }

    // 2. Firebase 초기화
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // 3. AdMob 초기화
    await AdService.instance.initialize();
    AdService.instance.preloadInterstitial();
    AdService.instance.loadRewardedAd();

    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint("🔥 초기화 오류: $e");
    debugPrint(stack.toString());
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Emoti Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.themeMode,
      routerConfig: AppRouter.getRouter(ref),
    );
  }
}
