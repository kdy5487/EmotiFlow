import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

/// 프로필 상태 클래스
class ProfileState {
  final UserProfile? profile;
  final Map<String, dynamic>? stats;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.profile,
    this.stats,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    UserProfile? profile,
    Map<String, dynamic>? stats,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 프로필 관리 클래스
class ProfileProvider extends StateNotifier<ProfileState> {
  final ProfileService _profileService = ProfileService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  ProfileProvider() : super(const ProfileState()) {
    _init();
  }

  /// 초기화
  void _init() {
    _loadCurrentUserProfile();
  }

  /// 현재 사용자 프로필 로드
  Future<void> _loadCurrentUserProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        state = state.copyWith(
          profile: null,
          stats: null,
          isLoading: false,
        );
        return;
      }

      final profile = await _profileService.getCurrentUserProfile();
      if (profile != null) {
        state = state.copyWith(profile: profile);
        await _loadUserStats(profile.id);
      }
    } catch (e) {
      state = state.copyWith(error: '프로필 로드 실패: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 사용자 통계 로드
  Future<void> _loadUserStats(String userId) async {
    try {
      final stats = await _profileService.getUserStats(userId);
      state = state.copyWith(stats: stats);
    } catch (e) {
      print('❌ 사용자 통계 로드 실패: $e');
    }
  }

  /// 프로필 새로고침
  Future<void> refreshProfile() async {
    await _loadCurrentUserProfile();
  }

  /// 프로필 업데이트
  Future<bool> updateProfile(UserProfile updatedProfile) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _profileService.createOrUpdateProfile(updatedProfile);
      
      if (success) {
        state = state.copyWith(profile: updatedProfile);
        await _loadUserStats(updatedProfile.id);
        return true;
      } else {
        state = state.copyWith(error: '프로필 업데이트 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '프로필 업데이트 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 프로필 이미지 업로드
  Future<String?> uploadProfileImage(String imagePath) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final imageUrl = await _profileService.uploadProfileImage(
        File(imagePath),
        user.uid,
      );

      if (imageUrl != null) {
        final updatedProfile = state.profile?.copyWith(
          profileImageUrl: imageUrl,
          updatedAt: DateTime.now(),
        );
        
        if (updatedProfile != null) {
          await updateProfile(updatedProfile);
        }
      }

      return imageUrl;
    } catch (e) {
      print('❌ 프로필 이미지 업로드 실패: $e');
      return null;
    }
  }

  /// 프로필 이미지 삭제
  Future<bool> deleteProfileImage() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final success = await _profileService.deleteProfileImage(user.uid);
      
      if (success) {
        final updatedProfile = state.profile?.copyWith(
          profileImageUrl: null,
          updatedAt: DateTime.now(),
        );
        
        if (updatedProfile != null) {
          await updateProfile(updatedProfile);
        }
      }

      return success;
    } catch (e) {
      print('❌ 프로필 이미지 삭제 실패: $e');
      return false;
    }
  }

  /// 프로필 삭제
  Future<bool> deleteProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final success = await _profileService.deleteProfile(user.uid);
      
      if (success) {
        state = state.copyWith(
          profile: null,
          stats: null,
        );
      }

      return success;
    } catch (e) {
      print('❌ 프로필 삭제 실패: $e');
      return false;
    }
  }

  /// 사용자 로그아웃
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      state = state.copyWith(
        profile: null,
        stats: null,
      );
    } catch (e) {
      print('❌ 로그아웃 실패: $e');
    }
  }

  /// 사용자 계정 삭제
  Future<bool> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // 프로필 삭제
      await deleteProfile();
      
      // Firebase Auth 계정 삭제
      await user.delete();
      
      state = state.copyWith(
        profile: null,
        stats: null,
      );

      return true;
    } catch (e) {
      print('❌ 계정 삭제 실패: $e');
      return false;
    }
  }
}

/// ProfileProvider를 위한 Riverpod provider
final profileProvider = StateNotifierProvider<ProfileProvider, ProfileState>((ref) {
  return ProfileProvider();
});

/// 현재 사용자 프로필만 가져오는 provider
final currentUserProfileProvider = Provider<UserProfile?>((ref) {
  return ref.watch(profileProvider).profile;
});

/// 사용자 통계만 가져오는 provider
final userStatsProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(profileProvider).stats;
});

/// 프로필 로딩 상태 provider
final profileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).isLoading;
});

/// 프로필 에러 provider
final profileErrorProvider = Provider<String?>((ref) {
  return ref.watch(profileProvider).error;
});
