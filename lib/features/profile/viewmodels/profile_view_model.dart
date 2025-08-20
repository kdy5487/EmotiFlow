import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';

/// 프로필 페이지의 ViewModel
/// UI 로직과 비즈니스 로직을 분리하여 관리
class ProfileViewModel extends ChangeNotifier {
  final WidgetRef ref;
  
  ProfileViewModel(this.ref);

  /// 현재 사용자 프로필 가져오기
  UserProfile? get currentProfile => ref.read(profileProvider).profile;
  
  /// 로딩 상태
  bool get isLoading => ref.read(profileProvider).isLoading;
  
  /// 에러 상태
  String? get error => ref.read(profileProvider).error;
  
  /// 사용자 통계
  Map<String, dynamic>? get userStats => ref.read(profileProvider).stats;

  /// 프로필 새로고침
  Future<void> refreshProfile() async {
    await ref.read(profileProvider.notifier).refreshProfile();
  }

  /// 프로필 업데이트
  Future<void> updateProfile(UserProfile updatedProfile) async {
    await ref.read(profileProvider.notifier).updateProfile(updatedProfile);
  }

  /// 닉네임 업데이트
  Future<void> updateNickname(String newNickname) async {
    await ref.read(profileProvider.notifier).updateNickname(newNickname);
  }

  /// 생년월일 업데이트
  Future<void> updateBirthDate(DateTime? newBirthDate) async {
    if (newBirthDate != null) {
      await ref.read(profileProvider.notifier).updateBirthDate(newBirthDate);
    }
  }

  /// 자기소개 업데이트
  Future<void> updateBio(String? newBio) async {
    if (newBio != null) {
      await ref.read(profileProvider.notifier).updateBio(newBio);
    }
  }

  /// 프로필 이미지 업데이트
  Future<void> updateProfileImage(String? newImageUrl) async {
    if (newImageUrl != null) {
      await ref.read(profileProvider.notifier).updateProfileImage(newImageUrl);
    }
  }

  /// 감정 프로필 업데이트
  Future<void> updateEmotionProfile(EmotionProfile newEmotionProfile) async {
    await ref.read(profileProvider.notifier).updateEmotionProfile(newEmotionProfile);
  }

  /// 개인정보 설정 업데이트
  Future<void> updatePrivacySettings(PrivacySettings newPrivacySettings) async {
    await ref.read(profileProvider.notifier).updatePrivacySettings(newPrivacySettings);
  }

  /// 프로필 삭제
  Future<void> deleteProfile() async {
    await ref.read(profileProvider.notifier).deleteProfile();
  }

  /// 연속 일수 계산
  int calculateContinuousDays(List<DateTime> diaryDates) {
    if (diaryDates.isEmpty) return 0;
    
    final sortedDates = diaryDates.toList()..sort((a, b) => b.compareTo(a));
    int continuousDays = 1;
    
    for (int i = 1; i < sortedDates.length; i++) {
      final currentDate = sortedDates[i];
      final previousDate = sortedDates[i - 1];
      
      if (previousDate.difference(currentDate).inDays == 1) {
        continuousDays++;
      } else {
        break;
      }
    }
    
    return continuousDays;
  }

  /// 감정 통계 계산
  Map<String, int> calculateEmotionStats(List<String> emotions) {
    final Map<String, int> emotionCounts = {};
    
    for (final emotion in emotions) {
      emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
    }
    
    return emotionCounts;
  }

  /// 나이 계산
  int? calculateAge(DateTime? birthDate) {
    if (birthDate == null) return null;
    
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }
}
