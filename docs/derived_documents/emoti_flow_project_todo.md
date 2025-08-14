# EmotiFlow - 프로젝트 계획서

## 📋 프로젝트 개요

| 항목 | 내용 |
|------|------|
| **프로젝트명** | EmotiFlow (AI 기반 감정 일기 앱) |
| **개발 기간** | 2주 |
| **개발 도구** | Flutter + Firebase + OpenAI API |
| **목표** | AI와 함께하는 일상의 감정 파트너, 개인화된 감정 관리 및 성장 도구 |

---

## 🚀 전체 페이지 개발 우선순위 및 상태

### **1주차 (핵심 기능)**
- [ ] **인증 및 프로필 페이지** - 우선순위: 높음 
- [ ] **홈 페이지** - 우선순위: 높음
- [ ] **일기 작성 페이지** - 우선순위: 높음
- [ ] **AI 서비스 페이지** - 우선순위: 높음
- [ ] **기본 설정 페이지** - 우선순위: 중간

### **2주차 (고급 기능)**
- [ ] **데이터 분석 페이지** - 우선순위: 높음
- [ ] **음악 플레이어 페이지** - 우선순위: 중간
- [ ] **커뮤니티 페이지** - 우선순위: 중간
- [ ] **고급 설정 페이지** - 우선순위: 중간
- [ ] **프로필 상세 페이지** - 우선순위: 중간

---

## 📱 각 페이지별 주요 기능 및 상태

### **🏠 홈 페이지 (`/`)**
- [ ] 오늘의 감정 요약 표시
- [ ] 최근 일기 미리보기 (최근 3개)
- [ ] AI 일일 조언 카드
- [ ] 빠른 액션 버튼 (일기 작성, 음악 재생)
- [ ] 감정 상태 인디케이터

### **🔐 인증 페이지 (`/auth`)**
- [ ] **회원가입** (`/auth/signup`)
  - [ ] 이메일/비밀번호 입력 폼
  - [ ] 약관 동의 체크박스
  - [ ] 이메일 인증 프로세스
- [ ] **로그인** (`/auth/login`)
  - [ ] 이메일/비밀번호 로그인
  - [ ] 소셜 로그인 (Google, Apple)
  - [ ] 비밀번호 찾기 링크
- [ ] **비밀번호 재설정** (`/auth/forgot`)
  - [ ] 이메일 입력 폼
  - [ ] 재설정 링크 발송

### **✍️ 일기 페이지 (`/diary`)**
- [ ] **AI 대화형 일기** (`/diary/chat-write`)
  - [ ] AI와의 대화형 인터페이스
  - [ ] 감정 키워드 기반 질문
  - [ ] 실시간 AI 응답
- [ ] **자유형 일기** (`/diary/free-write`)
  - [ ] 텍스트 입력 에디터
  - [ ] 감정 아이콘 선택
  - [ ] 사진 첨부 기능
- [ ] **일기 목록** (`/diary/list`)
  - [ ] 일기 카드 그리드 뷰
  - [ ] 검색 및 필터링
  - [ ] 정렬 옵션 (날짜, 감정)
- [ ] **일기 상세** (`/diary/detail/:id`)
  - [ ] 일기 내용 표시
  - [ ] AI 분석 결과
  - [ ] 편집/삭제 버튼
- [ ] **그림 그리기** (`/diary/draw`)
  - [ ] 캔버스 드로잉 도구
  - [ ] 색상 팔레트
  - [ ] 브러시 크기 조절

### **🤖 AI 서비스 페이지 (`/ai`)**
- [ ] **감정 분석 결과** (`/ai/analysis`)
  - [ ] 일기 내용 분석 표시
  - [ ] 감정 점수 및 패턴
  - [ ] 개선 제안사항
- [ ] **AI 조언 및 위로** (`/ai/advice`)
  - [ ] 개인화된 조언 카드
  - [ ] 자기 성찰 질문
  - [ ] 해결 방안 제시
- [ ] **감정 시각화** (`/ai/emotion-visual`)
  - [ ] AI 생성 감정 이미지
  - [ ] 이미지 다운로드
  - [ ] 갤러리 저장

### **📊 데이터 분석 페이지 (`/analytics`)**
- [ ] **감정 트렌드** (`/analytics/trends`)
  - [ ] 주간/월간/연간 차트
  - [ ] 감정 변화 그래프
  - [ ] 패턴 분석 결과
- [ ] **감정 달력** (`/analytics/calendar`)
  - [ ] 월별 감정 달력 뷰
  - [ ] 일별 감정 상태 표시
  - [ ] 통계 요약
- [ ] **월간 리포트** (`/analytics/monthly-video`)
  - [ ] 일기 모음 영상 생성
  - [ ] 감정별 음악 배경
  - [ ] 영상 다운로드

### **🎵 음악 페이지 (`/music`)**
- [ ] **감정별 BGM** (`/music/emotion-bgm`)
  - [ ] 감정별 음악 카테고리
  - [ ] 자동 재생 기능
  - [ ] 재생 목록 관리
- [ ] **음악 라이브러리** (`/music/library`)
  - [ ] 음악 검색
  - [ ] 즐겨찾기 기능
  - [ ] 재생 히스토리

### **👥 커뮤니티 페이지 (`/community`)**
- [ ] **고민 공유** (`/community/share`)
  - [ ] 익명 게시글 작성
  - [ ] 감정별 카테고리
  - [ ] 댓글 및 공감 기능
- [ ] **익명 소통** (`/community/anonymous`)
  - [ ] 익명 채팅방
  - [ ] 감정별 매칭
  - [ ] 안전 가이드라인

### **⚙️ 설정 페이지 (`/settings`)**
- [ ] **테마 설정** (`/settings/theme`)
  - [ ] 다크/라이트 모드
  - [ ] 앱 아이콘 커스터마이징
  - [ ] 색상 테마 선택
- [ ] **알림 설정** (`/settings/notifications`)
  - [ ] 일기 작성 리마인더
  - [ ] AI 조언 알림
  - [ ] 목표 달성 알림
- [ ] **보안 설정** (`/settings/security`)
  - [ ] 생체 인증
  - [ ] 앱 잠금
  - [ ] 민감 데이터 암호화
- [ ] **데이터 관리** (`/settings/backup`)
  - [ ] 클라우드 동기화
  - [ ] 데이터 내보내기/가져오기
  - [ ] 백업 설정

### **👤 프로필 페이지 (`/profile`)**
- [ ] **개인 정보** (`/profile/edit`)
  - [ ] 닉네임, 생년월일 수정
  - [ ] 프로필 이미지 변경
  - [ ] 개인정보 수정
- [ ] **감정 프로필** (`/profile/emotions`)
  - [ ] 감정 선호도 설정
  - [ ] 감정 패턴 분석
  - [ ] 맞춤형 설정

---

## 🧩 공통 컴포넌트 리스트 및 상태

### **기본 UI 컴포넌트**
- [ ] **버튼 컴포넌트**
  - [ ] Primary Button (주요 액션)
  - [ ] Secondary Button (보조 액션)
  - [ ] Icon Button (아이콘 전용)
  - [ ] Text Button (텍스트 링크)
- [ ] **입력 필드 컴포넌트**
  - [ ] Text Input (텍스트 입력)
  - [ ] Search Input (검색 입력)
  - [ ] Textarea (긴 텍스트)
  - [ ] Select Dropdown (선택 드롭다운)
- [ ] **카드 컴포넌트**
  - [ ] Basic Card (기본 카드)
  - [ ] Emotion Card (감정 카드)
  - [ ] Input Card (입력 카드)
  - [ ] Action Card (액션 카드)

### **데이터 표시 컴포넌트**
- [ ] **차트 컴포넌트**
  - [ ] Line Chart (선형 차트)
  - [ ] Bar Chart (막대 차트)
  - [ ] Pie Chart (원형 차트)
  - [ ] Calendar Heatmap (달력 히트맵)
- [ ] **리스트 컴포넌트**
  - [ ] Diary List (일기 목록)
  - [ ] Emotion List (감정 목록)
  - [ ] Music List (음악 목록)
  - [ ] Community List (커뮤니티 목록)

### **네비게이션 컴포넌트**
- [ ] **Bottom Navigation Bar**
  - [ ] 홈, 일기, AI, 분석, 프로필 탭
  - [ ] 활성 탭 표시
  - [ ] 알림 배지 표시
- [ ] **App Bar**
  - [ ] 페이지 제목
  - [ ] 액션 버튼
  - [ ] 뒤로가기 버튼
- [ ] **Sidebar** (데스크톱)
  - [ ] 확장된 네비게이션
  - [ ] 사용자 프로필
  - [ ] 빠른 액세스 메뉴

### **피드백 컴포넌트**
- [ ] **로딩 컴포넌트**
  - [ ] Spinner (스피너)
  - [ ] Skeleton (스켈레톤)
  - [ ] Progress Bar (진행바)
- [ ] **알림 컴포넌트**
  - [ ] Toast Message (토스트)
  - [ ] Snackbar (스낵바)
  - [ ] Dialog (다이얼로그)
- [ ] **상태 컴포넌트**
  - [ ] Success State (성공)
  - [ ] Error State (오류)
  - [ ] Empty State (빈 상태)

### **MVVM 관련 컴포넌트**
- [ ] **ViewModel 기반 위젯**
  - [ ] ConsumerWidget (Riverpod 연동)
  - [ ] StateNotifierProvider (상태 관리)
  - [ ] FutureProvider (비동기 데이터)
  - [ ] StreamProvider (실시간 데이터)
- [ ] **상태 관리 컴포넌트**
  - [ ] LoadingState (로딩 상태)
  - [ ] ErrorState (에러 상태)
  - [ ] SuccessState (성공 상태)
  - [ ] EmptyState (빈 상태)

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
│   │   ├── app_constants.dart         # 앱 상수
│   │   ├── api_constants.dart         # API 상수
│   │   └── ui_constants.dart          # UI 상수
│   ├── utils/                         # 유틸리티 함수
│   │   ├── date_utils.dart            # 날짜 유틸리티
│   │   ├── string_utils.dart          # 문자열 유틸리티
│   │   └── validation_utils.dart      # 검증 유틸리티
│   ├── errors/                        # 에러 처리
│   │   ├── app_exception.dart         # 앱 예외
│   │   ├── error_handler.dart         # 에러 핸들러
│   │   └── error_messages.dart        # 에러 메시지
│   └── network/                       # 네트워크 관련
│       ├── api_client.dart            # API 클라이언트
│       ├── interceptors.dart          # 인터셉터
│       └── network_info.dart          # 네트워크 정보
├── data/
│   ├── models/                        # 데이터 모델
│   │   ├── user_model.dart            # 사용자 모델
│   │   ├── diary_model.dart           # 일기 모델
│   │   ├── emotion_model.dart         # 감정 모델
│   │   └── music_model.dart           # 음악 모델
│   ├── repositories/                  # 데이터 저장소
│   │   ├── user_repository.dart       # 사용자 저장소
│   │   ├── diary_repository.dart      # 일기 저장소
│   │   ├── emotion_repository.dart    # 감정 저장소
│   │   └── music_repository.dart      # 음악 저장소
│   ├── datasources/                   # 데이터 소스
│   │   ├── local/                     # 로컬 데이터
│   │   │   ├── local_storage.dart     # 로컬 저장소
│   │   │   └── database_helper.dart   # 데이터베이스 헬퍼
│   │   └── remote/                    # 원격 데이터
│   │       ├── firebase_service.dart  # Firebase 서비스
│   │       ├── openai_service.dart    # OpenAI 서비스
│   │       └── api_service.dart       # API 서비스
│   └── mappers/                       # 데이터 변환
│       ├── user_mapper.dart           # 사용자 매퍼
│       ├── diary_mapper.dart          # 일기 매퍼
│       └── emotion_mapper.dart        # 감정 매퍼
├── domain/
│   ├── entities/                      # 비즈니스 엔티티
│   │   ├── user_entity.dart           # 사용자 엔티티
│   │   ├── diary_entity.dart          # 일기 엔티티
│   │   ├── emotion_entity.dart        # 감정 엔티티
│   │   └── music_entity.dart          # 음악 엔티티
│   ├── repositories/                  # 리포지토리 인터페이스
│   │   ├── user_repository.dart       # 사용자 리포지토리
│   │   ├── diary_repository.dart      # 일기 리포지토리
│   │   ├── emotion_repository.dart    # 감정 리포지토리
│   │   └── music_repository.dart      # 음악 리포지토리
│   ├── usecases/                      # 비즈니스 로직
│   │   ├── user/                      # 사용자 관련
│   │   │   ├── sign_up_usecase.dart   # 회원가입
│   │   │   ├── sign_in_usecase.dart   # 로그인
│   │   │   └── update_profile_usecase.dart # 프로필 수정
│   │   ├── diary/                     # 일기 관련
│   │   │   ├── create_diary_usecase.dart    # 일기 작성
│   │   │   ├── get_diary_usecase.dart       # 일기 조회
│   │   │   └── update_diary_usecase.dart    # 일기 수정
│   │   ├── emotion/                   # 감정 관련
│   │   │   ├── analyze_emotion_usecase.dart # 감정 분석
│   │   │   └── get_emotion_stats_usecase.dart # 감정 통계
│   │   └── ai/                        # AI 관련
│   │       ├── generate_advice_usecase.dart  # 조언 생성
│   │       └── create_emotion_image_usecase.dart # 감정 이미지 생성
│   └── exceptions/                    # 도메인 예외
│       ├── user_exception.dart        # 사용자 예외
│       ├── diary_exception.dart       # 일기 예외
│       └── ai_exception.dart          # AI 예외
├── presentation/
│   ├── pages/                         # 화면 페이지
│   │   ├── auth/                      # 인증 페이지
│   │   │   ├── signup_page.dart       # 회원가입
│   │   │   ├── login_page.dart        # 로그인
│   │   │   └── forgot_password_page.dart # 비밀번호 찾기
│   │   ├── home/                      # 홈 페이지
│   │   │   ├── home_page.dart         # 홈 메인
│   │   │   └── home_controller.dart   # 홈 컨트롤러
│   │   ├── diary/                     # 일기 페이지
│   │   │   ├── diary_list_page.dart   # 일기 목록
│   │   │   ├── diary_write_page.dart  # 일기 작성
│   │   │   ├── diary_detail_page.dart # 일기 상세
│   │   │   └── diary_draw_page.dart   # 그림 그리기
│   │   ├── ai/                        # AI 서비스 페이지
│   │   │   ├── ai_analysis_page.dart  # AI 분석
│   │   │   ├── ai_advice_page.dart    # AI 조언
│   │   │   └── emotion_visual_page.dart # 감정 시각화
│   │   ├── analytics/                 # 데이터 분석 페이지
│   │   │   ├── trends_page.dart       # 트렌드
│   │   │   ├── calendar_page.dart     # 달력
│   │   │   └── monthly_video_page.dart # 월간 영상
│   │   ├── music/                     # 음악 페이지
│   │   │   ├── music_player_page.dart # 음악 플레이어
│   │   │   └── music_library_page.dart # 음악 라이브러리
│   │   ├── community/                 # 커뮤니티 페이지
│   │   │   ├── community_share_page.dart # 고민 공유
│   │   │   └── anonymous_chat_page.dart # 익명 채팅
│   │   ├── settings/                  # 설정 페이지
│   │   │   ├── settings_page.dart     # 설정 메인
│   │   │   ├── theme_settings_page.dart # 테마 설정
│   │   │   ├── notification_settings_page.dart # 알림 설정
│   │   │   ├── security_settings_page.dart # 보안 설정
│   │   │   └── backup_settings_page.dart # 백업 설정
│   │   └── profile/                   # 프로필 페이지
│   │       ├── profile_page.dart      # 프로필 메인
│   │       ├── edit_profile_page.dart # 프로필 수정
│   │       └── emotion_profile_page.dart # 감정 프로필
│   ├── widgets/                       # 재사용 위젯
│   │   ├── common/                    # 공통 위젯
│   │   │   ├── custom_button.dart     # 커스텀 버튼
│   │   │   ├── custom_input.dart      # 커스텀 입력
│   │   │   ├── custom_card.dart       # 커스텀 카드
│   │   │   └── loading_widget.dart    # 로딩 위젯
│   │   ├── diary/                     # 일기 관련 위젯
│   │   │   ├── diary_card.dart        # 일기 카드
│   │   │   ├── emotion_selector.dart  # 감정 선택기
│   │   │   └── drawing_canvas.dart    # 그림 캔버스
│   │   ├── analytics/                 # 분석 관련 위젯
│   │   │   ├── emotion_chart.dart     # 감정 차트
│   │   │   ├── emotion_calendar.dart  # 감정 달력
│   │   │   └── trend_graph.dart       # 트렌드 그래프
│   │   └── music/                     # 음악 관련 위젯
│   │       ├── music_player.dart      # 음악 플레이어
│   │       ├── playlist_item.dart     # 플레이리스트 아이템
│   │       └── volume_control.dart    # 볼륨 컨트롤
│   ├── viewmodels/                    # ViewModel (Riverpod Providers)
│   │   ├── auth_viewmodel.dart        # 인증 ViewModel
│   │   ├── diary_viewmodel.dart       # 일기 ViewModel
│   │   ├── emotion_viewmodel.dart     # 감정 ViewModel
│   │   ├── ai_viewmodel.dart          # AI ViewModel
│   │   ├── music_viewmodel.dart       # 음악 ViewModel
│   │   ├── theme_viewmodel.dart       # 테마 ViewModel
│   │   └── settings_viewmodel.dart    # 설정 ViewModel
│   └── providers/                     # Riverpod Providers
│       ├── auth_provider.dart         # 인증 상태
│       ├── diary_provider.dart        # 일기 상태
│       ├── emotion_provider.dart      # 감정 상태
│       ├── music_provider.dart        # 음악 상태
│       ├── theme_provider.dart        # 테마 상태
│       └── settings_provider.dart     # 설정 상태
├── services/
│   ├── ai_service.dart                # AI 서비스
│   ├── auth_service.dart              # 인증 서비스
│   ├── storage_service.dart           # 저장소 서비스
│   ├── notification_service.dart      # 알림 서비스
│   ├── music_service.dart             # 음악 서비스
│   ├── analytics_service.dart         # 분석 서비스
│   └── community_service.dart         # 커뮤니티 서비스
└── shared/
    ├── components/                     # 공통 컴포넌트
    │   ├── app_bar.dart               # 앱 바
    │   ├── bottom_navigation.dart     # 하단 네비게이션
    │   ├── sidebar.dart               # 사이드바
    │   └── error_boundary.dart        # 에러 경계
    ├── styles/                         # 공통 스타일
    │   ├── colors.dart                # 색상 정의
    │   ├── typography.dart            # 타이포그래피
    │   ├── spacing.dart               # 간격 정의
    │   └── animations.dart            # 애니메이션
    └── assets/                         # 이미지, 폰트 등
        ├── images/                     # 이미지 파일
        ├── icons/                      # 아이콘 파일
        └── fonts/                      # 폰트 파일
```

---

## 📊 개발 일정 및 마일스톤

### **1주차 마일스톤**
- [ ] **Day 1-2**: 프로젝트 설정 및 기본 구조
- [ ] **Day 3-4**: 인증 시스템 및 사용자 관리
- [ ] **Day 5-7**: 일기 작성 및 AI 연동

### **2주차 마일스톤**
- [ ] **Day 8-10**: 데이터 분석 및 시각화
- [ ] **Day 11-12**: 음악 및 커뮤니티 기능
- [ ] **Day 13-14**: 최적화 및 테스트

---

## 🎯 완료 기준

### **기능 완성도**
- [ ] 모든 핵심 기능 구현 완료
- [ ] UI/UX 가이드라인 준수
- [ ] 반응형 디자인 적용
- [ ] 접근성 기준 충족

### **품질 기준**
- [ ] 코드 리뷰 완료
- [ ] 단위 테스트 작성
- [ ] 통합 테스트 완료
- [ ] 성능 최적화 적용

### **배포 준비**
- [ ] 빌드 오류 해결
- [ ] 테스트 환경 검증
- [ ] 배포 스크립트 준비
- [ ] 사용자 가이드 작성
