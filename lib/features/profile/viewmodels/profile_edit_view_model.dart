import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_provider.dart';

/// 프로필 편집 페이지의 ViewModel
/// UI 로직과 비즈니스 로직을 분리하여 관리
class ProfileEditViewModel extends ChangeNotifier {
  final WidgetRef ref;
  final ImagePicker _imagePicker = ImagePicker();
  
  ProfileEditViewModel(this.ref);

  // 상태 변수들
  String _nickname = '';
  String _bio = '';
  DateTime? _selectedBirthDate;
  String? _selectedImagePath;
  bool _isLoading = false;
  String? _error;

  // Getters
  String get nickname => _nickname;
  String get bio => _bio;
  DateTime? get selectedBirthDate => _selectedBirthDate;
  String? get selectedImagePath => _selectedImagePath;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Setters
  set nickname(String value) {
    _nickname = value;
    notifyListeners();
  }

  set bio(String value) {
    _bio = value;
    notifyListeners();
  }

  set selectedBirthDate(DateTime? value) {
    _selectedBirthDate = value;
    notifyListeners();
  }

  set selectedImagePath(String? value) {
    _selectedImagePath = value;
    notifyListeners();
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set error(String? value) {
    _error = value;
    notifyListeners();
  }

  /// 현재 프로필 로드
  Future<void> loadCurrentProfile() async {
    try {
      isLoading = true;
      error = null;
      
      final profile = ref.read(profileProvider).profile;
      if (profile != null) {
        _nickname = profile.nickname;
        _bio = profile.bio ?? '';
        _selectedBirthDate = profile.birthDate;
        _selectedImagePath = profile.profileImageUrl;
      }
    } catch (e) {
      error = '프로필을 불러올 수 없습니다: $e';
    } finally {
      isLoading = false;
    }
  }

  /// 이미지 선택 (갤러리)
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        selectedImagePath = image.path;
      }
    } catch (e) {
      error = '이미지를 선택할 수 없습니다: $e';
    }
  }

  /// 이미지 선택 (카메라)
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        selectedImagePath = image.path;
      }
    } catch (e) {
      error = '카메라로 이미지를 촬영할 수 없습니다: $e';
    }
  }

  /// 생년월일 선택
  Future<void> selectBirthDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedBirthDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        locale: const Locale('ko', 'KR'),
      );
      
      if (picked != null) {
        selectedBirthDate = picked;
      }
    } catch (e) {
      error = '날짜를 선택할 수 없습니다: $e';
    }
  }

  /// 프로필 저장
  Future<bool> saveProfile() async {
    try {
      if (_nickname.trim().isEmpty) {
        error = '닉네임을 입력해주세요';
        return false;
      }

      isLoading = true;
      error = null;

      final currentProfile = ref.read(profileProvider).profile;
      if (currentProfile == null) {
        error = '현재 프로필을 찾을 수 없습니다';
        return false;
      }

      // 프로필 업데이트
      final updatedProfile = currentProfile.copyWith(
        nickname: _nickname.trim(),
        bio: _bio.trim().isEmpty ? null : _bio.trim(),
        birthDate: _selectedBirthDate,
        profileImageUrl: _selectedImagePath,
        updatedAt: DateTime.now(),
      );

      await ref.read(profileProvider.notifier).updateProfile(updatedProfile);
      
      return true;
    } catch (e) {
      error = '프로필을 저장할 수 없습니다: $e';
      return false;
    } finally {
      isLoading = false;
    }
  }

  /// 프로필 초기화
  void resetProfile() {
    _nickname = '';
    _bio = '';
    _selectedBirthDate = null;
    _selectedImagePath = null;
    _error = null;
    notifyListeners();
  }

  /// 유효성 검사
  bool get isValid => _nickname.trim().isNotEmpty;

  /// 변경사항이 있는지 확인
  bool get hasChanges {
    final currentProfile = ref.read(profileProvider).profile;
    if (currentProfile == null) return false;
    
    return _nickname != currentProfile.nickname ||
           _bio != (currentProfile.bio ?? '') ||
           _selectedBirthDate != currentProfile.birthDate ||
           _selectedImagePath != currentProfile.profileImageUrl;
  }
}
