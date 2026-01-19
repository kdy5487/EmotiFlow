## 구글 로그인 트러블슈팅 (ApiException: 10)

이 문서는 `PlatformException(sign_in_failed, ApiException: 10)` 오류를 해결하기 위한
실전 체크리스트입니다.

### 1) 실제 디버그 SHA-1 확인 (가장 중요)
가장 흔한 원인은 **현재 PC의 디버그 키와 Firebase에 등록된 SHA-1 불일치**입니다.

아래 명령으로 **실제 사용 중인 디버그 SHA-1**을 확인합니다.

```
cd android
.\gradlew signingReport
```

출력 중 `Variant: debug` 아래의 `SHA1` 값이 **실제 사용하는 지문**입니다.

예시:
```
SHA1: C1:9E:23:76:3A:06:0A:34:8E:97:79:D0:88:B3:C3:FE:D4:98:35:8E
```

이 값을 Firebase 콘솔의 **프로젝트 설정 > 내 앱 > SHA 인증서 지문**에 추가합니다.
가능하면 **SHA-256도 함께 추가**합니다.

### 2) google-services.json 재다운로드
SHA를 추가한 뒤에는 반드시 **google-services.json을 재다운로드**하여
프로젝트의 `android/app/google-services.json`에 덮어씌웁니다.

### 3) 클린 빌드 및 앱 삭제
설정 변경 후에는 캐시 때문에 이전 값이 남을 수 있습니다.

1. 에뮬레이터(또는 디바이스)에서 앱 삭제
2. `flutter clean`
3. `flutter run`

### 4) 프로젝트 불일치 점검
`google-services.json`의 `project_number` / `project_id`와
`lib/firebase_options.dart`가 **같은 프로젝트를 가리키는지** 확인합니다.

서로 다르면 인증이 실패합니다.

### 5) OAuth 동의 화면 및 테스트 사용자 확인
Google Cloud Console에서 다음 항목을 확인합니다.

- **OAuth 동의 화면 상태**가 `테스트`라면, **테스트 사용자에 로그인 이메일 추가**
- **프로젝트 지원 이메일**이 설정되어 있는지 확인

### 6) `.env` 초기화 오류 (NotInitializedError)
앱에서 `.env`를 사용하는 경우, `main()`에서 반드시 로드해야 합니다.

```
await dotenv.load(fileName: ".env");
```

로드 전에 `.env`를 참조하면 `NotInitializedError`가 발생합니다.

### 7) [core/duplicate-app] 오류
Firebase가 이미 초기화된 상태에서 다시 초기화하면 발생합니다.

```
if (Firebase.apps.isEmpty) {
  await Firebase.initializeApp(...);
}
```

### 8) AppCheck 경고
`No AppCheckProvider installed` 경고는 **로그인 실패 원인이 아닙니다.**
필요 시 AppCheck를 나중에 설정해도 됩니다.

### 9) Gemini Fallback(대화가 항상 같음) 탈출 방법
AI 대화가 항상 같은 질문만 반복된다면 **Gemini API가 실제로 호출되지 않고 Fallback만 쓰는 상태**일 수 있습니다.

확인/해결 순서:
1. `.env`에 `GEMINI_API_KEY`가 있는지 확인
2. `main()`에서 `.env` 로드가 **Firebase 초기화보다 먼저** 호출되는지 확인
3. 앱 재시작 후 로그에 `Gemini API 호출 시작...` 메시지가 뜨는지 확인

이 순서가 정상이라면 Fallback이 아닌 실제 Gemini 응답이 사용됩니다.

---

### 요약
1. `.\gradlew signingReport`로 **현재 PC의 SHA-1** 확인
2. Firebase 콘솔에 **SHA-1/256 등록**
3. `google-services.json` **재다운로드**
4. 앱 삭제 → `flutter clean` → `flutter run`

이 순서대로 진행하면 `ApiException: 10` 문제는 대부분 해결됩니다.

