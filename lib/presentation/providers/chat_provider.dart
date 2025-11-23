import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chat_session_model.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/enums/goal_category.dart';
import 'auth_provider.dart';
import 'user_provider.dart';
import 'mission_provider.dart';

/// Chat Repository Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

/// Chat State
class ChatState {
  final ChatSessionModel? session;
  final List<ChatMessageModel> messages;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? parsedResult;

  const ChatState({
    this.session,
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.parsedResult,
  });

  ChatState copyWith({
    ChatSessionModel? session,
    List<ChatMessageModel>? messages,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? parsedResult,
  }) {
    return ChatState(
      session: session ?? this.session,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      parsedResult: parsedResult ?? this.parsedResult,
    );
  }

  bool get hasResult => parsedResult != null;
  bool get isOnboardingComplete =>
      parsedResult?['action'] == 'create_plan';
}

/// Chat Notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository;
  final Ref _ref;
  final String? _uid;

  ChatNotifier(this._chatRepository, this._ref, this._uid)
      : super(const ChatState());

  /// 온보딩 세션 시작/재개
  Future<void> startOnboarding() async {
    if (_uid == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // 기존 세션 확인
      var session = await _chatRepository.getActiveOnboardingSession(_uid!);

      if (session == null) {
        // 새 세션 생성
        session = await _chatRepository.createSession(
          uid: _uid!,
          sessionType: SessionType.onboarding,
        );

        // 초기 인사 메시지 추가
        final welcomeMessage = ChatMessageModel.assistant(
          '안녕하세요! 저는 건축가 토끼예요 🐰\n\n'
          '당신의 꿈을 현실로 만들어 드릴게요!\n\n'
          '어떤 목표를 가지고 계신가요?\n'
          '(예: 10년 뒤 건물주가 되고 싶어요)',
        );

        state = state.copyWith(
          session: session,
          messages: [welcomeMessage],
          isLoading: false,
        );
      } else {
        // 기존 세션 재개
        state = state.copyWith(
          session: session,
          messages: session.messages,
          parsedResult: session.resultJson,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '채팅을 시작할 수 없습니다.',
      );
    }
  }

  /// 메시지 전송
  Future<void> sendMessage(String message) async {
    if (state.session == null || message.trim().isEmpty) return;

    // 사용자 메시지 UI에 추가
    final userMessage = ChatMessageModel.user(message);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      // AI 응답 받기
      final response = await _chatRepository.sendMessage(
        sessionId: state.session!.id,
        message: message,
        history: state.messages,
      );

      // AI 응답 UI에 추가
      state = state.copyWith(
        messages: [...state.messages, response],
        isLoading: false,
      );

      // 세션 업데이트 확인 (JSON 결과)
      final updatedSession = await _chatRepository.getSession(state.session!.id);
      if (updatedSession?.resultJson != null) {
        state = state.copyWith(parsedResult: updatedSession!.resultJson);

        // 온보딩 완료 처리
        if (state.isOnboardingComplete) {
          await _handleOnboardingComplete(updatedSession.resultJson!);
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '메시지 전송에 실패했습니다. 다시 시도해주세요.',
      );
    }
  }

  /// 온보딩 완료 처리
  Future<void> _handleOnboardingComplete(Map<String, dynamic> result) async {
    if (_uid == null) return;

    try {
      final plan = result['plan'] as Map<String, dynamic>;
      final totalDays = plan['total_days'] as int? ?? 365;
      final dailyMissions = plan['daily_missions'] as List<dynamic>? ?? [];

      // 목표 카테고리 추론
      GoalCategory category = GoalCategory.study;
      final goalText = dailyMissions.join(' ').toLowerCase();
      if (goalText.contains('돈') ||
          goalText.contains('저축') ||
          goalText.contains('투자') ||
          goalText.contains('부동산')) {
        category = GoalCategory.finance;
      } else if (goalText.contains('운동') ||
          goalText.contains('건강') ||
          goalText.contains('다이어트')) {
        category = GoalCategory.health;
      } else if (goalText.contains('취업') ||
          goalText.contains('이직') ||
          goalText.contains('커리어')) {
        category = GoalCategory.career;
      }

      // 사용자 정보 업데이트
      await _ref.read(userNotifierProvider.notifier).completeOnboarding(
            finalGoal: state.messages
                .where((m) => m.isUser)
                .map((m) => m.content)
                .join(' ')
                .substring(0, 100),
            goalCategory: category,
            targetDate: DateTime.now().add(Duration(days: totalDays)),
            totalBlocksNeeded: totalDays * 2,
          );

      // 미션 생성
      final missionData = dailyMissions.map((content) {
        return {
          'content': content.toString(),
          'type': category == GoalCategory.finance
              ? 'SAVING'
              : category == GoalCategory.health
                  ? 'HEALTH'
                  : 'STUDY',
          'difficulty': 'EASY',
        };
      }).toList();

      await _ref.read(missionNotifierProvider.notifier).saveMissionsFromAI(missionData);

      // 세션 종료
      await _chatRepository.closeSession(state.session!.id);
    } catch (e) {
      // 온보딩 완료 처리 실패
      state = state.copyWith(error: '온보딩 완료 처리에 실패했습니다.');
    }
  }

  /// 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 세션 초기화
  void reset() {
    state = const ChatState();
  }
}

/// Chat Notifier Provider
final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  final uid = authState.valueOrNull?.uid;
  return ChatNotifier(chatRepository, ref, uid);
});
