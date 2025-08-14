# 🗺️ 여행 다이어리 프로젝트 기획서

## 📋 프로젝트 개요
**프로젝트명**: Travel Diary - 여행 다이어리 & 갤러리  
**목표**: 외부 API를 활용한 멀티 페이지 여행 웹 애플리케이션  
**기술 스택**: React + TypeScript + Tailwind CSS  
**난이도**: ⭐⭐⭐ (중급)

---

## 🎯 주요 기능

### 1. 홈페이지 (Landing Page)
- **히어로 섹션**: 배경 비디오/이미지 + 메인 타이틀
- **인기 여행지 카드**: 호버 시 확대 효과
- **카테고리별 여행지**: 해변, 산, 도시, 문화 등
- **최근 여행 기록**: 타임라인 형태
- **검색바**: 애니메이션 효과

### 2. 여행지 탐색 페이지
- **필터 사이드바**: 카테고리, 지역, 계절별 필터
- **갤러리 뷰**: 그리드 레이아웃 + 무한 스크롤
- **지도 뷰**: Google Maps 통합
- **뷰 토글**: 갤러리 ↔ 지도 전환 애니메이션
- **실시간 검색**: 검색 결과 즉시 표시

### 3. 여행 다이어리 페이지
- **여행 기록 카드**: 날짜별 정렬
- **여행 상세 페이지**: 모달 또는 별도 페이지
- **사진 갤러리**: 슬라이더 형태
- **여행 경로**: 지도에 표시
- **여행 통계**: 차트 및 그래프

### 4. 찜한 여행지 페이지
- **북마크 카드**: 호버 시 삭제 버튼
- **카테고리별 정렬**: 드래그 앤 드롭
- **공유 기능**: 소셜 미디어 공유
- **여행 계획**: 날짜별 정렬

### 5. 프로필 페이지
- **사용자 정보**: 아바타, 이름, 소개
- **여행 통계**: 방문한 국가, 총 여행일수
- **여행 히스토리**: 타임라인
- **설정**: 테마, 언어, 알림

---

## 🛠️ 기술 스택

### Frontend
- **React 18** + **TypeScript**
- **Tailwind CSS** (스타일링)
- **React Router** (라우팅)
- **Framer Motion** (애니메이션)
- **Lucide React** (아이콘)
- **Recharts** (차트)

### External APIs
- **Unsplash API**: 여행 사진
- **Google Places API**: 장소 정보
- **Google Maps API**: 지도 기능

### 상태 관리
- **React Context** 또는 **Zustand**

---

## 📱 페이지 구조

```
src/
├── components/
│   ├── layout/
│   │   ├── Navbar.tsx
│   │   ├── Footer.tsx
│   │   └── Layout.tsx
│   ├── home/
│   │   ├── HeroSection.tsx
│   │   ├── PopularDestinations.tsx
│   │   └── CategoryCards.tsx
│   ├── explore/
│   │   ├── FilterSidebar.tsx
│   │   ├── GalleryView.tsx
│   │   ├── MapView.tsx
│   │   └── DestinationCard.tsx
│   ├── diary/
│   │   ├── TravelCard.tsx
│   │   ├── TravelDetail.tsx
│   │   └── PhotoGallery.tsx
│   ├── favorites/
│   │   ├── BookmarkCard.tsx
│   │   └── FavoritesGrid.tsx
│   └── profile/
│       ├── UserInfo.tsx
│       ├── TravelStats.tsx
│       └── TravelTimeline.tsx
├── pages/
│   ├── Home.tsx
│   ├── Explore.tsx
│   ├── Diary.tsx
│   ├── Favorites.tsx
│   └── Profile.tsx
├── hooks/
│   ├── useUnsplash.ts
│   ├── useGoogleMaps.ts
│   └── useLocalStorage.ts
├── types/
│   └── index.ts
└── utils/
    ├── api.ts
    └── helpers.ts
```

---

## 🎨 UI/UX 디자인 가이드

### 색상 팔레트
```css
/* Primary Colors */
--primary: #3B82F6 (파란색)
--secondary: #10B981 (초록색)
--accent: #F59E0B (주황색)

/* Background Colors */
--bg-primary: #FFFFFF
--bg-secondary: #F8FAFC
--bg-dark: #1E293B

/* Text Colors */
--text-primary: #1E293B
--text-secondary: #64748B
--text-light: #94A3B8
```

### 타이포그래피
- **제목**: Inter, Bold, 24-48px
- **부제목**: Inter, Medium, 18-24px
- **본문**: Inter, Regular, 14-16px
- **캡션**: Inter, Light, 12-14px

### 애니메이션
- **페이지 전환**: Fade in/out (300ms)
- **카드 호버**: Scale up + shadow (200ms)
- **버튼 클릭**: Scale down (100ms)
- **로딩**: Skeleton animation

---

## 📊 API 설계

### Unsplash API
```typescript
// 여행 사진 검색
GET /search/photos?query=travel&orientation=landscape

// 카테고리별 사진
GET /search/photos?query=beach&per_page=20
GET /search/photos?query=mountain&per_page=20
GET /search/photos?query=city&per_page=20
```

### Google Places API
```typescript
// 장소 검색
GET /place/textsearch/json?query=tourist+attractions

// 장소 상세 정보
GET /place/details/json?place_id={place_id}
```

### Google Maps API
```typescript
// 지도 렌더링
<GoogleMap
  center={center}
  zoom={zoom}
  markers={markers}
/>
```

---

## 💡 추가 아이디어

### 고급 기능 (선택사항)
- **다크모드**: 테마 전환 기능
- **다국어 지원**: i18n 구현
- **PWA**: 오프라인 지원
- **소셜 로그인**: Google, Facebook 로그인
- **여행 계획**: 캘린더 연동
- **여행 통계**: 방문 국가 지도

### 확장 가능성
- **백엔드 연동**: 사용자 데이터 저장
- **실시간 채팅**: 여행자 커뮤니티
- **AI 추천**: 개인화된 여행지 추천
- **모바일 앱**: React Native 버전

---

## 📞 지원 및 리소스

### 유용한 링크
- [Unsplash API 문서](https://unsplash.com/developers)
- [Google Maps API 문서](https://developers.google.com/maps)
- [Framer Motion 문서](https://www.framer.com/motion/)
- [Tailwind CSS 문서](https://tailwindcss.com/docs)

### 참고 자료
- [React Router 튜토리얼](https://reactrouter.com/docs/en/v6)
- [TypeScript 핸드북](https://www.typescriptlang.org/docs/)
- [반응형 디자인 가이드](https://web.dev/responsive/)

