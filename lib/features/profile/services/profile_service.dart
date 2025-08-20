import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 현재 사용자 프로필 가져오기
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      } else {
        // 프로필이 없으면 기본 프로필 생성
        final defaultProfile = UserProfile.createDefault(
          id: user.uid,
          email: user.email ?? '',
          nickname: user.displayName,
        );
        await createOrUpdateProfile(defaultProfile);
        return defaultProfile;
      }
    } catch (e) {
      print('❌ 프로필 가져오기 실패: $e');
      return null;
    }
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

  /// 프로필 이미지 업로드
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final ref = _storage.ref().child('profile_images/$userId.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ 프로필 이미지 업로드 성공');
      return downloadUrl;
    } catch (e) {
      print('❌ 프로필 이미지 업로드 실패: $e');
      return null;
    }
  }

  /// 프로필 이미지 삭제
  Future<bool> deleteProfileImage(String userId) async {
    try {
      final ref = _storage.ref().child('profile_images/$userId.jpg');
      await ref.delete();
      
      print('✅ 프로필 이미지 삭제 성공');
      return true;
    } catch (e) {
      print('❌ 프로필 이미지 삭제 실패: $e');
      return false;
    }
  }

  /// 사용자 통계 가져오기
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // 일기 개수
      final diarySnapshot = await _firestore
          .collection('diaries')
          .where('userId', isEqualTo: userId)
          .get();
      
      final diaryCount = diarySnapshot.docs.length;

      // 감정 기록 개수
      final emotionSnapshot = await _firestore
          .collection('emotions')
          .where('userId', isEqualTo: userId)
          .get();
      
      final emotionCount = emotionSnapshot.docs.length;

      // 연속 기록 일수 (간단한 구현)
      final continuousDays = await _calculateContinuousDays(userId);

      return {
        'diaryCount': diaryCount,
        'emotionCount': emotionCount,
        'continuousDays': continuousDays,
      };
    } catch (e) {
      print('❌ 사용자 통계 가져오기 실패: $e');
      return {
        'diaryCount': 0,
        'emotionCount': 0,
        'continuousDays': 0,
      };
    }
  }

  /// 연속 기록 일수 계산
  Future<int> _calculateContinuousDays(String userId) async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      
      final recentDiaries = await _firestore
          .collection('diaries')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: sevenDaysAgo)
          .orderBy('createdAt', descending: true)
          .get();

      if (recentDiaries.docs.isEmpty) return 0;

      int continuousDays = 0;
      DateTime currentDate = now;
      
      for (int i = 0; i < 7; i++) {
        final checkDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
        final hasDiaryOnDate = recentDiaries.docs.any((doc) {
          final diaryDate = (doc.data()['createdAt'] as Timestamp).toDate();
          final diaryDay = DateTime(diaryDate.year, diaryDate.month, diaryDate.day);
          return diaryDay.isAtSameMomentAs(checkDate);
        });

        if (hasDiaryOnDate) {
          continuousDays++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      return continuousDays;
    } catch (e) {
      print('❌ 연속 기록 일수 계산 실패: $e');
      return 0;
    }
  }

  /// 프로필 삭제
  Future<bool> deleteProfile(String userId) async {
    try {
      // 프로필 이미지 삭제
      await deleteProfileImage(userId);
      
      // 프로필 문서 삭제
      await _firestore
          .collection('users')
          .doc(userId)
          .delete();
      
      print('✅ 프로필 삭제 성공');
      return true;
    } catch (e) {
      print('❌ 프로필 삭제 실패: $e');
      return false;
    }
  }
}
