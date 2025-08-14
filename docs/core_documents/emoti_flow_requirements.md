# EmotiFlow - AI 기반 감정 일기 앱 요구사항 정의서

## 📋 프로젝트 개요

| 항목 | 내용 |
|------|------|
| **프로젝트명** | EmotiFlow (AI 기반 감정 일기 앱) |
| **개발 기간** | 2주 |
| **개발 도구** | Flutter + Firebase + OpenAI API |
| **목표** | AI와 함께하는 일상의 감정 파트너, 개인화된 감정 관리 및 성장 도구 |

---

## 🚀 핵심 기능 요구사항

### **1. 사용자 인증 및 프로필 관리**

| ID | 기능명 | 설명 | 관련 페이지 | 우선순위 | 개발단계 |
|----|--------|------|-------------|----------|----------|
| **REQ-001** | 사용자 인증 | 회원가입, 로그인/로그아웃, 소셜 로그인, 비밀번호 찾기 | /auth/signup, /auth/login, /auth/forgot | 높음 | 1주차 |
| **REQ-002** | 개인 프로필 설정 | 닉네임, 생년월일, 프로필 이미지 설정 | /profile/edit | 중간 | 1주차 |
| **REQ-003** | 감정 프로필 설정 | 개인 감정 선호도 및 패턴 설정 | /profile/emotions | 중간 | 2주차 |
| **REQ-004** | 약관 및 동의 관리 | 이용약관, 개인정보처리방침 동의, 마케팅 수신 동의 | /auth/terms, /settings/privacy | 높음 | 1주차 |
| **REQ-005** | 계정 및 데이터 관리 | 계정 삭제(탈퇴), 데이터 영구 삭제, 데이터 보존 정책 | /settings/account, /settings/data | 높음 | 2주차 |

### **2. AI 기반의 일기 작성 및 피드백 기능**

| ID | 기능명 | 설명 | 관련 페이지 | 우선순위 | 개발단계 |
|----|--------|------|-------------|----------|----------|
| **REQ-006** | AI 대화형 일기 | AI와 대화하며 일기를 작성하는 기능. 감정 키워드 기반 질문으로 깊이 있는 글쓰기 유도 | /diary/chat-write | 높음 | 1주차 |
| **REQ-007** | 자유형 일기 | 감정 아이콘, 텍스트, 사진 등을 자유롭게 조합하여 일기 작성 | /diary/free-write | 높음 | 1주차 |
| **REQ-008** | AI 감정 시각화 | 일기 내용을 바탕으로 AI가 추상적인 '감정 이미지' 생성 | /diary/emotion-visual | 높음 | 1주차 |
| **REQ-009** | 일기 분석 및 위로 | AI가 일기 내용을 분석하고 따뜻한 위로, 자기 성찰 질문, 해결 방안 제공 | /ai/analysis, /ai/advice | 높음 | 1주차 |
| **REQ-010** | 일기 관리 | 일기 편집, 삭제, 목록 보기, 검색/필터링 | /diary/list, /diary/edit/:id, /diary/detail/:id | 높음 | 1주차 |

### **3. 감정 기반의 콘텐츠 기능**

| ID | 기능명 | 설명 | 관련 페이지 | 우선순위 | 개발단계 |
|----|--------|------|-------------|----------|----------|
| **REQ-011** | 치유 BGM 자동 재생 | 선택한 감정에 따라 저작권 없는 음원 즉시 재생 | /music/emotion-bgm | 중간 | 1주차 |
| **REQ-012** | 긍정 카드 추천 | AI가 3가지 '오늘의 긍정 카드' 추천하여 목표 설정 | /cards/daily-positive | 중간 | 1주차 |
| **REQ-013** | 감정 패턴 챌린지 | AI가 감정 통계를 분석하여 맞춤형 챌린지 제안 | /challenges/emotion-pattern | 중간 | 2주차 |
| **REQ-014** | 그림 그리기 | 감정 표현을 위한 그림 그리기 기능 | /diary/draw | 중간 | 2주차 |

### **4. 데이터 시각화 및 커뮤니티 기능**

| ID | 기능명 | 설명 | 관련 페이지 | 우선순위 | 개발단계 |
|----|--------|------|-------------|----------|----------|
| **REQ-015** | 감정 통계 분석 | 주간, 월간, 연간 감정 변화를 그래프와 달력으로 시각화 | /analytics/trends, /analytics/calendar | 높음 | 1주차 |
| **REQ-016** | 기록 영상화 | 한 달 일기들을 모아 감정 패턴에 어울리는 음악과 함께 영상 제작 | /analytics/monthly-video | 중간 | 2주차 |
| **REQ-017** | 고민 공유 커뮤니티 | 익명성을 보장하며 비슷한 감정을 느낀 사람들과 소통 | /community/share, /community/anonymous | 중간 | 2주차 |
| **REQ-018** | 감정 위기 대처 도구 | 긴급 상황 시 대처 방법 및 연락처 제공 | /crisis/tools, /crisis/contacts | 중간 | 2주차 |
| **REQ-019** | 커뮤니티 안전 관리 | 신고/차단/키워드 필터링, 관리자 모더레이션, 가이드라인 | /community/moderation, /community/guidelines | 중간 | 2주차 |

### **5. 개인화 및 설정 기능**

| ID | 기능명 | 설명 | 관련 페이지 | 우선순위 | 개발단계 |
|----|--------|------|-------------|----------|----------|
| **REQ-020** | 테마 및 UI 설정 | 다크/라이트 테마, 앱 아이콘 및 색상 커스터마이징 | /settings/theme, /settings/appearance | 중간 | 1주차 |
| **REQ-021** | 알림 및 리마인더 | 일기 작성 리마인더, AI 조언, 목표 달성 알림, 딥링크 지원 | /settings/notifications, /settings/reminders | 중간 | 1주차 |
| **REQ-022** | 데이터 관리 | 사용자 데이터 백업, 클라우드 동기화, CSV/JSON 내보내기/가져오기 | /settings/backup, /settings/export | 중간 | 2주차 |
| **REQ-023** | 보안 및 개인정보 | 생체 인증, 앱 잠금, 민감 데이터 암호화, 개인정보 관리 | /settings/security, /settings/privacy | 중간 | 2주차 |

### **6. 시스템 및 운영 기능**

| ID | 기능명 | 설명 | 관련 페이지 | 우선순위 | 개발단계 |
|----|--------|------|-------------|----------|----------|
| **REQ-024** | 오프라인 및 동기화 | 오프라인 일기 작성/조회, 네트워크 복구 시 동기화, 충돌 해결 | /settings/sync, /offline | 중간 | 2주차 |
| **REQ-025** | AI 운영 및 모니터링 | AI 요청 타임아웃/재시도/폴백, 사용량 제한, 비용 모니터링 | /ai/settings, /ai/usage | 중간 | 2주차 |
| **REQ-026** | 성능 및 안정성 | 크래시 리포팅, 성능 모니터링, 이미지/영상 압축, 캐싱 | /settings/performance, /system | 낮음 | 2주차 |
| **REQ-027** | 접근성 및 국제화 | 접근성 지원, 다국어 지원, 색상 대비, 폰트 스케일 | /settings/accessibility, /settings/language | 낮음 | 2주차 |
| **REQ-028** | 반응형 UI 및 멀티 디바이스 | 태블릿, 폴드, 데스크톱 등 다양한 화면 크기에서의 UI 최적화 | /settings/display, /ui/responsive | 중간 | 2주차 |

---

## 🎯 기술 요구사항

| ID | 기술 요구사항 | 구현 방법 | 우선순위 |
|----|---------------|-----------|----------|
| **TECH-001** | Flutter 앱 개발 | Flutter SDK 3.16+ | 높음 |
| **TECH-002** | Firebase 연동 | Firebase Auth, Firestore, Storage | 높음 |
| **TECH-003** | OpenAI API 연동 | OpenAI GPT-4 API, 감정 분석 | 높음 |
| **TECH-004** | 차트 및 데이터 시각화 | fl_chart, syncfusion_flutter_charts | 높음 |
| **TECH-005** | 그림 그리기 기능 | Custom Paint, Canvas API | 중간 |
| **TECH-006** | 음원 재생 | audioplayers, just_audio | 중간 |
| **TECH-007** | 이미지 생성 | OpenAI DALL-E API | 높음 |
| **TECH-008** | 영상 제작 | video_player, ffmpeg | 낮음 |
| **TECH-009** | 로컬 저장소 | SharedPreferences, Hive | 중간 |
| **TECH-010** | HTTP 통신 | Dio, http | 높음 |
| **TECH-011** | 보안 및 암호화 | flutter_secure_storage, crypto | 중간 |
| **TECH-012** | 오프라인 지원 | connectivity_plus, sqflite | 중간 |
| **TECH-013** | 성능 모니터링 | Firebase Performance, Sentry | 낮음 |
| **TECH-014** | 접근성 | flutter_semantics, accessibility_tools | 낮음 |
| **TECH-015** | 반응형 UI | flutter_responsive, adaptive_components | 중간 |
| **TECH-016** | 멀티 디바이스 | device_info_plus, screen_util | 중간 |

---

## 🛠️ Flutter 앱 구현 요구사항

### **앱 아키텍처**
- **상태 관리**: Riverpod (StateNotifierProvider, FutureProvider, StreamProvider)
- **라우팅**: GoRouter (선언적 라우팅, 딥링크 지원)
- **아키텍처 패턴**: MVVM + Clean Architecture
- **의존성 주입**: Riverpod Provider 시스템

### **프로젝트 구조**
```
lib/
├── main.dart                    # 앱 진입점
├── app/                        # 앱 설정
│   ├── app.dart               # 메인 앱 위젯
│   ├── theme/                 # 테마 설정
│   └── routes/                # 라우팅 설정
├── features/                   # 기능별 모듈
│   ├── home/                  # 홈 기능
│   ├── diary/                 # 일기 기능
│   ├── ai/                    # AI 기능
│   ├── analytics/             # 분석 기능
│   ├── music/                 # 음악 기능
│   └── profile/               # 프로필 기능
├── shared/                     # 공통 컴포넌트
│   ├── widgets/               # 공통 위젯
│   ├── models/                # 공통 모델
│   ├── services/              # 공통 서비스
│   └── utils/                 # 유틸리티
└── core/                       # 핵심 기능
    ├── constants/              # 상수
    ├── errors/                 # 에러 처리
    └── network/                # 네트워크 처리
```

### **UI/UX 요구사항**
- **Material Design 3**: 최신 Material Design 가이드라인 준수
- **반응형 디자인**: 모바일, 태블릿, 폴드 디바이스 지원
- **다크/라이트 테마**: 시스템 설정 연동 및 수동 전환
- **접근성**: WCAG 2.1 AA 기준 준수, 스크린 리더 지원
- **애니메이션**: 부드러운 전환 효과 및 사용자 피드백

### **성능 요구사항**
- **앱 시작 시간**: 3초 이내
- **화면 전환**: 300ms 이내
- **이미지 로딩**: 2초 이내
- **데이터 동기화**: 백그라운드에서 자동 처리
- **메모리 사용량**: 최적화된 이미지 캐싱 및 관리

### **테스트 요구사항**
- **단위 테스트**: 비즈니스 로직 80% 이상 커버리지
- **위젯 테스트**: 주요 UI 컴포넌트 테스트
- **통합 테스트**: API 연동 및 데이터베이스 테스트
- **성능 테스트**: 메모리 누수 및 성능 병목 지점 테스트

## 📱 화면 구성

### **Flutter 앱 구조**

#### **메인 네비게이션 (BottomNavigationBar)**
```
🏠 홈 (/) → HomePage
✍️ 일기 (/diary) → DiaryPage  
🤖 AI (/ai) → AIPage
📊 분석 (/analytics) → AnalyticsPage
🎵 음악 (/music) → MusicPage
👤 프로필 (/profile) → ProfilePage
```

#### **페이지별 구성**

**1. 홈 페이지 (HomePage)**
- **AppBar**: 앱 제목, 알림 아이콘, 설정 아이콘
- **Body**: 
  - 오늘의 감정 체크 카드
  - 최근 일기 요약
  - AI 추천 콘텐츠
  - 빠른 일기 작성 버튼
- **BottomNavigationBar**: 메인 네비게이션

**2. 일기 작성 페이지 (DiaryPage)**
- **AppBar**: 뒤로가기, 저장, 공유
- **Body**:
  - 감정 선택 (EmotionSelector)
  - 일기 작성 폼 (DiaryForm)
  - 미디어 첨부 (MediaAttachment)
  - AI 도움말 (AIHelper)
- **FloatingActionButton**: 새 일기 작성

**3. AI 분석 페이지 (AIPage)**
- **AppBar**: 뒤로가기, 설정, 히스토리
- **Body**:
  - 감정 분석 결과 (EmotionAnalysis)
  - AI 조언 카드 (AIAdviceCard)
  - 감정 시각화 (EmotionVisualization)
  - 대화형 인터페이스 (ChatInterface)

**4. 분석 페이지 (AnalyticsPage)**
- **AppBar**: 뒤로가기, 기간 선택, 필터
- **Body**:
  - 감정 통계 차트 (EmotionChart)
  - 달력 뷰 (CalendarView)
  - 트렌드 분석 (TrendAnalysis)
  - 인사이트 요약 (InsightSummary)

**5. 음악 페이지 (MusicPage)**
- **AppBar**: 뒤로가기, 검색, 플레이리스트
- **Body**:
  - 현재 재생 (NowPlaying)
  - 감정별 음악 (EmotionMusic)
  - 플레이리스트 (Playlist)
  - 음악 추천 (MusicRecommendation)

**6. 프로필 페이지 (ProfilePage)**
- **AppBar**: 뒤로가기, 편집, 설정
- **Body**:
  - 프로필 정보 (ProfileInfo)
  - 감정 프로필 (EmotionProfile)
  - 통계 요약 (StatsSummary)
  - 설정 메뉴 (SettingsMenu)

### **공통 UI 컴포넌트**
- **AppBar**: 각 페이지 상단의 앱바 (제목, 뒤로가기, 액션 버튼)
- **BottomNavigationBar**: 하단 메인 네비게이션
- **FloatingActionButton**: 주요 액션 버튼
- **Card**: 정보 표시용 카드 컴포넌트
- **Dialog**: 모달 다이얼로그
- **SnackBar**: 간단한 알림 메시지
- **BottomSheet**: 하단에서 올라오는 시트

### **네비게이션 흐름**
```
SplashScreen → Onboarding → Login/Signup → MainApp
                                    ↓
                              HomePage (메인)
                                    ↓
                    ┌─────────┬─────────┬─────────┐
                    ↓         ↓         ↓         ↓
                DiaryPage  AIPage  AnalyticsPage  MusicPage
                    ↓         ↓         ↓         ↓
                DiaryDetail  AIAnalysis  ChartDetail  PlaylistDetail
                    ↓         ↓         ↓         ↓
                SettingsPage ← ProfilePage ← CommunityPage
```

### **주요 화면 및 기능**

#### **인증 및 프로필**
- **인증**: 로그인, 회원가입, 비밀번호 찾기, 약관 동의
- **프로필**: 개인 정보 수정, 감정 프로필 설정, 계정 관리
- **설정**: 테마, 알림, 데이터, 보안, 접근성

#### **일기 작성 및 관리**
- **AI 대화형 일기**: AI와 대화하며 일기 작성
- **자유형 일기**: 텍스트, 이미지, 그림 자유롭게 조합
- **일기 관리**: 편집, 삭제, 목록 보기, 검색/필터링
- **그림 그리기**: 감정 표현을 위한 그림 도구

#### **AI 서비스**
- **감정 분석**: 일기 내용 분석 및 위로 메시지
- **AI 감정 시각화**: 추상적인 감정 이미지 생성
- **긍정 카드 추천**: 맞춤형 목표 설정 및 격려
- **감정 패턴 챌린지**: 개인 맞춤형 감정 관리 챌린지

#### **콘텐츠 및 엔터테인먼트**
- **치유 BGM**: 감정별 맞춤 음악 자동 재생
- **음악 플레이어**: 감정별 BGM 재생 및 플레이리스트
- **기록 영상화**: 월간 일기 요약 영상 제작

#### **데이터 분석 및 시각화**
- **감정 통계**: 주간/월간/연간 감정 변화 차트
- **트렌드 분석**: 감정 패턴 및 변화 추이
- **달력 뷰**: 일별 감정 상태 및 일기 요약

#### **커뮤니티 및 지원**
- **고민 공유**: 익명 고민 공유 및 상호 지원
- **커뮤니티 관리**: 신고/차단/키워드 필터링
- **감정 위기 대처**: 긴급 상황 대처 가이드 및 연락처

#### **시스템 및 기술**
- **오프라인 지원**: 네트워크 없이 일기 작성/조회
- **동기화**: 클라우드 데이터 동기화 및 충돌 해결
- **성능 모니터링**: 크래시 리포팅 및 성능 최적화
- **접근성**: 스크린 리더 지원, 색상 대비, 다국어
- **반응형 UI**: 다양한 화면 크기 최적화 (모바일/태블릿/데스크톱)

### **사용자 경험 (UX) 특징**
- **직관적 인터페이스**: 감정 기반 색상 및 아이콘 활용
- **개인화**: 사용자 선호도 및 패턴 기반 맞춤 서비스
- **접근성**: 모든 사용자가 편리하게 이용할 수 있는 UI/UX
- **반응형**: 다양한 디바이스에서 최적화된 경험 제공
- **오프라인 지원**: 네트워크 상태와 관계없이 핵심 기능 이용 가능

---

## 📋 문서 정보

### **문서 버전 관리**
| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|-----------|--------|
| 1.0 | 2024년 12월 | 초기 작성 | AI Assistant |
| 1.1 | 2024년 12월 | 화면 구성 상세화 및 일관성 개선 | AI Assistant |

### **검토 및 승인**
| 단계 | 담당자 | 날짜 | 상태 |
|------|--------|------|------|
| 작성 | AI Assistant | 2024년 12월 | 완료 |
| 검토 | - | - | 대기 |
| 승인 | - | - | 대기 |

### **참고 문서**
- `emoti_flow_functional_spec.md`: 기능 상세 명세서
- `emoti_flow_ia.md`: 정보 아키텍처 문서
- `emoti_flow_page_definition.md`: 페이지 정의서
- `emoti_flow_uiux_guide.md`: UI/UX 상세 가이드

---

## 🔄 변경 이력

### **v1.1 (2024년 12월)**
- **개선된 내용**:
  - 화면 구성 섹션 상세화
  - 기능별 분류 체계 정리
  - 사용자 경험 특징 추가
  - functional_spec과의 일관성 확보

- **수정된 내용**:
  - 주요 화면을 기능별로 체계적 분류
  - 시스템 및 기술 기능 상세 설명 추가
  - UX 특징 및 접근성 강조



