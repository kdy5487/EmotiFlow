import 'package:flutter/foundation.dart';

/// 홈 화면 상태와 로직을 관리하는 ViewModel
class HomeViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// 초기 데이터 로드 (예: 오늘의 감정, 최근 일기 등)
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // TODO: 필요한 초기 데이터 로드 구현
    } catch (e) {
      _setError('초기화 중 오류가 발생했어요: $e');
    } finally {
      _setLoading(false);
    }
  }
}


