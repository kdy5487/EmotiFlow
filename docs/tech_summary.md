# EmotiFlow - 기술적 요약 문서

## 📋 프로젝트 개요

| 항목 | 내용 |
|------|------|
| **프로젝트명** | EmotiFlow (AI 기반 감정 일기 앱) |
| **개발 기간** | 2주 |
| **개발 도구** | Flutter + Firebase + OpenAI API |
| **목표** | AI와 함께하는 일상의 감정 파트너, 개인화된 감정 관리 및 성장 도구 |

---

## 🛠️ 사용 기술 스택

### **Frontend Framework**
- **Flutter 3.16+**: 크로스 플랫폼 모바일 앱 개발
- **Dart**: Flutter 앱의 프로그래밍 언어

### **Backend Services**
- **Firebase Authentication**: 사용자 인증 및 소셜 로그인
- **Cloud Firestore**: NoSQL 데이터베이스
- **Firebase Storage**: 이미지 및 파일 저장
- **Firebase Cloud Messaging**: 푸시 알림
- **Firebase Performance**: 앱 성능 모니터링

### **AI Services**
- **OpenAI GPT-4 API**: 감정 분석 및 AI 대화형 일기
- **OpenAI DALL-E API**: 감정 기반 이미지 생성

### **Data Visualization & Media**
- **fl_chart**: 감정 통계 차트
- **syncfusion_flutter_charts**: 고급 차트 및 데이터 시각화
- **Custom Paint & Canvas API**: 그림 그리기 기능
- **audioplayers/just_audio**: 음원 재생
- **video_player**: 영상 재생 및 제작

### **Local Storage & Offline**
- **SharedPreferences**: 간단한 설정 데이터 저장
- **Hive**: 로컬 NoSQL 데이터베이스
- **sqflite**: SQLite 데이터베이스 (오프라인 지원)

### **Network & Security**
- **Dio/http**: HTTP 통신
- **flutter_secure_storage**: 민감 데이터 암호화 저장
- **crypto**: 데이터 암호화
- **connectivity_plus**: 네트워크 상태 모니터링

### **UI & UX**
- **flutter_responsive**: 반응형 UI 구현
- **adaptive_components**: 적응형 컴포넌트
- **device_info_plus**: 디바이스 정보
- **screen_util**: 화면 크기 유틸리티

---

## 🏗️ 주요 아키텍처 개요

### **1. 앱 아키텍처 구조**
```
EmotiFlow App
├── Presentation Layer (UI Components)
├── Business Logic Layer (State Management)
├── Data Layer (Local + Remote)
├── Service Layer (AI, Firebase, External APIs)
└── Infrastructure Layer (Platform Services)
```

### **2. 컴포넌트 구조**
- **Stateless Widgets**: 순수 UI 컴포넌트
- **Stateful Widgets**: 상태 관리가 필요한 컴포넌트
- **Custom Widgets**: 재사용 가능한 커스텀 컴포넌트
- **MVVM Pattern**: Model-View-ViewModel 아키텍처

### **3. 상태관리 (Riverpod + MVVM)**
- **Riverpod**: 메인 상태 관리 솔루션
  - `StateNotifierProvider`: 복잡한 상태 관리
  - `FutureProvider`: 비동기 데이터 처리
  - `StreamProvider`: 실시간 데이터 스트림
  - `ChangeNotifierProvider`: 간단한 상태 변경
- **MVVM 구조**:
  - **Model**: 데이터 모델 및 비즈니스 로직
  - **View**: UI 컴포넌트 (Stateless Widgets)
  - **ViewModel**: 상태 관리 및 UI 로직 (Riverpod Providers)
- **의존성 주입**: Riverpod의 자동 의존성 관리
- **상태 분리**: UI 상태와 비즈니스 로직 분리

### **4. 라우팅 구조**
- **GoRouter**: 선언적 라우팅
- **Named Routes**: 명명된 라우트
- **Deep Linking**: 딥링크 지원
- **Route Guards**: 인증이 필요한 페이지 보호

---

## 🚀 개발 환경 및 빌드 도구

### **개발 환경**
- **IDE**: Android Studio / VS Code
- **Flutter SDK**: 3.16.0 이상
- **Dart SDK**: 3.2.0 이상
- **Android Studio**: JBR (Java 11)
- **Xcode**: iOS 개발용 (macOS)

### **빌드 도구**
- **Flutter CLI**: Flutter 명령어 도구
- **Gradle**: Android 빌드 시스템
- **CocoaPods**: iOS 의존성 관리
- **Flutter Build**: 크로스 플랫폼 빌드

### **의존성 관리**
- **pubspec.yaml**: Flutter 패키지 관리
- **Version Constraints**: 호환성 보장
- **Dependency Injection**: 의존성 주입 패턴

---

## 🔄 데이터 흐름 및 처리 방식

### **1. 데이터 흐름**
```
User Input → Local Processing → Cloud Sync → AI Analysis → Results → UI Update
```

### **2. 데이터 처리 방식**
- **Local First**: 오프라인 우선 데이터 처리
- **Real-time Sync**: 실시간 클라우드 동기화
- **Conflict Resolution**: 데이터 충돌 해결
- **Caching Strategy**: 효율적인 캐싱 전략

### **3. Mock 데이터 처리**
- **Development Mode**: 개발 환경에서 Mock 데이터 사용
- **Offline Mode**: 네트워크 없이 로컬 데이터 사용
- **Fallback Data**: API 실패 시 기본 데이터 제공

---

## 🎨 퍼블리싱 관련 주요 규칙

### **1. 반응형 디자인**
- **Breakpoints**: 모바일(640px), 태블릿(1024px), 데스크톱(1440px)
- **Grid System**: 12컬럼 그리드 기반 레이아웃
- **Adaptive Layout**: 화면 크기별 자동 레이아웃 조정
- **Flexible Components**: 유연한 컴포넌트 크기 조정

### **2. 접근성**
- **WCAG 2.1 AA**: 색상 대비 기준 준수
- **Touch Targets**: 최소 44x44px 터치 영역
- **Screen Reader**: 시맨틱 라벨 및 상태 정보
- **Keyboard Navigation**: 키보드 포커스 및 단축키

### **3. 디자인 시스템**
- **Color Palette**: Primary, Secondary, Semantic, Neutral 색상
- **Typography**: Display, Heading, Body, Caption, Button 스타일
- **Component Library**: 버튼, 카드, 입력 필드 등 재사용 컴포넌트
- **Spacing System**: 8px 기준의 일관된 간격 체계

---

## 📁 예상 폴더 구조 (Flutter + Riverpod + MVVM 기준)

```
lib/
├── main.dart                          # 앱 진입점
├── app/
│   ├── app.dart                       # 앱 설정
│   ├── routes.dart                    # 라우팅 설정
│   └── theme.dart                     # 테마 설정
├── core/
│   ├── constants/                     # 상수 정의
│   ├── utils/                         # 유틸리티 함수
│   ├── errors/                        # 에러 처리
│   └── network/                       # 네트워크 관련
├── data/
│   ├── models/                        # 데이터 모델
│   ├── repositories/                  # 데이터 저장소
│   ├── datasources/                   # 데이터 소스
│   └── mappers/                       # 데이터 변환
├── domain/
│   ├── entities/                      # 비즈니스 엔티티
│   ├── repositories/                  # 리포지토리 인터페이스
│   ├── usecases/                      # 비즈니스 로직
│   └── exceptions/                    # 도메인 예외
├── presentation/                      # MVVM 구조
│   ├── pages/                         # View (화면 페이지)
│   ├── widgets/                       # View (재사용 위젯)
│   ├── viewmodels/                    # ViewModel (Riverpod Providers)
│   └── providers/                     # Riverpod Providers
├── services/
│   ├── ai_service.dart                # AI 서비스
│   ├── auth_service.dart              # 인증 서비스
│   ├── storage_service.dart           # 저장소 서비스
│   └── notification_service.dart      # 알림 서비스
└── shared/
    ├── components/                     # 공통 컴포넌트
    ├── styles/                         # 공통 스타일
    └── assets/                         # 이미지, 폰트 등
```

---

## 🔮 향후 확장 및 유지보수 고려사항

### **1. 확장성**
- **Modular Architecture**: 모듈화된 아키텍처로 기능 확장 용이
- **Plugin System**: 플러그인 기반 기능 확장
- **API Versioning**: API 버전 관리로 하위 호환성 보장
- **Microservices**: 필요시 마이크로서비스로 전환 가능

### **2. 성능 최적화**
- **Lazy Loading**: 필요시에만 데이터 로드
- **Image Optimization**: 이미지 압축 및 캐싱
- **Memory Management**: 메모리 누수 방지
- **Background Processing**: 백그라운드 작업 최적화

### **3. 보안 강화**
- **Data Encryption**: 민감 데이터 암호화
- **API Security**: API 키 보안 및 요청 제한
- **User Privacy**: 개인정보 보호 및 GDPR 준수
- **Audit Logging**: 보안 이벤트 로깅

### **4. 모니터링 및 분석**
- **Crash Reporting**: 크래시 리포팅 및 분석
- **Performance Monitoring**: 성능 지표 모니터링
- **User Analytics**: 사용자 행동 분석
- **A/B Testing**: 기능 테스트 및 최적화

### **5. 국제화 및 현지화**
- **Multi-language**: 다국어 지원
- **Cultural Adaptation**: 문화적 특성 반영
- **Local Content**: 지역별 콘텐츠 제공
- **Time Zone**: 시간대별 처리

---

## 📊 개발 우선순위 및 일정

### **1주차 (핵심 기능)**
- 사용자 인증 및 프로필 관리
- AI 기반 일기 작성 기능
- 기본 UI/UX 구현
- Firebase 연동

### **2주차 (고급 기능)**
- 데이터 시각화 및 분석
- 커뮤니티 기능
- 고급 설정 및 보안
- 성능 최적화 및 테스트

---

## 🎯 성공 기준

- **기능 완성도**: 모든 핵심 기능 구현 완료
- **성능 지표**: 앱 시작 시간 < 3초, 반응 시간 < 100ms
- **사용자 경험**: 직관적이고 아름다운 UI/UX
- **안정성**: 크래시율 < 1%, 오류 처리 완벽
- **접근성**: WCAG 2.1 AA 기준 준수
- **반응형**: 모든 디바이스에서 최적화된 경험

---

## 🔧 개발자 가이드

### **Riverpod + MVVM 구조 구현 예시**

#### **1. State (Model)**
```dart
class DiaryState {
  final List<Diary> diaries;
  final bool isLoading;
  final String? error;
  
  const DiaryState({
    this.diaries = const [],
    this.isLoading = false,
    this.error,
  });
  
  DiaryState copyWith({
    List<Diary>? diaries,
    bool? isLoading,
    String? error,
  }) {
    return DiaryState(
      diaries: diaries ?? this.diaries,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
```

#### **2. ViewModel**
```dart
class DiaryViewModel extends StateNotifier<DiaryState> {
  final DiaryRepository _repository;
  
  DiaryViewModel(this._repository) : super(const DiaryState());
  
  Future<void> createDiary(String content, Emotion emotion) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final diary = await _repository.createDiary(content, emotion);
      state = state.copyWith(
        diaries: [...state.diaries, diary],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
  
  Future<void> loadDiaries() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final diaries = await _repository.getDiaries();
      state = state.copyWith(
        diaries: diaries,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}
```

#### **3. Provider**
```dart
final diaryViewModelProvider = StateNotifierProvider<DiaryViewModel, DiaryState>(
  (ref) => DiaryViewModel(ref.read(diaryRepositoryProvider)),
);
```

#### **4. View (Page)**
```dart
class DiaryWritePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryState = ref.watch(diaryViewModelProvider);
    final diaryViewModel = ref.read(diaryViewModelProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(title: Text('일기 작성')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 감정 선택기
            EmotionSelector(
              onEmotionSelected: (emotion) {
                // 감정 선택 처리
              },
            ),
            
            // 일기 입력 필드
            TextField(
              decoration: InputDecoration(
                hintText: '오늘 하루는 어땠나요?',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            
            SizedBox(height: 16),
            
            // 저장 버튼
            ElevatedButton(
              onPressed: () {
                // 일기 저장
                diaryViewModel.createDiary('일기 내용', Emotion.joy);
              },
              child: Text('저장'),
            ),
            
            // 로딩 및 에러 상태 표시
            if (diaryState.isLoading) 
              CircularProgressIndicator(),
            if (diaryState.error != null) 
              Text(
                diaryState.error!,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
```

### **주요 변경사항**

#### **기존 Provider → Riverpod + MVVM**
- **Provider Pattern** → **Riverpod StateNotifier**
- **Controller** → **ViewModel**
- **StatefulWidget** → **ConsumerWidget + WidgetRef**

#### **아키텍처 개선**
- **상태 분리**: UI 상태와 비즈니스 로직 명확히 분리
- **의존성 주입**: Riverpod의 자동 의존성 관리
- **테스트 용이성**: ViewModel 단위 테스트 가능
- **코드 재사용**: ViewModel을 여러 View에서 공유

#### **성능 최적화**
- **불필요한 리빌드 방지**: Riverpod의 스마트 리빌드
- **메모리 효율성**: 자동 메모리 관리
- **비동기 처리**: FutureProvider, StreamProvider 활용

---

## 📚 참고 문서

- `emoti_flow_requirements.md`: 요구사항 정의서
- `emoti_flow_ia.md`: 정보 아키텍처 문서
- `emoti_flow_page_definition.md`: 페이지 정의서
- `emoti_flow_functional_spec.md`: 기능 상세 명세서
- `emoti_flow_uiux_guide.md`: UI/UX 상세 가이드
