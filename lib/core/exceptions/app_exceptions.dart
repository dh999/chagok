class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class AuthException extends AppException {
  AuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class NetworkException extends AppException {
  NetworkException({
    super.message = '인터넷 연결을 확인해주세요.',
    super.code = 'NETWORK_ERROR',
    super.originalError,
  });
}

class FirestoreException extends AppException {
  FirestoreException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class AIException extends AppException {
  AIException({
    super.message = 'AI 응답에 문제가 발생했습니다.',
    super.code = 'AI_ERROR',
    super.originalError,
  });
}

class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.originalError,
  });
}
