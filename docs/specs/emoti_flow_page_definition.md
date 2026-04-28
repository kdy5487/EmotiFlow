# EmotiFlow - Flutter 앱 페이지 정의서

## 📋 문서 개요

| 항목 | 내용 |
|------|------|
| **문서명** | EmotiFlow Flutter 앱 페이지 정의서 |
| **작성일** | 2024년 12월 |
| **버전** | 1.1 |
| **작성자** | AI Assistant |
| **목적** | Flutter 앱의 각 페이지 구조, UI 컴포넌트, 상호작용 상세 정의 |

---

## 📱 Flutter 앱 구조 개요

### **앱 네비게이션 구조**
```
SplashScreen → Onboarding → Auth (Login/Signup) → MainApp
                                                    ↓
                                              HomePage (메인)
                                                    ↓
                    ┌─────────┬─────────┬─────────┬─────────┬─────────┐
                    ↓         ↓         ↓         ↓         ↓
                DiaryPage  AIPage  AnalyticsPage  MusicPage  ProfilePage
                    ↓         ↓         ↓         ↓         ↓
                DiaryDetail  AIAnalysis  ChartDetail  PlaylistDetail  SettingsPage
```

### **공통 UI 컴포넌트**
- **AppBar**: 각 페이지 상단의 앱바 (제목, 뒤로가기, 액션 버튼)
- **BottomNavigationBar**: 하단 메인 네비게이션 (6개 탭)
- **FloatingActionButton**: 주요 액션 버튼
- **Card**: 정보 표시용 카드 컴포넌트
- **Dialog**: 모달 다이얼로그
- **SnackBar**: 간단한 알림 메시지
- **BottomSheet**: 하단에서 올라오는 시트

### **스크롤 성능 최적화**
- **ListView.builder**: `SingleChildScrollView` 대신 사용하여 성능 최적화
  - **장점**: 화면에 보이는 아이템만 렌더링, 메모리 효율적, 부드러운 스크롤
  - **사용 시기**: 고정된 개수의 섹션이나 동적 리스트 데이터
  - **구현 방식**: `itemCount`와 `itemBuilder`를 사용한 조건부 렌더링
- **CustomScrollView**: 복잡한 스크롤 레이아웃 (SliverAppBar, SliverList 등)
- **NestedScrollView**: 중첩된 스크롤 뷰 (탭과 리스트 동시 스크롤)

---

## 🏠 메인 페이지

### **HomePage (홈 페이지)**
- **Route**: /
- **목적**: 앱의 메인 대시보드, 사용자의 일일 감정 요약 및 빠른 액션 제공
- **Flutter 구조**:
  ```dart
  Scaffold(
    appBar: EmotiAppBar(
      title: 'EmotiFlow',
      actions: [
        IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        IconButton(icon: Icon(Icons.settings), onPressed: () {}),
      ],
    ),
    body: ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return TodayMoodCard();
          case 1:
            return QuickActionsRow();
          case 2:
            return RecentEntriesSection();
          case 3:
            return AIDailyTipCard();
          default:
            return SizedBox.shrink();
        }
      },
    ),
    bottomNavigationBar: EmotiBottomNavigationBar(currentIndex: 0),
  )
  ```

- **주요 UI 컴포넌트**:
  - **AppBar**: 앱 제목 "EmotiFlow", 알림 아이콘, 설정 아이콘
  - **TodayMoodCard**: 오늘의 감정 요약 카드 (감정 아이콘, 감정명, 감정 강도)
  - **QuickActionsRow**: 일기 작성, AI 분석, 트렌드 보기 버튼들
  - **RecentEntriesSection**: 최근 일기 미리보기 (3-5개 카드)
  - **AIDailyTipCard**: 오늘의 AI 조언 카드
  - **BottomNavigationBar**: 메인 네비게이션 (현재 홈 탭 활성화)

- **상호작용**:
  - 각 카드 터치 시 해당 상세 페이지로 이동
  - 빠른 액션 버튼 터치 시 해당 기능 실행
  - 알림 아이콘 터치 시 알림 목록 표시
  - 설정 아이콘 터치 시 설정 페이지로 이동
  - 하단 네비게이션으로 다른 메인 페이지 이동

---

## 🔐 인증 페이지

### **SignupPage (회원가입 페이지)**
- **Route**: /auth/signup
- **목적**: 신규 사용자 회원가입
- **Flutter 구조**:
  ```dart
  Scaffold(
    appBar: EmotiAppBar(
      title: '회원가입',
      showBackButton: true,
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          EmotiLogo(),
          SizedBox(height: 32),
          SignupForm(),
          SizedBox(height: 24),
          TermsAndConditions(),
          SizedBox(height: 24),
          EmotiButton(
            text: '회원가입',
            onPressed: _handleSignup,
            isFullWidth: true,
          ),
          SizedBox(height: 16),
          LoginLink(),
        ],
      ),
    ),
  )
  ```

- **주요 UI 컴포넌트**:
  - **AppBar**: "회원가입" 제목, 뒤로가기 버튼
  - **EmotiLogo**: 앱 로고 및 브랜딩
  - **SignupForm**: 이메일, 비밀번호, 비밀번호 확인, 닉네임 입력 필드
  - **TermsAndConditions**: 이용약관, 개인정보처리방침 동의 체크박스
  - **EmotiButton**: 회원가입 버튼 (전체 너비)
  - **LoginLink**: 로그인 페이지 링크

- **상호작용**:
  - 모든 필수 필드 입력 시 회원가입 버튼 활성화
  - 약관 동의 필수 (체크박스)
  - 회원가입 성공 시 자동 로그인 및 홈으로 이동
  - 뒤로가기 버튼으로 이전 페이지로 이동

### **LoginPage (로그인 페이지)**
- **Route**: /auth/login
- **목적**: 기존 사용자 로그인
- **Flutter 구조**:
  ```dart
  Scaffold(
    appBar: EmotiAppBar(
      title: '로그인',
      showBackButton: true,
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          EmotiLogo(),
          SizedBox(height: 32),
          LoginForm(),
          SizedBox(height: 16),
          ForgotPasswordLink(),
          SizedBox(height: 24),
          EmotiButton(
            text: '로그인',
            onPressed: _handleLogin,
            isFullWidth: true,
          ),
          SizedBox(height: 24),
          DividerWithText(text: '또는'),
          SizedBox(height: 16),
          SocialLoginButtons(),
          SizedBox(height: 24),
          SignupLink(),
        ],
      ),
    ),
  )
  ```

- **주요 UI 컴포넌트**:
  - **AppBar**: "로그인" 제목, 뒤로가기 버튼
  - **EmotiLogo**: 앱 로고 및 브랜딩
  - **LoginForm**: 이메일, 비밀번호 입력 필드
  - **ForgotPasswordLink**: 비밀번호 찾기 링크
  - **EmotiButton**: 로그인 버튼 (전체 너비)
  - **DividerWithText**: "또는" 구분선
  - **SocialLoginButtons**: Google, Apple 로그인 버튼들
  - **SignupLink**: 회원가입 페이지 링크

- **상호작용**:
  - 이메일/비밀번호 입력 시 로그인 버튼 활성화
  - 소셜 로그인 시 해당 플랫폼 인증 진행
  - 로그인 성공 시 홈 페이지로 이동
  - 비밀번호 찾기 링크로 비밀번호 재설정 페이지 이동
  - 회원가입 링크로 회원가입 페이지 이동

### **ForgotPasswordPage (비밀번호 찾기 페이지)**
- **Route**: /auth/forgot
- **목적**: 비밀번호 재설정
- **Flutter 구조**:
  ```dart
  Scaffold(
    appBar: EmotiAppBar(
      title: '비밀번호 찾기',
      showBackButton: true,
    ),
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          EmotiLogo(),
          SizedBox(height: 32),
          Text(
            '비밀번호를 잊으셨나요?',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            '가입하신 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          EmailForm(),
          SizedBox(height: 24),
          EmotiButton(
            text: '재설정 이메일 발송',
            onPressed: _handleSendResetEmail,
            isFullWidth: true,
          ),
          SizedBox(height: 24),
          BackToLoginLink(),
        ],
      ),
    ),
  )
  ```

- **주요 UI 컴포넌트**:
  - **AppBar**: "비밀번호 찾기" 제목, 뒤로가기 버튼
  - **EmotiLogo**: 앱 로고 및 브랜딩
  - **안내 텍스트**: 비밀번호 찾기 방법 설명
  - **EmailForm**: 이메일 주소 입력 필드
  - **EmotiButton**: 재설정 이메일 발송 버튼 (전체 너비)
  - **BackToLoginLink**: 로그인 페이지로 돌아가기 링크

- **상호작용**:
  - 이메일 입력 후 버튼 터치 시 재설정 이메일 발송
  - 발송 완료 시 확인 메시지 표시 (SnackBar)
  - 뒤로가기 버튼으로 이전 페이지로 이동
  - 로그인 링크로 로그인 페이지로 이동

---

## ✍️ 일기 관련 페이지

### **DiaryChatWritePage (AI 대화형 일기 작성 페이지)**
- **Route**: /diary/chat-write
- **목적**: AI와 대화하며 일기 작성
- **Flutter 구조**:
  ```dart
  Scaffold(
    appBar: EmotiAppBar(
      title: 'AI와 대화하며 일기 작성',
      showBackButton: true,
      actions: [
        IconButton(
          icon: Icon(Icons.save),
          onPressed: _handleSave,
        ),
      ],
    ),
    body: Column(
      children: [
        DatePickerSection(),
        EmotionSelectorSection(),
        Expanded(
          child: ChatInterface(),
        ),
        TextInputSection(),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _handleNewChat,
      child: Icon(Icons.add),
    ),
  )
  ```

- **주요 UI 컴포넌트**:
  - **AppBar**: "AI와 대화하며 일기 작성" 제목, 뒤로가기 버튼, 저장 버튼
  - **DatePickerSection**: 날짜 선택 (오늘/어제/직접 선택)
  - **EmotionSelectorSection**: 감정 카테고리 및 강도 선택 (8가지 감정 + 강도 1-10)
  - **ChatInterface**: AI와의 대화 인터페이스 (채팅 형태)
  - **TextInputSection**: 사용자 응답 입력 필드 및 전송 버튼
  - **FloatingActionButton**: 새로운 대화 시작 버튼

- **상호작용**:
  - AI가 감정 키워드 기반 질문 제시
  - 사용자 응답에 따른 다음 질문 생성
  - 감정 선택 시 해당 감정에 맞는 질문 조정
  - 저장 시 AI 분석 결과와 함께 일기 저장
  - 새로운 대화 시작 시 기존 대화 초기화
  - 뒤로가기 시 저장 확인 다이얼로그 표시

#### 실제 구현 (업데이트)
- **AppBar**: 좌측 뒤로가기, 우측 `새 대화(새로고침)` 아이콘, `일기 완성` 텍스트 버튼. 저장은 결과 다이얼로그에서 수행됨.
- **대화 흐름**:
  - 진입 시 Gemini `generateEmotionSelectionPrompt()`로 첫 AI 메시지 생성 후 `chatHistory`에 추가.
  - 사용자가 입력하면 `generateEmotionBasedQuestion()` 호출 → AI 응답을 추가하며 타이핑 인디케이터 표시.
  - 첫 사용자 메시지 이후 하단에 감정 선택 UI(8가지 감정, 이모지/색상 포함)가 노출되며 탭 시 감정 기반 질문 1회 추가 전송.
- **일기 완성**: `generateDiarySummary()`로 요약 생성 → 결과 다이얼로그에서
  - 선택 감정 표시
  - AI 그림 생성 버튼 제공(`generateImage()`) → 성공 시 이미지 표시, 실패 시 안내 문구
  - `저장 후 완료` 선택 시 Firestore에 `DiaryType.aiChat`으로 저장(메타데이터: `isChatDiary`, `conversationCount`, `aiGeneratedImage`).
- **UI 구성**: 말풍선 버블, 좌측 AI(아이콘), 우측 사용자. 타이핑 인디케이터, 자동 스크롤.
- **오류 처리/폴백**: 네트워크/AI 오류 시 간단한 폴백 텍스트로 대체, 스낵바 안내.

### **DiaryFreeWritePage (자유형 일기 작성 페이지)**
- **Route**: /diary/free-write
- **목적**: 자유롭게 일기 작성
- **Flutter 구조**:
  ```dart
  Scaffold(
    appBar: EmotiAppBar(
      title: '자유형 일기 작성',
      showBackButton: true,
      actions: [
        IconButton(
          icon: Icon(Icons.save),
          onPressed: _handleSave,
        ),
        IconButton(
          icon: Icon(Icons.share),
          onPressed: _handleShare,
        ),
      ],
    ),
    body: ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 7,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return DatePickerSection();
          case 1:
            return SizedBox(height: 16);
          case 2:
            return EmotionSelectorSection();
          case 3:
            return SizedBox(height: 16);
          case 4:
            return TitleInputField();
          case 5:
            return SizedBox(height: 16);
          case 6:
            return ContentInputField();
          case 7:
            return SizedBox(height: 16);
          case 8:
            return MediaAttachmentSection();
          case 9:
            return SizedBox(height: 16);
          case 10:
            return DrawingSection();
          case 11:
            return SizedBox(height: 16);
          case 12:
            return VoiceRecordingSection();
          default:
            return SizedBox.shrink();
        }
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _handleSave,
      child: Icon(Icons.save),
    ),
  )
  ```

- **주요 UI 컴포넌트**:
  - **AppBar**: "자유형 일기 작성" 제목, 뒤로가기 버튼, 저장 버튼, 공유 버튼
  - **DatePickerSection**: 날짜 선택
  - **EmotionSelectorSection**: 감정 카테고리 및 강도 선택
  - **TitleInputField**: 일기 제목 입력 필드
  - **ContentInputField**: 일기 내용 입력 필드 (리치 텍스트 에디터)
  - **MediaAttachmentSection**: 사진 첨부 (갤러리/카메라, 최대 5장)
  - **DrawingSection**: 그림 그리기 도구 (브러시, 색상 팔레트)
  - **VoiceRecordingSection**: 음성 메모 녹음 (최대 3분)
  - **FloatingActionButton**: 저장 버튼

- **상호작용**:
  - 모든 필드 자동 저장 (30초마다)
  - 미디어 파일 첨부 및 편집
  - 그림 그리기 및 저장
  - 음성 녹음 및 재생
  - 저장 시 감정 분석 및 AI 피드백 제공
  - 공유 기능으로 일기 내보내기

#### 실제 구현 (업데이트)
- **AppBar**: 프라이머리 색 배경, 우측 `저장` 텍스트 버튼. 공유 버튼은 UI 정의서상 존재하나 실제 구현에는 미노출.
- **입력 섹션**:
  - 날짜 선택: 상단 카드에서 오늘/어제/직접선택(달력) 지원.
  - 제목/내용: `EmotiTextField`, 내용은 글자수/단어수 카운터 제공. 리치 텍스트 서식은 미구현.
  - 감정: 8가지 기본 감정 그리드, 최대 3개 선택, 선택된 감정에 한해 강도(1~10) 슬라이더 제공.
  - 태그: 입력 → 칩으로 추가/삭제.
  - 미디어: 사진(갤러리)·그림(드로잉 캔버스) 버튼 제공, 썸네일 가로 리스트 프리뷰. 음성은 TODO로 스낵바 안내.
  - AI 분석 스위치: 토글만 제공(분석 호출은 후속 단계 연동 예정).
  - 공개 설정 스위치.
- **검증/저장**: 로그인 필요. 자유형은 최소 1개 감정, 제목, 내용이 있어야 저장. 저장 직후 미리보기 바텀시트 표시.
- **자동 저장**: 상태에 `lastAutoSave` 타임스탬프를 기록하는 수준으로 반영되어 있으며, 주기적 백그라운드 저장 타이머는 미구현.

---

## 📋 일기 관리 페이지

### **DiaryListPage (일기 목록 페이지)**
- **Route**: /diary/list
- **목적**: 작성된 일기 목록 확인 및 관리 (리스트/그리드 전환, 검색, 필터/정렬, 일괄 삭제)
- **Flutter 구조 (요약)**:
  ```dart
  Scaffold(
    appBar: AppBar(
      leading: isDeleteMode ? CloseButton(onPressed: exitDeleteMode) : null,
      title: isDeleteMode ? Text('${selectedCount}개 선택') : Text('일기 목록'),
      actions: isDeleteMode
        ? [IconButton(icon: Icon(Icons.delete_outline), onPressed: confirmAndDeleteSelected)]
        : [
            IconButton(icon: Icon(isSearchActive ? Icons.close : Icons.search), onPressed: toggleSearch),
            IconButton(icon: Icon(isGridView ? Icons.view_list : Icons.grid_view), onPressed: toggleView),
            PopupMenuButton(
              itemBuilder: (_) => [
                PopupMenuItem(value: 'filter', child: Row(children:[Icon(Icons.filter_list), SizedBox(width:8), Text('필터') ])),
                PopupMenuItem(value: 'sort',   child: Row(children:[Icon(Icons.sort),       SizedBox(width:8), Text('정렬') ])),
                PopupMenuItem(value: 'delete_mode', child: Row(children:[Icon(Icons.delete_outline, color: Colors.red), SizedBox(width:8), Text('삭제 모드', style: TextStyle(color: Colors.red)) ])),
              ],
              onSelected: handleMenuSelection,
            ),
          ],
    ),
    body: Column(children: [
      if (isSearchActive) SearchSection(),
      if (hasActiveFilters) FilterTagsBar(),
      Expanded(child: isGridView ? DiaryGridViewFromDB() : DiaryListViewFromDB()),
    ]),
    floatingActionButton: FloatingActionButton(onPressed: openWriteOptions, child: Icon(Icons.add)),
  )
  ```

- **주요 UI 컴포넌트 (업데이트)**:
  - **AppBar (일반 모드)**:
    - 좌측: 기본 (뒤로가기 없음)
    - 제목: "일기 목록"
    - 우측 액션:
      - 검색 토글 버튼: 검색창 표시/닫기
      - 뷰 전환 버튼: 리스트 ↔ 그리드 토글
      - 설정 메뉴: 필터, 정렬, 삭제 모드 진입을 개별 항목으로 분리
  - **AppBar (삭제 모드)**:
    - 좌측: 닫기(X) → 삭제 모드 종료
    - 제목: 선택된 수 실시간 표시 (예: "3개 선택")
    - 우측: 휴지통 아이콘 → 선택 항목 일괄 삭제
  - **SearchSection**: 제목/내용/태그 검색 입력, 즉시 반영, 클리어 버튼 제공
  - **FilterTagsBar**: 활성화된 필터들의 태그 나열 및 개별 제거, "모두 지우기" 제공
  - **DiaryListViewFromDB (리스트)**: Firestore StreamProvider 기반 실시간 목록, 카드형 가로 레이아웃
  - **DiaryGridViewFromDB (그리드)**: Firestore StreamProvider 기반 2열 그리드, 사진 없는 텍스트 중심 카드 (가독성 우선)
  - **삭제 선택 오버레이**: 삭제 모드에서 각 카드 우상단에 동그라미 선택 표시 (체크/해제)

#### 실제 구현 (세부 사항)
- **검색**: AppBar 토글 → 상단 검색 입력 노출, 입력 즉시 필터 적용, 닫기 시 초기화.
- **뷰 전환**: 리스트/그리드 토글 버튼. 그리드는 이미지 미포함, 텍스트 전용 카드.
- **삭제 모드**: 우측 설정 메뉴 → 삭제 모드 진입. 카드마다 원형 체크박스 오버레이, 다중 선택 후 AppBar 휴지통으로 일괄 삭제. 제목에 선택 개수 표기.
- **상태/오류**: 로딩/오류/빈 상태를 뷰 내부에서 직접 처리. 스낵바 피드백 제공.

- **상호작용 (업데이트)**:
  - 리스트/그리드 모두 동일한 DB 데이터(실시간 Stream) 사용
  - 검색 버튼 탭 시 검색창 표시 → 입력 즉시 필터 반영, 닫기 버튼으로 검색 종료 및 초기화
  - 설정 메뉴에서 필터/정렬을 각각 별도 다이얼로그로 진입 (통합이 아닌 분리 운영)
  - 삭제 모드 진입 시:
    - 모든 카드에 선택 동그라미 표시
    - 카드 탭 또는 동그라미 탭으로 선택/해제
    - AppBar에 선택 개수 표시, 휴지통으로 일괄 삭제 (확인 다이얼로그 후 진행)
    - 좌측 X로 삭제 모드 종료 (선택 상태 초기화)

- **오류/비어있음 상태 처리**:
  - 데이터 없음: 인박스 아이콘과 안내 문구 표시, 작성 유도 버튼 노출 가능
  - 오류 발생: 에러 아이콘/문구 및 재시도 안내

- **성능/UX 고려 사항**:
  - StreamProvider로 실시간 업데이트 (추가/삭제/수정 반영)
  - 그리드 카드는 미디어 썸네일 생략하여 정보 밀도와 가독성 강화
  - 스크롤 및 아이템 렌더링 최적화 (ListView/GridView.builder)

### **DiaryDetailPage (일기 상세 페이지)**
- **Route**: /diary/detail/:id
- **목적**: 특정 일기 상세 내용 확인 및 관리
- **Flutter 구조**:
  ```dart
  Scaffold(
    appBar: EmotiAppBar(
      title: '일기 상세',
      showBackButton: true,
      actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _handleEdit(),
        ),
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () => _handleShare(),
        ),
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Text('삭제'),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') _handleDelete();
          },
        ),
      ],
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          DiaryHeaderSection(),
          DiaryContentSection(),
          EmotionInfoSection(),
          AIAnalysisSection(),
          MediaSection(),
          ActionButtonsSection(),
        ],
      ),
    ),
  )
  ```

- **주요 UI 컴포넌트**:
  - **AppBar**: "일기 상세" 제목, 뒤로가기 버튼, 편집 버튼, 공유 버튼, 메뉴 버튼
  - **DiaryHeaderSection**: 날짜, 제목, 작성 시간
  - **DiaryContentSection**: 일기 내용 텍스트
  - **EmotionInfoSection**: 선택된 감정 및 강도 표시
  - **AIAnalysisSection**: AI 분석 결과 및 조언
  - **MediaSection**: 첨부된 사진, 그림, 음성
  - **ActionButtonsSection**: 편집, 삭제, 공유 버튼들

- **상호작용**:
  - 편집 버튼 터치 시 편집 페이지로 이동
  - 삭제 버튼 터치 시 확인 다이얼로그 표시
  - 공유 버튼 터치 시 공유 옵션 표시
  - 뒤로가기 버튼으로 목록 페이지로 이동

---

## 🤖 AI 서비스 페이지

### **AIAnalysisPage (AI 감정 분석 페이지)**
- **Route**: /ai/analysis
- **목적**: AI 감정 분석 결과 표시 및 인사이트 제공
- **Flutter 구조**:
  ```dart
  Scaffold(
    appBar: EmotiAppBar(
      title: 'AI 감정 분석',
      showBackButton: true,
      actions: [
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () => _handleShare(),
        ),
      ],
    ),
    body: ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return EmotionSummaryCard();
          case 1:
            return DetailedAnalysisSection();
          case 2:
            return EmotionTrendsChart();
          case 3:
            return PersonalizedAdviceSection();
          case 4:
            return ActionItemsSection();
          default:
            return SizedBox.shrink();
        }
      },
    ),
    bottomNavigationBar: EmotiBottomNavigationBar(currentIndex: 2),
  )
  ```

- **주요 UI 컴포넌트**:
  - **AppBar**: "AI 감정 분석" 제목, 뒤로가기 버튼, 공유 버튼
  - **EmotionSummaryCard**: 감정 요약 카드 (주요 감정, 강도, 변화)
  - **DetailedAnalysisSection**: 상세 분석 결과 (확장/축소 가능)
  - **EmotionTrendsChart**: 감정 변화 트렌드 차트
  - **PersonalizedAdviceSection**: 개인화된 조언 및 피드백
  - **ActionItemsSection**: 실행 가능한 액션 아이템 체크리스트
  - **BottomNavigationBar**: 메인 네비게이션 (AI 탭 활성화)

- **상호작용**:
  - 각 섹션 확장/축소 가능 (ExpansionTile)
  - 공유 버튼으로 분석 결과 공유
  - 액션 아이템 체크박스로 완료 표시
  - 하단 네비게이션으로 다른 메인 페이지 이동

---

## 📊 분석 및 통계 페이지

### **AnalyticsPage (분석 페이지)**
- **Route**: /analytics
- **목적**: 감정 통계 및 트렌드 분석 결과 표시
- **Flutter 구조**:
  ```dart
  Scaffold(
    appBar: EmotiAppBar(
      title: '감정 분석',
      showBackButton: true,
      actions: [
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () => _showDateRangePicker(),
        ),
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () => _showFilterOptions(),
        ),
      ],
    ),
    body: ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return DateRangeSelector();
          case 1:
            return EmotionStatsOverview();
          case 2:
            return EmotionTrendsChart();
          case 3:
            return CalendarView();
          case 4:
            return InsightsSummary();
          default:
            return SizedBox.shrink();
        }
      },
    ),
    bottomNavigationBar: EmotiBottomNavigationBar(currentIndex: 3),
  )
  ```

- **주요 UI 컴포넌트**:
  - **AppBar**: "감정 분석" 제목, 뒤로가기 버튼, 기간 선택 버튼, 필터 버튼
  - **DateRangeSelector**: 기간 선택 (주간/월간/연간/직접 선택)
  - **EmotionStatsOverview**: 감정 통계 요약 (파이 차트, 막대 차트)
  - **EmotionTrendsChart**: 감정 변화 트렌드 (선 그래프)
  - **CalendarView**: 달력 뷰 (일별 감정 상태 표시)
  - **InsightsSummary**: AI 인사이트 및 개선 제안
  - **BottomNavigationBar**: 메인 네비게이션 (분석 탭 활성화)

- **상호작용**:
  - 기간 선택으로 통계 범위 조정
  - 차트 터치로 상세 정보 표시
  - 달력에서 특정 날짜 터치 시 해당 일기로 이동
  - 필터 옵션으로 감정별 통계 확인
  - 하단 네비게이션으로 다른 메인 페이지 이동

---

## 🎵 음악 및 콘텐츠 페이지

### **MusicPage (음악 페이지)**
- **Route**: /music
- **목적**: 감정별 음악 재생 및 플레이리스트 관리
- **Flutter 구조**:
  ```dart
  Scaffold(
    appBar: EmotiAppBar(
      title: '치유 음악',
      showBackButton: true,
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => _showSearchBar(),
        ),
        IconButton(
          icon: Icon(Icons.playlist_play),
          onPressed: () => _showPlaylists(),
        ),
      ],
    ),
    body: Column(
      children: [
        NowPlayingSection(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return EmotionMusicSection();
                case 1:
                  return PlaylistsSection();
                case 2:
                  return MusicRecommendations();
                default:
                  return SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    ),
    bottomNavigationBar: EmotiBottomNavigationBar(currentIndex: 4),
  )
  ```

- **주요 UI 컴포넌트**:
  - **AppBar**: "치유 음악" 제목, 뒤로가기 버튼, 검색 버튼, 플레이리스트 버튼
  - **NowPlayingSection**: 현재 재생 중인 음악 정보 및 컨트롤
  - **EmotionMusicSection**: 감정별 음악 카테고리 (8가지 감정)
  - **PlaylistsSection**: 사용자 플레이리스트 목록
  - **MusicRecommendations**: AI 추천 음악
  - **BottomNavigationBar**: 메인 네비게이션 (음악 탭 활성화)

- **상호작용**:
  - 감정별 음악 카테고리 터치로 해당 음악 재생
  - 플레이리스트 생성 및 관리
  - 음악 검색 및 필터링
  - 재생 컨트롤 (재생/일시정지, 이전/다음, 볼륨 조절)
  - 하단 네비게이션으로 다른 메인 페이지 이동

---

## 👤 프로필 및 설정 페이지

### **ProfilePage (프로필 페이지)**
- **Route**: /profile
- **목적**: 사용자 프로필 정보 및 설정 관리
- **Flutter 구조**:
  ```dart
  Scaffold(
    appBar: EmotiAppBar(
      title: '프로필',
      showBackButton: true,
      actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _handleEditProfile(),
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => context.go('/settings'),
        ),
      ],
    ),
    body: ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return ProfileHeaderSection();
          case 1:
            return EmotionProfileSection();
          case 2:
            return StatsSummarySection();
          case 3:
            return SettingsMenuSection();
          default:
            return SizedBox.shrink();
        }
      },
    ),
    bottomNavigationBar: EmotiBottomNavigationBar(currentIndex: 5),
  )
  ```

- **주요 UI 컴포넌트**:
  - **AppBar**: "프로필" 제목, 뒤로가기 버튼, 편집 버튼, 설정 버튼
  - **ProfileHeaderSection**: 프로필 이미지, 닉네임, 생년월일
  - **EmotionProfileSection**: 감정 선호도 및 패턴 설정
  - **StatsSummarySection**: 통계 요약 (총 일기 수, 연속 작성일 등)
  - **SettingsMenuSection**: 설정 메뉴 (테마, 알림, 데이터 등)
  - **BottomNavigationBar**: 메인 네비게이션 (프로필 탭 활성화)

- **상호작용**:
  - 편집 버튼으로 프로필 정보 수정
  - 설정 버튼으로 설정 페이지로 이동
  - 감정 프로필 설정 및 수정
  - 통계 정보 확인
  - 하단 네비게이션으로 다른 메인 페이지 이동

---

## 📋 문서 정보



### **참고 문서**
- `emoti_flow_requirements.md`: 프로젝트 요구사항 정의서
- `emoti_flow_functional_spec.md`: 기능 상세 명세서
- `emoti_flow_ia.md`: 정보 아키텍처 문서
- `emoti_flow_uiux_guide.md`: UI/UX 상세 가이드

---

## 🔄 변경 이력

### **v1.1 (2024년 12월)**
- **주요 변경사항**:
  - 웹 중심 구조에서 Flutter 모바일 앱 구조로 완전 재작성
  - "Header" → "AppBar"로 용어 통일
  - 각 페이지별 Flutter Scaffold 구조 상세 정의
  - UI 컴포넌트별 상세 설명 추가
  - 상호작용 및 네비게이션 흐름 명확화

- **추가된 내용**:
  - Flutter 앱 구조 개요
  - 공통 UI 컴포넌트 정의
  - 각 페이지별 Flutter 코드 구조 예시
  - BottomNavigationBar 네비게이션 구조
  - FloatingActionButton 활용 방법

- **개선된 내용**:
  - 페이지 구조의 시각적 이해도 향상
  - 개발자가 바로 구현할 수 있는 상세한 구조 제공
  - Flutter 앱 개발에 최적화된 문서 구조
