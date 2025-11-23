import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class PixelHouse extends StatelessWidget {
  final int level;
  final bool isHighlighted;

  const PixelHouse({
    super.key,
    this.level = 1,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: isHighlighted
          ? (Matrix4.identity()..scale(1.05))
          : Matrix4.identity(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 집 본체
          _buildHouse(),
          // 바닥
          Container(
            width: AppSizes.houseWidth + 40,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF8B7355),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHouse() {
    return Container(
      width: AppSizes.houseWidth,
      height: AppSizes.houseHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 레벨에 따른 집
          _buildHouseByLevel(),
          // 하이라이트 효과
          if (isHighlighted)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                    width: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHouseByLevel() {
    switch (level) {
      case 1:
        return _buildTent();
      case 2:
        return _buildCabin();
      case 3:
        return _buildSmallHouse();
      case 4:
        return _buildTwoStoryHouse();
      case 5:
        return _buildHouseWithGarden();
      case 6:
        return _buildSmallBuilding();
      case 7:
        return _buildGoalBuilding();
      default:
        return _buildTent();
    }
  }

  // 레벨 1: 텐트
  Widget _buildTent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomPaint(
          size: const Size(80, 60),
          painter: _TentPainter(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // 레벨 2: 오두막
  Widget _buildCabin() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 지붕
        CustomPaint(
          size: const Size(100, 40),
          painter: _RoofPainter(color: const Color(0xFF8B4513)),
        ),
        // 본체
        Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFDEB887),
            border: Border.all(color: const Color(0xFF8B4513), width: 3),
          ),
          child: const Center(
            child: Text('🚪', style: TextStyle(fontSize: 24)),
          ),
        ),
      ],
    );
  }

  // 레벨 3: 작은 집
  Widget _buildSmallHouse() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 지붕
        CustomPaint(
          size: const Size(120, 50),
          painter: _RoofPainter(color: const Color(0xFFB22222)),
        ),
        // 본체
        Container(
          width: 100,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAF0),
            border: Border.all(color: const Color(0xFF8B7355), width: 3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Text('🪟', style: TextStyle(fontSize: 20)),
                  Text('🪟', style: TextStyle(fontSize: 20)),
                ],
              ),
              const Text('🚪', style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
      ],
    );
  }

  // 레벨 4: 2층 집
  Widget _buildTwoStoryHouse() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 지붕
        CustomPaint(
          size: const Size(140, 50),
          painter: _RoofPainter(color: const Color(0xFF4169E1)),
        ),
        // 2층
        Container(
          width: 120,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAF0),
            border: Border.all(color: const Color(0xFF8B7355), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Text('🪟', style: TextStyle(fontSize: 18)),
              Text('🪟', style: TextStyle(fontSize: 18)),
              Text('🪟', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
        // 1층
        Container(
          width: 120,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAF0),
            border: Border.all(color: const Color(0xFF8B7355), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Text('🪟', style: TextStyle(fontSize: 18)),
              Text('🚪', style: TextStyle(fontSize: 22)),
              Text('🪟', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }

  // 레벨 5: 정원 있는 집
  Widget _buildHouseWithGarden() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // 정원
        Positioned(
          bottom: 0,
          left: 10,
          child: const Text('🌳', style: TextStyle(fontSize: 30)),
        ),
        Positioned(
          bottom: 0,
          right: 10,
          child: const Text('🌲', style: TextStyle(fontSize: 30)),
        ),
        // 집
        _buildTwoStoryHouse(),
      ],
    );
  }

  // 레벨 6: 작은 빌딩
  Widget _buildSmallBuilding() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 100,
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFF87CEEB),
            border: Border.all(color: const Color(0xFF4682B4), width: 3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(8, (index) {
              return const Center(
                child: Text('🪟', style: TextStyle(fontSize: 16)),
              );
            }),
          ),
        ),
      ],
    );
  }

  // 레벨 7: 목표 달성 건물
  Widget _buildGoalBuilding() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 깃발
        const Text('🏳️', style: TextStyle(fontSize: 24)),
        Container(
          width: 120,
          height: 180,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            border: Border.all(color: const Color(0xFFB8860B), width: 3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.blockGold.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              const Text(
                '목표 달성!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF228B22)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // 테두리
    paint
      ..color = const Color(0xFF006400)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoofPainter extends CustomPainter {
  final Color color;

  _RoofPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
