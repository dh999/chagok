class AppSizes {
  AppSizes._();

  // Padding & Margin
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 100.0;

  // Font Sizes
  static const double fontXs = 10.0;
  static const double fontSm = 12.0;
  static const double fontMd = 14.0;
  static const double fontLg = 16.0;
  static const double fontXl = 20.0;
  static const double fontXxl = 24.0;
  static const double fontDisplay = 32.0;

  // Icon Sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Block Sizes
  static const double blockSize = 60.0;
  static const double blockSizeLg = 80.0;

  // House Sizes
  static const double houseWidth = 200.0;
  static const double houseHeight = 250.0;

  // Character Sizes
  static const double rabbitSize = 80.0;

  // Animation Durations (milliseconds)
  static const int animFast = 150;
  static const int animNormal = 300;
  static const int animSlow = 500;
  static const int animVerySlow = 800;

  // Game Constants
  static const int maxMissionsPerDay = 5;
  static const int baseExpPerMission = 10;
  static const int allClearBonusExp = 30;
  static const int allClearBonusBlocks = 1;
  static const int maxLevel = 10;

  // Level Thresholds (EXP required for each level)
  static const List<int> levelThresholds = [0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500];

  // Streak Thresholds for rewards
  static const List<int> streakMilestones = [7, 14, 30, 60, 100];

  // Input constraints
  static const int maxNicknameLength = 20;
  static const int maxGoalLength = 100;
  static const int maxMessageLength = 500;
}
