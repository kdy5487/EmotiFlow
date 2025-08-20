import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/cards/emoti_card.dart';
import '../../../theme/app_theme.dart';

/// 설정 섹션 위젯
/// 설정 카테고리별 섹션을 표시하는 공통 위젯
class SettingsSectionWidget extends ConsumerWidget {
  final String title;
  final String emoji;
  final List<Widget> children;
  final VoidCallback? onEditTap;
  final bool showEditButton;

  const SettingsSectionWidget({
    super.key,
    required this.title,
    required this.emoji,
    required this.children,
    this.onEditTap,
    this.showEditButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$emoji $title',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showEditButton && onEditTap != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEditTap,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// 설정 아이템 위젯
/// 개별 설정 항목을 표시하는 위젯
class SettingItemWidget extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool showColor;
  final Color? color;
  final VoidCallback? onTap;
  final bool isSwitch;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  const SettingItemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.showColor = false,
    this.color,
    this.onTap,
    this.isSwitch = false,
    this.switchValue,
    this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (showColor && color != null) ...[
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.border),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (isSwitch)
                Switch(
                  value: switchValue ?? false,
                  onChanged: onSwitchChanged,
                  activeColor: AppTheme.primary,
                )
              else
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 설정 그룹 위젯
/// 관련된 설정들을 그룹화하여 표시하는 위젯
class SettingsGroupWidget extends ConsumerWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const SettingsGroupWidget({
    super.key,
    required this.title,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

/// 설정 액션 위젯
/// 설정 변경을 위한 액션 버튼을 표시하는 위젯
class SettingsActionWidget extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;
  final Color? iconColor;

  const SettingsActionWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? (isDestructive ? AppTheme.error : AppTheme.primary),
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
