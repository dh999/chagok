import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 온보딩 세션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).startOnboarding();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);

    // 온보딩 완료 시 홈으로 이동
    ref.listen(isOnboardingCompletedProvider, (previous, next) {
      if (next) {
        context.go(AppRoutes.home);
      }
    });

    // 새 메시지 시 스크롤
    ref.listen(chatNotifierProvider.select((s) => s.messages.length),
        (previous, next) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐰', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Text(AppStrings.onboardingTitle),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // 채팅 메시지 영역
          Expanded(
            child: chatState.messages.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      return ChatBubble(
                        message: message.content,
                        isUser: message.isUser,
                        showRabbit: !message.isUser && index == 0,
                      );
                    },
                  ),
          ),

          // 로딩 인디케이터
          if (chatState.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Row(
                children: [
                  const Text('🐰', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const SizedBox(
                      width: 40,
                      child: LinearProgressIndicator(
                        color: AppColors.primary,
                        backgroundColor: AppColors.background,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 에러 메시지
          if (chatState.error != null)
            Container(
              margin: const EdgeInsets.all(AppSizes.md),
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatState.error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.error),
                    onPressed: () {
                      ref.read(chatNotifierProvider.notifier).clearError();
                    },
                  ),
                ],
              ),
            ),

          // 입력 영역
          ChatInput(
            enabled: !chatState.isLoading && !chatState.isOnboardingComplete,
            onSend: (message) {
              ref.read(chatNotifierProvider.notifier).sendMessage(message);
            },
          ),
        ],
      ),
    );
  }
}
