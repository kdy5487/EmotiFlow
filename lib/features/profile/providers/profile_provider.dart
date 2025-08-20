import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  /// 닉네임 업데이트
  Future<bool> updateNickname(String nickname) async {
    final profile = state.profile;
    if (profile == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _profileService.updateNickname(profile.id, nickname);
      
      if (success) {
        final updatedProfile = profile.copyWith(nickname: nickname);
        state = state.copyWith(profile: updatedProfile);
        return true;
      } else {
        state = state.copyWith(error: '이미 사용 중인 닉네임입니다');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '닉네임 업데이트 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 생년월일 업데이트
  Future<bool> updateBirthDate(DateTime birthDate) async {
    final profile = state.profile;
    if (profile == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _profileService.updateBirthDate(profile.id, birthDate);
      
      if (success) {
        final updatedProfile = profile.copyWith(birthDate: birthDate);
        state = state.copyWith(profile: updatedProfile);
        return true;
      } else {
        state = state.copyWith(error: '생년월일 업데이트 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '생년월일 업데이트 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 자기소개 업데이트
  Future<bool> updateBio(String bio) async {
    final profile = state.profile;
    if (profile == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _profileService.updateBio(profile.id, bio);
      
      if (success) {
        final updatedProfile = profile.copyWith(bio: bio);
        state = state.copyWith(profile: updatedProfile);
        return true;
      } else {
        state = state.copyWith(error: '자기소개 업데이트 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '자기소개 업데이트 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 프로필 이미지 업데이트
  Future<bool> updateProfileImage(String imageUrl) async {
    final profile = state.profile;
    if (profile == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _profileService.updateProfileImage(profile.id, imageUrl);
      
      if (success) {
        final updatedProfile = profile.copyWith(profileImageUrl: imageUrl);
        state = state.copyWith(profile: updatedProfile);
        return true;
      } else {
        state = state.copyWith(error: '프로필 이미지 업데이트 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '프로필 이미지 업데이트 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 감정 프로필 업데이트
  Future<bool> updateEmotionProfile(EmotionProfile emotionProfile) async {
    final profile = state.profile;
    if (profile == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _profileService.updateEmotionProfile(profile.id, emotionProfile);
      
      if (success) {
        final updatedProfile = profile.copyWith(emotionProfile: emotionProfile);
        state = state.copyWith(profile: updatedProfile);
        return true;
      } else {
        state = state.copyWith(error: '감정 프로필 업데이트 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '감정 프로필 업데이트 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 개인정보 설정 업데이트
  Future<bool> updatePrivacySettings(PrivacySettings privacySettings) async {
    final profile = state.profile;
    if (profile == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _profileService.updatePrivacySettings(profile.id, privacySettings);
      
      if (success) {
        final updatedProfile = profile.copyWith(privacySettings: privacySettings);
        state = state.copyWith(profile: updatedProfile);
        return true;
      } else {
        state = state.copyWith(error: '개인정보 설정 업데이트 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '개인정보 설정 업데이트 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 프로필 삭제
  Future<bool> deleteProfile() async {
    final profile = state.profile;
    if (profile == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _profileService.deleteProfile(profile.id);
      
      if (success) {
        state = const ProfileState();
        return true;
      } else {
        state = state.copyWith(error: '프로필 삭제 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '프로필 삭제 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 로딩 상태 설정
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
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
