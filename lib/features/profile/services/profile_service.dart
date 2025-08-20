import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

/// 프로필 서비스 클래스
class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 현재 사용자 ID 가져오기
  String? get currentUserId => _auth.currentUser?.uid;

  /// 사용자 프로필 가져오기
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ 프로필 가져오기 실패: $e');
      return null;
    }
  }

  /// 현재 사용자 프로필 가져오기
  Future<UserProfile?> getCurrentUserProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;
    
    return await getUserProfile(userId);
  }

  /// 프로필 생성 또는 업데이트
  Future<bool> createOrUpdateProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.id)
          .set(profile.toMap(), SetOptions(merge: true));
      
      print('✅ 프로필 저장 성공');
      return true;
    } catch (e) {
      print('❌ 프로필 저장 실패: $e');
      return false;
    }
  }

  /// 프로필 이미지 URL 업데이트
  Future<bool> updateProfileImage(String userId, String imageUrl) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'profileImageUrl': imageUrl,
        'updatedAt': Timestamp.now(),
      });
      
      print('✅ 프로필 이미지 업데이트 성공');
      return true;
    } catch (e) {
      print('❌ 프로필 이미지 업데이트 실패: $e');
      return false;
    }
  }

  /// 닉네임 업데이트
  Future<bool> updateNickname(String userId, String nickname) async {
    try {
      // 닉네임 중복 확인
      final existingUser = await _firestore
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .where(FieldPath.documentId, isNotEqualTo: userId)
          .get();
      
      if (existingUser.docs.isNotEmpty) {
        print('❌ 이미 사용 중인 닉네임입니다');
        return false;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'nickname': nickname,
        'updatedAt': Timestamp.now(),
      });
      
      print('✅ 닉네임 업데이트 성공');
      return true;
    } catch (e) {
      print('❌ 닉네임 업데이트 실패: $e');
      return false;
    }
  }

  /// 생년월일 업데이트
  Future<bool> updateBirthDate(String userId, DateTime birthDate) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'birthDate': Timestamp.fromDate(birthDate),
        'updatedAt': Timestamp.now(),
      });
      
      print('✅ 생년월일 업데이트 성공');
      return true;
    } catch (e) {
      print('❌ 생년월일 업데이트 실패: $e');
      return false;
    }
  }

  /// 자기소개 업데이트
  Future<bool> updateBio(String userId, String bio) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'bio': bio,
        'updatedAt': Timestamp.now(),
      });
      
      print('✅ 자기소개 업데이트 성공');
      return true;
    } catch (e) {
      print('❌ 자기소개 업데이트 실패: $e');
      return false;
    }
  }

  /// 감정 프로필 업데이트
  Future<bool> updateEmotionProfile(String userId, EmotionProfile emotionProfile) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'emotionProfile': emotionProfile.toMap(),
        'updatedAt': Timestamp.now(),
      });
      
      print('✅ 감정 프로필 업데이트 성공');
      return true;
    } catch (e) {
      print('❌ 감정 프로필 업데이트 실패: $e');
      return false;
    }
  }

  /// 개인정보 설정 업데이트
  Future<bool> updatePrivacySettings(String userId, PrivacySettings privacySettings) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'privacySettings': privacySettings.toMap(),
        'updatedAt': Timestamp.now(),
      });
      
      print('✅ 개인정보 설정 업데이트 성공');
      return true;
    } catch (e) {
      print('❌ 개인정보 설정 업데이트 실패: $e');
      return false;
    }
  }

  /// 프로필 삭제
  Future<bool> deleteProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      
      print('✅ 프로필 삭제 성공');
      return true;
    } catch (e) {
      print('❌ 프로필 삭제 실패: $e');
      return false;
    }
  }

  /// 사용자 통계 가져오기
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // 일기 수
      final diaryCount = await _firestore
          .collection('diaries')
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      
      // 감정 통계
      final emotionStats = await _firestore
          .collection('diaries')
          .where('userId', isEqualTo: userId)
          .get();
      
      final emotionCounts = <String, int>{};
      for (final doc in emotionStats.docs) {
        final data = doc.data();
        final emotions = List<String>.from(data['emotions'] ?? []);
        for (final emotion in emotions) {
          emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
        }
      }
      
      // 연속 작성 일수
      final continuousDays = await _calculateContinuousDays(userId);
      
      return {
        'totalDiaries': diaryCount.count,
        'emotionCounts': emotionCounts,
        'continuousDays': continuousDays,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ 사용자 통계 가져오기 실패: $e');
      return {};
    }
  }

  /// 연속 작성 일수 계산
  Future<int> _calculateContinuousDays(String userId) async {
    try {
      final diaries = await _firestore
          .collection('diaries')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      if (diaries.docs.isEmpty) return 0;
      
      final dates = diaries.docs
          .map((doc) => (doc.data()['createdAt'] as Timestamp).toDate())
          .map((date) => DateTime(date.year, date.month, date.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));
      
      if (dates.isEmpty) return 0;
      
      int continuousDays = 1;
      final today = DateTime.now();
      final yesterday = DateTime(today.year, today.month, today.day - 1);
      
      // 오늘 일기가 없으면 0일
      if (dates.first != DateTime(today.year, today.month, today.day)) {
        return 0;
      }
      
      // 연속 일수 계산
      for (int i = 0; i < dates.length - 1; i++) {
        final current = dates[i];
        final next = dates[i + 1];
        
        if (current.difference(next).inDays == 1) {
          continuousDays++;
        } else {
          break;
        }
      }
      
      return continuousDays;
    } catch (e) {
      print('❌ 연속 작성 일수 계산 실패: $e');
      return 0;
    }
  }

  /// 프로필 스트림 구독
  Stream<UserProfile?> profileStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  /// 현재 사용자 프로필 스트림
  Stream<UserProfile?> get currentUserProfileStream {
    final userId = currentUserId;
    if (userId == null) return Stream.value(null);
    
    return profileStream(userId);
  }
}
