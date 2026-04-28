# EmotiFlow - Agent Harness

> AI 에이전트가 이 프로젝트에서 작업하기 전에 반드시 읽어야 하는 문서입니다.
> Cursor, Claude, Codex, Gemini CLI 등 모든 에이전트에 적용됩니다.

---

## 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 앱명 | EmotiFlow (AI 기반 감정 일기) — 이름 변경 예정 |
| 스택 | Flutter 3.16+ / Firebase / Google Gemini API |
| 아키텍처 | Clean Architecture + MVVM + Riverpod |
| 플랫폼 | Android / iOS (Flutter Web 예정) |

---

## 작업 시작 전 필수 순서

```
1. docs/plan/PLAN.md 읽기        → 현재 기획 상태, 우선순위 확인
2. .cursor/rules/03-known-mistakes.mdc → 반복 실수 방지
3. 관련 기존 코드 검색            → 중복 방지
4. 설계 제안 → 승인 후 코딩      → 계층 결정 명시
5. 코드 완성 후 → 관련 문서 자동 업데이트 (아래 규칙 참조)
```

---

## 명령 → 자동 문서 업데이트 규칙

| 명령 유형 | 자동 업데이트 문서 |
|----------|------------------|
| 새 기능 구현 완료 | `docs/plan/PLAN.md` 완료 체크, `docs/dev/EMOTI_FLOW_DEVELOPMENT_PLAN.md` 체크리스트 |
| 버그 수정 | `docs/troubleshooting.md` 추가, `docs/plan/PLAN.md` 이슈 목록 제거 |
| 새 버그 패턴 발견 | `.cursor/rules/03-known-mistakes.mdc` M-번호 추가 |
| 기획 변경 | `docs/plan/PLAN.md` 먼저 수정 후 작업 |
| Gemini 프롬프트 변경 | `docs/dev/gemini_prompts_guide.md` 히스토리 기록 |
| 세션 종료 시 | `docs/logs/YYYY-MM-DD.md` 작업 내용 기록 |

---

## 코드 구조 요약

```
lib/
├── core/ai/gemini/gemini_service.dart   ← 모든 Gemini 프롬프트 여기에만
├── features/<기능>/
│   ├── domain/    ← Entity, Repository 인터페이스, UseCase
│   ├── data/      ← Model(DTO), Repository 구현체, DataSource(Firebase)
│   └── presentation/ ← ViewModel(Riverpod Notifier), View, Widget
└── shared/        ← 공통 위젯/서비스/상수
```

**계층 규칙**: `View → ViewModel → UseCase → Repository → DataSource`  
❌ UI에서 Firebase 직접 접근 금지

---

## 핵심 제약

- View 파일 **300줄 이하** (초과 시 위젯 분리)
- `const` 생성자 최대 활용
- 새 에셋 추가 → `pubspec.yaml` 업데이트 필수
- GoRouter 경로는 상수(`AppRoutes`)로만 참조
- 모든 Gemini 프롬프트는 `gemini_service.dart`에만 작성

---

## 반복 금지 실수 (요약)

| 코드 | 실수 |
|------|------|
| M-001 | 구글 로그인 무조건 signOut() |
| M-002 | UI 오버플로우 고정 높이 |
| M-003 | AI 채팅 일기 라우팅 타입 미분기 |
| M-004 | Firebase 이중 초기화 |
| M-005 | 에셋 pubspec.yaml 미등록 |
| M-006 | SHA-1 미등록 (ApiException: 10) |
| M-007 | 파일 300줄 초과 비대화 |
| M-008 | Provider → Firebase 직접 접근 |
| M-009 | lint 에러 무시 |

상세 내용: `.cursor/rules/03-known-mistakes.mdc`

---

## 문서 맵

```
docs/
├── plan/                           # 기획 & 로드맵
│   ├── PLAN.md                     ← 현재 상태/우선순위 (항상 최신) ★
│   └── ROADMAP.md                  ← 중장기 방향
├── design/                         # UI/UX 디자인
│   ├── emoti_flow_uiux_guide.md    ← 색상/컴포넌트 상세
│   ├── EMOTI_FLOW_UI_UX_PLAN.md   ← UI/UX 방향성 요약
│   ├── diary_list_detail_ui.md     ← 일기 목록/상세 UI
│   └── HOME_SCREEN_REDESIGN.md    ← 홈화면 설계 의도
├── specs/                          # 요구사항/명세
│   ├── emoti_flow_requirements.md  ← 전체 기능 요구사항 (28 REQ)
│   ├── emoti_flow_functional_spec.md
│   ├── emoti_flow_ia.md
│   └── emoti_flow_page_definition*.md
├── dev/                            # 개발/기술 문서
│   ├── EMOTI_FLOW_DEVELOPMENT_PLAN.md  ← 개발 계획 + 체크리스트
│   ├── implementation_updates.md   ← 구현 현황 상세
│   ├── gemini_prompts_guide.md     ← 프롬프트 히스토리
│   └── emoti_flow_tech_summary.md  ← 기술 스택 요약
├── logs/                           ← 일일 개발 로그
│   └── YYYY-MM-DD.md
└── troubleshooting.md              ← 버그 해결 모음
```
