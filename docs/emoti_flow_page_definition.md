# EmotiFlow - 페이지 정의서

## 📋 문서 개요

| 항목 | 내용 |
|------|------|
| **문서명** | EmotiFlow 페이지 정의서 |
| **작성일** | 2024년 12월 |
| **버전** | 1.0 |
| **작성자** | AI Assistant |
| **목적** | 각 페이지의 목적, 구성 요소, 기능 상세 정의 |

---

## 🏠 메인 페이지

### **PAGE_HOME**
- **URL**: /
- **목적**: 앱의 메인 대시보드, 사용자의 일일 감정 요약 및 빠른 액션 제공
- **주요 구성 요소**:
  - Header: 앱 로고, 프로필 아이콘, 알림 아이콘
  - Today's Mood: 오늘의 감정 요약 카드
  - Quick Actions: 일기 작성, AI 분석, 트렌드 보기 버튼
  - Recent Entries: 최근 일기 미리보기 (3-5개)
  - AI Daily Tip: 오늘의 AI 조언 카드
  - Bottom Navigation Bar
- **상호작용**:
  - 각 카드 터치 시 해당 상세 페이지로 이동
  - 빠른 액션 버튼 터치 시 해당 기능 실행
  - 프로필 아이콘 터치 시 프로필 페이지로 이동

---

## 🔐 인증 페이지

### **PAGE_AUTH_SIGNUP**
- **URL**: /auth/signup
- **목적**: 신규 사용자 회원가입
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 앱 로고
  - Signup Form: 이메일, 비밀번호, 비밀번호 확인, 닉네임 입력
  - Terms & Conditions: 이용약관, 개인정보처리방침 동의 체크박스
  - Sign Up Button: 회원가입 버튼
  - Login Link: 로그인 페이지 링크
- **상호작용**:
  - 모든 필수 필드 입력 시 회원가입 버튼 활성화
  - 약관 동의 필수
  - 회원가입 성공 시 자동 로그인 및 홈으로 이동

### **PAGE_AUTH_LOGIN**
- **URL**: /auth/login
- **목적**: 기존 사용자 로그인
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 앱 로고
  - Login Form: 이메일, 비밀번호 입력
  - Social Login: Google, Apple 로그인 버튼
  - Forgot Password: 비밀번호 찾기 링크
  - Login Button: 로그인 버튼
  - Sign Up Link: 회원가입 페이지 링크
- **상호작용**:
  - 이메일/비밀번호 입력 시 로그인 버튼 활성화
  - 소셜 로그인 시 해당 플랫폼 인증 진행
  - 로그인 성공 시 홈 페이지로 이동

### **PAGE_AUTH_FORGOT**
- **URL**: /auth/forgot
- **목적**: 비밀번호 재설정
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 앱 로고
  - Email Form: 이메일 주소 입력
  - Send Reset Button: 재설정 이메일 발송 버튼
  - Instructions: 재설정 방법 안내 텍스트
- **상호작용**:
  - 이메일 입력 후 버튼 터치 시 재설정 이메일 발송
  - 발송 완료 시 확인 메시지 표시

---

## ✍️ 일기 관련 페이지

### **PAGE_DIARY_CHAT_WRITE**
- **URL**: /diary/chat-write
- **목적**: AI와 대화하며 일기 작성
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 저장 버튼
  - Date Picker: 날짜 선택
  - Chat Interface: AI와의 대화 인터페이스
  - Emotion Selector: 감정 카테고리 및 강도 선택
  - Text Input: 사용자 응답 입력
  - AI Suggestions: AI 질문 및 제안
- **상호작용**:
  - AI가 감정 키워드 기반 질문 제시
  - 사용자 응답에 따른 다음 질문 생성
  - 감정 선택 시 해당 감정에 맞는 질문 조정
  - 저장 시 AI 분석 결과와 함께 일기 저장

### **PAGE_DIARY_FREE_WRITE**
- **URL**: /diary/free-write
- **목적**: 자유롭게 일기 작성
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 저장 버튼
  - Date Picker: 날짜 선택
  - Emotion Selector: 감정 카테고리 및 강도 선택
  - Text Editor: 자유 텍스트 입력
  - Photo Upload: 사진 첨부 버튼
  - Drawing Button: 그림 그리기 버튼
- **상호작용**:
  - 자유롭게 텍스트 입력
  - 사진 첨부 및 그림 그리기 가능
  - 감정 선택 시 해당 감정에 맞는 UI 색상 변경
  - 저장 시 AI 분석 진행

### **PAGE_DIARY_LIST**
- **URL**: /diary/list
- **목적**: 작성된 일기 목록 확인
- **주요 구성 요소**:
  - Header: 제목, 필터 버튼
  - Search Bar: 일기 검색
  - Filter Options: 날짜, 감정, 키워드 필터
  - Diary List: 일기 카드 목록
  - FAB: 새 일기 작성 버튼
- **상호작용**:
  - 일기 카드 터치 시 상세 페이지로 이동
  - 검색 및 필터링으로 원하는 일기 찾기
  - 새 일기 작성 버튼으로 작성 페이지로 이동

### **PAGE_DIARY_DETAIL**
- **URL**: /diary/detail/:id
- **목적**: 특정 일기 상세 내용 확인
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 편집 버튼, 공유 버튼
  - Diary Content: 일기 내용 표시
  - Emotion Info: 선택된 감정 및 강도
  - AI Analysis: AI 분석 결과
  - Media: 첨부된 사진, 그림
  - Action Buttons: 편집, 삭제, 공유
- **상호작용**:
  - 편집 버튼 터치 시 편집 페이지로 이동
  - 삭제 버튼 터치 시 확인 다이얼로그 표시
  - 공유 버튼 터치 시 공유 옵션 표시

### **PAGE_DIARY_DRAW**
- **URL**: /diary/draw
- **목적**: 감정 표현을 위한 그림 그리기
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 저장 버튼
  - Canvas: 그림 그리기 영역
  - Tool Bar: 브러시 크기, 색상 선택
  - Emotion Tags: 감정 태그 선택
  - Clear Button: 캔버스 초기화
- **상호작용**:
  - 터치/드래그로 그림 그리기
  - 브러시 크기 및 색상 변경
  - 감정 태그 선택으로 그림에 감정 표현
  - 저장 시 일기에 그림 첨부

---

## 🤖 AI 서비스 페이지

### **PAGE_AI_ANALYSIS**
- **URL**: /ai/analysis
- **목적**: AI 감정 분석 결과 표시
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 공유 버튼
  - Emotion Summary: 감정 요약 카드
  - Detailed Analysis: 상세 분석 결과
  - Emotion Trends: 감정 변화 트렌드
  - Personalized Advice: 개인화된 조언
  - Action Items: 실행 가능한 액션 아이템
- **상호작용**:
  - 각 섹션 확장/축소 가능
  - 공유 버튼으로 분석 결과 공유
  - 액션 아이템 체크박스로 완료 표시

### **PAGE_AI_ADVICE**
- **URL**: /ai/advice
- **목적**: AI 개인 조언 및 피드백 제공
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 새로고침 버튼
  - Daily Advice: 오늘의 AI 조언
  - Personalized Tips: 개인 맞춤 팁
  - Growth Suggestions: 성장 제안
  - Mood Improvement: 기분 개선 방법
- **상호작용**:
  - 새로고침 버튼으로 새로운 조언 요청
  - 각 조언 카드 터치 시 상세 내용 표시
  - 유용한 조언 북마크 가능

---

## 📊 분석 및 통계 페이지

### **PAGE_ANALYTICS_TRENDS**
- **URL**: /analytics/trends
- **목적**: 감정 변화 트렌드 차트 표시
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 필터 버튼
  - Time Range Selector: 기간 선택 (일/주/월/년)
  - Emotion Chart: 감정 변화 선 그래프
  - Mood Distribution: 감정 분포 파이 차트
  - Weekly Summary: 주간 요약
  - Monthly Insights: 월간 인사이트
- **상호작용**:
  - 기간 선택으로 차트 데이터 변경
  - 차트 터치로 특정 데이터 포인트 상세 확인
  - 줌 인/아웃으로 차트 확대/축소

### **PAGE_ANALYTICS_CALENDAR**
- **URL**: /analytics/calendar
- **목적**: 감정 달력 뷰로 월간 감정 패턴 확인
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 월 선택
  - Calendar View: 월간 달력
  - Emotion Legend: 감정별 색상 범례
  - Monthly Stats: 월간 통계 요약
  - Quick Actions: 빠른 액션 버튼
- **상호작용**:
  - 날짜 터치로 해당 날짜 일기 확인
  - 월 변경으로 다른 달 데이터 확인
  - 감정 색상으로 일별 감정 상태 파악

---

## 🎵 음악 페이지

### **PAGE_MUSIC_EMOTION_BGM**
- **URL**: /music/emotion-bgm
- **목적**: 감정별 BGM 자동 재생 및 관리
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 설정 버튼
  - Current Track: 현재 재생 중인 곡 정보
  - Player Controls: 재생/일시정지, 이전/다음, 볼륨
  - Emotion Playlists: 감정별 재생 목록
  - Favorites: 즐겨찾기한 곡
  - Search: 곡 검색
- **상호작용**:
  - 감정 선택 시 해당 감정에 맞는 BGM 자동 재생
  - 재생 컨트롤으로 음악 조작
  - 즐겨찾기 버튼으로 좋아하는 곡 저장

---

## 👥 커뮤니티 페이지

### **PAGE_COMMUNITY_SHARE**
- **URL**: /community/share
- **목적**: 감정 공유 및 소통
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 글 작성 버튼
  - Post List: 공유된 글 목록
  - Filter Options: 감정, 인기순, 최신순 필터
  - Interaction Buttons: 좋아요, 댓글, 공유
  - Search: 글 검색
- **상호작용**:
  - 글 작성 버튼으로 새 글 작성
  - 각 글에 좋아요, 댓글, 공유 가능
  - 필터로 원하는 글 찾기

### **PAGE_COMMUNITY_ANONYMOUS**
- **URL**: /community/anonymous
- **목적**: 익명으로 고민 공유
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 익명 글 작성 버튼
  - Anonymous Posts: 익명 글 목록
  - Support System: 응원 및 조언
  - Guidelines: 익명 공유 가이드라인
- **상호작용**:
  - 익명으로 글 작성
  - 다른 사용자 응원 및 조언
  - 가이드라인 준수

---

## ⚙️ 설정 페이지

### **PAGE_SETTINGS_THEME**
- **URL**: /settings/theme
- **목적**: 앱 테마 및 UI 설정
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 제목
  - Theme Options: 다크/라이트/자동 테마 선택
  - Color Customization: 앱 색상 커스터마이징
  - Font Settings: 폰트 크기 및 스타일
  - Preview: 설정 미리보기
- **상호작용**:
  - 테마 선택 시 즉시 적용
  - 색상 커스터마이징으로 개인화
  - 미리보기로 설정 결과 확인

### **PAGE_SETTINGS_NOTIFICATIONS**
- **URL**: /settings/notifications
- **목적**: 알림 설정 및 관리
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 제목
  - Notification Toggles: 각종 알림 켜기/끄기
  - Time Settings: 알림 시간 설정
  - Sound Settings: 알림음 설정
  - Do Not Disturb: 방해 금지 시간 설정
- **상호작용**:
  - 각 알림 유형별로 개별 설정
  - 시간 설정으로 알림 받을 시간 조정
  - 방해 금지 시간 설정

### **PAGE_SETTINGS_BACKUP**
- **URL**: /settings/backup
- **목적**: 데이터 백업 및 동기화
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 제목
  - Backup Status: 백업 상태 표시
  - Backup Options: 백업 주기 및 방법 선택
  - Sync Settings: 동기화 설정
  - Storage Info: 저장 공간 정보
- **상호작용**:
  - 수동 백업 실행
  - 자동 백업 설정
  - 동기화 켜기/끄기

---

## 👤 프로필 페이지

### **PAGE_PROFILE_EDIT**
- **URL**: /profile/edit
- **목적**: 개인 프로필 정보 편집
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 저장 버튼
  - Profile Image: 프로필 사진 (편집 가능)
  - Personal Info: 닉네임, 생년월일, 자기소개
  - Privacy Settings: 개인정보 공개 설정
  - Save Button: 변경사항 저장
- **상호작용**:
  - 프로필 사진 변경
  - 개인정보 편집
  - 개인정보 공개 범위 설정
  - 저장 시 변경사항 적용

### **PAGE_PROFILE_EMOTIONS**
- **URL**: /profile/emotions
- **목적**: 감정 프로필 및 선호도 설정
- **주요 구성 요소**:
  - Header: 뒤로가기 버튼, 저장 버튼
  - Emotion Preferences: 선호하는 감정 설정
  - Sensitivity Levels: 감정 민감도 조정
  - Trigger Words: 감정 트리거 단어 설정
  - Growth Goals: 감정 성장 목표 설정
- **상호작용**:
  - 감정별 선호도 조정
  - 민감도 슬라이더로 조정
  - 트리거 단어 추가/삭제
  - 성장 목표 설정

---

## 📝 문서 정보

| 항목 | 내용 |
|------|------|
| **문서명** | EmotiFlow 페이지 정의서 |
| **작성일** | 2024년 12월 |
| **버전** | 1.0 |
| **작성자** | AI Assistant |
| **마지막 수정일** | 2024년 12월 |
