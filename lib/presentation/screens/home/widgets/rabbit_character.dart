import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class RabbitCharacter extends StatefulWidget {
  final bool isJumping;
  final String? message;

  const RabbitCharacter({
    super.key,
    this.isJumping = false,
    this.message,
  });

  @override
  State<RabbitCharacter> createState() => _RabbitCharacterState();
}

class _RabbitCharacterState extends State<RabbitCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _jumpAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _jumpAnimation = Tween<double>(begin: 0, end: -30).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void didUpdateWidget(RabbitCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isJumping && !oldWidget.isJumping) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 말풍선
        if (widget.message != null)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSizes.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.message!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('🎉', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),

        // 토끼
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _jumpAnimation.value),
              child: child,
            );
          },
          child: Container(
            width: AppSizes.rabbitSize,
            height: AppSizes.rabbitSize,
            decoration: BoxDecoration(
              color: AppColors.rabbitPrimary,
              borderRadius: BorderRadius.circular(AppSizes.rabbitSize / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 귀
                Positioned(
                  top: -20,
                  left: 15,
                  child: _buildEar(isLeft: true),
                ),
                Positioned(
                  top: -20,
                  right: 15,
                  child: _buildEar(isLeft: false),
                ),
                // 얼굴
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 눈
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildEye(widget.isJumping),
                        const SizedBox(width: 12),
                        _buildEye(widget.isJumping),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 코
                    Container(
                      width: 8,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.rabbitSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // 입
                    Text(
                      widget.isJumping ? '◡' : 'ω',
                      style: TextStyle(
                        fontSize: widget.isJumping ? 16 : 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                // 볼 터치
                Positioned(
                  left: 8,
                  bottom: 20,
                  child: Container(
                    width: 12,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.rabbitSecondary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 20,
                  child: Container(
                    width: 12,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.rabbitSecondary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEar({required bool isLeft}) {
    return Transform.rotate(
      angle: isLeft ? -0.2 : 0.2,
      child: Container(
        width: 16,
        height: 35,
        decoration: BoxDecoration(
          color: AppColors.rabbitPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.rabbitSecondary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: 8,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.rabbitSecondary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEye(bool isHappy) {
    if (isHappy) {
      return const Text(
        '^',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      );
    }

    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AppColors.textPrimary,
        shape: BoxShape.circle,
      ),
      child: Align(
        alignment: const Alignment(0.3, -0.3),
        child: Container(
          width: 3,
          height: 3,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
