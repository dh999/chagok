import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Keys
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyLastSyncTime = 'last_sync_time';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyHapticEnabled = 'haptic_enabled';
  static const String _keyNotificationEnabled = 'notification_enabled';
  static const String _keyCachedMissions = 'cached_missions';
  static const String _keyCachedUserData = 'cached_user_data';

  // Onboarding
  bool get isOnboardingCompleted => prefs.getBool(_keyOnboardingCompleted) ?? false;
  Future<void> setOnboardingCompleted(bool value) =>
      prefs.setBool(_keyOnboardingCompleted, value);

  // Last sync time
  DateTime? get lastSyncTime {
    final timestamp = prefs.getInt(_keyLastSyncTime);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  Future<void> setLastSyncTime(DateTime time) =>
      prefs.setInt(_keyLastSyncTime, time.millisecondsSinceEpoch);

  // Settings
  bool get isSoundEnabled => prefs.getBool(_keySoundEnabled) ?? true;
  Future<void> setSoundEnabled(bool value) =>
      prefs.setBool(_keySoundEnabled, value);

  bool get isHapticEnabled => prefs.getBool(_keyHapticEnabled) ?? true;
  Future<void> setHapticEnabled(bool value) =>
      prefs.setBool(_keyHapticEnabled, value);

  bool get isNotificationEnabled => prefs.getBool(_keyNotificationEnabled) ?? true;
  Future<void> setNotificationEnabled(bool value) =>
      prefs.setBool(_keyNotificationEnabled, value);

  // Cached Missions (오프라인 지원)
  List<Map<String, dynamic>>? get cachedMissions {
    final data = prefs.getString(_keyCachedMissions);
    if (data == null) return null;
    try {
      final decoded = jsonDecode(data) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  Future<void> setCachedMissions(List<Map<String, dynamic>> missions) =>
      prefs.setString(_keyCachedMissions, jsonEncode(missions));

  Future<void> clearCachedMissions() => prefs.remove(_keyCachedMissions);

  // Cached User Data (오프라인 지원)
  Map<String, dynamic>? get cachedUserData {
    final data = prefs.getString(_keyCachedUserData);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> setCachedUserData(Map<String, dynamic> userData) =>
      prefs.setString(_keyCachedUserData, jsonEncode(userData));

  Future<void> clearCachedUserData() => prefs.remove(_keyCachedUserData);

  // Clear all
  Future<void> clearAll() => prefs.clear();
}
