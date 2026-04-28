# Google AdMob 연동 계획

> 작성일: 2026-04-29  
> 상태: 구현 완료 (테스트 ID 기준)

---

## 1. 광고 단위 구성

| 유형 | 위치 | 트리거 | 빈도 |
|------|------|--------|------|
| **배너** | AI 페이지 하단 | 페이지 진입 시 자동 | 항상 표시 |
| **배너** | 음성 AI 대화 페이지 하단 | 페이지 진입 시 자동 | 항상 표시 |
| **네이티브(Small)** | 일기 목록 중간 | 5번째 아이템마다 | 5개마다 1회 |
| **전면(Interstitial)** | 일기 저장 직후 | 5회 저장마다 1회 | 5회에 1회 |
| **보상형(Rewarded)** | 사용량 소진 시 버튼 | 사용자 자발적 탭 | 무제한 (사용자 선택) |

---

## 2. 보상형 광고 보상 내용

| 광고 시청 | 보상 | 유효 범위 |
|-----------|------|-----------|
| 1회 시청 | Soniox 음성 AI +3회 | 당일(테스트)/당월(무료) |
| 1회 시청 | Gemini AI 분석 +5회 | 당일 |

보상량은 `.env`로 조절 가능:
```
USAGE_REWARD_SONIOX=3
USAGE_REWARD_GEMINI=5
```

---

## 3. 사용량 티어 설계

| 티어 | Soniox STT | Gemini API | 전면 광고 |
|------|-----------|-----------|-----------|
| **test** (ENVIRONMENT=development) | 3회/일 | 10회/일 | 없음 |
| **free** | 10회/월 | 20회/일 | 5회마다 1회 |
| **premium** | 무제한 | 무제한 | 없음 |

---

## 4. 실제 광고 단위 ID (Android 발급 완료)

| 유형 | 광고 단위 ID |
|------|-------------|
| 앱 ID | `ca-app-pub-8918591811866398~1324086928` |
| 배너 | `ca-app-pub-8918591811866398/5201195716` |
| 보상형 | `ca-app-pub-8918591811866398/1872639429` |
| 네이티브 | `ca-app-pub-8918591811866398/1245864174` |

> iOS는 별도 앱 등록 후 `ADMOB_*_IOS` 키 교체 필요.

---

## 5. 광고 ID 교체 절차

1. Google AdMob 콘솔(https://apps.admob.com)에서 앱 등록
2. 앱 ID 발급 → `AndroidManifest.xml` `GADApplicationIdentifier` 교체
3. iOS App ID → `Info.plist` `GADApplicationIdentifier` 교체
4. 광고 단위 ID `.env` 교체:
   ```
   ADMOB_BANNER_ANDROID=ca-app-pub-XXXXXXXXXX/XXXXXXXXXX
   ADMOB_BANNER_IOS=ca-app-pub-XXXXXXXXXX/XXXXXXXXXX
   ADMOB_REWARDED_ANDROID=ca-app-pub-XXXXXXXXXX/XXXXXXXXXX
   ADMOB_REWARDED_IOS=ca-app-pub-XXXXXXXXXX/XXXXXXXXXX
   ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-XXXXXXXXXX/XXXXXXXXXX
   ADMOB_INTERSTITIAL_IOS=ca-app-pub-XXXXXXXXXX/XXXXXXXXXX
   ```

> **주의**: 개발/테스트 중 테스트 광고 ID를 실제 ID로 교체하면 계정 정지 위험.
> 반드시 빌드 직전에만 교체할 것.

---

## 5. 핵심 파일

| 파일 | 역할 |
|------|------|
| `lib/core/services/ad_service.dart` | AdMob 초기화, 배너/전면/보상형/네이티브 광고 관리 |
| `lib/core/services/usage_limit_service.dart` | 티어별 사용량 제한 및 보너스 추적 |
| `lib/shared/widgets/ads/banner_ad_widget.dart` | 배너 광고 위젯 |
| `lib/shared/widgets/ads/reward_ad_button.dart` | 보상형 광고 버튼 위젯 |
| `lib/shared/widgets/ads/native_ad_widget.dart` | 네이티브 광고 위젯 (Small 템플릿) |

---

## 6. 향후 계획

- [ ] 프리미엄 구독 구현 (in-app purchase) → `UserTier.premium` 전환
- [ ] Firestore 기반 사용량 동기화 (멀티 기기 지원)
- [ ] 광고 수익 분석 (Firebase Analytics 연동)
