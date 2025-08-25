# 다크모드 구현 계획

## 🎯 목표
앱 전체에 완전한 다크모드 지원을 구현하여 사용자가 라이트/다크/시스템 테마를 선택할 수 있도록 함

## 📋 구현 단계

### 1단계: 기본 테마 구조 완성 ✅
- [x] 테마 프로바이더 생성 (`lib/theme/theme_provider.dart`)
- [x] 테마 설정 페이지 구현 (`lib/features/settings/views/theme_settings_page.dart`)
- [x] 메인 앱에 테마 적용 (`lib/main.dart`)

### 2단계: 오류 수정 및 테마 래퍼 정리 🔧
- [ ] `theme_wrapper.dart` 린터 오류 수정
- [ ] 테마 래퍼 위젯들 정리 및 최적화

### 3단계: 홈 페이지 테마 적용 🏠
- [x] 기본 배경색 및 AppBar 색상 테마화
- [x] 모달 배경색 테마화
- [ ] 주요 색상들 (primary, secondary, success, info 등) 테마화
- [ ] 텍스트 색상들 테마화
- [ ] 카드 및 컨테이너 색상 테마화

### 4단계: 다른 주요 페이지들 테마 적용 📱
- [ ] 일기 관련 페이지들 테마화
- [ ] AI 페이지 테마화
- [ ] 프로필 페이지 테마화
- [ ] 설정 페이지 테마화
- [ ] 음악 페이지 테마화

### 5단계: 공통 위젯 테마화 🧩
- [ ] EmotiCard 위젯 테마화
- [ ] EmotiButton 위젯 테마화
- [ ] 기타 공통 위젯들 테마화

### 6단계: 테마 테스트 및 최적화 ✅
- [ ] 다크모드 전환 테스트
- [ ] 색상 대비 및 가독성 확인
- [ ] 성능 최적화

## 🚨 현재 문제점
1. `theme_wrapper.dart`에서 `isSemanticButton`, `enableFeedback` 파라미터 오류
2. 홈 페이지에서 하드코딩된 색상들이 많음
3. 일부 위젯에서 테마 색상 미적용

## 🔧 해결 방법
1. 테마 래퍼 오류 수정
2. 하드코딩된 색상들을 `Theme.of(context).colorScheme` 색상으로 교체
3. 단계별로 페이지별 테마 적용

## 📱 테마 적용 우선순위
1. 홈 페이지 (사용자 경험에 가장 중요)
2. 일기 관련 페이지들 (핵심 기능)
3. 설정 및 프로필 페이지들
4. 기타 페이지들

## 🎨 테마 색상 매핑
- `AppTheme.primary` → `Theme.of(context).colorScheme.primary`
- `AppTheme.secondary` → `Theme.of(context).colorScheme.secondary`
- `AppTheme.background` → `Theme.of(context).colorScheme.background`
- `AppTheme.surface` → `Theme.of(context).colorScheme.surface`
- `AppTheme.textPrimary` → `Theme.of(context).colorScheme.onSurface`
- `AppTheme.textSecondary` → `Theme.of(context).colorScheme.onSurface.withOpacity(0.7)`
- `AppTheme.textTertiary` → `Theme.of(context).colorScheme.onSurface.withOpacity(0.5)`
- `AppTheme.success` → `Theme.of(context).colorScheme.primary`
- `AppTheme.info` → `Theme.of(context).colorScheme.secondary`
- `AppTheme.warning` → `Theme.of(context).colorScheme.tertiary`
- `AppTheme.error` → `Theme.of(context).colorScheme.error`
