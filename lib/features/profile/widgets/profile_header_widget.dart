import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../../../shared/widgets/buttons/emoti_button.dart';
import '../../../theme/app_colors.dart';

/// 프로필 헤더 위젯
/// 사용자의 기본 정보와 프로필 이미지를 표시
class ProfileHeaderWidget extends ConsumerWidget {
  final UserProfile profile;
  final VoidCallback? onEditTap;
  final VoidCallback? onImageTap;

  const ProfileHeaderWidget({
    super.key,
    required this.profile,
    this.onEditTap,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // 프로필 이미지
          GestureDetector(
            onTap: onImageTap,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.backgroundSecondary,
                  backgroundImage: profile.profileImageUrl != null
                      ? NetworkImage(profile.profileImageUrl!)
                      : null,
                  child: profile.profileImageUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.textTertiary,
                        )
                      : null,
                ),
                if (onImageTap != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: AppColors.textInverse,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 닉네임
          Text(
            profile.nickname,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // 이메일
          Text(
            profile.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          // 나이 (생년월일이 있는 경우)
          if (profile.age != null) ...[
            const SizedBox(height: 8),
            Text(
              '${profile.age}세',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          
          // 자기소개
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              profile.bio!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
          
          const SizedBox(height: 20),
          
          // 편집 버튼
          if (onEditTap != null)
            EmotiButton(
              text: '프로필 편집',
              onPressed: onEditTap,
              isFullWidth: true,
            ),
        ],
      ),
    );
  }
}
