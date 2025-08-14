import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// EmotiFlow 앱의 버튼 시스템
/// UI/UX 가이드에 정의된 모든 버튼 스타일을 포함
enum EmotiButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
}

enum EmotiButtonSize {
  small,
  medium,
  large,
}

class EmotiButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final EmotiButtonType type;
  final EmotiButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final bool isDisabled;
  final Color? textColor;

  const EmotiButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = EmotiButtonType.primary,
    this.size = EmotiButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
    this.padding,
    this.isDisabled = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    Widget button;
    
    switch (type) {
      case EmotiButtonType.primary:
        button = ElevatedButton(
          onPressed: (isLoading || isDisabled) ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textInverse,
            elevation: 4,
            shadowColor: AppColors.primary.withOpacity(0.3),
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_getBorderRadius()),
            ),
            minimumSize: Size(_getMinWidth(), _getHeight()),
          ),
          child: _buildButtonContent(),
        );
        break;
        
      case EmotiButtonType.secondary:
        button = ElevatedButton(
          onPressed: (isLoading || isDisabled) ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textInverse,
            elevation: 3,
            shadowColor: AppColors.secondary.withOpacity(0.25),
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_getBorderRadius()),
            ),
            minimumSize: Size(_getMinWidth(), _getHeight()),
          ),
          child: _buildButtonContent(),
        );
        break;
        
      case EmotiButtonType.outline:
        button = OutlinedButton(
          onPressed: (isLoading || isDisabled) ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_getBorderRadius()),
            ),
            minimumSize: Size(_getMinWidth(), _getHeight()),
          ),
          child: _buildButtonContent(),
        );
        break;
        
      case EmotiButtonType.text:
        button = TextButton(
          onPressed: (isLoading || isDisabled) ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_getBorderRadius()),
            ),
            minimumSize: Size(_getMinWidth(), _getHeight()),
          ),
          child: _buildButtonContent(),
        );
        break;
        
      case EmotiButtonType.danger:
        button = ElevatedButton(
          onPressed: (isLoading || isDisabled) ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.textInverse,
            elevation: 3,
            shadowColor: AppColors.error.withOpacity(0.25),
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_getBorderRadius()),
            ),
            minimumSize: Size(_getMinWidth(), _getHeight()),
          ),
          child: _buildButtonContent(),
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textInverse),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: _getTextStyle().copyWith(color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      );
    }

    return Flexible(
      child: Text(
        text,
        style: _getTextStyle().copyWith(color: textColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        textAlign: TextAlign.center,
      ),
    );
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case EmotiButtonSize.small:
        return AppTypography.buttonSmall;
      case EmotiButtonSize.medium:
        return AppTypography.buttonMedium;
      case EmotiButtonSize.large:
        return AppTypography.buttonLarge;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    if (padding != null) return padding!;
    
    switch (size) {
      case EmotiButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case EmotiButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case EmotiButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getHeight() {
    switch (size) {
      case EmotiButtonSize.small:
        return 40;
      case EmotiButtonSize.medium:
        return 48;
      case EmotiButtonSize.large:
        return 56;
    }
  }

  double _getMinWidth() {
    switch (size) {
      case EmotiButtonSize.small:
        return 80;
      case EmotiButtonSize.medium:
        return 100;
      case EmotiButtonSize.large:
        return 120;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case EmotiButtonSize.small:
        return 8;
      case EmotiButtonSize.medium:
        return 12;
      case EmotiButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case EmotiButtonSize.small:
        return 16;
      case EmotiButtonSize.medium:
        return 18;
      case EmotiButtonSize.large:
        return 20;
    }
  }
}

/// 특수 목적 버튼들
class EmotiIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final EmotiButtonSize size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;

  const EmotiIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = EmotiButtonSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _getSize(),
      height: _getSize(),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? AppColors.textInverse,
          elevation: 2,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: _getIconSize(),
                height: _getIconSize(),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textInverse),
                ),
              )
            : Icon(icon, size: _getIconSize()),
      ),
    );
  }

  double _getSize() {
    switch (size) {
      case EmotiButtonSize.small:
        return 40;
      case EmotiButtonSize.medium:
        return 48;
      case EmotiButtonSize.large:
        return 56;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case EmotiButtonSize.small:
        return 8;
      case EmotiButtonSize.medium:
        return 12;
      case EmotiButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case EmotiButtonSize.small:
        return 16;
      case EmotiButtonSize.medium:
        return 18;
      case EmotiButtonSize.large:
        return 20;
    }
  }
}
