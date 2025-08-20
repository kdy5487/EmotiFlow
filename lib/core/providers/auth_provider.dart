import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// 인증 상태를 관리하는 클래스
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 인증 상태 관리 클래스
class AuthProvider extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService.instance;
  
  /// 초기화
  AuthProvider() : super(const AuthState()) {
    _init();
  }
  
  /// 현재 사용자
  User? get user => state.user;
  
  /// 로딩 상태
  bool get isLoading => state.isLoading;
  
  /// 에러 메시지
  String? get error => state.error;
  
  /// 로그인 상태
  bool get isLoggedIn => state.user != null;
  
  /// 사용자 이메일
  String? get userEmail => state.user?.email;
  
  /// 사용자 이름
  String? get userName => state.user?.displayName;
  
  /// 사용자 프로필 사진
  String? get userPhoto => state.user?.photoURL;
  
  /// 초기화 및 자동 로그인 체크
  void _init() {
    state = state.copyWith(user: _authService.currentUser);
    
    // 앱 시작 시 자동 로그인 체크
    _checkAutoLogin();
    
    // 인증 상태 변화 감지
    _authService.authStateChanges.listen((User? user) {
      state = state.copyWith(user: user, error: null);
    });
  }
  
  /// 자동 로그인 체크
  Future<void> _checkAutoLogin() async {
    _setLoading(true);
    
    try {
      final isAutoLoggedIn = await _authService.checkAutoLogin();
      
      if (isAutoLoggedIn) {
        final currentUser = _authService.currentUser;
        state = state.copyWith(user: currentUser);
        print('✅ 자동 로그인 성공');
      } else {
        state = state.copyWith(user: null);
        print('❌ 자동 로그인 실패 - 수동 로그인 필요');
      }
    } catch (e) {
      print('❌ 자동 로그인 체크 중 오류: $e');
      state = state.copyWith(user: null);
    } finally {
      _setLoading(false);
    }
  }
  
  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
  
  /// 에러 설정
  void _setError(String? error) {
    state = state.copyWith(error: error);
  }
  
  /// Google 로그인
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);
      
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential != null) {
        state = state.copyWith(user: userCredential.user);
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
      state = state.copyWith(user: null);
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
      // user는 authStateChanges 스트림에서 자동 업데이트됨
      
      _setLoading(false);
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

/// AuthProvider를 위한 Riverpod provider
final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  return AuthProvider();
});
