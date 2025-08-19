# EmotiFlow 

감정을 기록하고 AI와 함께 성장하는 일기 앱

##  프로젝트 소개

EmotiFlow는 사용자의 일상적인 감정을 AI와 함께 분석하고, 개인화된 인사이트를 제공하는 Flutter 기반 모바일 애플리케이션입니다.

### 주요 기능
-  **AI 대화형 일기 작성**: AI와 대화하며 자연스럽게 일기 작성
-  **자유형 일기 작성**: 텍스트, 사진, 그림, 음성으로 자유롭게 표현
-  **AI 감정 분석**: 작성된 일기를 바탕으로 한 감정 패턴 분석
-  **감정 통계 및 트렌드**: 개인 감정 변화를 시각적으로 확인
-  **치유 음악 추천**: 감정에 맞는 음악과 플레이리스트 제공
-  **개인화된 프로필**: 감정 선호도와 패턴 기반 맞춤 서비스

## 🏗️ 기술 스택

- **프레임워크**: Flutter 3.x
- **언어**: Dart
- **상태 관리**: Provider
- **라우팅**: GoRouter
- **백엔드**: Firebase (Auth, Firestore, Storage)
- **AI 서비스**: OpenAI API
- **UI/UX**: Material Design 3

## 📱 앱 구조

```
SplashScreen → Onboarding → Auth → MainApp
                                    ↓
                              HomePage (메인)
                                    ↓
                ┌─────────┬─────────┬─────────┬─────────┬─────────┐
                ↓         ↓         ↓         ↓         ↓
            DiaryPage  AIPage  AnalyticsPage  MusicPage  ProfilePage
```

##  시작하기

### 필수 요구사항
- Flutter SDK 3.0.0 이상
- Dart SDK 3.0.0 이상
- Android Studio / VS Code
- iOS 개발을 위한 Xcode (macOS)

### 설치 및 실행
```bash
# 저장소 클론
git clone https://github.com/your-username/emoti-flow.git
cd emoti-flow

# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

### 환경 설정
1. **환경 변수 설정**:
   ```bash
   # lib/config/env_config.template.dart 파일을 복사하여 env_config.dart로 이름 변경
   cp lib/config/env_config.template.dart lib/config/env_config.dart
   
   # env_config.dart 파일에서 실제 API 키와 설정값들을 입력
   ```

2. **필요한 API 키들**:
   - Firebase Project ID
   - Firebase API Keys (Android/iOS)
   - Google OAuth Client IDs
   - OpenAI API Key (향후 추가 예정)

3. **플랫폼별 설정**:
   - Android: `android/app/google-services.json` (Firebase Console에서 다운로드)
   - iOS: `ios/Runner/GoogleService-Info.plist` (Firebase Console에서 다운로드)

4. **보안 주의사항**:
   - `lib/config/env_config.dart` 파일은 Git에 커밋되지 않습니다
   - API 키가 포함된 파일들은 `.gitignore`에 등록되어 있습니다
   - 프로덕션 환경에서는 별도의 환경 변수 관리 시스템을 사용하세요

## 📚 문서

프로젝트에 대한 자세한 정보는 다음 문서들을 참고하세요:

-  **[요구사항 정의서](docs/core_documents/emoti_flow_requirements.md)**: 프로젝트 목표 및 기능 요구사항
-  **[기능 명세서](docs/core_documents/emoti_flow_functional_spec.md)**: 상세 기능 및 비즈니스 로직
-  **[정보 아키텍처](docs/core_documents/emoti_flow_ia.md)**: 앱 구조 및 데이터 흐름
-  **[UI/UX 가이드](docs/core_documents/emoti_flow_uiux_guide.md)**: 디자인 시스템 및 사용자 경험
-  **[페이지 정의서](docs/core_documents/emoti_flow_page_definition.md)**: 각 페이지별 상세 구조 (개발자용)
-  **[페이지 정의서 (노코드)](docs/core_documents/emoti_flow_page_definition_nocode.md)**: 페이지 구조 요약 (기획자/디자이너용)
-  **[프로젝트 계획](docs/derived_documents/emoti_flow_project_plan.md)**: 개발 일정 및 마일스톤
-  **[프로젝트 TODO](docs/derived_documents/emoti_flow_project_todo.md)**: 현재 작업 및 다음 단계


## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참고하세요.

##  연락처

프로젝트에 대한 문의사항이나 제안사항이 있으시면 이슈를 생성해 주세요.

---

**EmotiFlow** - 감정을 기록하고, AI와 함께 성장하세요 