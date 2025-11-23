import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mission_model.dart';
import '../services/firebase_service.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/extensions/datetime_ext.dart';
import '../../domain/enums/mission_status.dart';

class MissionRepository {
  final FirebaseService _firebaseService = FirebaseService();

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firebaseService.missionsCollection;

  /// 오늘의 미션 조회
  Future<List<MissionModel>> getTodayMissions(String uid) async {
    try {
      final today = DateTime.now().startOfDay;
      final tomorrow = today.add(const Duration(days: 1));

      final snapshot = await _collection
          .where('uid', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
          .where('date', isLessThan: Timestamp.fromDate(tomorrow))
          .get();

      return snapshot.docs.map((doc) => MissionModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw FirestoreException(
        message: '미션을 불러오는데 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 오늘의 미션 스트림
  Stream<List<MissionModel>> watchTodayMissions(String uid) {
    final today = DateTime.now().startOfDay;
    final tomorrow = today.add(const Duration(days: 1));

    return _collection
        .where('uid', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .where('date', isLessThan: Timestamp.fromDate(tomorrow))
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MissionModel.fromFirestore(doc)).toList());
  }

  /// 특정 날짜의 미션 조회
  Future<List<MissionModel>> getMissionsForDate(String uid, DateTime date) async {
    try {
      final startOfDay = date.startOfDay;
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _collection
          .where('uid', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs.map((doc) => MissionModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw FirestoreException(
        message: '미션을 불러오는데 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 월간 미션 조회 (캘린더용)
  Future<Map<DateTime, List<MissionModel>>> getMonthlyMissions(
    String uid,
    int year,
    int month,
  ) async {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 1);

      final snapshot = await _collection
          .where('uid', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThan: Timestamp.fromDate(endOfMonth))
          .get();

      final missions =
          snapshot.docs.map((doc) => MissionModel.fromFirestore(doc)).toList();

      // 날짜별로 그룹화
      final Map<DateTime, List<MissionModel>> grouped = {};
      for (final mission in missions) {
        final date = mission.date.startOfDay;
        grouped.putIfAbsent(date, () => []).add(mission);
      }

      return grouped;
    } catch (e) {
      throw FirestoreException(
        message: '월간 미션을 불러오는데 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 미션 생성
  Future<MissionModel> createMission(MissionModel mission) async {
    try {
      final docRef = await _collection.add(mission.toFirestore());
      return mission.copyWith(id: docRef.id);
    } catch (e) {
      throw FirestoreException(
        message: '미션 생성에 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 여러 미션 일괄 생성
  Future<void> createMissions(List<MissionModel> missions) async {
    try {
      final batch = _firebaseService.firestore.batch();

      for (final mission in missions) {
        final docRef = _collection.doc();
        batch.set(docRef, mission.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw FirestoreException(
        message: '미션 생성에 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 미션 완료 처리
  Future<void> completeMission(String missionId) async {
    try {
      await _collection.doc(missionId).update({
        'status': MissionStatus.completed.value,
        'is_completed': true,
        'completed_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw FirestoreException(
        message: '미션 완료 처리에 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 미션 스킵 처리
  Future<void> skipMission(String missionId) async {
    try {
      await _collection.doc(missionId).update({
        'status': MissionStatus.skipped.value,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw FirestoreException(
        message: '미션 스킵 처리에 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 미션 삭제
  Future<void> deleteMission(String missionId) async {
    try {
      await _collection.doc(missionId).delete();
    } catch (e) {
      throw FirestoreException(
        message: '미션 삭제에 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 특정 날짜에 완료된 미션이 있는지 확인
  Future<bool> hasCompletedMissionOnDate(String uid, DateTime date) async {
    final missions = await getMissionsForDate(uid, date);
    return missions.any((m) => m.isCompleted);
  }

  /// 모든 미션 완료 여부 확인
  Future<bool> areAllMissionsCompleted(String uid, DateTime date) async {
    final missions = await getMissionsForDate(uid, date);
    if (missions.isEmpty) return false;
    return missions.every((m) => m.isCompleted);
  }
}
