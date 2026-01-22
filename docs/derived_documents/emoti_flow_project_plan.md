# 🧠 EmotiFlow - AI 기반 감정 일기 앱 프로젝트 기획서

## 📋 프로젝트 개요
**프로젝트명**: EmotiFlow - AI 기반 감정 일기 앱  
**목표**: AI와 함께하는 일상의 감정 파트너, 개인화된 감정 관리 및 성장 도구  
**기술 스택**: Flutter + Firebase + OpenAI API  


---

## 🎯 주요 기능

### 1. 홈페이지 (메인 대시보드)
- **감정 요약 섹션**: 오늘의 감정 상태 + AI 일일 조언
- **최근 일기 미리보기**: 감정별 색상 코딩된 카드
- **빠른 액션 버튼**: 일기 작성, 음악 재생, AI 상담
- **감정 트렌드**: 주간 감정 변화 미니 차트
- **개인화 위젯**: 사용자 맞춤형 콘텐츠

### 2. AI 일기 작성 페이지
- **대화형 AI 인터페이스**: GPT-4 기반 자연스러운 대화
- **감정 키워드 추천**: 상황별 감정 표현 가이드
- **실시간 AI 피드백**: 작성 중 감정 분석 및 조언
- **멀티미디어 지원**: 텍스트, 사진, 그림, 음성
- **자동 감정 태깅**: AI가 감정을 자동으로 분류

### 3. 감정 분석 및 시각화 페이지
- **감정 대시보드**: 차트, 그래프, 달력 뷰
- **AI 감정 이미지**: DALL-E 기반 추상적 감정 표현
- **패턴 분석**: 감정 변화 추이 및 원인 분석
- **개선 제안**: AI 기반 맞춤형 조언
- **성장 트래킹**: 감정 관리 진전 상황

### 4. 음악 치료 페이지
- **감정별 BGM**: 8가지 감정에 맞는 음악 카테고리
- **자동 재생**: 감정 상태에 따른 음악 자동 선택
- **플레이리스트 관리**: 개인 맞춤형 음악 컬렉션
- **음악 히스토리**: 듣던 음악 기록 및 통계
- **음악 추천**: AI 기반 개인화된 음악 추천

### 5. 커뮤니티 페이지
- **익명 고민 공유**: 감정별 카테고리 게시판
- **AI 모더레이션**: 부적절한 콘텐츠 자동 필터링
- **감정별 매칭**: 비슷한 감정을 느끼는 사용자 연결
- **안전 가이드라인**: 커뮤니티 이용 규칙
- **긴급 지원**: 위기 상황 대처 도구

### 6. 프로필 및 설정 페이지
- **감정 프로필**: 개인 감정 패턴 및 선호도
- **AI 학습 설정**: 개인화 수준 조절
- **테마 커스터마이징**: 다크/라이트 모드, 색상 테마
- **데이터 관리**: 백업, 동기화, 내보내기
- **보안 설정**: 생체 인증, 앱 잠금

---

## 🛠️ 기술 스택

### Frontend (Flutter)
- **Flutter 3.16+** + **Dart**
- **Material Design 3** (UI 컴포넌트)
- **Riverpod** (상태 관리 + 의존성 주입)
- **MVVM 아키텍처** (Model-View-ViewModel)
- **GoRouter** (라우팅)
- **Custom Paint** (그림 그리기)
- **fl_chart** (데이터 시각화)

### Backend & AI
- **Firebase Authentication**: 사용자 인증
- **Cloud Firestore**: NoSQL 데이터베이스
- **Firebase Storage**: 파일 저장
- **OpenAI GPT-4 API**: AI 대화 및 감정 분석
- **OpenAI DALL-E API**: 감정 이미지 생성

### 외부 서비스
- **Unsplash API**: 감정별 배경 이미지
- **Spotify API**: 음악 추천 및 재생
- **Google Analytics**: 사용자 행동 분석

---

## 📱 앱 구조 (Riverpod + MVVM)

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

## 🎨 UI/UX 디자인 가이드

### 색상 팔레트
```dart
// Primary Colors (감정 기반)
--joy: #FBBF24 (기쁨 - 노랑)
--gratitude: #F97316 (감사 - 주황)
--excitement: #EC4899 (설렘 - 핑크)
--calm: #10B981 (평온 - 초록)
--sadness: #3B82F6 (슬픔 - 파랑)
--anger: #EF4444 (분노 - 빨강)
--worry: #8B5CF6 (걸정 - 보라)
--boredom: #6B7280 (지루함 - 회색)

// Brand Colors
--primary: #6366F1 (인디고 - 신뢰)
--secondary: #EC4899 (핑크 - 따뜻함)
--success: #10B981 (에메랄드 - 성장)
--warning: #F59E0B (앰버 - 주의)
--error: #EF4444 (레드 - 위험)

// Neutral Colors
--background: #F8FAFC (슬레이트 - 깔끔)
--surface: #FFFFFF (화이트 - 순수)
--text-primary: #1E293B (슬레이트 - 가독성)
--border: #E2E8F0 (테두리)
```

### 타이포그래피
- **Display**: Pretendard, Bold, 32-48px
- **Heading**: Pretendard, SemiBold, 18-24px
- **Body**: Pretendard, Regular, 14-16px
- **Caption**: Pretendard, Light, 12-14px
- **Button**: Pretendard, SemiBold, 14-16px

### 애니메이션
- **페이지 전환**: Slide + Fade (300ms)
- **카드 등장**: Scale + Fade (400ms)
- **감정 선택**: Bounce + Scale (200ms)
- **AI 응답**: Typewriter 효과
- **로딩**: Shimmer + Pulse

---

## 🤖 AI 기능 설계

### OpenAI GPT-4 API
```dart
// 감정 분석
POST /v1/chat/completions
{
  "model": "gpt-4",
  "messages": [
    {"role": "system", "content": "당신은 감정 전문 상담사입니다."},
    {"role": "user", "content": "일기 내용: ${diaryText}"}
  ],
  "temperature": 0.7
}

// AI 조언 생성
POST /v1/chat/completions
{
  "model": "gpt-4",
  "messages": [
    {"role": "system", "content": "감정 상태에 맞는 따뜻한 조언을 제공하세요."},
    {"role": "user", "content": "감정: ${emotion}, 상황: ${situation}"}
  ]
}
```

### OpenAI DALL-E API
```dart
// 감정 이미지 생성
POST /v1/images/generations
{
  "model": "dall-e-3",
  "prompt": "추상적인 ${emotion} 감정을 표현한 아름다운 이미지",
  "size": "1024x1024",
  "quality": "standard"
}
```

### Firebase 연동
```dart
// 사용자 인증
FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password
);

// 데이터 저장
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .collection('diaries')
  .add(diaryData);
```

---

## 💡 추가 아이디어

### 고급 기능 (선택사항)
- **음성 일기**: STT/TTS를 활용한 음성 기반 일기
- **AR 감정 표현**: 카메라로 감정을 시각화
- **웨어러블 연동**: 심박수와 감정 상태 연동
- **가족 공유**: 가족 구성원과 감정 상태 공유
- **전문가 상담**: AI + 인간 상담사 하이브리드

### 확장 가능성
- **웹 버전**: Flutter Web으로 확장
- **데스크톱 앱**: Windows, macOS 지원
- **API 서비스**: 타사 앱에서 감정 분석 서비스 제공
- **기업 솔루션**: 직장 내 감정 관리 도구
- **교육 연동**: 학교에서 감정 교육 도구로 활용

---

## 📊 개발 일정

### 1주차: 핵심 기능
- **Day 1-2**: 프로젝트 설정 및 기본 구조
- **Day 3-4**: 인증 시스템 및 사용자 관리
- **Day 5-7**: 일기 작성 및 AI 연동

### 2주차: 고급 기능
- **Day 8-10**: 데이터 분석 및 시각화
- **Day 11-12**: 음악 및 커뮤니티 기능
- **Day 13-14**: 최적화 및 테스트

---

## 📞 지원 및 리소스

### 유용한 링크
- [Flutter 공식 문서](https://docs.flutter.dev/)
- [Firebase 문서](https://firebase.google.com/docs)
- [OpenAI API 문서](https://platform.openai.com/docs)
- [Material Design 3](https://m3.material.io/)

### 참고 자료
- [Flutter 상태 관리 가이드](https://docs.flutter.dev/development/data-and-backend/state-mgmt)
- [Firebase Flutter 플러그인](https://firebase.flutter.dev/)
- [Flutter 반응형 디자인](https://docs.flutter.dev/development/ui/layout/responsive)
- [Flutter 접근성](https://docs.flutter.dev/development/ui/accessibility)

---

## 🎯 성공 기준

### 기능 완성도
- ✅ 사용자 회원가입/로그인 가능
- ✅ AI와 대화하며 일기 작성 가능
- ✅ 감정 분석 및 시각화 완벽 작동
- ✅ 감정 캐릭터 UI 전면 적용 (2026-01-23)
- ✅ 일기 목록/상세페이지 UI 개선 (2026-01-23)
- ✅ UI 오버플로우 완전 해결 (2026-01-23)
- ⏳ 음악 추천 및 재생 기능 (개발 중)
- ⏳ 커뮤니티 및 안전 관리 (준비 중)

### 품질 기준
- ✅ 앱 시작 시간 < 3초
- ✅ 반응 시간 < 100ms
- ✅ 크래시율 < 1%
- ✅ WCAG 2.1 AA 접근성 준수
- ✅ 모든 디바이스에서 최적화된 경험

### 사용자 경험
- ✅ 직관적이고 아름다운 UI/UX
- ✅ AI와의 자연스러운 상호작용
- ✅ 개인화된 감정 관리 경험
- ✅ 감정적 안정감과 성장 도움
- ✅ 일관된 브랜드 아이덴티티 (캐릭터 이미지 전면 적용)
- ✅ 반응형 레이아웃으로 모든 화면 크기 대응
- ✅ 다크모드 완벽 지원
