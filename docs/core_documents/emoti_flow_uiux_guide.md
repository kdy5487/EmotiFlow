# EmotiFlow - UI/UX 상세 가이드

## 📋 문서 개요

| 항목 | 내용 |
|------|------|
| **문서명** | EmotiFlow UI/UX 상세 가이드 |
| **작성일** | 2024년 12월 |
| **버전** | 1.0 |
| **작성자** | AI Assistant |
| **목적** | 앱의 디자인 시스템, UI 컴포넌트, UX 가이드라인 정의 |

---

## 🎨 디자인 시스템

### **1. 컬러 팔레트**

#### **Primary Colors (주요 색상)**
```dart
// Primary Brand Colors
primary: Color(0xFF6366F1),      // 인디고 - 신뢰와 안정감
primaryLight: Color(0xFF818CF8), // 밝은 인디고
primaryDark: Color(0xFF4F46E5),  // 어두운 인디고

// Secondary Brand Colors
secondary: Color(0xFFEC4899),    // 핑크 - 따뜻함과 공감
secondaryLight: Color(0xFFF472B6), // 밝은 핑크
secondaryDark: Color(0xFFDB2777),  // 어두운 핑크
```

#### **Semantic Colors (의미론적 색상)**
```dart
// Success Colors
success: Color(0xFF10B981),      // 에메랄드 - 성장과 긍정
successLight: Color(0xFF34D399), // 밝은 에메랄드
successDark: Color(0xFF059669),  // 어두운 에메랄드

// Warning Colors
warning: Color(0xFFF59E0B),      // 앰버 - 주의와 경계
warningLight: Color(0xFFFBBF24), // 밝은 앰버
warningDark: Color(0xFFD97706),  // 어두운 앰버

// Error Colors
error: Color(0xFFEF4444),        // 레드 - 위험과 경고
errorLight: Color(0xFFF87171),   // 밝은 레드
errorDark: Color(0xFFDC2626),    // 어두운 레드
```

#### **Neutral Colors (중성 색상)**
```dart
// Background Colors
background: Color(0xFFF8FAFC),   // 슬레이트 - 깔끔함
backgroundSecondary: Color(0xFFF1F5F9), // 보조 배경
backgroundTertiary: Color(0xFFE2E8F0),  // 3차 배경

// Surface Colors
surface: Color(0xFFFFFFFF),      // 화이트 - 순수함
surfaceSecondary: Color(0xFFF8FAFC),    // 보조 표면
surfaceTertiary: Color(0xFFF1F5F9),    // 3차 표면

// Text Colors
textPrimary: Color(0xFF1E293B),  // 슬레이트 - 가독성
textSecondary: Color(0xFF64748B), // 슬레이트 - 부가 정보
textTertiary: Color(0xFF94A3B8),  // 3차 텍스트
textInverse: Color(0xFFFFFFFF),   // 반전 텍스트

// Border Colors
border: Color(0xFFE2E8F0),       // 테두리 기본
borderSecondary: Color(0xFFCBD5E1), // 보조 테두리
borderFocus: Color(0xFF6366F1),   // 포커스 테두리
```

### **2. 감정별 컬러 매핑**

#### **감정 색상 체계**
```dart
emotions: {
  // 긍정적 감정
  'joy': {
    primary: Color(0xFFFBBF24),      // 기쁨 - 노랑
    light: Color(0xFFFCD34D),        // 밝은 노랑
    dark: Color(0xFFF59E0B),         // 어두운 노랑
    background: Color(0xFFFEF3C7),   // 배경 노랑
  },
  'gratitude': {
    primary: Color(0xFFF97316),      // 감사 - 주황
    light: Color(0xFFFB923C),        // 밝은 주황
    dark: Color(0xFFEA580C),         // 어두운 주황
    background: Color(0xFFFFEDD5),   // 배경 주황
  },
  'excitement': {
    primary: Color(0xFFEC4899),      // 설렘 - 핑크
    light: Color(0xFFF472B6),        // 밝은 핑크
    dark: Color(0xFFDB2777),         // 어두운 핑크
    background: Color(0xFFFCE7F3),   // 배경 핑크
  },
  'calm': {
    primary: Color(0xFF10B981),      // 평온 - 초록
    light: Color(0xFF34D399),        // 밝은 초록
    dark: Color(0xFF059669),         // 어두운 초록
    background: Color(0xFFD1FAE5),   // 배경 초록
  },
  
  // 부정적 감정
  'sadness': {
    primary: Color(0xFF3B82F6),      // 슬픔 - 파랑
    light: Color(0xFF60A5FA),        // 밝은 파랑
    dark: Color(0xFF2563EB),         // 어두운 파랑
    background: Color(0xFFDBEAFE),   // 배경 파랑
  },
  'anger': {
    primary: Color(0xFFEF4444),      // 분노 - 빨강
    light: Color(0xFFF87171),        // 밝은 빨강
    dark: Color(0xFFDC2626),         // 어두운 빨강
    background: Color(0xFFFEE2E2),   // 배경 빨강
  },
  'worry': {
    primary: Color(0xFF8B5CF6),      // 걱정 - 보라
    light: Color(0xFFA78BFA),        // 밝은 보라
    dark: Color(0xFF7C3AED),         // 어두운 보라
    background: Color(0xFFEDE9FE),   // 배경 보라
  },
  'boredom': {
    primary: Color(0xFF6B7280),      // 지루함 - 회색
    light: Color(0xFF9CA3AF),        // 밝은 회색
    dark: Color(0xFF4B5563),         // 어두운 회색
    background: Color(0xFFF3F4F6),   // 배경 회색
  },
}
```

---

## 🔤 타이포그래피

### **1. 폰트 패밀리**
```dart
// Font Family
fontFamily: 'Pretendard',        // 기본 폰트
fontFamilyFallback: ['-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'sans-serif'], // 폴백 폰트
```

### **2. 텍스트 스타일 계층**
```dart
// Display Styles (큰 제목)
displayLarge: TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  height: 1.2,
  letterSpacing: -0.5,
),

displayMedium: TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  height: 1.3,
  letterSpacing: -0.3,
),

displaySmall: TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  height: 1.4,
  letterSpacing: -0.2,
),

// Heading Styles (제목)
headingLarge: TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w600,
  height: 1.4,
  letterSpacing: -0.1,
),

headingMedium: TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  height: 1.4,
  letterSpacing: 0,
),

headingSmall: TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  height: 1.4,
  letterSpacing: 0,
),

// Body Styles (본문)
bodyLarge: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  height: 1.5,
  letterSpacing: 0,
),

bodyMedium: TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  height: 1.5,
  letterSpacing: 0,
),

bodySmall: TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  height: 1.5,
  letterSpacing: 0.1,
),

// Caption Styles (부가 정보)
caption: TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  height: 1.4,
  letterSpacing: 0.2,
),

captionSmall: TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.normal,
  height: 1.4,
  letterSpacing: 0.3,
),

// Button Styles (버튼)
buttonLarge: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  height: 1.4,
  letterSpacing: 0.1,
),

buttonMedium: TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  height: 1.4,
  letterSpacing: 0.1,
),

buttonSmall: TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  height: 1.4,
  letterSpacing: 0.1,
),
```

---

## 🧩 컴포넌트 스타일

### **1. 버튼 스타일**

#### **Primary Button (주요 버튼)**
```dart
// Primary Button - Large
primaryButtonLarge: {
  height: 56,
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  borderRadius: BorderRadius.circular(16),
  backgroundColor: primary,
  foregroundColor: textInverse,
  elevation: 4,
  shadowColor: primary.withOpacity(0.3),
  shadowOffset: Offset(0, 4),
  shadowBlurRadius: 12,
  
  // Hover State
  hoverColor: primaryDark,
  hoverElevation: 6,
  
  // Pressed State
  pressedColor: primaryDark,
  pressedElevation: 2,
}

// Primary Button - Medium
primaryButtonMedium: {
  height: 48,
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  borderRadius: BorderRadius.circular(12),
  backgroundColor: primary,
  foregroundColor: textInverse,
  elevation: 3,
  shadowColor: primary.withOpacity(0.25),
  shadowOffset: Offset(0, 2),
  shadowBlurRadius: 8,
}

// Primary Button - Small
primaryButtonSmall: {
  height: 40,
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  borderRadius: BorderRadius.circular(8),
  backgroundColor: primary,
  foregroundColor: textInverse,
  elevation: 2,
  shadowColor: primary.withOpacity(0.2),
  shadowOffset: Offset(0, 1),
  shadowBlurRadius: 4,
}
```

#### **Secondary Button (보조 버튼)**
```dart
// Secondary Button
secondaryButton: {
  height: 48,
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  borderRadius: BorderRadius.circular(12),
  backgroundColor: Colors.transparent,
  foregroundColor: primary,
  border: Border.all(color: primary, width: 2),
  
  // Hover State
  hoverColor: primary.withOpacity(0.1),
  
  // Pressed State
  pressedColor: primary.withOpacity(0.2),
}
```

#### **Icon Button (아이콘 버튼)**
```dart
// Icon Button
iconButton: {
  size: 48,
  borderRadius: BorderRadius.circular(50),
  backgroundColor: surface,
  foregroundColor: textPrimary,
  border: Border.all(color: border, width: 1),
  
  // Hover State
  hoverColor: backgroundSecondary,
  
  // Pressed State
  pressedColor: backgroundTertiary,
}
```

### **2. 카드 스타일**

#### **기본 카드**
```dart
// Basic Card
basicCard: {
  backgroundColor: surface,
  borderRadius: BorderRadius.circular(16),
  padding: EdgeInsets.all(20),
  margin: EdgeInsets.all(16),
  elevation: 2,
  shadowColor: Colors.black.withOpacity(0.1),
  shadowOffset: Offset(0, 2),
  shadowBlurRadius: 8,
  
  // Hover State
  hoverElevation: 4,
  hoverShadowBlurRadius: 12,
}
```

#### **감정 카드**
```dart
// Emotion Card
emotionCard: {
  backgroundColor: surface,
  borderRadius: BorderRadius.circular(20),
  padding: EdgeInsets.all(24),
  margin: EdgeInsets.all(16),
  elevation: 3,
  shadowColor: Colors.black.withOpacity(0.15),
  shadowOffset: Offset(0, 3),
  shadowBlurRadius: 12,
  
  // 감정별 테두리 색상
  border: Border.all(
    color: emotionColor.withOpacity(0.3),
    width: 2,
  ),
  
  // Hover State
  hoverElevation: 6,
  hoverShadowBlurRadius: 16,
}
```

#### **입력 카드**
```dart
// Input Card
inputCard: {
  backgroundColor: surface,
  borderRadius: BorderRadius.circular(12),
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.all(8),
  elevation: 1,
  shadowColor: Colors.black.withOpacity(0.05),
  shadowOffset: Offset(0, 1),
  shadowBlurRadius: 4,
  
  // Focus State
  focusBorder: Border.all(
    color: borderFocus,
    width: 2,
  ),
}
```

### **3. 입력 필드 스타일**

#### **텍스트 입력 필드**
```dart
// Text Input Field
textInputField: {
  height: 56,
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  borderRadius: BorderRadius.circular(12),
  backgroundColor: surface,
  border: Border.all(color: border, width: 1),
  
  // Focus State
  focusBorder: Border.all(
    color: borderFocus,
    width: 2,
  ),
  
  // Error State
  errorBorder: Border.all(
    color: error,
    width: 2,
  ),
  
  // Disabled State
  disabledBackgroundColor: backgroundSecondary,
  disabledBorder: Border.all(
    color: borderSecondary,
    width: 1,
  ),
}
```

#### **검색 입력 필드**
```dart
// Search Input Field
searchInputField: {
  height: 48,
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  borderRadius: BorderRadius.circular(24),
  backgroundColor: backgroundSecondary,
  border: Border.all(color: borderSecondary, width: 1),
  
  // Focus State
  focusBackgroundColor: surface,
  focusBorder: Border.all(
    color: borderFocus,
    width: 2,
  ),
}
```

---

## 📱 반응형 디자인 규칙

### **1. 브레이크포인트 정의**
```dart
// Breakpoints
class Breakpoints {
  static const double mobile = 640;      // 모바일
  static const double tablet = 1024;     // 태블릿
  static const double desktop = 1440;    // 데스크톱
  static const double wide = 1920;       // 와이드 데스크톱
}
```

### **2. 화면 크기별 레이아웃**

#### **모바일 (< 640px)**
```dart
// Mobile Layout
mobileLayout: {
  columns: 1,                    // 1단 레이아웃
  padding: 16,                   // 좌우 여백 16px
  cardSpacing: 12,               // 카드 간격 12px
  buttonHeight: 48,              // 버튼 높이 48px
  fontSize: 'bodyMedium',        // 기본 폰트 크기
  navigation: 'bottom',          // 하단 네비게이션
}
```

#### **태블릿 (641~1024px)**
```dart
// Tablet Layout
tabletLayout: {
  columns: 2,                    // 2단 레이아웃
  padding: 24,                   // 좌우 여백 24px
  cardSpacing: 16,               // 카드 간격 16px
  buttonHeight: 56,              // 버튼 높이 56px
  fontSize: 'bodyLarge',         // 기본 폰트 크기
  navigation: 'bottom',          // 하단 네비게이션
  sidebar: false,                // 사이드바 없음
}
```

#### **데스크톱 (> 1024px)**
```dart
// Desktop Layout
desktopLayout: {
  columns: 3,                    // 3단 레이아웃
  padding: 32,                   // 좌우 여백 32px
  cardSpacing: 20,               // 카드 간격 20px
  buttonHeight: 56,              // 버튼 높이 56px
  fontSize: 'bodyLarge',         // 기본 폰트 크기
  navigation: 'left',            // 좌측 네비게이션
  sidebar: true,                 // 사이드바 있음
  maxWidth: 1440,                // 최대 너비 제한
}
```

### **3. 그리드 시스템**
```dart
// Grid System
gridSystem: {
  // 12컬럼 그리드
  columns: 12,
  
  // 간격
  gutter: {
    mobile: 12,
    tablet: 16,
    desktop: 20,
  },
  
  // 마진
  margin: {
    mobile: 16,
    tablet: 24,
    desktop: 32,
  },
}
```

---

## ✨ 애니메이션 및 전환

### **1. 기본 애니메이션 값**
```dart
// Animation Durations
animationDuration: {
  fast: Duration(milliseconds: 150),      // 빠른 애니메이션
  normal: Duration(milliseconds: 300),    // 일반 애니메이션
  slow: Duration(milliseconds: 500),      // 느린 애니메이션
  verySlow: Duration(milliseconds: 800),  // 매우 느린 애니메이션
}

// Animation Curves
animationCurve: {
  easeIn: Curves.easeIn,                 // 점진적 시작
  easeOut: Curves.easeOut,               // 점진적 종료
  easeInOut: Curves.easeInOut,           // 점진적 시작/종료
  bounce: Curves.bounceOut,              // 바운스 효과
  elastic: Curves.elasticOut,            // 탄성 효과
}
```

### **2. 페이지 전환 애니메이션**
```dart
// Page Transitions
pageTransitions: {
  // 슬라이드 전환
  slideTransition: {
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    direction: AxisDirection.right,       // 오른쪽에서 슬라이드
  },
  
  // 페이드 전환
  fadeTransition: {
    duration: Duration(milliseconds: 250),
    curve: Curves.easeInOut,
  },
  
  // 스케일 전환
  scaleTransition: {
    duration: Duration(milliseconds: 200),
    curve: Curves.easeOut,
    scale: 0.95,                         // 95%에서 시작
  },
}
```

### **3. 컴포넌트 애니메이션**
```dart
// Component Animations
componentAnimations: {
  // 카드 등장
  cardEntrance: {
    duration: Duration(milliseconds: 400),
    curve: Curves.easeOut,
    delay: Duration(milliseconds: 100),   // 지연 시작
    stagger: Duration(milliseconds: 50),  // 순차 등장
  },
  
  // 버튼 클릭
  buttonPress: {
    duration: Duration(milliseconds: 150),
    curve: Curves.easeIn,
    scale: 0.95,                         // 95%로 축소
  },
  
  // 감정 선택
  emotionSelection: {
    duration: Duration(milliseconds: 200),
    curve: Curves.bounceOut,
    scale: 1.1,                          // 110%로 확대
  },
  
  // 로딩 스피너
  loadingSpinner: {
    duration: Duration(milliseconds: 1000),
    curve: Curves.linear,
    rotation: 360,                        // 360도 회전
  },
}
```

### **4. 마이크로 인터랙션**
```dart
// Micro Interactions
microInteractions: {
  // 호버 효과
  hover: {
    duration: Duration(milliseconds: 200),
    curve: Curves.easeOut,
    scale: 1.02,                         // 2% 확대
    elevation: 2,                         // 그림자 증가
  },
  
  // 포커스 효과
  focus: {
    duration: Duration(milliseconds: 150),
    curve: Curves.easeOut,
    borderColor: borderFocus,             // 포커스 테두리 색상
    borderWidth: 2,                       // 포커스 테두리 두께
  },
  
  // 활성화 효과
  active: {
    duration: Duration(milliseconds: 100),
    curve: Curves.easeIn,
    scale: 0.98,                          // 2% 축소
    opacity: 0.8,                         // 투명도 감소
  },
}
```

---

## ♿ 접근성 지침

### **1. 색상 대비**
```dart
// Color Contrast Requirements
colorContrast: {
  // WCAG 2.1 AA 기준
  normalText: 4.5,                        // 일반 텍스트 최소 대비
  largeText: 3.0,                         // 큰 텍스트 최소 대비
  uiComponents: 3.0,                      // UI 컴포넌트 최소 대비
  
  // 감정별 색상 대비 검증
  emotionColors: {
    joy: 4.8,                             // 기쁨 색상 대비
    sadness: 4.6,                         // 슬픔 색상 대비
    anger: 4.9,                           // 분노 색상 대비
    calm: 4.7,                            // 평온 색상 대비
  },
}
```

### **2. 터치 영역**
```dart
// Touch Target Sizes
touchTargets: {
  // 최소 터치 영역
  minimum: 44,                            // 44x44px (iOS 가이드라인)
  recommended: 48,                        // 48x48px (Material Design)
  
  // 컴포넌트별 터치 영역
  button: 48,                             // 버튼 최소 높이
  iconButton: 48,                         // 아이콘 버튼 크기
  checkbox: 44,                           // 체크박스 크기
  radioButton: 44,                        // 라디오 버튼 크기
}
```

### **3. 스크린 리더 지원**
```dart
// Screen Reader Support
screenReader: {
  // 시맨틱 라벨
  semanticLabels: {
    button: '버튼',
    input: '입력 필드',
    image: '이미지',
    link: '링크',
  },
  
  // 상태 정보
  stateInformation: {
    selected: '선택됨',
    unselected: '선택되지 않음',
    loading: '로딩 중',
    error: '오류 발생',
    success: '완료됨',
  },
  
  // 힌트 텍스트
  hintText: {
    search: '검색어를 입력하세요',
    email: '이메일 주소를 입력하세요',
    password: '비밀번호를 입력하세요',
  },
}
```

### **4. 키보드 네비게이션**
```dart
// Keyboard Navigation
keyboardNavigation: {
  // 포커스 순서
  focusOrder: [
    'header',
    'navigation',
    'mainContent',
    'sidebar',
    'footer',
  ],
  
  // 단축키
  shortcuts: {
    'Tab': '다음 요소로 이동',
    'Shift + Tab': '이전 요소로 이동',
    'Enter': '선택/실행',
    'Space': '체크박스 토글',
    'Arrow Keys': '방향 이동',
  },
  
  // 포커스 표시
  focusIndicator: {
    visible: true,                        // 포커스 표시 여부
    style: 'outline',                     // 포커스 스타일
    color: borderFocus,                   // 포커스 색상
    width: 2,                             // 포커스 두께
  },
}
```

---

## 📐 레이아웃 가이드라인

### **1. 여백 및 간격**
```dart
// Spacing System
spacing: {
  // 기본 간격 단위 (8px 기준)
  unit: 8,
  
  // 간격 크기
  xs: 4,                                 // 4px
  sm: 8,                                 // 8px
  md: 16,                                // 16px
  lg: 24,                                // 24px
  xl: 32,                                // 32px
  xxl: 48,                               // 48px
  
  // 컴포넌트별 여백
  component: {
    padding: 16,                         // 컴포넌트 내부 여백
    margin: 8,                           // 컴포넌트 외부 여백
    gap: 12,                             // 컴포넌트 간 간격
  },
  
  // 섹션별 여백
  section: {
    padding: 24,                         // 섹션 내부 여백
    margin: 16,                          // 섹션 외부 여백
    gap: 20,                             // 섹션 간 간격
  },
}
```

### **2. 정렬 및 배치**
```dart
// Alignment Guidelines
alignment: {
  // 텍스트 정렬
  text: {
    heading: TextAlign.left,             // 제목: 좌측 정렬
    body: TextAlign.left,                // 본문: 좌측 정렬
    button: TextAlign.center,            // 버튼: 중앙 정렬
    caption: TextAlign.center,           // 캡션: 중앙 정렬
  },
  
  // 컴포넌트 정렬
  component: {
    card: CrossAxisAlignment.start,      // 카드: 상단 정렬
    button: MainAxisAlignment.center,    // 버튼: 중앙 정렬
    list: CrossAxisAlignment.stretch,   // 리스트: 늘리기
  },
  
  // 레이아웃 정렬
  layout: {
    mobile: MainAxisAlignment.start,     // 모바일: 상단 정렬
    tablet: MainAxisAlignment.center,    // 태블릿: 중앙 정렬
    desktop: MainAxisAlignment.start,    // 데스크톱: 상단 정렬
  },
}
```

### **3. 계층 구조**
```dart
// Hierarchy Guidelines
hierarchy: {
  // 시각적 계층
  visual: {
    primary: 1,                          // 주요 요소
    secondary: 2,                        // 보조 요소
    tertiary: 3,                         // 3차 요소
    background: 0,                       // 배경 요소
  },
  
  // 정보 계층
  information: {
    critical: 1,                         // 중요 정보
    important: 2,                        // 주요 정보
    helpful: 3,                          // 도움 정보
    optional: 4,                         // 선택 정보
  },
  
  // 상호작용 계층
  interaction: {
    primary: 1,                          // 주요 액션
    secondary: 2,                        // 보조 액션
    tertiary: 3,                         // 3차 액션
    destructive: 0,                      // 위험 액션
  },
}
```

---

## 🎯 사용자 경험 가이드라인

### **1. 로딩 상태**
```dart
// Loading States
loadingStates: {
  // 스켈레톤 로딩
  skeleton: {
    duration: Duration(milliseconds: 1500),
    shimmer: true,                       // 반짝임 효과
    borderRadius: BorderRadius.circular(8),
  },
  
  // 스피너 로딩
  spinner: {
    size: 24,                            // 스피너 크기
    color: primary,                      // 스피너 색상
    strokeWidth: 2,                      // 선 두께
  },
  
  // 프로그레스 바
  progressBar: {
    height: 4,                           // 높이
    backgroundColor: backgroundSecondary, // 배경 색상
    progressColor: primary,              // 진행 색상
    borderRadius: BorderRadius.circular(2), // 모서리 둥글기
  },
}
```

### **2. 오류 처리**
```dart
// Error Handling
errorHandling: {
  // 오류 메시지
  message: {
    style: 'bodyMedium',                 // 폰트 스타일
    color: error,                        // 색상
    icon: Icons.error_outline,           // 아이콘
  },
  
  // 재시도 버튼
  retryButton: {
    style: 'secondaryButton',            // 버튼 스타일
    text: '다시 시도',                   // 버튼 텍스트
    icon: Icons.refresh,                 // 아이콘
  },
  
  // 폴백 UI
  fallback: {
    showDefaultContent: true,            // 기본 내용 표시
    showRetryOption: true,               // 재시도 옵션 표시
    showHelpLink: true,                  // 도움말 링크 표시
  },
}
```

### **3. 성공 피드백**
```dart
// Success Feedback
successFeedback: {
  // 성공 메시지
  message: {
    style: 'bodyMedium',                 // 폰트 스타일
    color: success,                      // 색상
    icon: Icons.check_circle,            // 아이콘
    duration: Duration(seconds: 3),      // 표시 시간
  },
  
  // 애니메이션
  animation: {
    type: 'scale',                       // 애니메이션 타입
    duration: Duration(milliseconds: 300), // 지속 시간
    curve: Curves.bounceOut,             // 애니메이션 곡선
  },
  
  // 다음 액션 안내
  nextAction: {
    showHint: true,                      // 힌트 표시
    autoNavigate: false,                 // 자동 이동
    highlightNext: true,                 // 다음 단계 강조
  },
}
```

---

## 🔧 개발자 가이드

### **1. 테마 적용 방법**
```dart
// Theme Application
class EmotiFlowTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // 색상 팔레트
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      
      // 텍스트 테마
      textTheme: AppTextStyles.textTheme,
      
      // 컴포넌트 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.primaryButton,
      ),
      
      // 카드 테마
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
      ),
    );
  }
}
```

### **2. 반응형 UI 구현**
```dart
// Responsive UI Implementation
class ResponsiveBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < Breakpoints.mobile) {
          return MobileLayout();
        } else if (constraints.maxWidth < Breakpoints.tablet) {
          return TabletLayout();
        } else {
          return DesktopLayout();
        }
      },
    );
  }
}
```

### **3. 애니메이션 구현**
```dart
// Animation Implementation
class AnimatedCard extends StatefulWidget {
  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.cardEntrance.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.cardEntrance.curve,
    ));
    _controller.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        child: widget.child,
      ),
    );
  }
}
```

---

## 🧩 공통 위젯 구현 가이드

### **1. 감정 선택 위젯 (EmotionSelector)**
```dart
// 감정 선택 위젯
class EmotionSelector extends StatelessWidget {
  final Emotion selectedEmotion;
  final ValueChanged<Emotion> onEmotionChanged;
  
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: Emotion.values.map((emotion) {
        return EmotionChip(
          emotion: emotion,
          isSelected: selectedEmotion == emotion,
          onTap: () => onEmotionChanged(emotion),
        );
      }).toList(),
    );
  }
}
```

### **2. 일기 카드 위젯 (DiaryCard)**
```dart
// 일기 카드 위젯
class DiaryCard extends StatelessWidget {
  final Diary diary;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(diary.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(diary.content, maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(
                children: [
                  EmotionIcon(emotion: diary.emotion),
                  const SizedBox(width: 8),
                  Text(diary.createdAt.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### **3. 감정 아이콘 위젯 (EmotionIcon)**
```dart
// 감정 아이콘 위젯
class EmotionIcon extends StatelessWidget {
  final Emotion emotion;
  final double size;
  final Color? color;
  
  const EmotionIcon({
    super.key,
    required this.emotion,
    this.size = 24,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Icon(
      _getEmotionIcon(emotion),
      size: size,
      color: color ?? _getEmotionColor(emotion),
    );
  }
  
  IconData _getEmotionIcon(Emotion emotion) {
    switch (emotion) {
      case Emotion.joy:
        return Icons.sentiment_very_satisfied;
      case Emotion.sadness:
        return Icons.sentiment_dissatisfied;
      case Emotion.anger:
        return Icons.whatshot;
      case Emotion.fear:
        return Icons.psychology;
      case Emotion.surprise:
        return Icons.emoji_emotions;
      default:
        return Icons.sentiment_neutral;
    }
  }
  
  Color _getEmotionColor(Emotion emotion) {
    return AppColors.getEmotionPrimary(emotion.name);
  }
}
```

### **4. 감정 칩 위젯 (EmotionChip)**
```dart
// 감정 칩 위젯
class EmotionChip extends StatelessWidget {
  final Emotion emotion;
  final bool isSelected;
  final VoidCallback? onTap;
  
  const EmotionChip({
    super.key,
    required this.emotion,
    this.isSelected = false,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final emotionColor = AppColors.getEmotionPrimary(emotion.name);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? emotionColor.withOpacity(0.2) : AppColors.surface,
          border: Border.all(
            color: isSelected ? emotionColor : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmotionIcon(emotion: emotion, size: 16),
            const SizedBox(width: 6),
            Text(
              _getEmotionLabel(emotion),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? emotionColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getEmotionLabel(Emotion emotion) {
    const labels = {
      Emotion.joy: '기쁨',
      Emotion.sadness: '슬픔',
      Emotion.anger: '분노',
      Emotion.fear: '두려움',
      Emotion.surprise: '놀람',
      Emotion.neutral: '중립',
    };
    return labels[emotion] ?? emotion.name;
  }
}
```

### **5. 위젯 사용 예시**
```dart
// 감정 선택기 사용 예시
class DiaryWritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('일기 작성')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 감정 선택기
            EmotionSelector(
              selectedEmotion: selectedEmotion,
              onEmotionChanged: (emotion) {
                setState(() {
                  selectedEmotion = emotion;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // 일기 입력 필드
            TextField(
              decoration: InputDecoration(
                hintText: '오늘 하루는 어땠나요?',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
```
