# 차곡 (Chagok) 🏠🐰

> 하루하루 쌓아가는 나의 꿈

막연한 장기 목표를 AI와의 대화를 통해 구체적인 오늘 할 일로 쪼개고, 픽셀 블록을 쌓는 시각적 재미를 통해 실행을 지속하게 하는 앱입니다.

## 주요 기능

- **🐰 AI 건축가 토끼**: 채팅을 통해 목표를 분석하고 일일 미션 추천
- **🧱 블록 쌓기**: 드래그 앤 드롭으로 미션 완료, 집이 점점 커짐
- **📊 대시보드**: 월간 달력으로 성실도 확인, 보상 아이템 수집
- **🔥 Streak 시스템**: 연속 성공 보상으로 동기 부여

## 기술 스택

- **Frontend**: Flutter 3.x
- **Backend**: Firebase (Auth, Firestore, Cloud Functions)
- **AI**: OpenAI GPT-4o-mini
- **State Management**: Riverpod

## 프로젝트 구조

```
lib/
├── core/           # 상수, 유틸, 라우터
├── data/           # 모델, 리포지토리, 서비스
├── domain/         # 엔티티, Enum, UseCase
├── presentation/   # Provider, Screen, Widget
└── config/         # Firebase 설정

functions/
└── src/            # Cloud Functions (TypeScript)
```

## 시작하기

### 1. 사전 요구사항

- Flutter SDK 3.x
- Firebase CLI
- Node.js 18+

### 2. Firebase 설정

```bash
# Firebase CLI 로그인
firebase login

# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 프로젝트 연결
flutterfire configure
```

### 3. 환경 변수 설정

Cloud Functions에 OpenAI API 키 설정:

```bash
firebase functions:config:set openai.key="YOUR_OPENAI_API_KEY"
```

### 4. 실행

```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

### 5. Cloud Functions 배포

```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

## 주요 화면

| 온보딩 | 현미경 모드 | 망원경 모드 |
|--------|------------|------------|
| AI와 대화로 목표 설정 | 드래그로 미션 완료 | 달력과 통계 확인 |

## 게이미피케이션

### 블록 & 집 레벨
- 미션 완료 시 블록 획득
- 블록 누적에 따라 집이 진화 (텐트 → 빌딩)

### Streak 보상
- 7일: 화분 🪴
- 14일: 울타리 🏚️
- 30일: 자전거 🚲
- 60일: 정원 🌳
- 100일: 2층 증축 🏗️

### 토끼 레벨
- EXP 획득으로 레벨업 (1~10)
- 레벨별 토끼 꾸미기 아이템 해금

## 라이선스

Private - All rights reserved
