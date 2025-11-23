import 'dart:async';
import 'dart:io';

/// 네트워크 연결 상태 관리 서비스
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Timer? _checkTimer;

  /// 초기화 및 연결 상태 체크 시작
  void startMonitoring() {
    _checkConnectivity();
    _checkTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnectivity(),
    );
  }

  /// 모니터링 중지
  void stopMonitoring() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  /// 연결 상태 체크
  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _updateConnectivity(connected);
    } on SocketException catch (_) {
      _updateConnectivity(false);
    }
  }

  /// 연결 상태 업데이트
  void _updateConnectivity(bool connected) {
    if (_isConnected != connected) {
      _isConnected = connected;
      _connectivityController.add(connected);
    }
  }

  /// 수동으로 연결 상태 체크
  Future<bool> checkNow() async {
    await _checkConnectivity();
    return _isConnected;
  }

  void dispose() {
    stopMonitoring();
    _connectivityController.close();
  }
}
