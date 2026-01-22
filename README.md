![KakaoTalk_20260123_060902823](https://github.com/user-attachments/assets/b1ad353a-78d4-4a8b-a0af-bbdae7f788bc)# EmotiFlow 🌱

> AI와 함께 감정을 기록하고 성장하는 일기 앱

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.3-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Storage-FFCA28?logo=firebase)](https://firebase.google.com)
[![Gemini](https://img.shields.io/badge/Google%20Gemini-2.5%20Flash-4285F4?logo=google)](https://gemini.google.com)

## 📱 프로젝트 소개

EmotiFlow는 사용자의 일상적인 감정을 AI와 함께 분석하고, 개인화된 인사이트를 제공하는 Flutter 기반 모바일 애플리케이션입니다.

**"일기를 쓰기 어려운 순간에도 감정 기록을 시작할 수 있게 하자"**는 문제의식에서 출발하여, AI가 먼저 질문을 던지는 대화형 흐름을 통해 기록 진입 장벽을 낮추고, 작성된 일기를 기반으로 감정 분석 · 위로 메시지까지 하나의 흐름으로 제공합니다.


## ✨ 주요 기능

### 1. AI 대화형 일기 작성 💬
AI가 질문을 던지고 사용자가 응답하며 자연스럽게 일기를 완성하는 대화형 UX
- Google Gemini 2.5 Flash API 연동
- 감정 기반 맞춤형 질문 생성
- 실시간 대화형 인터페이스
- 일기 자동 요약 및 저장
![KakaoTalk_20260123_060902823_06](https://github.com/user-attachments/assets/0c7af225-8a93-4c2b-a5c0-a1e34dae900c)
![KakaoTalk_20260123_060902823_05](https://github.com/user-attachments/assets/5e5361bd-bd82-41ea-8b85-7d7beea465ba)
![KakaoTalk_20260123_060902823_04](https://github.com/user-attachments/assets/6f74b13f-59fe-4f28-b7a0-d0e22f122335)

### 2. 자유형 일기 작성 ✍️
텍스트·이미지를 자유롭게 기록하는 기본 일기 작성 기능
- 텍스트, 이미지, 그림 자유롭게 조합
- 감정 선택 및 강도 설정 (10가지 감정)
- 그림 그리기 캔버스 (스티커, 도형 도구 포함)

### 3. 일기 목록 관리 📋
Firestore 실시간 동기화 기반 검색 / 필터 / 정렬
- 리스트/그리드 뷰 전환
- 실시간 검색 기능
- 고급 필터링 및 정렬
- 일괄 삭제 모드
![KakaoTalk_20260123_060902823_01](https://github.com/user-attachments/assets/28bab6e5-2635-4167-aeb7-c9b077618410)

### 4. AI 감정 분석 및 조언 🤖
작성된 일기를 분석해 감정 요약과 조언 제공
- 일기 내용 기반 감정 분석
- 개인화된 조언 생성
- 감정 트렌드 차트 시각화 (주간/월간)
- 상세 분석 및 조언 다이얼로그
![KakaoTalk_20260123_060902823_03](https://github.com/user-attachments/assets/c61b65d3-5d72-4112-9e3f-48379db26a65)
![KakaoTalk_20260123_060902823_02](https://github.com/user-attachments/assets/f398263d-58e6-4f38-8722-78b07f350223)
![KakaoTalk_20260123_060902823](https://github.com/user-attachments/assets/bfdb2604-e14f-4295-a5df-dd80cdd86c35)


### 5. 홈 대시보드 🏠
감정 성장을 시각화하는 홈 화면
- 씨앗 성장 메타포 (연속 기록에 따라 성장)
- 최근 7일 감정 캘린더
- 최근 작성 일기 미리보기
- 빠른 일기 작성 버튼
![KakaoTalk_20260123_060902823_09](https://github.com/user-attachments/assets/cd0d676a-5c89-4dfc-928f-629c418f3208)
![KakaoTalk_20260123_060902823_08](https://github.com/user-attachments/assets/73f74ed5-622c-4860-a369-71717dfbdfd1)
![KakaoTalk_20260123_060902823_07](https://github.com/user-attachments/assets/4fe2c316-832b-4f8e-939f-77df5febb9fa)
![홈 화면 (라이트 모드)](docs/images/home_light.png)
![홈 화면 (다크 모드)](docs/images/home_dark.png)

### 6. 다크 / 라이트 테마 🌓
Material 3 기반 시스템 테마 연동
- 시스템 설정 자동 연동
- 수동 테마 전환 지원
- 모든 화면 일관된 테마 적용

## 🛠️ 기술 스택

### 프론트엔드
- **Flutter 3.x** + **Dart 3.5.3**
- **Material Design 3** (다크/라이트 테마)

### 상태 관리 & 라우팅
- **Riverpod 2.4.9** (StateNotifier, StreamProvider)
- **GoRouter 13.2.0** (선언적 라우팅, 딥링크)

### 백엔드 & 서비스
- **Firebase Authentication** (Google 로그인)
- **Cloud Firestore** (실시간 데이터 동기화)
- **Firebase Storage** (이미지 저장)
- **Google Gemini 2.5 Flash API** (AI 대화형 일기)

### 아키텍처 패턴
- **Clean Architecture** (일기 기능)
- **MVVM Pattern** (홈, 설정 등 간단한 기능)
- **Feature-based 폴더 구조**

## 🏗️ 아키텍처

### 계층 구조
```
Presentation Layer (UI)
    ↕
Domain Layer (비즈니스 로직)
    ↕
Data Layer (데이터 소스)
```

### 상태 관리 전략
- **Firestore Stream** = 데이터 공급 (실시간 동기화)
- **UI 상태** = 별도 관리 (검색어, 필터, 삭제 모드)
- 두 상태를 섞지 않고 렌더링 단계에서만 조합하여 안정적인 UX 제공

## 📊 주요 성과

- ✅ **성능 최적화**: UI 지연 시간 95% 개선 (2200ms → 50ms)
- ✅ **코드 품질**: 대규모 리팩토링으로 파일 크기 50% 감소 (1005줄 → 500줄)
- ✅ **아키텍처**: Clean Architecture + MVVM 패턴으로 확장성 확보
- ✅ **상태 관리**: Firestore Stream과 UI 상태 분리로 안정적인 UX 구현

## 🚀 시작하기

### 필수 요구사항
- Flutter SDK 3.16.0 이상
- Dart SDK 3.5.3 이상
- Android Studio / VS Code
- Firebase 프로젝트 설정
- Google Gemini API 키

### 설치 및 실행

```bash
# 저장소 클론
git clone https://github.com/kdy5487/EmotiFlow.git
cd EmotiFlow

# 의존성 설치
flutter pub get

# 환경 변수 설정
# .env 파일을 생성하고 GEMINI_API_KEY를 추가하세요
echo "GEMINI_API_KEY=your_api_key_here" > .env

# 앱 실행
flutter run
```

### 환경 설정

1. **Firebase 설정**
   - Firebase Console에서 프로젝트 생성
   - `google-services.json` (Android) 다운로드 후 `android/app/`에 배치
   - SHA-1 인증서 지문 등록

2. **Gemini API 키 설정**
   - Google AI Studio에서 API 키 생성
   - `.env` 파일에 `GEMINI_API_KEY` 추가

## 📁 프로젝트 구조

```
lib/
├── core/                    # 핵심 기능
│   ├── ai/                 # Gemini AI 서비스
│   ├── providers/          # 전역 Provider
│   └── services/           # 인증, Firebase 서비스
│
├── features/                # 기능별 모듈
│   ├── diary/              # 일기 (Clean Architecture)
│   │   ├── domain/         # Entities, UseCases, Repository 인터페이스
│   │   ├── data/           # Models, Repository 구현, DataSource
│   │   └── views/          # Pages, ViewModels, Widgets
│   ├── home/               # 홈 (MVVM)
│   ├── ai/                 # AI 분석
│   ├── profile/           # 프로필
│   └── settings/           # 설정
│
├── shared/                  # 공통 컴포넌트
│   ├── widgets/            # 재사용 위젯
│   └── constants/          # 감정-캐릭터 매핑
│
├── routes/                  # GoRouter 설정
└── theme/                   # Material Design 3 테마
```
![image.png](attachment:e6139663-01d5-49cf-a2b9-4467ce134129:image.png)
## 🎯 핵심 설계 원칙

1. **낮은 진입 장벽**: AI 질문 기반 대화형 일기로 자연스러운 기록 유도
2. **감정 인식과 정리**: 일기 내용을 AI로 분석해 감정 요약 및 인사이트 제공
3. **개인화된 경험**: 감정 상태에 맞는 조언과 맞춤형 AI 응답
4. **안정적인 UX**: 실시간 데이터 환경에서도 화면 흔들림 없는 상태 관리

## 📝 트러블슈팅

주요 트러블슈팅 및 해결 과정은 [트러블슈팅 문서](docs/troubleshooting.md)를 참고하세요.

### 대표 트러블슈팅
- **감정 선택 UI 지연 문제**: 95% 성능 개선 (2200ms → 50ms)
- **Firestore Stream과 UI 상태 분리**: 실시간 동기화 중 안정적인 UX 구현
- **대규모 코드 리팩토링**: 50% 코드 감소 (1005줄 → 500줄)

## 📚 문서

- [포트폴리오 트러블슈팅](docs/PORTFOLIO_TROUBLESHOOTING.md)
- [이력서 작성 가이드](docs/RESUME_CONTENT.md)
- [개발 가이드](docs/EMOTI_FLOW_DEVELOPMENT_PLAN.md)

## 👤 개발자

- **김동연** - 단독 개발 (기획, 설계, 개발, 배포 전 과정)
- GitHub: [@kdy5487](https://github.com/kdy5487)
- Velog: [EmotiFlow 시리즈](https://velog.io/@kdy5487/series/%EC%9D%B8%ED%84%B4%EB%94%94%EB%B9%84%EC%95%88%EC%B8%A0)

## 📄 라이선스

이 프로젝트는 개인 포트폴리오용으로 제작되었습니다.

---

**EmotiFlow** - AI와 함께 감정을 기록하고 성장하는 일기 앱 🌱
