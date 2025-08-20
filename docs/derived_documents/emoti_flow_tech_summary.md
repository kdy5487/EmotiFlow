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
- **Gemini 1.5 Flash API**: 감정 기반 음악 추천 및 대화형 인터페이스

### **Data Visualization & Media**
- **fl_chart**: 감정 통계 차트
- **syncfusion_flutter_charts**: 고급 차트 및 데이터 시각화
- **Custom Paint & Canvas API**: 그림 그리기 기능
- **audioplayers/just_audio**: 음원 재생
- **video_player**: 영상 재생 및 제작
- **spotify_sdk**: Spotify API 연동 및 음악 재생
- **youtube_explode_dart**: YouTube Music API 연동
- **flutter_audio_query**: 로컬 음악 라이브러리 접근

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

## 📱 기술 요구사항 상세

### **기능명: Flutter 앱 개발**
- **기술 ID**: TECH-001
- **설명**: Flutter SDK 3.16+ 기반 크로스 플랫폼 앱 개발
- **구현 방법**:
  - Flutter 3.16+ SDK 사용
  - Dart 언어로 비즈니스 로직 구현
  - Material Design 3 컴포넌트 활용
  - 반응형 UI 및 적응형 레이아웃 구현

### **기능명: Firebase 연동**
- **기술 ID**: TECH-002
- **설명**: Firebase Auth, Firestore, Storage 연동
- **구현 방법**:
  - Firebase Authentication으로 사용자 인증
  - Cloud Firestore로 실시간 데이터베이스
  - Firebase Storage로 미디어 파일 저장
  - Firebase Cloud Messaging으로 푸시 알림

### **기능명: OpenAI API 연동**
- **기술 ID**: TECH-003
- **설명**: OpenAI GPT-4 API, 감정 분석
- **구현 방법**:
  - GPT-4 API로 일기 내용 분석 및 피드백
  - DALL-E API로 감정 이미지 생성
  - 감정 키워드 추출 및 패턴 분석
  - 맞춤형 조언 및 위로 메시지 생성

### **기능명: 차트 및 데이터 시각화**
- **기술 ID**: TECH-004
- **설명**: fl_chart, syncfusion_flutter_charts 활용
- **구현 방법**:
  - fl_chart로 기본 차트 구현
  - syncfusion_flutter_charts로 고급 차트
  - 인터랙티브 차트 및 애니메이션
  - 실시간 데이터 업데이트

### **기능명: 그림 그리기 기능**
- **기술 ID**: TECH-005
- **설명**: Custom Paint, Canvas API 활용
- **구현 방법**:
  - CustomPainter로 브러시 도구 구현
  - Canvas API로 그림 그리기 기능
  - 레이어 시스템 및 편집 기능
  - 감정별 색상 팔레트 및 가이드

### **기능명: 음원 재생**
- **기술 ID**: TECH-006
- **설명**: audioplayers, just_audio 패키지 활용
- **구현 방법**:
  - audioplayers로 기본 음원 재생
  - just_audio로 고급 오디오 기능
  - 플레이리스트 및 재생 모드
  - 백그라운드 재생 및 컨트롤

### **기능명: 이미지 생성**
- **기술 ID**: TECH-007
- **설명**: OpenAI DALL-E API 연동
- **구현 방법**:
  - DALL-E API로 감정 기반 이미지 생성
  - 이미지 품질 및 스타일 조절
  - 생성된 이미지 저장 및 관리
  - 이미지 편집 및 필터링

### **기능명: 영상 제작**
- **기술 ID**: TECH-008
- **설명**: video_player, ffmpeg 활용
- **구현 방법**:
  - video_player로 영상 재생 및 편집
  - ffmpeg로 영상 합성 및 효과
  - 자동 전환 효과 및 애니메이션
  - 영상 품질 조절 및 압축

### **기능명: 로컬 저장소**
- **기술 ID**: TECH-009
- **설명**: SharedPreferences, Hive 활용
- **구현 방법**:
  - SharedPreferences로 간단한 설정 저장
  - Hive로 구조화된 데이터 저장
  - 오프라인 데이터 동기화
  - 데이터 백업 및 복원

### **기능명: HTTP 통신**
- **기술 ID**: TECH-010
- **설명**: Dio, http 패키지 활용
- **구현 방법**:
  - Dio로 고급 HTTP 클라이언트 구현
  - http로 기본 HTTP 요청 처리
  - 인터셉터 및 에러 핸들링
  - 요청/응답 로깅 및 모니터링

### **기능명: 보안 및 암호화**
- **기술 ID**: TECH-011
- **설명**: flutter_secure_storage, crypto 활용
- **구현 방법**:
  - flutter_secure_storage로 민감 데이터 저장
  - crypto로 데이터 암호화/복호화
  - SSL/TLS 인증서 검증
  - 보안 키 관리 및 갱신

### **기능명: 오프라인 지원**
- **기술 ID**: TECH-012
- **설명**: connectivity_plus, sqflite 활용
- **구현 방법**:
  - connectivity_plus로 네트워크 상태 모니터링
  - sqflite로 로컬 데이터베이스 구현
  - 오프라인 데이터 캐싱
  - 네트워크 복구 시 자동 동기화

### **기능명: 성능 모니터링**
- **기술 ID**: TECH-013
- **설명**: Firebase Performance, Sentry 활용
- **구현 방법**:
  - Firebase Performance로 앱 성능 추적
  - Sentry로 에러 모니터링 및 리포팅
  - 성능 병목 지점 식별
  - 사용자 경험 개선 제안

### **기능명: 접근성**
- **기술 ID**: TECH-014
- **설명**: flutter_semantics, accessibility_tools 활용
- **구현 방법**:
  - flutter_semantics로 스크린 리더 지원
  - accessibility_tools로 접근성 테스트
  - 색상 대비 및 터치 영역 최적화
  - 키보드 네비게이션 지원

### **기능명: 반응형 UI**
- **기술 ID**: TECH-015
- **설명**: flutter_responsive, adaptive_components 활용
- **구현 방법**:
  - flutter_responsive로 화면 크기별 레이아웃
  - adaptive_components로 플랫폼별 컴포넌트
  - 브레이크포인트 기반 반응형 디자인
  - 다양한 디바이스 최적화

### **기능명: 멀티 디바이스**
- **기술 ID**: TECH-016
- **설명**: device_info_plus, screen_util 활용
- **구현 방법**:
  - device_info_plus로 디바이스 정보 수집
  - screen_util로 화면 크기 및 밀도 처리
  - 디바이스별 기능 최적화
  - 크로스 플랫폼 호환성 보장

---

## 🗃️ 데이터 모델 및 서비스 구현

### **1. 데이터 모델**

#### **일기 모델 (Diary)**
```dart
// 일기 모델
class Diary {
  final String id;
  final String title;
  final String content;
  final Emotion emotion;
  final DateTime createdAt;
  final List<String> mediaUrls;
  final Map<String, dynamic> aiAnalysis;
  
  Diary({
    required this.id,
    required this.title,
    required this.content,
    required this.emotion,
    required this.createdAt,
    this.mediaUrls = const [],
    this.aiAnalysis = const {},
  });
  
  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      emotion: Emotion.values.firstWhere((e) => e.name == json['emotion']),
      createdAt: DateTime.parse(json['createdAt']),
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      aiAnalysis: Map<String, dynamic>.from(json['aiAnalysis'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'emotion': emotion.name,
      'createdAt': createdAt.toIso8601String(),
      'mediaUrls': mediaUrls,
      'aiAnalysis': aiAnalysis,
    };
  }
}
```

#### **감정 열거형 (Emotion)**
```dart
// 감정 열거형
enum Emotion {
  joy,      // 기쁨
  love,     // 사랑
  calm,     // 평온
  sadness,  // 슬픔
  anger,    // 분노
  fear,     // 두려움
  surprise, // 놀람
  neutral,  // 중립
}
```

#### **사용자 모델 (User)**
```dart
// 사용자 모델
class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final Map<String, dynamic> preferences;
  final EmotionProfile emotionProfile;
  
  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    this.preferences = const {},
    required this.emotionProfile,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      createdAt: DateTime.parse(json['createdAt']),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      emotionProfile: EmotionProfile.fromJson(json['emotionProfile']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'preferences': preferences,
      'emotionProfile': emotionProfile.toJson(),
    };
  }
}
```

### **2. 서비스 구현**

#### **일기 서비스 (DiaryService)**
```dart
// 일기 서비스
class DiaryService {
  final FirebaseFirestore _firestore;
  final String userId;
  
  DiaryService(this._firestore, this.userId);
  
  Future<List<Diary>> getDiaries() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaries')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => Diary.fromJson(doc.data())).toList();
    } catch (e) {
      throw DiaryException('일기 목록을 불러오는데 실패했습니다: $e');
    }
  }
  
  Future<void> createDiary(Diary diary) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaries')
          .doc(diary.id)
          .set(diary.toJson());
    } catch (e) {
      throw DiaryException('일기 저장에 실패했습니다: $e');
    }
  }
  
  Future<void> updateDiary(Diary diary) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaries')
          .doc(diary.id)
          .update(diary.toJson());
    } catch (e) {
      throw DiaryException('일기 수정에 실패했습니다: $e');
    }
  }
  
  Future<void> deleteDiary(String diaryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaries')
          .doc(diaryId)
          .delete();
    } catch (e) {
      throw DiaryException('일기 삭제에 실패했습니다: $e');
    }
  }
}
```

#### **AI 서비스 (AIService)**
```dart
// AI 서비스
class AIService {
  final OpenAI _openAI;
  
  AIService(this._openAI);
  
  Future<String> analyzeEmotion(String content) async {
    try {
      final completion = await _openAI.chat.completions.create(
        model: 'gpt-4',
        messages: [
          ChatMessage(
            role: ChatMessageRole.system,
            content: '당신은 감정 분석 전문가입니다. 주어진 텍스트의 감정을 분석하고 따뜻한 위로를 제공하세요.',
          ),
          ChatMessage(
            role: ChatMessageRole.user,
            content: content,
          ),
        ],
      );
      
      return completion.choices.first.message.content ?? '분석을 완료할 수 없습니다.';
    } catch (e) {
      throw AIException('AI 분석에 실패했습니다: $e');
    }
  }
  
  Future<String> generateImage(String prompt) async {
    try {
      final response = await _openAI.images.generate(
        model: 'dall-e-3',
        prompt: prompt,
        size: '1024x1024',
        quality: 'standard',
        n: 1,
      );
      
      return response.data.first.url ?? '';
    } catch (e) {
      throw AIException('이미지 생성에 실패했습니다: $e');
    }
  }
}
```

#### **인증 서비스 (AuthService)**
```dart
// 인증 서비스
class AuthService {
  final FirebaseAuth _auth;
  
  AuthService(this._auth);
  
  Future<UserCredential> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw AuthException('로그인에 실패했습니다: $e');
    }
  }
  
  Future<UserCredential> createUserWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw AuthException('회원가입에 실패했습니다: $e');
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('로그아웃에 실패했습니다: $e');
    }
  }
}
```

### **3. 예외 처리**

#### **커스텀 예외 클래스들**
```dart
// 일기 관련 예외
class DiaryException implements Exception {
  final String message;
  DiaryException(this.message);
  
  @override
  String toString() => 'DiaryException: $message';
}

// AI 관련 예외
class AIException implements Exception {
  final String message;
  AIException(this.message);
  
  @override
  String toString() => 'AIException: $message';
}

// 인증 관련 예외
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}
```

---

## 🏗️ 아키텍처 및 기술 구현

### **1. 상태 관리 (Riverpod)**

#### **상태 관리 구조**
```dart
// 상태 관리 구조
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

final diaryProvider = StateNotifierProvider<DiaryNotifier, DiaryState>((ref) {
  return DiaryNotifier(ref.read(diaryServiceProvider));
});

final aiProvider = StateNotifierProvider<AINotifier, AIState>((ref) {
  return AINotifier(ref.read(aiServiceProvider));
});

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref.read(userServiceProvider));
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier(ref.read(themeServiceProvider));
});
```

#### **상태 관리 패턴**
```dart
// 인증 상태 관리
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(AuthState.initial());
  
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);
      state = state.copyWith(
        user: user,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _authService.signOut();
      state = AuthState.initial();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// 상태 클래스
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });
  
  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
  
  factory AuthState.initial() => const AuthState();
}
```

### **2. 라우팅 (GoRouter)**

#### **라우팅 설정**
```dart
// 라우팅 설정
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/diary',
      builder: (context, state) => const DiaryPage(),
    ),
    GoRoute(
      path: '/diary/:id',
      builder: (context, state) {
        final diaryId = state.pathParameters['id']!;
        return DiaryDetailPage(diaryId: diaryId);
      },
    ),
    GoRoute(
      path: '/ai',
      builder: (context, state) => const AIPage(),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsPage(),
    ),
    GoRoute(
      path: '/music',
      builder: (context, state) => const MusicPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
  ],
);
```

#### **라우팅 가드 및 미들웨어**
```dart
// 인증이 필요한 라우트 보호
final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authState = ref.read(authProvider);
    final isLoggedIn = authState.user != null;
    final isOnboarding = state.matchedLocation == '/onboarding';
    final isAuth = state.matchedLocation == '/login' || 
                   state.matchedLocation == '/signup';
    
    // 온보딩이 필요한 경우
    if (!isLoggedIn && !isOnboarding && !isAuth) {
      return '/onboarding';
    }
    
    // 로그인이 필요한 경우
    if (isLoggedIn && isAuth) {
      return '/';
    }
    
    // 로그인이 필요한 페이지 접근 시
    if (!isLoggedIn && !isOnboarding && !isAuth) {
      return '/login';
    }
    
    return null;
  },
  routes: [
    // ... 라우트 정의
  ],
);
```

#### **딥링크 및 웹 URL 지원**
```dart
// 딥링크 설정
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/diary/:id',
      builder: (context, state) {
        final diaryId = state.pathParameters['id']!;
        return DiaryDetailPage(diaryId: diaryId);
      },
      // 웹 URL에서 직접 접근 가능
      redirect: (context, state) {
        // 특별한 처리 로직
        return null;
      },
    ),
  ],
);

// 딥링크 처리
void handleDeepLink(String link) {
  if (link.contains('/diary/')) {
    final diaryId = link.split('/diary/').last;
    router.go('/diary/$diaryId');
  }
}
```

### **3. 프로젝트 구조**

#### **폴더 구조**
```
lib/
├── main.dart                    # 앱 진입점
├── app.dart                     # 앱 설정
├── theme/                       # 테마 및 스타일
│   ├── app_theme.dart
│   ├── app_colors.dart
│   └── app_typography.dart
├── shared/                      # 공통 컴포넌트
│   ├── widgets/                # 공통 위젯
│   ├── models/                 # 공통 모델
│   ├── services/               # 공통 서비스
│   └── utils/                  # 유틸리티
├── features/                    # 기능별 모듈
│   ├── auth/                   # 인증
│   ├── diary/                  # 일기
│   ├── ai/                     # AI
│   ├── analytics/              # 분석
│   ├── music/                  # 음악
│   └── profile/                # 프로필
└── core/                        # 핵심 기능
    ├── constants/               # 상수
    ├── errors/                  # 에러 처리
    └── network/                 # 네트워크 처리
```

---

## 📚 참고 문서

- `emoti_flow_requirements.md`: 요구사항 정의서
- `emoti_flow_ia.md`: 정보 아키텍처 문서
- `emoti_flow_page_definition.md`: 페이지 정의서
- `emoti_flow_functional_spec.md`: 기능 상세 명세서
- `emoti_flow_uiux_guide.md`: UI/UX 상세 가이드

---

## 🎵 감정 기반 음악 기능 구현 방식

### **1. 전체 아키텍처 및 데이터 흐름**

#### **감정 → 음악 매핑 시스템**
- **감정 분류**: 기존 8가지 감정 (기쁨, 슬픔, 분노, 평온, 설렘, 우울, 불안, 희망)
- **음악 태그 시스템**: 각 감정별로 적합한 음악 장르, BPM, 분위기 태그 정의
- **실시간 매칭**: 사용자의 현재 감정 상태를 분석하여 최적의 음악 추천

#### **데이터 소스 및 API 연동**
- **Spotify Web API**: 음악 검색, 재생, 플레이리스트 생성
- **YouTube Music API**: 대안 음악 소스 (무료 사용자용)
- **로컬 음악 라이브러리**: 사용자 기기 내 음악 파일 활용

### **2. 핵심 기능 구현 방식**

#### **감정 분석 및 음악 매칭**
```
사용자 감정 입력 → 감정 강도 분석 → 음악 태그 생성 → API 검색 → 결과 필터링 → 추천 목록 생성
```

#### **음악 추천 알고리즘**
- **감정 기반 필터링**: 감정과 음악의 분위기 매칭
- **BPM 기반 매칭**: 감정 강도에 따른 템포 조절
- **사용자 선호도 학습**: 이전 재생 기록 기반 개인화
- **실시간 피드백**: 좋아요/싫어요로 추천 정확도 향상

#### **재생 시스템**
- **자동 재생**: 감정 선택 시 자동으로 적합한 음악 재생
- **플레이리스트 생성**: 감정별 맞춤 플레이리스트 자동 구성
- **연속 재생**: 감정 변화에 따른 음악 자동 전환
- **백그라운드 재생**: 다른 앱 사용 중에도 음악 계속 재생

### **3. 기술적 구현 세부사항**

#### **백엔드 서비스**
- **감정-음악 매핑 데이터베이스**: 감정별 음악 태그 및 메타데이터
- **음악 추천 엔진**: 머신러닝 기반 개인화 추천 시스템
- **API 프록시 서버**: 외부 음악 서비스 API 통합 관리
- **사용자 선호도 분석**: 재생 패턴 및 피드백 데이터 수집

#### **프론트엔드 구현**
- **음악 플레이어 위젯**: 재생/일시정지, 볼륨, 진행바
- **플레이리스트 뷰**: 감정별 음악 목록 및 재생 순서
- **음악 검색 및 필터**: 장르, 아티스트, BPM별 필터링
- **사용자 피드백 UI**: 좋아요/싫어요, 건너뛰기 버튼

#### **데이터 모델**
```dart
// 감정-음악 매핑 모델
class EmotionMusicMapping {
  final String emotion;
  final List<String> musicTags;
  final int targetBPM;
  final List<String> genres;
  final String mood;
}

// 음악 트랙 모델
class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String albumArt;
  final int duration;
  final int bpm;
  final List<String> genres;
  final List<String> moods;
  final String previewUrl;
  final String fullTrackUrl;
}

// 사용자 음악 선호도 모델
class UserMusicPreference {
  final String userId;
  final Map<String, double> emotionGenrePreferences;
  final Map<String, double> artistPreferences;
  final List<String> favoriteTracks;
  final List<String> dislikedTracks;
  final Map<String, int> playCounts;
}
```

### **4. 사용자 경험 (UX) 설계**

#### **음악 선택 및 재생 플로우**
1. **감정 선택**: 일기 작성 시 또는 홈 화면에서 감정 선택
2. **자동 추천**: 감정에 맞는 음악 3-5곡 자동 추천
3. **음악 미리듣기**: 30초 미리듣기로 적합성 확인
4. **플레이리스트 생성**: 마음에 드는 곡들로 자동 플레이리스트 구성
5. **연속 재생**: 감정 변화에 따른 음악 자동 전환

#### **개인화 기능**
- **감정 히스토리**: 과거 감정별 음악 선호도 학습
- **시간대별 추천**: 아침/점심/저녁 시간대별 적합한 음악
- **활동별 매칭**: 운동, 휴식, 작업 등 활동에 맞는 음악
- **계절별 감정**: 계절 변화에 따른 감정과 음악 연계

### **5. 구현 단계 및 우선순위**

#### **Phase 1: 기본 기능 (MVP)**
- 감정별 음악 태그 시스템 구축
- Spotify API 연동 및 기본 음악 검색
- 간단한 음악 플레이어 구현
- 감정 선택 시 음악 추천 표시

#### **Phase 2: 고급 기능**
- 개인화 추천 알고리즘 구현
- 플레이리스트 자동 생성
- 사용자 피드백 시스템
- 음악 재생 히스토리 관리

#### **Phase 3: 고도화**
- 머신러닝 기반 추천 시스템
- 실시간 감정 변화 감지
- 소셜 기능 (음악 공유, 추천)
- 오프라인 재생 지원

### **6. 기술적 도전과제 및 해결방안**

#### **API 제한 및 비용**
- **해결방안**: YouTube Music API 활용, 로컬 음악 라이브러리 통합
- **대안**: 오픈소스 음악 데이터베이스 활용

#### **음악 저작권 문제**
- **해결방안**: 미리듣기만 제공, 전체 곡은 외부 서비스로 연결
- **대안**: 로열티 프리 음악 데이터베이스 활용

#### **개인화 정확도**
- **해결방안**: 사용자 피드백 데이터 수집 및 분석
- **대안**: 감정별 기본 추천 알고리즘으로 시작
