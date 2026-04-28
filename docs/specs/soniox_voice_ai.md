# Soniox 음성 AI 대화 기술 스펙

> 최종 수정: 2026-04-29  
> 담당 파일: `lib/core/services/soniox_service.dart`, `lib/features/ai/views/voice_chat_page/`

---

## 개요

Soniox Real-time STT WebSocket API를 사용해 마이크 음성을 실시간으로 텍스트 변환한 뒤,  
기존 Gemini API로 AI 응답을 생성하는 음성 대화 기능.

---

## 아키텍처

```
[마이크] → AudioRecorder(PCM16bits)
             ↓ 오디오 청크 (binary)
         WebSocket(wss://stt-rt.soniox.com/transcribe-websocket)
             ↓ JSON transcript (tokens)
         SonioxService (Dart)
             ↓ onFinal stream (확정 문장)
         GeminiService.generateEmotionBasedQuestion()
             ↓ AI 응답 텍스트
         VoiceChatPage (UI)
```

---

## 사용 패키지

| 패키지 | 버전 | 용도 |
|--------|------|------|
| `record` | ^6.2.0 | 마이크 오디오 스트리밍 (PCM16bits) |
| `web_socket_channel` | ^3.0.0 | Soniox WebSocket 연결 |
| `permission_handler` | ^11.3.0 | 마이크 권한 요청 |

---

## Soniox API 설정

### 엔드포인트
```
wss://stt-rt.soniox.com/transcribe-websocket
```

### 연결 설정 메시지 (JSON)
```json
{
  "api_key": "<SONIOX_API_KEY>",
  "model": "stt-rt-preview",
  "audio_format": "pcm_s16le",
  "sample_rate": 16000,
  "num_channels": 1,
  "language_hints": ["ko"],
  "enable_endpoint_detection": true,
  "max_endpoint_delay_ms": 1200
}
```

### 오디오 설정
- 인코더: PCM 16-bit signed little endian (`pcm_s16le`)
- 샘플레이트: 16000 Hz
- 채널: 1 (모노)
- Flutter `record` 패키지: `AudioEncoder.pcm16bits`

### 응답 포맷
```json
{
  "tokens": [
    { "text": "안녕", "is_final": true },
    { "text": "하세요", "is_final": false }
  ],
  "is_endpoint": true,
  "is_finished": false
}
```

- `is_final: true` 토큰 = 확정된 텍스트
- `is_endpoint: true` = 발화 끝 감지 → Gemini에 전달
- `is_finished: true` = 서버 처리 완료

---

## API 키 관리

### 개발 (현재)
- `.env` 파일: `SONIOX_API_KEY=...`
- `flutter_dotenv`로 로드
- `.gitignore`에 `.env` 포함 필수

### 프로덕션 (예정)
임시 키 방식으로 전환 필요:
```
POST /tmp-key → { "usage_type": "transcribe_websocket", "expires_in_seconds": 300 }
```
- 클라이언트에 API 키 직접 노출 방지
- 백엔드 서버(Node.js/Cloud Functions)에서 발급
- 보안 규칙: 인증된 사용자만 임시 키 요청 가능

---

## 플랫폼 권한 설정

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>AI와 음성으로 대화하기 위해 마이크 접근이 필요합니다.</string>
```

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

---

## SonioxService 상태 머신

```
idle
 └─ start() ──→ connecting
                 └─ WebSocket 연결 + 오디오 시작 ──→ recording
                                                      └─ stop() ──→ stopping ──→ idle
                                                      └─ 오류 ────→ error ────→ idle
```

---

## 향후 개선 계획

### TTS (Text-to-Speech)
Soniox TTS WebSocket API 연동:
```
wss://tts-rt.soniox.com
```
- AI 응답을 음성으로 재생
- `just_audio` 패키지로 WAV 스트림 재생
- 음성 선택: `voice: "Adrian"` (영어) → 한국어 음성 지원 확인 필요

### 다국어 지원
- `language_hints` 배열에 언어 코드 추가: `["ko", "en", "ja"]`
- `enable_language_identification: true` 옵션으로 자동 언어 감지

### 음성 일기 저장
- 확정된 전체 대화를 `DiaryEntry(diaryType: DiaryType.voice)` 로 저장
- `chatHistory` 필드에 음성 대화 내용 저장
- 새 `DiaryType.voice` 케이스 추가 필요

### 보안
- 임시 키 백엔드 서버 구현 (Firebase Cloud Functions 활용)
- 사용자별 STT 사용량 제한 (Firestore 카운터)

---

## 알려진 제한사항

| 항목 | 내용 |
|------|------|
| 공식 Flutter SDK | 없음 (Web/React Native SDK만 존재) |
| TTS | 미구현 (텍스트만 표시) |
| 배경 소음 | `noiseSuppress: true`로 일부 완화 |
| 오프라인 | 불가 (WebSocket 필요) |
| 최대 스트림 시간 | 300분 / 세션 |
