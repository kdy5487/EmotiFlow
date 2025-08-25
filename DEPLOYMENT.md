# 🚀 EmotiFlow 배포 환경 구축 가이드

## 📋 목차
1. [개요](#개요)
2. [사전 준비사항](#사전-준비사항)
3. [환경 설정](#환경-설정)
4. [릴리즈 빌드](#릴리즈-빌드)
5. [배포](#배포)
6. [모니터링](#모니터링)

## 🎯 개요
이 문서는 EmotiFlow 앱의 배포 환경을 구축하고 관리하는 방법을 설명합니다.

## 🔧 사전 준비사항

### 필수 도구
- Flutter SDK 3.24.0 이상
- Android Studio / Xcode
- Git
- GitHub 계정

### 계정 및 서비스
- Firebase 프로젝트
- Google Play Console (Android)
- App Store Connect (iOS)
- GitHub Actions

## ⚙️ 환경 설정

### 1. 환경 변수 설정
```bash
# env.example 파일을 복사하여 .env 파일 생성
cp env.example .env

# .env 파일을 편집하여 실제 값 입력
nano .env
```

### 2. Firebase 설정
```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Firebase 로그인
firebase login

# 프로젝트 초기화
firebase init
```

### 3. GitHub Secrets 설정
GitHub 저장소의 Settings > Secrets and variables > Actions에서 다음 시크릿을 설정:

- `FIREBASE_SERVICE_ACCOUNT_KEY`: Firebase 서비스 계정 키
- `GOOGLE_PLAY_SERVICE_ACCOUNT_KEY`: Google Play 서비스 계정 키
- `APP_STORE_CONNECT_API_KEY`: App Store Connect API 키

## 🏗️ 릴리즈 빌드

### Android 릴리즈 빌드
```bash
# 릴리즈 APK 빌드
flutter build apk --release

# App Bundle 빌드 (Google Play 배포용)
flutter build appbundle --release

# 빌드된 파일 위치
# APK: build/app/outputs/flutter-apk/app-release.apk
# Bundle: build/app/outputs/bundle/release/app-release.aab
```

### iOS 릴리즈 빌드
```bash
# 릴리즈 IPA 빌드
flutter build ios --release

# 빌드된 파일 위치
# build/ios/iphoneos/Runner.app
```

### 웹 릴리즈 빌드
```bash
# 웹 빌드
flutter build web --release

# 빌드된 파일 위치
# build/web/
```

## 🚀 배포

### 자동 배포 (GitHub Actions)
1. `main` 브랜치에 푸시하면 자동으로 릴리즈 빌드 및 배포
2. `develop` 브랜치에 푸시하면 스테이징 빌드

### 수동 배포
```bash
# CI/CD 파이프라인 수동 실행
gh workflow run ci-cd.yml

# 특정 환경으로 배포
gh workflow run ci-cd.yml -f environment=production
```

### Google Play Store 배포
1. Google Play Console에서 새 릴리즈 생성
2. App Bundle (.aab) 파일 업로드
3. 릴리즈 노트 작성
4. 검토 후 배포

### App Store 배포
1. Xcode에서 Archive 생성
2. App Store Connect에 업로드
3. TestFlight 또는 App Store 배포

## 📊 모니터링

### Firebase Analytics
- 사용자 행동 분석
- 앱 성능 모니터링
- 크래시 리포트

### GitHub Actions
- 빌드 상태 모니터링
- 배포 이력 추적
- 자동화된 테스트 결과

### 로그 모니터링
```dart
// 환경별 로그 레벨 설정
Logger.debug('디버그 정보');      // 개발 환경에서만
Logger.info('일반 정보');         // 모든 환경
Logger.warning('경고');          // 스테이징/운영 환경
Logger.error('오류');            // 모든 환경
```

## 🔒 보안 고려사항

### 코드 난독화
- ProGuard 규칙 적용 (Android)
- 코드 서명 설정
- 민감한 정보 암호화

### API 키 관리
- 환경 변수 사용
- GitHub Secrets 활용
- 프로덕션 키 분리

## 🧪 테스트

### 자동화된 테스트
```bash
# 단위 테스트
flutter test

# 통합 테스트
flutter test integration_test/

# 코드 커버리지
flutter test --coverage
```

### 수동 테스트
- 다양한 디바이스에서 테스트
- 네트워크 상태별 테스트
- 사용자 시나리오 테스트

## 📝 체크리스트

### 배포 전 체크리스트
- [ ] 모든 테스트 통과
- [ ] 코드 리뷰 완료
- [ ] 환경 변수 설정 완료
- [ ] Firebase 설정 확인
- [ ] 앱 아이콘 및 스플래시 화면 설정
- [ ] 버전 번호 업데이트

### 배포 후 체크리스트
- [ ] 앱 스토어에서 다운로드 테스트
- [ ] 푸시 알림 테스트
- [ ] 주요 기능 동작 확인
- [ ] 모니터링 시스템 확인
- [ ] 사용자 피드백 수집

## 🆘 문제 해결

### 일반적인 문제들
1. **빌드 실패**: 의존성 확인, Flutter 버전 확인
2. **서명 오류**: 키스토어 설정 확인
3. **배포 실패**: 권한 및 설정 확인

### 지원 채널
- GitHub Issues
- Flutter 공식 문서
- Firebase 지원

## 📚 추가 리소스
- [Flutter 배포 가이드](https://flutter.dev/docs/deployment)
- [Firebase 문서](https://firebase.google.com/docs)
- [GitHub Actions 문서](https://docs.github.com/en/actions)
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com)

---

**⚠️ 주의사항**: 이 가이드는 개발 환경을 위한 것입니다. 실제 프로덕션 배포 시에는 보안 및 규정 준수 요구사항을 반드시 확인하세요.
