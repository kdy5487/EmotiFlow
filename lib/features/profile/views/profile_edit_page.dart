import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/layout/emoti_appbar.dart';
import '../../../shared/widgets/buttons/emoti_button.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_colors.dart';
import '../providers/profile_provider.dart';
import '../models/user_profile.dart';
import '../viewmodels/profile_edit_view_model.dart';

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
  late final ProfileEditViewModel _viewModel;
  
  String? _selectedImagePath;
  DateTime? _selectedBirthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileEditViewModel(ref);
    _viewModel.loadCurrentProfile();
    _initializeControllers();
  }

  void _initializeControllers() {
    final profile = ref.read(profileProvider).profile;
    if (profile != null) {
      _nicknameController.text = profile.nickname ?? '';
      _bioController.text = profile.bio ?? '';
      _selectedBirthDate = profile.birthDate;
      _selectedImagePath = profile.profileImageUrl;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).profile;
    
    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: EmotiAppBar(
        title: '프로필 편집',
        showBackButton: true,
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 프로필 이미지
            _buildProfileImageSection(context, profile),
            const SizedBox(height: 24),
            
            // 기본 정보
            _buildBasicInfoSection(context, profile),
            const SizedBox(height: 24),
            
            // 자기소개
            _buildBioSection(context, profile),
            const SizedBox(height: 24),
            
            // 저장 버튼
            EmotiButton(
              text: '프로필 저장',
              onPressed: _isLoading ? null : _saveProfile,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  /// 프로필 이미지 섹션
  Widget _buildProfileImageSection(BuildContext context, UserProfile profile) {
    return Center(
      child: Column(
        children: [
          // 프로필 이미지
          GestureDetector(
            onTap: _showImagePickerDialog,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.backgroundSecondary,
                  backgroundImage: _selectedImagePath != null
                      ? NetworkImage(_selectedImagePath!)
                      : null,
                  child: _selectedImagePath == null
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
                    decoration: BoxDecoration(
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
          const SizedBox(height: 16),
          
          // 이미지 변경 버튼
          TextButton(
            onPressed: _showImagePickerDialog,
            child: const Text('프로필 이미지 변경'),
          ),
        ],
      ),
    );
  }

  /// 기본 정보 섹션
  Widget _buildBasicInfoSection(BuildContext context, UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기본 정보',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
        _buildBirthDateField(context),
        const SizedBox(height: 16),
        
        // 이메일 (읽기 전용)
        TextFormField(
          initialValue: profile.email,
          decoration: InputDecoration(
            labelText: '이메일',
            prefixIcon: const Icon(Icons.email),
            helperText: '이메일은 변경할 수 없습니다',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          enabled: false,
        ),
      ],
    );
  }

  /// 생년월일 필드
  Widget _buildBirthDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '생년월일',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                Icon(
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _selectedBirthDate != null
                          ? AppTheme.textPrimary
                          : AppTheme.textTertiary,
                    ),
                  ),
                ),
                Icon(
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
  Widget _buildBioSection(BuildContext context, UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '자기소개',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _bioController,
          decoration: InputDecoration(
            labelText: '자기소개',
            hintText: '자신에 대해 간단히 소개해주세요',
            prefixIcon: const Icon(Icons.edit_note),
            helperText: '${_bioController.text.length}/200',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('이미지 제거'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedImagePath = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지 선택
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
        
        // TODO: 이미지 업로드 및 URL 가져오기
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지가 선택되었습니다')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택에 실패했습니다: $e')),
      );
    }
  }

  /// 날짜 선택기 표시
  Future<void> _showDatePicker(BuildContext context) async {
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
    );

    if (pickedDate != null) {
      setState(() {
        _selectedBirthDate = pickedDate;
      });
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
      final profile = ref.read(profileProvider).profile;
      if (profile == null) return;

      final updatedProfile = profile.copyWith(
        nickname: _nicknameController.text.trim(),
        birthDate: _selectedBirthDate,
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        profileImageUrl: _selectedImagePath,
        updatedAt: DateTime.now(),
      );

      final success = await ref.read(profileProvider.notifier).updateProfile(updatedProfile);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('프로필이 저장되었습니다')),
          );
          Navigator.of(context).pop();
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
