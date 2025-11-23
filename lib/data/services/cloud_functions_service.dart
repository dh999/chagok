import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionsService {
  static final CloudFunctionsService _instance = CloudFunctionsService._internal();
  factory CloudFunctionsService() => _instance;
  CloudFunctionsService._internal();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// AI 토끼와 대화
  Future<Map<String, dynamic>> chatWithRabbit({
    required String sessionId,
    required String message,
    required List<Map<String, dynamic>> history,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        'chatWithRabbit',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 60),
        ),
      );

      final result = await callable.call({
        'sessionId': sessionId,
        'message': message,
        'history': history,
      });

      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      throw Exception('AI 응답 오류: ${e.message}');
    }
  }

  /// 일일 미션 수동 생성 요청
  Future<List<Map<String, dynamic>>> requestDailyMissions({
    required String uid,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        'generateMissionsForUser',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 30),
        ),
      );

      final result = await callable.call({'uid': uid});
      return List<Map<String, dynamic>>.from(result.data['missions']);
    } on FirebaseFunctionsException catch (e) {
      throw Exception('미션 생성 오류: ${e.message}');
    }
  }
}
