import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticUtil {
  HapticUtil._();

  static Future<void> light() async {
    if (await Vibration.hasVibrator() ?? false) {
      HapticFeedback.lightImpact();
    }
  }

  static Future<void> medium() async {
    if (await Vibration.hasVibrator() ?? false) {
      HapticFeedback.mediumImpact();
    }
  }

  static Future<void> heavy() async {
    if (await Vibration.hasVibrator() ?? false) {
      HapticFeedback.heavyImpact();
      await Vibration.vibrate(duration: 50);
    }
  }

  static Future<void> success() async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(pattern: [0, 50, 50, 50]);
    }
  }

  static Future<void> error() async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(pattern: [0, 100, 50, 100]);
    }
  }

  static Future<void> selection() async {
    HapticFeedback.selectionClick();
  }
}
