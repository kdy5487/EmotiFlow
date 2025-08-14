import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// 인증 상태 관리 클래스
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  /// 현재 사용자
  User? get user => _user;
  
  /// 로딩 상태
  bool get isLoading => _isLoading;
  
  /// 에러 메시지
  String? get error => _error;
  
  /// 로그인 상태
  bool get isLoggedIn => _user != null;
  
  /// 사용자 이메일
  String? get userEmail => _user?.email;
  
  /// 사용자 이름
  String? get userName => _user?.displayName;
  
  /// 사용자 프로필 사진
  String? get userPhoto => _user?.photoURL;
  
  /// 초기화
  AuthProvider() {
    _init();
  }
  
  /// 초기화 및 자동 로그인 체크
  void _init() {
    _user = _authService.currentUser;
    
    // 앱 시작 시 자동 로그인 체크
    _checkAutoLogin();
    
    // 인증 상태 변화 감지
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _error = null;
      notifyListeners();
    });
  }
  
  /// 자동 로그인 체크
  Future<void> _checkAutoLogin() async {
    _setLoading(true);
    
    try {
      final isAutoLoggedIn = await _authService.checkAutoLogin();
      
      if (isAutoLoggedIn) {
        _user = _authService.currentUser;
        print('✅ 자동 로그인 성공');
      } else {
        _user = null;
        print('❌ 자동 로그인 실패 - 수동 로그인 필요');
      }
    } catch (e) {
      print('❌ 자동 로그인 체크 중 오류: $e');
      _user = null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// 에러 설정
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  /// Google 로그인
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);
      
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential != null) {
        _user = userCredential.user;
        _setLoading(false);
        return true;
      } else {
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Google 로그인에 실패했습니다: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // 이메일/비밀번호 로그인 기능 제거 - Google 로그인만 사용
  
  /// 로그아웃
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _user = null;
      _setLoading(false);
    } catch (e) {
      _setError('로그아웃에 실패했습니다: $e');
      _setLoading(false);
    }
  }
  
  // 비밀번호 재설정 기능 제거 - Google 로그인만 사용
  
  /// 사용자 프로필 업데이트
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      
      // 로컬 상태 업데이트는 Firebase Auth에서 자동으로 처리됨
      // _user는 authStateChanges 스트림에서 자동 업데이트됨
      
      _setLoading(false);
      notifyListeners();
      return true;
      
    } catch (e) {
      _setError('프로필 업데이트에 실패했습니다: $e');
      _setLoading(false);
      return false;
    }
  }
  
  /// 에러 초기화
  void clearError() {
    _setError(null);
  }
}
