# 차곡 (Chagok) 개발 계획서

## 프로젝트 구조

```
chagok/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/                      # 공통 핵심 모듈
│   │   ├── constants/             # 색상, 사이즈, 문자열
│   │   ├── exceptions/            # 커스텀 예외
│   │   ├── extensions/            # 확장 메서드
│   │   ├── router/                # GoRouter 설정
│   │   └── utils/                 # 햅틱, 사운드 유틸
│   ├── data/                      # 데이터 레이어
│   │   ├── models/                # Firestore 모델
│   │   ├── repositories/          # 데이터 접근
│   │   └── services/              # Firebase, API 서비스
│   ├── domain/                    # 비즈니스 로직
│   │   ├── enums/                 # 열거형
│   │   └── usecases/              # 유스케이스
│   ├── presentation/              # UI 레이어
│   │   ├── providers/             # Riverpod Provider
│   │   ├── screens/               # 화면
│   │   └── widgets/               # 재사용 위젯
│   └── config/                    # Firebase 설정
├── functions/                     # Cloud Functions
└── docs/                          # 문서
```

## Phase별 개발 현황

### ✅ Phase 1: 프로젝트 셋업
- [x] Flutter 프로젝트 구조 생성
- [x] 패키지 의존성 정의 (pubspec.yaml)
- [x] 상수 정의 (colors, sizes, strings)
- [x] GoRouter 라우팅 설정
- [x] Riverpod Provider 구조 설정
- [x] Firebase 설정 파일

### ✅ Phase 2: 인증 시스템
- [x] UserModel 정의
- [x] AuthRepository (Google, Apple 로그인)
- [x] UserRepository (CRUD)
- [x] AuthProvider, UserProvider
- [x] 로그인 화면 UI
- [x] 스플래시 화면

### ✅ Phase 3: 온보딩 채팅
- [x] ChatMessageModel, ChatSessionModel
- [x] ChatRepository
- [x] CloudFunctionsService
- [x] ChatProvider (상태 관리)
- [x] ChatBubble, ChatInput 위젯
- [x] OnboardingScreen

### ✅ Phase 4: 메인 화면 (현미경 모드)
- [x] MissionModel
- [x] MissionRepository
- [x] MissionProvider
- [x] DraggableMissionBlock (드래그 가능한 블록)
- [x] PixelHouse (레벨별 집)
- [x] RabbitCharacter (토끼 캐릭터)
- [x] MicroscopeView (메인 화면)
- [x] 햅틱 피드백, 파티클 효과

### ✅ Phase 5: 대시보드 (망원경 모드)
- [x] ViewModeProvider
- [x] ZoomTransition 애니메이션
- [x] PixelCalendar (픽셀 달력)
- [x] StatsCard (통계 카드)
- [x] TelescopeView (대시보드)
- [x] 보상 아이템 그리드

### ✅ Phase 6: Cloud Functions
- [x] chatWithRabbit (AI 대화)
- [x] generateDailyMissions (일일 미션 생성)
- [x] processEndOfDay (하루 마감 처리)
- [x] onMissionComplete (미션 완료 트리거)
- [x] OpenAI 유틸 모듈
- [x] 프롬프트 상수

### ✅ Phase 7: 폴리싱
- [x] Firestore 보안 규칙
- [x] Firestore 인덱스
- [x] .gitignore
- [x] README.md
- [x] analysis_options.yaml

## 파일 목록

### Flutter (lib/)
| 파일 | 설명 |
|------|------|
| main.dart | 앱 진입점 |
| app.dart | MaterialApp 설정 |
| core/constants/app_colors.dart | 색상 상수 |
| core/constants/app_sizes.dart | 사이즈 상수 |
| core/constants/app_strings.dart | 문자열 상수 |
| core/router/app_router.dart | GoRouter 설정 |
| core/utils/haptic_util.dart | 햅틱 피드백 |
| core/utils/sound_util.dart | 사운드 재생 |
| core/exceptions/app_exceptions.dart | 커스텀 예외 |
| core/extensions/datetime_ext.dart | DateTime 확장 |
| core/extensions/string_ext.dart | String 확장 |
| data/models/*.dart | Firestore 모델 (5개) |
| data/repositories/*.dart | 리포지토리 (5개) |
| data/services/*.dart | 서비스 (3개) |
| domain/enums/*.dart | Enum (4개) |
| presentation/providers/*.dart | Provider (5개) |
| presentation/screens/**/*.dart | 화면 (6개) |
| presentation/widgets/**/*.dart | 위젯 (10개+) |

### Cloud Functions (functions/src/)
| 파일 | 설명 |
|------|------|
| index.ts | 함수 진입점 |
| chat/chatWithRabbit.ts | AI 대화 처리 |
| missions/generateDailyMissions.ts | 일일 미션 생성 |
| missions/processEndOfDay.ts | 하루 마감 처리 |
| gamification/onMissionComplete.ts | 미션 완료 트리거 |
| utils/openai.ts | OpenAI API 래퍼 |
| utils/prompts.ts | AI 프롬프트 |

## 배포 체크리스트

### Firebase 설정
- [ ] Firebase 프로젝트 생성
- [ ] Android 앱 등록
- [ ] iOS 앱 등록
- [ ] Firestore 데이터베이스 생성
- [ ] Authentication 활성화 (Google, Apple)
- [ ] Cloud Functions 활성화

### 환경 변수
- [ ] OpenAI API 키 설정
- [ ] Firebase 설정 파일 교체

### 배포
- [ ] Firestore 보안 규칙 배포
- [ ] Firestore 인덱스 배포
- [ ] Cloud Functions 배포
- [ ] Android 빌드 & 배포
- [ ] iOS 빌드 & 배포
