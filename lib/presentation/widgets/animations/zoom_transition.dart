import 'package:flutter/material.dart';

class ZoomTransition extends StatelessWidget {
  final bool showFirst;
  final Widget first;
  final Widget second;
  final Duration duration;

  const ZoomTransition({
    super.key,
    required this.showFirst,
    required this.first,
    required this.second,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        // 들어오는 위젯인지 나가는 위젯인지 확인
        final isEntering = child.key == ValueKey(showFirst ? 'first' : 'second');

        // 줌 효과
        final scaleAnimation = Tween<double>(
          begin: isEntering ? 0.8 : 1.2,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        // 페이드 효과
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: showFirst
          ? KeyedSubtree(key: const ValueKey('first'), child: first)
          : KeyedSubtree(key: const ValueKey('second'), child: second),
    );
  }
}
