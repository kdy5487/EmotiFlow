# EmotiFlow - AI 기반 감정 일기 앱 요구사항 정의서

## **프로젝트 개요**
- **프로젝트명**: EmotiFlow (AI 기반 감정 일기 앱)
- **개발 기간**: 2주
- **개발 도구**: Flutter + Firebase + OpenAI API
- **목표**: AI와 함께하는 일상의 감정 파트너, 개인화된 감정 관리 및 성장 도구

---

## **1. 만들고 싶은 프로젝트 주제 선정**

### **프로젝트명**: EmotiFlow (AI 기반 감정 일기 앱)
- **개발 기간**: 2주
- **개발 도구**: Flutter + Firebase + OpenAI API
- **목표**: AI와 함께하는 일상의 감정 파트너, 개인화된 감정 관리 및 성장 도구

---

## **2. 아이디어, 컨셉, 주요기능등을 적은 문서를 생성(아이디어문서)**

### **아이디어**
- AI가 사용자의 감정을 분석하고 개인화된 조언을 제공하는 감정 일기 앱
- 매일 사용하는 습관 형성으로 정신 건강 관리
- 감정 데이터를 시각화하여 자기 이해 증진

### **컨셉**
- **앱 이름**: EmotiFlow (이모티플로우)
- **핵심 가치**: AI와 함께하는 일상의 감정 파트너
- **슬로건**: "감정의 흐름을 AI와 함께 탐험하세요"
- **타겟**: 20-30대 감정 표현과 자기 성찰에 관심 있는 젊은 층

### **주요 기능**
1. **일기 작성**: 텍스트 + 감정 선택 + 그림 그리기
2. **AI 감정 분석**: OpenAI API를 활용한 감정 상태 분석
3. **감정 트렌드**: 일별/주별/월별 감정 변화 차트
4. **AI 개인 조언**: 감정에 맞는 맞춤형 조언 및 피드백
5. **감정 관리 도구**: 위기 대처, 목표 설정, 알림 시스템

---

## **3. 요구사항 정의서 (Requirement Specification)**

| ID | 요구사항 설명 | 우선순위 | 관련 페이지 | 개발 단계 |
|----|---------------|----------|-------------|-----------|
| **REQ-001** | 사용자 인증 (회원가입/로그인) | 높음 | /auth/signup, /auth/login | 1주차 |
| **REQ-002** | 일기 작성 (텍스트 + 감정 선택) | 높음 | /diary/write, /diary/edit | 1주차 |
| **REQ-003** | 감정 카테고리 및 강도 설정 | 높음 | /diary/write, /emotions | 1주차 |
| **REQ-004** | AI 감정 분석 (텍스트 기반) | 높음 | /diary/analysis, /ai/insights | 1주차 |
| **REQ-005** | 감정 트렌드 차트 및 통계 | 높음 | /analytics, /analytics/trends | 1주차 |
| **REQ-006** | AI 개인 조언 및 피드백 | 높음 | /ai/advice, /ai/daily-tip | 1주차 |
| **REQ-007** | 그림 그리기 및 감정 표현 | 중간 | /diary/draw, /diary/art | 1주차 |
| **REQ-008** | 감정 일정 관리 및 알림 | 중간 | /calendar, /reminders | 1주차 |
| **REQ-009** | 감정 위기 대처 도구 | 중간 | /crisis, /crisis/tools | 2주차 |
| **REQ-010** | 개인 감정 프로필 및 설정 | 중간 | /profile, /profile/emotions | 2주차 |
| **REQ-011** | 감정 데이터 내보내기 | 중간 | /export, /export/data | 2주차 |
| **REQ-012** | 감정 기반 목표 설정 및 추적 | 중간 | /goals, /goals/tracking | 2주차 |
| **REQ-013** | 감정 공유 및 커뮤니티 | 낮음 | /community, /community/share | 2주차 |
| **REQ-014** | 다크/라이트 테마 및 개인화 | 낮음 | /settings, /settings/theme | 2주차 |
| **REQ-015** | 데이터 백업 및 동기화 | 낮음 | /settings/backup | 2주차 |

---

## **4. IA 문서 (Information Architecture)**

### **사이트맵 구조**
- Home (/)
- 인증
  - 로그인 (/auth/login)
  - 회원가입 (/auth/signup)
- 일기
  - 일기 작성 (/diary/write)
  - 일기 편집 (/diary/edit/:id)
  - 일기 목록 (/diary/list)
  - 일기 상세 (/diary/detail/:id)
  - 그림 그리기 (/diary/draw)
- AI 분석
  - 감정 분석 (/ai/analysis)
  - AI 조언 (/ai/advice)
  - 일일 피드백 (/ai/daily-tip)
- 분석
  - 감정 트렌드 (/analytics/trends)
  - 감정 통계 (/analytics/stats)
  - 개인 리포트 (/analytics/report)
- 캘린더
  - 감정 캘린더 (/calendar)
  - 일정 관리 (/calendar/events)
  - 알림 설정 (/calendar/reminders)
- 목표
  - 목표 설정 (/goals)
  - 목표 추적 (/goals/tracking)
  - 성취 기록 (/goals/achievements)
- 커뮤니티
  - 감정 공유 (/community/share)
  - 익명 공유 (/community/anonymous)
  - 팁 공유 (/community/tips)
- 프로필
  - 개인 정보 (/profile)
  - 감정 프로필 (/profile/emotions)
  - 설정 (/profile/settings)
- 설정
  - 테마 설정 (/settings/theme)
  - 알림 설정 (/settings/notifications)
  - 데이터 관리 (/settings/data)
  - 백업/동기화 (/settings/backup)

### **네비게이션 메뉴**
- [홈](/)
- [일기 작성](/diary/write)
- [AI 분석](/ai/analysis)
- [트렌드](/analytics/trends)
- [캘린더](/calendar)
- [프로필](/profile)

---

## **5. 페이지 정의서 (Page Definition)**

### **PAGE_HOME**
- URL: /
- 설명: 메인 홈 화면
- 주요 섹션:
  - Header (앱 로고, 프로필 아이콘)
  - Quick Actions (일기 작성, AI 분석, 트렌드 보기)
  - Today's Mood (오늘의 감정 요약)
  - Recent Entries (최근 일기 미리보기)
  - AI Daily Tip (오늘의 AI 조언)
  - Bottom Navigation

### **PAGE_AUTH_LOGIN**
- URL: /auth/login
- 설명: 로그인 페이지
- 주요 섹션:
  - Header (뒤로가기, 로고)
  - LoginForm (이메일, 비밀번호 입력)
  - Social Login (Google, Apple 로그인)
  - Forgot Password (비밀번호 찾기)
  - Sign Up Link (회원가입 링크)

### **PAGE_AUTH_SIGNUP**
- URL: /auth/signup
- 설명: 회원가입 페이지
- 주요 섹션:
  - Header (뒤로가기, 로고)
  - SignupForm (이메일, 비밀번호, 닉네임, 생년월일)
  - Terms & Conditions (이용약관 동의)
  - Privacy Policy (개인정보처리방침)
  - Login Link (로그인 링크)

### **PAGE_DIARY_WRITE**
- URL: /diary/write
- 설명: 일기 작성 페이지
- 주요 섹션:
  - Header (뒤로가기, 저장 버튼)
  - DatePicker (날짜 선택)
  - EmotionSelector (감정 카테고리 및 강도)
  - TextEditor (일기 내용 작성)
  - DrawingCanvas (그림 그리기)
  - PhotoUpload (사진 첨부)
  - SaveButton (저장 버튼)

### **PAGE_AI_ANALYSIS**
- URL: /ai/analysis
- 설명: AI 감정 분석 결과 페이지
- 주요 섹션:
  - Header (뒤로가기, 공유 버튼)
  - EmotionSummary (감정 요약)
  - DetailedAnalysis (상세 분석 결과)
  - EmotionTrends (감정 변화 트렌드)
  - PersonalizedAdvice (개인화된 조언)
  - ActionItems (실행 가능한 액션 아이템)

### **PAGE_ANALYTICS_TRENDS**
- URL: /analytics/trends
- 설명: 감정 트렌드 분석 페이지
- 주요 섹션:
  - Header (뒤로가기, 필터 버튼)
  - TimeRangeSelector (기간 선택)
  - EmotionChart (감정 변화 차트)
  - MoodDistribution (감정 분포 파이 차트)
  - WeeklySummary (주간 요약)
  - MonthlyInsights (월간 인사이트)

---

## **6. 기능 상세 명세서 (Functional Detail Spec)**

### **기능명: 일기 작성**
- **입력**: 날짜, 감정 선택, 감정 강도, 일기 내용, 그림(선택), 사진(선택)
- **처리**: 
  - 모든 필수 필드 입력 확인
  - 감정 강도 1-10점 범위 검증
  - 일기 내용 최소 10자 이상 확인
  - 이미지 압축 및 최적화
- **출력**: 저장 완료 시 일기 목록으로 이동, 성공 메시지 표시

### **기능명: AI 감정 분석**
- **입력**: 일기 텍스트 내용, 선택된 감정, 감정 강도
- **처리**: 
  - OpenAI API로 텍스트 감정 분석
  - 사용자 선택 감정과 AI 분석 결과 비교
  - 감정 변화 패턴 분석
  - 개인화된 조언 생성
- **출력**: 감정 분석 결과, AI 조언, 실행 가능한 액션 아이템

### **기능명: 감정 트렌드 차트**
- **입력**: 선택된 기간 (일/주/월), 감정 데이터
- **처리**: 
  - 기간별 감정 데이터 집계
  - 감정 변화 선 그래프 생성
  - 감정별 분포 파이 차트 생성
  - 평균 감정 점수 계산
- **출력**: 인터랙티브 차트, 통계 요약, 인사이트 텍스트

### **기능명: 감정 위기 대처**
- **입력**: 현재 감정 상태, 위기 수준
- **처리**: 
  - 위기 수준에 따른 대처법 분류
  - 개인 맞춤형 대처 방법 제안
  - 긴급 연락처 정보 제공
  - 즉시 실행 가능한 액션 제시
- **출력**: 대처 방법 목록, 긴급 연락처, 액션 가이드

### **기능명: 그림 그리기**
- **입력**: 터치/드래그 제스처, 색상 선택, 브러시 크기
- **처리**: 
  - Canvas API를 통한 그림 데이터 저장
  - 색상 분석으로 감정 상태 추정
  - 그림 복잡도 및 패턴 분석
- **출력**: 완성된 그림, 감정 태그, 저장된 이미지

---

## **7. UI/UX 상세 가이드 (UI/UX Detailed Guide)**

### **컬러 팔레트**
- **Primary**: #6366F1 (인디고 - 신뢰와 안정감)
- **Secondary**: #EC4899 (핑크 - 따뜻함과 공감)
- **Success**: #10B981 (에메랄드 - 성장과 긍정)
- **Warning**: #F59E0B (앰버 - 주의와 경계)
- **Error**: #EF4444 (레드 - 위험과 경고)
- **Background**: #F8FAFC (슬레이트 - 깔끔함)
- **Surface**: #FFFFFF (화이트 - 순수함)
- **Text Primary**: #1E293B (슬레이트 - 가독성)
- **Text Secondary**: #64748B (슬레이트 - 부가 정보)

### **감정별 컬러 매핑**
- **기쁨**: #FBBF24 (노랑)
- **슬픔**: #3B82F6 (파랑)
- **분노**: #EF4444 (빨강)
- **평온**: #10B981 (초록)
- **설렘**: #EC4899 (핑크)
- **걱정**: #8B5CF6 (보라)
- **감사**: #F97316 (주황)
- **지루함**: #6B7280 (회색)

### **폰트**
- **기본 폰트**: Pretendard, sans-serif
- **크기 계층**:
  - H1: 32px Bold (메인 타이틀)
  - H2: 24px Bold (섹션 타이틀)
  - H3: 20px Medium (서브 타이틀)
  - Body Large: 16px Regular (본문)
  - Body: 14px Regular (기본 텍스트)
  - Caption: 12px Regular (부가 정보)

### **버튼 스타일**
- **Primary Button**: 
  - 배경색 Primary, 높이 56px, border-radius 16px
  - 그림자: 0 4px 12px rgba(99, 102, 241, 0.3)
  - Hover: 색상 #4F46E5, 그림자 강화
  
- **Secondary Button**:
  - 배경색 투명, 테두리 Primary, 높이 48px
  - border-radius 12px, Hover 시 배경색 Primary

- **Icon Button**:
  - 크기 48x48px, border-radius 50%
  - 배경색 Surface, 테두리 1px solid #E2E8F0

### **카드 스타일**
- **기본 카드**:
  - 배경색 Surface, border-radius 16px
  - 그림자: 0 2px 8px rgba(0, 0, 0, 0.1)
  - 패딩: 20px, 마진: 16px
  
- **감정 카드**:
  - 감정별 컬러 그라데이션 배경
  - border-radius 20px, 그림자 강화

### **반응형 규칙**
- **Mobile**: <640px (1단 레이아웃, 세로 스크롤)
- **Tablet**: 641~1024px (2단 레이아웃, 가로/세로 혼합)
- **Desktop**: >1024px (3단 레이아웃, 사이드바 포함)

### **애니메이션**
- **페이지 전환**: Slide transition (300ms ease-in-out)
- **카드 등장**: Fade in + Scale (400ms ease-out)
- **버튼 클릭**: Scale down (150ms ease-in)
- **감정 선택**: Bounce effect (200ms ease-out)
- **차트 로딩**: Progressive reveal (600ms ease-out)

### **접근성 지침**
- **색상 대비**: 최소 4.5:1 비율 유지
- **터치 영역**: 최소 44x44px
- **폰트 크기**: 사용자 설정 반영
- **스크린 리더**: 모든 요소에 적절한 라벨 제공
- **키보드 네비게이션**: Tab 키로 모든 요소 접근 가능

---

## **8. 기술적 요구사항**

| ID | 기술 요구사항 | 우선순위 | 구현 방법 |
|----|---------------|----------|-----------|
| **TECH-001** | Flutter 앱 개발 | 높음 | Flutter SDK 3.16+ |
| **TECH-002** | Firebase 연동 | 높음 | Firebase Auth, Firestore, Storage |
| **TECH-003** | OpenAI API 연동 | 높음 | OpenAI GPT-4 API, 감정 분석 |
| **TECH-004** | 차트 및 데이터 시각화 | 높음 | fl_chart, syncfusion_flutter_charts |
| **TECH-005** | 그림 그리기 기능 | 중간 | Custom Paint, Canvas API |
| **TECH-006** | 실시간 데이터 동기화 | 중간 | Firebase Realtime Database |
| **TECH-007** | 푸시 알림 및 리마인더 | 중간 | Firebase Cloud Messaging |
| **TECH-008** | 데이터 분석 및 통계 | 중간 | Firebase Analytics, Custom Analytics |
| **TECH-009** | 데이터 내보내기 | 낮음 | CSV/JSON Export, Share API |
| **TECH-010** | 테마 및 개인화 | 낮음 | SharedPreferences, ThemeData |

---

## **9. 개발 로드맵**

### **1주차 (MVP - 핵심 기능)**
- **REQ-001** ~ **REQ-007**: 기본 앱 구조 및 핵심 기능
- 목표: 사용자가 일기를 작성하고 AI 감정 분석을 받을 수 있는 기본적인 감정 일기 앱

### **2주차 (고도화 - 고급 기능)**
- **REQ-008** ~ **REQ-015**: 감정 관리 도구 강화 및 사용자 경험 개선
- 목표: AI 기반 고급 감정 분석과 개인화된 감정 관리 시스템 완성

---

## **10. 성공 기준**

### **1주차 완료 기준**
- ✅ 사용자 회원가입/로그인 가능
- ✅ 텍스트 일기 작성 및 감정 선택 가능
- ✅ AI 감정 분석 결과 확인 가능
- ✅ 기본 감정 트렌드 차트 표시 가능
- ✅ AI 개인 조언 받기 가능

### **2주차 완료 기준**
- ✅ 그림 그리기 및 감정 표현 가능
- ✅ 감정 일정 관리 및 알림 기능
- ✅ 감정 위기 대처 도구 제공
- ✅ 개인화된 감정 프로필 설정
- ✅ 감정 데이터 분석 및 인사이트 제공

---

## **11. 핵심 기능 상세**

### **감정 카테고리 (8가지)**
1. **기쁨** - 행복, 만족, 흥미
2. **슬픔** - 우울, 상실감, 외로움
3. **분노** - 화남, 짜증, 좌절
4. **평온** - 차분함, 안정감, 여유
5. **설렘** - 기대, 긴장, 흥미
6. **걱정** - 불안, 스트레스, 두려움
7. **감사** - 고마움, 만족, 행복
8. **지루함** - 단조로움, 무료함, 관심 없음

### **AI 감정 분석 기능**
- 텍스트 내용의 감정 상태 분석
- 감정 강도 및 복합 감정 식별
- 감정 변화 패턴 인식
- 개인화된 감정 관리 조언

---

## **문서 버전 정보**
- **작성일**: 2024년 12월
- **버전**: 1.0
- **작성자**: AI Assistant
- **검토자**: -
- **승인자**: -
