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

## 📱 화면 구성

### **메인 네비게이션**
- 🏠 홈 (/)
- ✍️ 일기 작성 (/diary)
- 🤖 AI 분석 (/ai)
- 📊 트렌드 (/analytics)
- 🎵 음악 (/music)
- 👤 프로필 (/profile)

### **주요 화면**
- **인증**: 로그인, 회원가입, 비밀번호 찾기, 약관 동의
- **일기 작성**: AI 대화형 + 자유형 일기 작성
- **AI 분석**: 감정 분석 결과, 위로 메시지, 해결 방안
- **감정 시각화**: AI 생성 감정 이미지, 감정 팔레트
- **음악 플레이어**: 감정별 BGM 재생
- **통계 대시보드**: 감정 변화 차트, 달력 뷰
- **커뮤니티**: 익명 고민 공유, 소통, 모더레이션
- **설정**: 테마, 알림, 데이터, 보안, 접근성
- **시스템**: 성능, 동기화, 오프라인 모드
- **반응형 UI**: 다양한 화면 크기에 최적화된 레이아웃

---



