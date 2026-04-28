---
name: dev-loop
description: 자동 개발 루프. PLAN.md의 다음 미완료 작업을 순서대로 구현→테스트→버그수정→완료마킹→다음작업으로 자동 진행. 토큰 최소화 설계, 무료/유료 모든 모델 호환. "자동 개발", "dev loop", "다음 기능 구현", "자동으로 진행" 등의 명령 시 사용.
---

# Dev Loop - 자동 개발 루프

## 한 사이클 = P0/P1 작업 하나 완성 → 다음으로 이동

---

## Step 0: 브랜치 준비 (항상 먼저)

```bash
git branch --show-current   # 현재 브랜치 확인

# 작업 유형별 브랜치 규칙
feat  → feature/<기능명-영문-소문자-하이픈>  예) feature/kakao-login
fix   → fix/<버그명>                        예) fix/ai-chat-routing
refactor → refactor/<대상>                  예) refactor/clean-architecture
docs  → docs/<명>                           예) docs/plan-update

# main 또는 develop이면 → 즉시 브랜치 생성
git checkout -b feature/<기능명>

# 이미 해당 브랜치 있으면 → switch만
git switch feature/<기능명>
```

**main에 직접 커밋 금지. 감지 시 즉시 알리고 브랜치 생성.**

---

## Step 1: 컨텍스트 로드 (토큰 최소)

```
읽기: docs/plan/PLAN.md (전체)
→ "우선순위별 다음 작업" 섹션에서
  P0 미체크 항목 → 없으면 P1 첫 항목 선택
→ 선택한 작업 1줄로 요약 출력
```

**대형 문서는 절대 통째로 읽지 않는다. 관련 파일만.**

---

## Step 2: 관련 코드 파악 (필요한 것만)

```
1. 작업과 직접 연관된 파일만 Glob/Grep으로 찾기
2. 찾은 파일의 관련 섹션만 읽기 (전체 읽기 금지)
3. 이미 읽은 파일 재읽기 금지
4. 시작 전 3줄 설계 요약 제시:
   - "구현 대상: ..."
   - "수정 파일: ..."  
   - "아키텍처 계층: domain/data/presentation 중 ..."
```

---

## Step 3: 구현

규칙 체크리스트 (코드 작성 전 확인):
- [ ] Clean Architecture 계층 경계 준수 (UI → VM → UseCase → Repo)
- [ ] 300줄 초과 예상 시 위젯 분리 먼저 계획
- [ ] M-001~M-009 실수 패턴 해당 없는지 확인
- [ ] const 생성자 사용 가능 여부 확인

UI 작업인 경우:
1. 접근 방식 A/B 2줄로 제시
2. 더 자연스러운 쪽 기본 선택 (사용자 응답 없으면 자동 진행)
3. "UI 다시" 명령 시 → B 방식으로 교체

---

## Step 4: 검증

```
1. ReadLints 실행 → 에러 전부 수정 (무시 금지)
2. 테스트 파일 존재 시 → flutter test 실행
3. 에러 발생 시:
   a. M-코드 패턴과 매칭 시도
   b. 새 패턴이면 수정 후 03-known-mistakes.mdc에 M-번호 추가
   c. 수정 후 Step 4 재실행
```

---

## Step 5: 커밋 + 문서 업데이트 (자동)

```
완료 시 반드시:
1. docs/plan/PLAN.md → 해당 항목 [ ] → [x] 체크
2. docs/logs/YYYY-MM-DD.md → 작업 요약 1~3줄 추가 (없으면 생성)
3. git add . → git commit (컨벤션 형식으로 자동 커밋)
   커밋: <type>(<scope>): <한글 제목>
   ※ git push는 절대 하지 않음 — 사용자가 직접 실행

버그 수정 시 추가:
4. docs/troubleshooting.md → 증상/원인/해결 추가
5. 새 실수 패턴 → .cursor/rules/03-known-mistakes.mdc M-번호 추가
```

---

## Step 6: 루프 판단

```
if (PLAN.md에 P0/P1 미완료 항목 남음):
  → "다음 작업: [항목명] 진행할까요?" 물어보지 말고 자동 진행
  → Step 1로 돌아가기

else:
  → "P0/P1 모든 작업 완료. P2 작업으로 넘어갈까요?" 확인 후 진행
```

---

## 토큰 절약 규칙

| 상황 | 방법 |
|------|------|
| 대형 문서 파악 | 처음 30줄 → 키워드 Grep |
| 기존 코드 확인 | Glob으로 파일 찾기 → 해당 함수만 Read |
| 에러 해결 | M-코드 먼저 → 없으면 최소 검색 |
| 설계 확인 | 00-project-core.mdc 상단만 (alwaysApply로 이미 로드됨) |

---

## 중단 조건 (루프 멈추고 사용자에게 확인)

- 기획이 불명확한 작업 (PLAN.md에 설명 부족)
- P0 버그가 3회 수정 후에도 재발
- 파일 구조를 크게 바꿔야 하는 리팩토링
- 외부 API 키/인증 정보 필요
- UI 방향성 결정이 필요한 경우 (A/B 모두 불확실)
