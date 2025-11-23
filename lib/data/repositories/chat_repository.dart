import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_session_model.dart';
import '../models/chat_message_model.dart';
import '../services/firebase_service.dart';
import '../services/cloud_functions_service.dart';
import '../../core/exceptions/app_exceptions.dart';

class ChatRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final CloudFunctionsService _functionsService = CloudFunctionsService();

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firebaseService.chatSessionsCollection;

  /// 새 세션 생성
  Future<ChatSessionModel> createSession({
    required String uid,
    SessionType sessionType = SessionType.onboarding,
  }) async {
    try {
      final session = ChatSessionModel.create(
        uid: uid,
        sessionType: sessionType,
      );

      final docRef = await _collection.add(session.toFirestore());
      return session.copyWith(id: docRef.id);
    } catch (e) {
      throw FirestoreException(
        message: '채팅 세션 생성에 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 세션 조회
  Future<ChatSessionModel?> getSession(String sessionId) async {
    try {
      final doc = await _collection.doc(sessionId).get();
      if (!doc.exists) return null;
      return ChatSessionModel.fromFirestore(doc);
    } catch (e) {
      throw FirestoreException(
        message: '채팅 세션을 불러오는데 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 진행 중인 온보딩 세션 조회
  Future<ChatSessionModel?> getActiveOnboardingSession(String uid) async {
    try {
      final snapshot = await _collection
          .where('uid', isEqualTo: uid)
          .where('session_type', isEqualTo: SessionType.onboarding.value)
          .where('closed_at', isNull: true)
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return ChatSessionModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw FirestoreException(
        message: '채팅 세션을 불러오는데 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 메시지 전송 및 AI 응답 받기
  Future<ChatMessageModel> sendMessage({
    required String sessionId,
    required String message,
    required List<ChatMessageModel> history,
  }) async {
    try {
      // 사용자 메시지 저장
      final userMessage = ChatMessageModel.user(message);
      await _addMessage(sessionId, userMessage);

      // AI 응답 요청
      final response = await _functionsService.chatWithRabbit(
        sessionId: sessionId,
        message: message,
        history: history.map((m) => m.toMap()).toList(),
      );

      // AI 응답 저장
      final aiReply = response['reply'] as String;
      final assistantMessage = ChatMessageModel.assistant(aiReply);
      await _addMessage(sessionId, assistantMessage);

      // JSON 파싱 결과가 있으면 저장
      if (response['parsedAction'] != null) {
        await _updateResultJson(
          sessionId,
          response['parsedAction'] as Map<String, dynamic>,
        );
      }

      return assistantMessage;
    } on AIException {
      rethrow;
    } catch (e) {
      throw AIException(
        message: '메시지 전송에 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 메시지 추가 (내부용)
  Future<void> _addMessage(String sessionId, ChatMessageModel message) async {
    await _collection.doc(sessionId).update({
      'messages': FieldValue.arrayUnion([message.toMap()]),
    });
  }

  /// 결과 JSON 업데이트
  Future<void> _updateResultJson(
    String sessionId,
    Map<String, dynamic> resultJson,
  ) async {
    await _collection.doc(sessionId).update({
      'result_json': resultJson,
    });
  }

  /// 세션 종료
  Future<void> closeSession(String sessionId) async {
    try {
      await _collection.doc(sessionId).update({
        'closed_at': Timestamp.now(),
      });
    } catch (e) {
      throw FirestoreException(
        message: '채팅 세션 종료에 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 세션 스트림
  Stream<ChatSessionModel?> watchSession(String sessionId) {
    return _collection.doc(sessionId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ChatSessionModel.fromFirestore(doc);
    });
  }
}
