# Git 워크플로우 가이드

## 📌 브랜치 전략

### 브랜치 구조
```
main (production)
  ↑
develop (default) ← 여기서 작업 시작
  ↑
feature/기능명
```

- **main**: 배포 가능한 안정 버전 (프로덕션)
- **develop**: 개발 중인 기능들이 통합되는 브랜치 (기본 브랜치)
- **feature/**: 새 기능 개발 브랜치
- **fix/**: 버그 수정 브랜치

---

## 🔧 초기 설정 (1회만 실행)

### 1. GitHub에서 Default 브랜치 변경

GitHub 웹사이트에서:
1. 저장소 페이지로 이동
2. **Settings** 탭 클릭
3. 왼쪽 메뉴에서 **Branches** 클릭
4. **Default branch** 섹션에서 **Switch to another branch** 버튼 클릭
5. `develop` 선택 후 **Update** 클릭
6. 경고 메시지 확인 후 **I understand, update the default branch** 클릭

또는 GitHub CLI 사용:
```bash
gh repo edit --default-branch develop
```

### 2. 로컬에서 develop 브랜치 설정
```bash
# develop 브랜치로 전환
git checkout develop

# 최신 상태로 업데이트
git pull origin develop
```

---

## 🚀 새 기능 개발 워크플로우

### 1단계: 새 기능 브랜치 생성
```bash
# develop 브랜치에서 시작
git checkout develop
git pull origin develop

# 새 기능 브랜치 생성 및 전환
git checkout -b feat/기능명

# 예시:
git checkout -b feat/emotion-character-ui
git checkout -b feat/diary-statistics
git checkout -b feat/dark-mode-enhancement
```

### 2단계: 작업 및 커밋
```bash
# 파일 수정 후

# 변경사항 확인
git status

# 스테이징
git add .
# 또는 특정 파일만
git add lib/features/diary/views/emotion_character_widget.dart

# 커밋 (커밋 메시지 규칙 준수)
git commit -m "feat: 감정 캐릭터 UI 컴포넌트 추가"

# 예시:
git commit -m "feat: 감정별 캐릭터 매핑 시스템 구현"
git commit -m "fix: AI 채팅 일기 라우팅 버그 수정"
git commit -m "docs: Gemini 프롬프트 가이드 업데이트"
```

### 3단계: GitHub에 푸시
```bash
# 처음 푸시할 때
git push -u origin feat/기능명

# 이후 푸시
git push
```

### 4단계: Pull Request 생성

#### 방법 1: GitHub 웹사이트
1. GitHub 저장소 페이지로 이동
2. **Pull requests** 탭 클릭
3. **New pull request** 버튼 클릭
4. **base**: `develop` 선택
5. **compare**: `feat/기능명` 선택
6. **Create pull request** 클릭
7. 제목과 설명 작성 후 **Create pull request** 클릭

#### 방법 2: GitHub CLI (추천)
```bash
# 현재 브랜치에서 develop으로 PR 생성
gh pr create --base develop --title "feat: 감정 캐릭터 UI 적용" --body "감정별 캐릭터 이미지를 UI에 통합했습니다."

# 또는 대화형으로
gh pr create
```

### 5단계: 코드 리뷰 및 머지
```bash
# PR이 승인되면 GitHub에서 Merge 버튼 클릭

# 또는 CLI로
gh pr merge 번호 --squash

# 로컬에서 develop 업데이트
git checkout develop
git pull origin develop

# 완료된 feature 브랜치 삭제
git branch -d feat/기능명
git push origin --delete feat/기능명
```

---

## 📝 커밋 메시지 규칙

### 형식
```
<type>: <subject>

<body> (선택)

<footer> (선택)
```

### Type 종류
- **feat**: 새 기능 추가
- **fix**: 버그 수정
- **docs**: 문서 수정
- **refactor**: 리팩토링 (기능 변경 없음)
- **style**: 코드 스타일 변경 (포맷팅, 세미콜론 등)
- **test**: 테스트 추가/수정
- **chore**: 빌드/설정 변경
- **perf**: 성능 개선

### 예시
```bash
feat: 감정 캐릭터 UI 적용
fix: AI 채팅 일기 라우팅 버그 수정
docs: Git 워크플로우 가이드 추가
refactor: DiaryProvider를 ViewModel로 전환
style: 코드 포맷팅 적용
test: DiaryUseCase 단위 테스트 추가
chore: pubspec.yaml 의존성 업데이트
perf: 이미지 로딩 성능 개선
```

### Subject 작성 규칙
- 50자 이내로 작성
- 명령문으로 작성 ("추가했다" ❌ → "추가" ✅)
- 마침표 없음
- 한글 또는 영어 사용 (일관성 유지)

---

## 🔄 일반적인 시나리오

### 시나리오 1: 캐릭터 UI 적용 작업
```bash
# 1. develop에서 시작
git checkout develop
git pull origin develop

# 2. feature 브랜치 생성
git checkout -b feat/emotion-character-ui

# 3. 작업 진행
# - EmotionCharacterMap 클래스 생성
# - UI 컴포넌트 수정
# - 테스트

# 4. 커밋
git add lib/shared/constants/emotion_character_map.dart
git commit -m "feat: 감정-캐릭터 매핑 시스템 추가"

git add lib/features/diary/views/diary_chat_write_page/
git commit -m "feat: AI 채팅 화면에 캐릭터 이미지 표시"

# 5. 푸시
git push -u origin feat/emotion-character-ui

# 6. PR 생성
gh pr create --base develop --title "feat: 감정 캐릭터 UI 적용" --body "- 감정별 캐릭터 매핑 시스템 구현
- AI 채팅 화면에 캐릭터 이미지 표시
- 일기 상세 화면에 캐릭터 추가"

# 7. 머지 후 정리
git checkout develop
git pull origin develop
git branch -d feat/emotion-character-ui
```

### 시나리오 2: 긴급 버그 수정
```bash
# 1. develop에서 시작
git checkout develop
git pull origin develop

# 2. fix 브랜치 생성
git checkout -b fix/ai-chat-routing

# 3. 버그 수정 후 커밋
git add lib/core/router/app_router.dart
git commit -m "fix: AI 채팅 일기가 상세 페이지로 이동하는 버그 수정"

# 4. 푸시 및 PR
git push -u origin fix/ai-chat-routing
gh pr create --base develop

# 5. 긴급하다면 바로 머지
gh pr merge --squash
```

### 시나리오 3: 여러 커밋을 하나로 정리
```bash
# 작업 중 여러 번 커밋했을 때
git log --oneline -5

# 최근 3개 커밋을 하나로 합치기
git rebase -i HEAD~3

# 에디터에서:
# pick abc123 첫 번째 커밋
# squash def456 두 번째 커밋
# squash ghi789 세 번째 커밋

# 저장 후 커밋 메시지 수정
# 강제 푸시 (주의: PR 생성 전에만!)
git push --force-with-lease
```

---

## 🛡️ 보호 규칙 (선택사항)

### GitHub Branch Protection 설정
1. GitHub Settings → Branches
2. **Add rule** 클릭
3. Branch name pattern: `develop`
4. 활성화 권장 옵션:
   - ✅ Require pull request before merging
   - ✅ Require approvals (개인 프로젝트는 0명으로 설정 가능)
   - ✅ Require status checks to pass (CI/CD 구축 후)
   - ✅ Require conversation resolution before merging

---

## 🚨 주의사항

### ❌ 하지 말아야 할 것
1. **develop/main에 직접 커밋하지 않기**
   ```bash
   # 잘못된 예
   git checkout develop
   # 파일 수정
   git commit -m "급하게 수정"  # ❌
   ```

2. **force push 남용하지 않기**
   ```bash
   git push --force  # ❌ 위험!
   git push --force-with-lease  # ✅ 더 안전
   ```

3. **커밋 메시지 대충 쓰지 않기**
   ```bash
   git commit -m "수정"  # ❌
   git commit -m "fix: AI 채팅 라우팅 버그 수정"  # ✅
   ```

4. **거대한 커밋 만들지 않기**
   - 한 커밋에는 하나의 논리적 변경사항만
   - 여러 기능을 한 번에 커밋하지 말 것

### ✅ 좋은 습관
1. **자주 커밋하기** (논리적 단위로)
2. **자주 푸시하기** (백업 차원)
3. **develop을 자주 pull 받기** (충돌 최소화)
4. **PR 설명을 상세히 작성하기**
5. **브랜치 이름을 명확히 짓기**

---

## 📚 유용한 Git 명령어

### 현재 상태 확인
```bash
git status                    # 현재 상태
git branch                    # 로컬 브랜치 목록
git branch -a                 # 모든 브랜치 (원격 포함)
git log --oneline -10         # 최근 10개 커밋
git diff                      # 변경사항 확인
```

### 브랜치 관리
```bash
git branch feat/new-feature   # 브랜치 생성 (전환 안함)
git checkout -b feat/new      # 생성 + 전환
git branch -d feat/old        # 로컬 브랜치 삭제
git push origin --delete feat/old  # 원격 브랜치 삭제
```

### 변경사항 되돌리기
```bash
git checkout -- 파일명        # 작업 디렉토리 변경사항 취소
git reset HEAD 파일명         # 스테이징 취소
git reset --soft HEAD~1      # 마지막 커밋 취소 (변경사항 유지)
git reset --hard HEAD~1      # 마지막 커밋 취소 (변경사항 삭제)
```

### 원격 저장소 관리
```bash
git remote -v                # 원격 저장소 확인
git fetch origin             # 원격 변경사항 가져오기 (머지 안함)
git pull origin develop      # 가져오기 + 머지
git push origin develop      # 푸시
```

---

## 🎯 빠른 참조

### 새 기능 개발 (한 줄 요약)
```bash
git checkout develop && git pull && git checkout -b feat/기능명 && # 작업 # && git add . && git commit -m "feat: 설명" && git push -u origin feat/기능명 && gh pr create
```

### 버그 수정 (한 줄 요약)
```bash
git checkout develop && git pull && git checkout -b fix/버그명 && # 작업 # && git add . && git commit -m "fix: 설명" && git push -u origin fix/버그명 && gh pr create
```

---

## 📞 문제 해결

### Q: 브랜치를 잘못 만들었어요
```bash
# develop으로 돌아가기
git checkout develop

# 잘못된 브랜치 삭제
git branch -D 잘못된브랜치명
```

### Q: 커밋 메시지를 잘못 썼어요
```bash
# 마지막 커밋 메시지 수정 (푸시 전)
git commit --amend -m "올바른 메시지"

# 푸시 했다면
git commit --amend -m "올바른 메시지"
git push --force-with-lease
```

### Q: 잘못된 브랜치에 커밋했어요
```bash
# 1. 올바른 브랜치 생성
git checkout -b 올바른브랜치

# 2. 원래 브랜치로 돌아가서 커밋 취소
git checkout 잘못된브랜치
git reset --hard HEAD~1
```

### Q: Conflict가 발생했어요
```bash
# 1. develop의 최신 변경사항 가져오기
git checkout develop
git pull origin develop

# 2. feature 브랜치로 돌아가기
git checkout feat/기능명

# 3. develop 내용 병합
git merge develop

# 4. 충돌 해결 후
git add .
git commit -m "merge: develop 병합"
git push
```

---

## 📅 일일 개발 로그 작성

매일 작업 완료 후 간단히 기록합니다.

### 로그 작성 방법
```bash
# 파일명: docs/daily_logs/YYYY-MM-DD.md
# 예: docs/daily_logs/2026-01-21.md
```

### 템플릿
```markdown
# 개발 일지 - YYYY-MM-DD

## ✅ 완료된 기능
- 기능명: 간단한 설명

**수정/추가 파일:**
- 파일 경로

**커밋 메시지 (복사용):**
```
커밋 메시지 내용
```

**테스트 사항:**
- [ ] 테스트 항목

## 📝 다음 작업 예정
1. 작업 1
2. 작업 2
```

### 작성 시점
- 커밋 전에 작성하여 커밋 메시지 참고
- PR 생성 시 본문에 복사 활용

---

## 🔗 관련 문서
- [개발 계획](./EMOTI_FLOW_DEVELOPMENT_PLAN.md)
- [Gemini 프롬프트 가이드](./gemini_prompts_guide.md)
- [트러블슈팅 가이드](./troubleshooting.md)
- [일일 개발 로그](./daily_logs/) ← 매일 작업 기록

