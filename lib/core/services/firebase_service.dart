import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Firebase 서비스들을 초기화하고 관리하는 클래스
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  
  FirebaseService._();
  
  // Firebase 서비스 인스턴스들
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late FirebaseStorage _storage;
  late FirebaseMessaging _messaging;
  
  /// Firebase 서비스들 초기화
  Future<void> initialize() async {
    try {
      // Firebase Core는 main.dart에서 이미 초기화됨
      // 각 서비스 인스턴스만 가져오기
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _messaging = FirebaseMessaging.instance;
      
      print('✅ Firebase 서비스 초기화 완료');
    } catch (e) {
      print('❌ Firebase 서비스 초기화 실패: $e');
      rethrow;
    }
  }
  
  /// Firebase Auth 인스턴스
  FirebaseAuth get auth => _auth;
  
  /// Firestore 인스턴스
  FirebaseFirestore get firestore => _firestore;
  
  /// Firebase Storage 인스턴스
  FirebaseStorage get storage => _storage;
  
  /// Firebase Messaging 인스턴스
  FirebaseMessaging get messaging => _messaging;
  
  /// 현재 사용자 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// 현재 로그인된 사용자
  User? get currentUser => _auth.currentUser;
  
  /// 사용자가 로그인되어 있는지 확인
  bool get isLoggedIn => currentUser != null;
}
