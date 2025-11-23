# 차곡 (Chagok) 상세 설계서

> 원본 MVP Product Spec의 보완 및 상세 설계 문서

---

## 1. 데이터베이스 구조 (보완)

### Collection: `users`

```json
{
  "uid": "string (Firebase Auth UID)",
  "email": "string",
  "nickname": "string",
  "profile_image_url": "string (nullable)",

  // 목표 관련
  "final_goal": "string (e.g., 10년 뒤 건물주)",
  "goal_category": "string (FINANCE | STUDY | HEALTH | CAREER)",
  "target_date": "timestamp (목표 달성 예정일)",
  "total_blocks_needed": "int (총 필요 블록 수)",
  "current_blocks": "int (현재 완료 블록 수)",

  // 게이미피케이션
  "rabbit_level": "int (1~10, default: 1)",
  "rabbit_exp": "int (경험치, default: 0)",
  "monthly_streak": "int (이번 달 연속 성공 일수)",
  "total_streak": "int (전체 연속 성공 일수)",
  "longest_streak": "int (최장 연속 기록)",
  "unlocked_items": ["string (아이템 ID 배열)"],

  // 메타
  "created_at": "timestamp",
  "updated_at": "timestamp",
  "last_login_at": "timestamp",
  "onboarding_completed": "boolean",
  "fcm_token": "string (Push 알림용, nullable)"
}
```

### Collection: `missions`

```json
{
  "id": "string (auto_gen)",
  "uid": "string (ref: users)",

  // 미션 내용
  "date": "timestamp (해당 날짜 00:00:00)",
  "content": "string (e.g., 부동산 경매 책 10p 읽기)",
  "type": "string (STUDY | SAVING | HEALTH | TASK)",
  "difficulty": "string (EASY | MEDIUM | HARD)",
  "block_value": "int (완료 시 획득 블록 수, 기본 1)",

  // 상태
  "status": "string (PENDING | COMPLETED | SKIPPED | FAILED)",
  "is_completed": "boolean",
  "completed_at": "timestamp (nullable)",

  // AI 생성 관련
  "generated_by": "string (AI | USER | SYSTEM)",
  "ai_context": "string (AI가 이 미션을 생성한 이유, nullable)",

  // 메타
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### Collection: `chat_sessions`

```json
{
  "id": "string (auto_gen)",
  "uid": "string (ref: users)",
  "session_type": "string (ONBOARDING | DAILY_CHECK | COUNSELING)",
  "messages": [
    {
      "role": "string (user | assistant)",
      "content": "string",
      "timestamp": "timestamp"
    }
  ],
  "result_json": "map (AI 최종 출력 JSON, nullable)",
  "created_at": "timestamp",
  "closed_at": "timestamp (nullable)"
}
```

### Collection: `rewards`

```json
{
  "id": "string (item_flower_pot, item_bicycle 등)",
  "name": "string (화분, 자전거)",
  "description": "string",
  "unlock_condition": "string (STREAK_7 | STREAK_30 | LEVEL_5)",
  "asset_path": "string (assets/items/flower_pot.png)",
  "category": "string (DECORATION | CHARACTER | EFFECT)"
}
```

---

## 2. 에러 처리 및 예외 케이스

### API 에러 처리

| 상황 | 처리 방식 |
|------|-----------|
| OpenAI API 타임아웃 | 30초 후 재시도 버튼 표시, 토끼 메시지 출력 |
| OpenAI API 실패 (500) | 3회 자동 재시도 (2초 간격), 실패 시 오프라인 모드 |
| JSON 파싱 실패 | AI에게 재요청 (최대 2회) |
| Firebase 연결 실패 | 로컬 캐시 사용, 재연결 시 동기화 |
| Rate Limit 초과 | 일일 상담 횟수 제한 안내 |

### 사용자 행동 예외 케이스

| 상황 | 처리 방식 |
|------|-----------|
| 온보딩 중 앱 종료 | chat_sessions에 저장, 재진입 시 이어서 진행 |
| AI가 JSON 미출력 | 대화 10턴 초과 시 강제 요약 요청 |
| 목표 없이 대화 종료 | 기본 미션 2개 제안 |
| 자정에 미션 미완료 | status: FAILED, streak 리셋, 위로 메시지 |
| 드래그 중 백그라운드 | 드래그 상태 초기화 |
| 미션 중복 생성 요청 | 기존 미션 유지, 토스트 알림 |

### 네트워크 상태별 처리

| 상태 | 동작 |
|------|------|
| 온라인 | 정상 동작, 실시간 Firestore 동기화 |
| 오프라인 | 로컬 캐시 읽기, 쓰기는 큐에 저장 |
| 온라인 복귀 | 큐 처리, 충돌 시 서버 우선 |

---

## 3. 미션 생성 로직

### 미션 생명주기

```
[온보딩 완료] → 오늘 미션 2개 즉시 생성

[매일 00:00 KST] → Cloud Functions 트리거
  ├─ 어제 미션 상태 정산 (PENDING → FAILED)
  ├─ streak 계산 및 업데이트
  └─ 오늘 미션 2개 자동 생성

[사용자 요청] → 토끼와 대화로 미션 수정/추가
```

### AI 일일 미션 생성 프롬프트

```
Role: 당신은 건축가 토끼입니다.

Context:
- 사용자 최종 목표: {final_goal}
- 목표 카테고리: {goal_category}
- 남은 일수: {days_remaining}
- 어제 미션 완료 여부: {yesterday_status}
- 현재 streak: {current_streak}
- 최근 7일 완료율: {weekly_rate}%

Rules:
1. 미션은 "오늘 당장" 실행 가능해야 함 (30분 이내)
2. 목표와 연관성 있되, 난이도는 점진적으로
3. 어제 실패했다면 더 쉬운 미션 제안
4. streak 7일 이상이면 약간 도전적인 미션

Output (JSON only):
{
  "daily_missions": [
    {"content": "미션1", "type": "STUDY", "difficulty": "EASY"},
    {"content": "미션2", "type": "SAVING", "difficulty": "MEDIUM"}
  ],
  "rabbit_message": "토끼의 한마디"
}
```

### 미션 상태 전이

```
PENDING (생성)
    │
    ├─→ COMPLETED (드래그 완료)
    ├─→ SKIPPED (사용자 스킵)
    └─→ FAILED (자정 경과)
```

### 미션 타입별 블록 가치

| Type | Difficulty | block_value | 예시 |
|------|------------|-------------|------|
| STUDY | EASY | 1 | 책 5페이지 읽기 |
| STUDY | MEDIUM | 2 | 강의 1개 완강 |
| STUDY | HARD | 3 | 모의고사 1회 |
| SAVING | EASY | 1 | 커피 안 마시기 |
| SAVING | MEDIUM | 2 | 만원 저축 |
| HEALTH | EASY | 1 | 물 2L 마시기 |
| HEALTH | MEDIUM | 2 | 30분 운동 |

---

## 4. 인증 및 보안

### 인증 방식

**Phase 1 (MVP)**
- Google 소셜 로그인 (Firebase Auth)
- Apple 로그인 (iOS 필수)

**Phase 2 (추후)**
- 이메일/비밀번호
- 카카오 로그인

### API 키 보안 아키텍처

```
Client (Flutter) → Firebase Cloud Functions → OpenAI API
       │                    │
       │ ID Token           │ API Key (환경 변수)
       ▼                    ▼
  클라이언트는 OpenAI API 키를 절대 보유하지 않음
```

### Cloud Functions 엔드포인트

| 함수명 | 트리거 | 역할 |
|--------|--------|------|
| `chatWithRabbit` | HTTPS | OpenAI 프록시, 대화 처리 |
| `generateDailyMissions` | Scheduled (00:00 KST) | 전체 유저 미션 생성 |
| `processEndOfDay` | Scheduled (23:59 KST) | 미완료 미션 FAILED 처리 |
| `calculateStreak` | Firestore Trigger | 미션 완료 시 streak 업데이트 |

### Firestore 보안 규칙

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }

    match /missions/{missionId} {
      allow read, write: if request.auth != null
                         && resource.data.uid == request.auth.uid;
      allow create: if request.auth != null
                    && request.resource.data.uid == request.auth.uid;
    }

    match /chat_sessions/{sessionId} {
      allow read, write: if request.auth != null
                         && resource.data.uid == request.auth.uid;
    }

    match /rewards/{rewardId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

---

## 5. 게이미피케이션 상세 규칙

### 블록 계산 공식

```
total_blocks_needed = 목표 기간(일) × 평균 일일 블록(2)

예시: 10년 목표 = 3650일 × 2 = 7,300 블록

일일 획득 블록 = Σ(완료 미션의 block_value)
미션 2개 모두 완료 시: 보너스 +1 블록
```

### 토끼 레벨 시스템

| Level | 필요 EXP | 누적 블록 | 해금 요소 |
|-------|----------|-----------|-----------|
| 1 | 0 | 0 | 기본 토끼 |
| 2 | 100 | 50 | 안전모 착용 |
| 3 | 300 | 150 | 망치 들기 |
| 4 | 600 | 300 | 청사진 배경 |
| 5 | 1000 | 500 | 황금 안전모 |
| 6 | 1500 | 750 | 크레인 등장 |
| 7 | 2100 | 1000 | 조수 토끼 |
| 8 | 2800 | 1400 | 야경 모드 |
| 9 | 3600 | 1800 | VIP 뱃지 |
| 10 | 4500 | 2250 | 마스터 빌더 |

### EXP 획득 규칙

| 행동 | EXP |
|------|-----|
| 미션 1개 완료 | +10 |
| 일일 미션 올클리어 | +30 (보너스) |
| 7일 연속 streak | +50 |
| 30일 연속 streak | +200 |
| 첫 100블록 달성 | +100 |

### Streak 보상 체계

| Streak | 보상 |
|--------|------|
| 7일 | 화분 해금 |
| 14일 | 울타리 해금 |
| 30일 | 자전거 해금 + 집 레벨업 애니메이션 |
| 60일 | 정원 해금 |
| 100일 | 2층 증축 시작 |

### 집 진화 단계

| 단계 | 조건 | 외형 |
|------|------|------|
| 1 | 시작 | 텐트 (1×1) |
| 2 | 100 블록 | 오두막 (2×2) |
| 3 | 500 블록 | 작은 집 (3×3) |
| 4 | 1500 블록 | 2층 집 |
| 5 | 3000 블록 | 정원 있는 집 |
| 6 | 5000 블록 | 작은 빌딩 |
| 7 | 7300 블록 | 목표 달성 건물 |

### Streak 실패 시 페널티

- `monthly_streak` = 0 (리셋)
- `total_streak` = 0 (리셋)
- `longest_streak`은 유지 (최고 기록)
- 해금된 아이템은 유지 (박탈 안 함)
- 토끼 위로 메시지 출력
- 복구 보너스: 3일 연속 복귀 시 "불사조 뱃지" + EXP 20

---

## 6. 화면별 상세 설계

### A. 스플래시 / 로그인

```
┌─────────────────────────┐
│                         │
│      [차곡 로고]         │
│      🐰 + 🧱            │
│                         │
│  ┌─────────────────┐    │
│  │ Google로 시작    │    │
│  └─────────────────┘    │
│  ┌─────────────────┐    │
│  │ Apple로 시작     │    │
│  └─────────────────┘    │
│                         │
└─────────────────────────┘
```

### B. 온보딩 채팅

```
┌─────────────────────────┐
│ ← 건축 상담소            │
├─────────────────────────┤
│                         │
│  🐰 안녕하세요!          │
│     저는 건축가 토끼예요  │
│                         │
│     어떤 꿈을 가지고     │
│     계신가요? 🏠        │
│                         │
│         ┌─────────────┐ │
│         │ 10년 뒤     │ │
│         │ 건물주가    │ │
│         │ 되고 싶어요 │ │
│         └─────────────┘ │
│                         │
├─────────────────────────┤
│ [메시지 입력...]    [➤] │
└─────────────────────────┘
```

### C. 현미경 모드 (메인)

```
┌─────────────────────────┐
│ 🏠 차곡차곡      [👤]   │
├─────────────────────────┤
│  ┌───┐  ┌───┐          │
│  │📚│  │💰│  ← 드래그  │
│  └───┘  └───┘    블록   │
│                         │
│      ┌─────────┐        │
│      │ 🏠      │        │
│      │  🐰     │ ← 집   │
│      │ ▓▓▓▓▓▓ │        │
│      └─────────┘        │
│                         │
│  "한 칸 올라갔다!" 🎉   │
│                         │
├─────────────────────────┤
│              [🔭]       │
└─────────────────────────┘
      ↑ 망원경 FAB
```

### D. 망원경 모드 (대시보드)

```
┌─────────────────────────┐
│ ← 내 건축 현황           │
├─────────────────────────┤
│                         │
│  전체 공정률: 12.34%    │
│  ████░░░░░░░░░░░░░░░   │
│                         │
│  ┌─ 11월 ─────────────┐ │
│  │ 월 화 수 목 금 토 일│ │
│  │ ▓  ▓  ▓  ░  ░  ░  ░│ │
│  │ ▓  ▓  ▓  ▓  ▓  ░  ░│ │
│  │ ▓  ▓  ▓  ▓  ◈  ·  ·│ │
│  │ ·  ·  ·  ·  ·  ·  ·│ │
│  └─────────────────────┘ │
│  ▓ 성공  ░ 실패  ◈ 오늘 │
│                         │
│  이번 달 성실도: 85%    │
│                         │
│  🏆 보상 아이템         │
│  [🪴] [🚲] [🔒] [🔒]    │
│                         │
└─────────────────────────┘
```

---

## 7. 개발 단계별 체크리스트

### Phase 1: 프로젝트 셋업
- [ ] Flutter 프로젝트 생성
- [ ] Firebase 프로젝트 연결 (Auth, Firestore)
- [ ] 기본 라우팅 설정 (GoRouter)
- [ ] 상태관리 설정 (Riverpod)
- [ ] 환경변수 설정 (.env)

### Phase 2: 인증
- [ ] Google 로그인 구현
- [ ] Apple 로그인 구현
- [ ] 사용자 문서 자동 생성
- [ ] 로그인 상태 유지

### Phase 3: 온보딩
- [ ] 채팅 UI 구현
- [ ] Cloud Functions - chatWithRabbit
- [ ] JSON 파싱 및 화면 전환
- [ ] 채팅 세션 저장

### Phase 4: 메인 화면
- [ ] 현미경 모드 UI
- [ ] 드래그 앤 드롭 구현
- [ ] 햅틱 피드백
- [ ] 미션 완료 처리
- [ ] 토끼 애니메이션

### Phase 5: 대시보드
- [ ] 망원경 모드 UI
- [ ] 줌 전환 애니메이션
- [ ] 픽셀 캘린더 구현
- [ ] 통계 표시
- [ ] 보상 아이템 표시

### Phase 6: 백엔드 로직
- [ ] generateDailyMissions (Scheduled)
- [ ] processEndOfDay (Scheduled)
- [ ] calculateStreak (Trigger)
- [ ] 레벨업 로직

### Phase 7: 폴리싱
- [ ] 사운드 효과
- [ ] 파티클 효과
- [ ] 푸시 알림
- [ ] 오프라인 지원
- [ ] 에러 핸들링 완성

---

## 8. 기술 스택 상세

### Flutter 패키지

```yaml
dependencies:
  # 상태관리
  flutter_riverpod: ^2.4.0

  # 라우팅
  go_router: ^12.0.0

  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.13.0
  cloud_functions: ^4.5.0
  firebase_messaging: ^14.7.0

  # UI
  flutter_animate: ^4.3.0
  rive: ^0.12.0  # 토끼 애니메이션
  table_calendar: ^3.0.9

  # 기타
  shared_preferences: ^2.2.0
  connectivity_plus: ^5.0.0
  vibration: ^1.8.0
  audioplayers: ^5.2.0
```

### Firebase Cloud Functions

```
functions/
├── src/
│   ├── chat/
│   │   └── chatWithRabbit.ts
│   ├── missions/
│   │   ├── generateDailyMissions.ts
│   │   └── processEndOfDay.ts
│   ├── gamification/
│   │   └── calculateStreak.ts
│   └── index.ts
├── package.json
└── tsconfig.json
```

---

*문서 버전: 1.0*
*최종 수정: 2025-11-23*
