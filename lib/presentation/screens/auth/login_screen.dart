import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          final isOnboardingCompleted = ref.read(isOnboardingCompletedProvider);
          if (isOnboardingCompleted) {
            context.go(AppRoutes.home);
          } else {
            context.go(AppRoutes.onboarding);
          }
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 로고
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '🏠\n🐰',
                    style: TextStyle(fontSize: 48),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.xl),

              // 앱 이름
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppSizes.sm),

              // 태그라인
              Text(
                AppStrings.appTagline,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(flex: 2),

              // 로그인 버튼들
              if (authState.isLoading)
                const CircularProgressIndicator(color: AppColors.primary)
              else ...[
                // Google 로그인
                _LoginButton(
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).signInWithGoogle();
                  },
                  icon: '🔵',
                  label: AppStrings.loginWithGoogle,
                  backgroundColor: Colors.white,
                  textColor: AppColors.textPrimary,
                ),

                const SizedBox(height: AppSizes.md),

                // Apple 로그인 (iOS만)
                if (Platform.isIOS)
                  _LoginButton(
                    onPressed: () {
                      ref.read(authNotifierProvider.notifier).signInWithApple();
                    },
                    icon: '🍎',
                    label: AppStrings.loginWithApple,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  ),
              ],

              // 에러 메시지
              if (authState.hasError) ...[
                const SizedBox(height: AppSizes.md),
                Text(
                  authState.error.toString(),
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _LoginButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: AppSizes.sm),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
