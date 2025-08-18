# EmotiFlow - 정보 아키텍처(IA) 문서

## 📋 문서 개요

| 항목 | 내용 |
|------|------|
| **문서명** | EmotiFlow 정보 아키텍처(IA) 문서 |
| **작성일** | 2024년 12월 |
| **버전** | 1.0 |
| **작성자** | AI Assistant |
| **목적** | 앱의 전체 구조, 네비게이션, 사용자 플로우 정의 |

---

## 🏗️ 앱 전체 구조

### **1. 앱 아키텍처 개요**
```
EmotiFlow App
├── Authentication Layer (인증 계층)
├── Core Features Layer (핵심 기능 계층)
├── AI Services Layer (AI 서비스 계층)
├── Data Visualization Layer (데이터 시각화 계층)
├── Community Layer (커뮤니티 계층)
├── Settings Layer (설정 계층)
└── Profile Layer (프로필 계층)
```

### **2. 기술적 아키텍처**
```
Frontend (Flutter)
├── UI Components
├── State Management
├── Navigation
└── Local Storage

Backend Services
├── Firebase Authentication
├── Cloud Firestore
├── Firebase Storage
├── Firebase Cloud Messaging
└── OpenAI API Integration

Data Flow
├── User Input → Local Processing
├── Local → Cloud Sync
├── AI Analysis → Results
└── Results → UI Update
```

---

## 🧭 네비게이션 구조

### **1. 메인 네비게이션 (Bottom Navigation)**
```
🏠 홈 (/)
├── 오늘의 감정 요약
├── 최근 일기 미리보기
├── AI 일일 조언
└── 빠른 액션 버튼

✍️ 일기 (/diary)
├── AI 대화형 일기 작성
├── 자유형 일기 작성
├── 일기 목록
└── 그림 그리기

🤖 AI (/ai)
├── 감정 분석 결과
├── AI 조언 및 위로
└── 감정 시각화

📊 트렌드 (/analytics)
├── 감정 변화 차트
├── 감정 달력
└── 월간 리포트

🎵 음악 (/music)
├── 감정별 BGM 플레이어
└── 음악 라이브러리

👤 프로필 (/profile)
├── 개인 정보
├── 감정 프로필
└── 설정
```

### **2. 세부 네비게이션 구조 (Riverpod + MVVM)**

#### **인증 플로우**
```
/auth
├── /auth/signup (회원가입)
├── /auth/login (로그인)
└── /auth/forgot (비밀번호 찾기)
```

#### **일기 관련**
```
/diary
├── /diary/chat-write (AI 대화형 일기)
├── /diary/free-write (자유형 일기)
├── /diary/list (일기 목록)
├── /diary/detail/:id (일기 상세)
└── /diary/draw (그림 그리기)
```

#### **AI 서비스**
```
/ai
├── /ai/analysis (감정 분석)
├── /ai/advice (AI 조언)
└── /ai/visual (감정 이미지)
```

#### **분석 및 통계**
```
/analytics
├── /analytics/trends (트렌드 차트)
├── /analytics/calendar (감정 달력)
└── /analytics/monthly-video (월간 영상)
```

#### **설정**
```
/settings
├── /settings/theme (테마 설정)
├── /settings/notifications (알림 설정)
├── /settings/backup (데이터 백업)
└── /settings/security (보안)
```

---

## 🔄 사용자 플로우

### **1. 신규 사용자 온보딩 플로우**
```
앱 설치 → 약관 동의 → 회원가입 → 프로필 설정 → 메인 홈
```

### **2. 일기 작성 플로우**
```
메인 홈 → 일기 작성 → AI 분석 → 결과 확인 → 저장 완료
```

### **3. 감정 트렌드 확인 플로우**
```
메인 홈 → 트렌드 탭 → 차트 표시 → 상세 분석
```

---

## 📱 화면 계층 구조 (MVVM)

### **1. 화면 깊이 (Screen Depth)**
```
Level 0: 메인 탭 (Bottom Navigation)
Level 1: 주요 기능 화면
Level 2: 상세 화면
Level 3: 설정/편집 화면
```

### **2. 화면 전환 규칙**
- **수평 전환**: 같은 레벨 내 탭 간 이동
- **수직 전환**: 상위 → 하위 레벨로 이동
- **뒤로가기**: 하위 → 상위 레벨로 복귀

---

## 🎯 사용자 경험(UX) 플로우

### **1. 일일 사용 플로우**
```
알림 수신 → 앱 실행 → 홈 화면 확인 → 일기 작성 → AI 분석 → 결과 확인 → 앱 종료
```

### **2. 주간 사용 플로우**
```
일일 일기 작성 → 주간 요약 확인 → 감정 패턴 분석 → 트렌드 확인
```

---

## 🔐 보안 및 권한 구조

### **1. 사용자 권한 레벨**
```
Guest (비로그인)
├── 앱 소개 보기
└── 회원가입/로그인

User (일반 사용자)
├── 모든 기본 기능 사용
└── 개인 데이터 관리
```

### **2. 데이터 접근 권한**
```
Private Data
├── 개인 일기 내용
├── 감정 분석 결과
└── 개인 설정
```

---

## 📊 데이터 구조 개요

### **1. 주요 데이터 엔티티**
```
User (사용자)
├── Profile (프로필)
├── DiaryEntries (일기 목록)
└── Settings (설정)

DiaryEntry (일기)
├── Content (내용)
├── Emotions (감정)
└── AIAnalysis (AI 분석)
```

### **2. 데이터 흐름**
```
사용자 입력 → 로컬 저장 → 클라우드 동기화 → AI 분석 → 결과 저장 → UI 업데이트
```

---

## 🚀 확장성 고려사항

### **1. 기능 확장 포인트**
- **AI 모델**: GPT-4 → GPT-5, 커스텀 모델
- **플랫폼**: 모바일 → 웹, 데스크톱
- **통합**: 건강 앱, 캘린더 앱 연동

### **2. 사용자 규모 확장**
- **개인 사용자**: 1인 → 가족 계정
- **지역**: 국내 → 글로벌


