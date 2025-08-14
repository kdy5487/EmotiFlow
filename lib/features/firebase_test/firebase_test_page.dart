import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoti_flow/core/services/firebase_service.dart';

/// Firebase 연결 테스트 페이지
class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({super.key});

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  final FirebaseService _firebaseService = FirebaseService.instance;
  String _status = '테스트 대기 중...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
  }

  /// Firebase 연결 테스트
  Future<void> _testFirebaseConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Firebase 연결 테스트 중...';
    });

    try {
      // Firebase 서비스 초기화
      await _firebaseService.initialize();
      
      // Firestore 연결 테스트
      await _testFirestore();
      
      // Auth 상태 확인
      await _testAuth();
      
      setState(() {
        _status = '✅ 모든 Firebase 서비스 연결 성공!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Firebase 연결 실패: $e';
        _isLoading = false;
      });
    }
  }

  /// Firestore 연결 테스트
  Future<void> _testFirestore() async {
    try {
      // 간단한 읽기 테스트
      await _firebaseService.firestore
          .collection('test')
          .doc('connection')
          .get();
      
      print('✅ Firestore 연결 성공');
    } catch (e) {
      print('❌ Firestore 연결 실패: $e');
      rethrow;
    }
  }

  /// Auth 상태 테스트
  Future<void> _testAuth() async {
    try {
      final currentUser = _firebaseService.currentUser;
      print('✅ Auth 상태 확인 성공: ${currentUser?.uid ?? '로그인되지 않음'}');
    } catch (e) {
      print('❌ Auth 상태 확인 실패: $e');
      rethrow;
    }
  }

  /// 테스트 데이터 생성
  Future<void> _createTestData() async {
    setState(() {
      _isLoading = true;
      _status = '테스트 데이터 생성 중...';
    });

    try {
      await _firebaseService.firestore
          .collection('test')
          .doc('connection')
          .set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Firebase 연결 테스트 성공!',
        'platform': 'Android',
      });

      setState(() {
        _status = '✅ 테스트 데이터 생성 성공!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ 테스트 데이터 생성 실패: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase 연결 테스트'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상태 표시
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '연결 상태',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        fontSize: 16,
                        color: _status.contains('성공') 
                            ? Colors.green 
                            : _status.contains('실패') 
                                ? Colors.red 
                                : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 테스트 버튼들
            ElevatedButton(
              onPressed: _isLoading ? null : _testFirebaseConnection,
              child: const Text('연결 재테스트'),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _createTestData,
              child: const Text('테스트 데이터 생성'),
            ),
            
            const SizedBox(height: 16),
            
            // Firebase 정보 표시
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firebase 프로젝트 정보',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('프로젝트 ID: emotiflow-b1ef1'),
                    Text('앱 ID: 1:671101750738:android:b02c9cb5a465f450b8cc0b'),
                    Text('메시징 ID: 671101750738'),
                    Text('스토리지 버킷: emotiflow-b1ef1.firebasestorage.app'),
                  ],
                ),
              ),
            ),
            
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
