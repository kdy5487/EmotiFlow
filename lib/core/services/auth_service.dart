import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Google 로그인 중심의 인증 서비스 클래스
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    // 서버 클라이언트 ID를 환경 변수에서 가져오기
    serverClientId: dotenv.env['WEB_OAUTH_CLIENT_ID'] ?? '',
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 현재 사용자
  User? get currentUser => _auth.currentUser;

  /// 사용자 상태 변화 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 로그인 상태
  bool get isLoggedIn => currentUser != null;

  /// 자동 로그인 체크 (앱 시작 시)
  Future<bool> checkAutoLogin() async {
    try {
      print('🔍 자동 로그인 상태 확인 중...');

      // Firebase Auth 현재 사용자 확인
      final firebaseUser = _auth.currentUser;

      if (firebaseUser == null) {
        print('❌ Firebase에 로그인된 사용자 없음');
        return false;
      }

      print('✅ Firebase 사용자 확인: ${firebaseUser.email}');

      // Google 로그인 상태도 확인
      final isGoogleSignedIn = await _googleSignIn.isSignedIn();
      final googleUser = _googleSignIn.currentUser;

      if (isGoogleSignedIn && googleUser != null) {
        print('✅ Google 로그인 상태도 유지됨: ${googleUser.email}');

        // 사용자 정보 업데이트 (최신 상태 유지)
        await _saveUserToFirestore(firebaseUser);

        print('✅ 자동 로그인 성공!');
        return true;
      } else {
        print('ℹ️ Google 세션이 캐시되어 있지 않아 자동 복원을 시도합니다.');

        // Firebase만 로그인된 상태라면 Google 로그인도 연동 시도
        try {
          await _googleSignIn.signInSilently();
          print('✅ Google 자동 로그인 복원 성공');
          return true;
        } catch (e) {
          print('❌ Google 자동 로그인 복원 실패: $e');
          // Firebase 로그아웃도 진행
          await _auth.signOut();
          return false;
        }
      }
    } catch (e) {
      print('❌ 자동 로그인 체크 실패: $e');
      return false;
    }
  }

  /// Google 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔍 Google 로그인 시작...');

      // 기존 Google 로그인 상태 확인
      final isSignedIn = await _googleSignIn.isSignedIn();
      if (isSignedIn) {
        print('🔍 기존 Google 세션 정리 중...');
        await _googleSignIn.signOut();
      }

      // Google 로그인 진행
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ Google 로그인이 사용자에 의해 취소되었습니다.');
        return null;
      }

      print('✅ Google 계정 선택 완료: ${googleUser.email}');

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Google 인증 토큰을 가져올 수 없습니다.');
      }

      print('✅ Google 인증 토큰 획득 완료');

      // Firebase 인증 정보 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Firebase 로그인에 실패했습니다.');
      }

      print('✅ Firebase 로그인 완료: ${userCredential.user!.email}');

      // 사용자 정보를 Firestore에 저장
      await _saveUserToFirestore(userCredential.user!);

      print('✅ Google 로그인 전체 과정 완료!');
      return userCredential;
    } catch (e) {
      print('❌ Google 로그인 실패: $e');

      // 자세한 에러 정보 출력
      if (e.toString().contains('ApiException: 10')) {
        print('🔍 Google 로그인 설정 문제:');
        print('   - Firebase Console에 SHA-1 핑거프린트 추가 필요');
        print(
            '   - SHA-1: 94:36:12:14:62:C9:0A:98:38:B9:A4:E4:66:2F:F7:3F:65:F0:E1:D3');
        print('   - Google Cloud Console에서 OAuth 2.0 클라이언트 ID 설정 필요');
      }

      // 실패 시 Google 로그인 상태 정리
      try {
        await _googleSignIn.signOut();
      } catch (signOutError) {
        print('⚠️ Google 로그아웃 정리 실패: $signOutError');
      }

      rethrow;
    }
  }

  // 이메일/비밀번호 로그인 기능 제거 - Google 로그인만 사용

  /// 완전 로그아웃 (Google + Firebase)
  Future<void> signOut() async {
    try {
      print('🔍 로그아웃 시작...');

      // Google 로그인 상태 확인
      final isGoogleSignedIn = await _googleSignIn.isSignedIn();

      if (isGoogleSignedIn) {
        print('🔍 Google 로그아웃 진행 중...');
        await _googleSignIn.signOut();
        print('✅ Google 로그아웃 완료');
      }

      // Firebase 로그아웃
      print('🔍 Firebase 로그아웃 진행 중...');
      await _auth.signOut();
      print('✅ Firebase 로그아웃 완료');

      print('✅ 전체 로그아웃 성공!');
    } catch (e) {
      print('❌ 로그아웃 실패: $e');

      // 부분적으로라도 로그아웃 시도
      try {
        await _auth.signOut();
        print('⚠️ Firebase 로그아웃은 완료됨');
      } catch (firebaseError) {
        print('❌ Firebase 로그아웃도 실패: $firebaseError');
      }

      rethrow;
    }
  }

  // 비밀번호 재설정 기능 제거 - Google 로그인만 사용

  /// 사용자 정보를 Firestore에 저장
  Future<void> _saveUserToFirestore(User user) async {
    try {
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '사용자',
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isEmailVerified': user.emailVerified,
        'providerId': user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'email',
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      print('✅ 사용자 정보 Firestore 저장 성공');
    } catch (e) {
      print('❌ 사용자 정보 Firestore 저장 실패: $e');
    }
  }

  /// 사용자 정보 업데이트
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (currentUser != null) {
        if (displayName != null) {
          await currentUser!.updateDisplayName(displayName);
        }
        if (photoURL != null) {
          await currentUser!.updatePhotoURL(photoURL);
        }

        // Firestore도 업데이트
        await _firestore.collection('users').doc(currentUser!.uid).update({
          if (displayName != null) 'displayName': displayName,
          if (photoURL != null) 'photoURL': photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('✅ 사용자 프로필 업데이트 성공');
      }
    } catch (e) {
      print('❌ 사용자 프로필 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ 사용자 정보 가져오기 실패: $e');
      return null;
    }
  }

  /// 계정 삭제
  Future<void> deleteAccount() async {
    try {
      if (currentUser != null) {
        // Firestore에서 사용자 데이터 삭제
        await _firestore.collection('users').doc(currentUser!.uid).delete();

        // Firebase Auth에서 계정 삭제
        await currentUser!.delete();

        print('✅ 계정 삭제 성공');
      }
    } catch (e) {
      print('❌ 계정 삭제 실패: $e');
      rethrow;
    }
  }
}
