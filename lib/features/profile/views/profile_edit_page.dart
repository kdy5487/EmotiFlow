import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/features/profile/providers/profile_provider.dart';
import 'package:emoti_flow/core/providers/auth_provider.dart';

/// 프로필 편집 페이지
class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  String? _selectedImagePath;
  File? _selectedImageFile;
  DateTime? _selectedBirthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // 현재 프로필 정보로 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(profileProvider).profile;
      if (profile != null) {
        _nicknameController.text = profile.nickname;
        _bioController.text = profile.bio ?? '';
        _selectedBirthDate = profile.birthDate;
        _selectedImagePath = profile.profileImageUrl;
      }
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);
    
    if (profileState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '프로필 편집',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장'),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // 키보드 외부 터치 시 키보드 내리기
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 프로필 이미지
              _buildProfileImageSection(),
              const SizedBox(height: 24),
              
              // 기본 정보
              _buildBasicInfoSection(authState.user),
              const SizedBox(height: 24),
              
              // 자기소개
              _buildBioSection(),
              const SizedBox(height: 24),
              
              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '프로필 저장',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 프로필 이미지 섹션
  Widget _buildProfileImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 섹션 제목
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              color: AppTheme.primary,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              '프로필 이미지',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // 프로필 이미지
        Center(
          child: GestureDetector(
            onTap: _showImagePickerDialog,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppTheme.surface,
                  backgroundImage: _selectedImageFile != null
                      ? FileImage(_selectedImageFile!)
                      : (_selectedImagePath != null && _selectedImagePath!.startsWith('http'))
                          ? NetworkImage(_selectedImagePath!)
                          : null,
                  child: (_selectedImageFile == null && (_selectedImagePath == null || _selectedImagePath!.startsWith('http')))
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: AppTheme.textTertiary,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // 이미지 변경 버튼
        TextButton(
          onPressed: _showImagePickerDialog,
          child: const Text('프로필 이미지 변경'),
        ),
      ],
    );
  }

  /// 기본 정보 섹션
  Widget _buildBasicInfoSection(User? user) {
    final currentProfile = ref.read(profileProvider).profile;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.person_outline,
              color: AppTheme.primary,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              '기본 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 닉네임
        TextFormField(
          controller: _nicknameController,
          decoration: InputDecoration(
            labelText: '닉네임',
            hintText: '사용할 닉네임을 입력하세요',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '닉네임을 입력해주세요';
            }
            if (value.trim().length < 2) {
              return '닉네임은 2자 이상이어야 합니다';
            }
            if (value.trim().length > 20) {
              return '닉네임은 20자 이하여야 합니다';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // 생년월일
        _buildBirthDateField(),
        const SizedBox(height: 16),
        
        // 이메일 (읽기 전용)
        InkWell(
          onTap: null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.surface.withOpacity(0.5),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.email,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '이메일',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentProfile?.email ?? user?.email ?? '이메일 없음',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 생년월일 필드
  Widget _buildBirthDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '생년월일',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        InkWell(
          onTap: () => _showDatePicker(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedBirthDate != null
                        ? '${_selectedBirthDate!.year}년 ${_selectedBirthDate!.month}월 ${_selectedBirthDate!.day}일'
                        : '생년월일을 선택하세요',
                    style: TextStyle(
                      color: _selectedBirthDate != null
                          ? AppTheme.textPrimary
                          : AppTheme.textTertiary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 자기소개 섹션
  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.edit_note,
              color: AppTheme.primary,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              '자기소개',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _bioController,
          decoration: InputDecoration(
            labelText: '자기소개',
            hintText: '자신에 대해 간단히 소개해주세요',
            helperText: '${_bioController.text.length}/200',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 4,
          maxLength: 200,
        ),
      ],
    );
  }

  /// 이미지 선택 다이얼로그 표시
  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('이미지 제거'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedImagePath = null;
                  _selectedImageFile = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지 선택 (갤러리)
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
          _selectedImagePath = image.path;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지가 선택되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  /// 이미지 선택 (카메라)
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
          _selectedImagePath = image.path;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지가 촬영되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카메라 촬영 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  /// 날짜 선택기 표시
  Future<void> _showDatePicker(BuildContext context) async {
    try {
      final currentDate = DateTime.now();
      final initialDate = _selectedBirthDate ?? DateTime(currentDate.year - 20, 1, 1);
      final firstDate = DateTime(currentDate.year - 100, 1, 1);
      final lastDate = currentDate;

      final pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        locale: const Locale('ko', 'KR'),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.primary,
                onPrimary: Colors.white,
                surface: AppTheme.surface,
                onSurface: AppTheme.textPrimary,
              ),
            ),
            child: child!,
          );
        },
        errorFormatText: '올바른 날짜 형식을 입력하세요',
        errorInvalidText: '올바른 날짜를 입력하세요',
        fieldLabelText: '생년월일',
        fieldHintText: 'YYYY/MM/DD',
        helpText: '생년월일을 선택하세요',
        cancelText: '취소',
        confirmText: '확인',
      );

      if (pickedDate != null) {
        setState(() {
          _selectedBirthDate = pickedDate;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('날짜 선택 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  /// 프로필 저장
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentProfile = ref.read(profileProvider).profile;
      final authState = ref.read(authProvider);
      
      if (currentProfile == null || authState.user == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
      }

      // 이미지가 선택된 경우 업로드
      String? finalImageUrl = _selectedImagePath;
      if (_selectedImageFile != null) {
        try {
          final uploadedUrl = await ref.read(profileProvider.notifier).uploadProfileImage(_selectedImageFile!.path);
          if (uploadedUrl != null) {
            finalImageUrl = uploadedUrl;
          }
        } catch (e) {
          print('이미지 업로드 실패: $e');
          // 이미지 업로드 실패 시 기존 이미지 URL 유지
        }
      }

      // 업데이트된 프로필 생성
      final updatedProfile = currentProfile.copyWith(
        nickname: _nicknameController.text.trim(),
        birthDate: _selectedBirthDate,
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        profileImageUrl: finalImageUrl,
        updatedAt: DateTime.now(),
      );

      // 프로필 저장
      final success = await ref.read(profileProvider.notifier).updateProfile(updatedProfile);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('프로필이 저장되었습니다')),
          );
          context.pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('프로필 저장에 실패했습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
