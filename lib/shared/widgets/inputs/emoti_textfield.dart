import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_typography.dart';

/// EmotiFlow 앱의 텍스트 필드 시스템
/// UI/UX 가이드에 정의된 모든 텍스트 필드 스타일을 포함
class EmotiTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool enableSuggestions;
  final String? initialValue;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final Color? fillColor;
  final bool filled;
  final Color? labelColor;
  final Color? hintColor;
  final Color? errorColor;
  final Color? helperTextColor;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final TextStyle? textStyle;
  final TextStyle? counterStyle;
  final bool isDense;
  final bool isCollapsed;
  final bool isOutlined;
  final bool isFilled;
  final bool isUnderlined;
  final bool isBorderless;
  final bool isDenseInput;
  final bool isCollapsedInput;
  final bool isOutlinedInput;
  final bool isFilledInput;
  final bool isUnderlinedInput;
  final bool isBorderlessInput;
  final bool isDenseTextField;
  final bool isCollapsedTextField;
  final bool isOutlinedTextField;
  final bool isFilledTextField;
  final bool isUnderlinedTextField;
  final bool isBorderlessTextField;
  final bool isDenseTextFormField;
  final bool isCollapsedTextFormField;
  final bool isOutlinedTextFormField;
  final bool isFilledTextFormField;
  final bool isUnderlinedTextFormField;
  final bool isBorderlessTextFormField;

  const EmotiTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.initialValue,
    this.contentPadding,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.fillColor,
    this.filled = true,
    this.labelColor,
    this.hintColor,
    this.errorColor,
    this.helperTextColor,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.helperStyle,
    this.textStyle,
    this.counterStyle,
    this.isDense = false,
    this.isCollapsed = false,
    this.isOutlined = false,
    this.isFilled = false,
    this.isUnderlined = false,
    this.isBorderless = false,
    this.isDenseInput = false,
    this.isCollapsedInput = false,
    this.isOutlinedInput = false,
    this.isFilledInput = false,
    this.isUnderlinedInput = false,
    this.isBorderlessInput = false,
    this.isDenseTextField = false,
    this.isCollapsedTextField = false,
    this.isOutlinedTextField = false,
    this.isFilledTextField = false,
    this.isUnderlinedTextField = false,
    this.isBorderlessTextField = false,
    this.isDenseTextFormField = false,
    this.isCollapsedTextFormField = false,
    this.isOutlinedTextFormField = false,
    this.isFilledTextFormField = false,
    this.isUnderlinedTextFormField = false,
    this.isBorderlessTextFormField = false,
  });

  @override
  State<EmotiTextField> createState() => _EmotiTextFieldState();
}

class _EmotiTextFieldState extends State<EmotiTextField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();
    
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      // Focus 상태 변경 시 UI 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: (widget.labelStyle ?? AppTypography.labelMedium).copyWith(
              color: widget.labelColor ?? AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          autofocus: widget.autofocus,
          textInputAction: widget.textInputAction,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          style: widget.textStyle ?? AppTypography.bodyMedium.copyWith(
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: widget.filled,
            fillColor: widget.enabled 
              ? widget.fillColor ?? AppTheme.surface
              : AppTheme.surface.withOpacity(0.5),
            hintStyle: (widget.hintStyle ?? AppTypography.bodyMedium).copyWith(
              color: widget.hintColor ?? AppTheme.textTertiary,
            ),
            helperStyle: (widget.helperStyle ?? AppTypography.bodySmall).copyWith(
              color: widget.helperTextColor ?? AppTheme.textSecondary,
            ),
            errorStyle: (widget.errorStyle ?? AppTypography.bodySmall).copyWith(
              color: widget.errorColor ?? AppTheme.error,
            ),
            counterStyle: widget.counterStyle ?? AppTypography.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            isDense: widget.isDense,
            isCollapsed: widget.isCollapsed,
            border: widget.border ?? OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: widget.enabledBorder ?? OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: widget.focusedBorder ?? OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            errorBorder: widget.errorBorder ?? OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.error, width: 2),
            ),
            focusedErrorBorder: widget.focusedErrorBorder ?? OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// 검색 전용 텍스트 필드
class EmotiSearchField extends StatefulWidget {
  final String? hint;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onSearch;
  final TextEditingController? controller;
  final bool autofocus;
  final FocusNode? focusNode;

  const EmotiSearchField({
    super.key,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.onClear,
    this.onSearch,
    this.controller,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<EmotiSearchField> createState() => _EmotiSearchFieldState();
}

class _EmotiSearchFieldState extends State<EmotiSearchField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
      _hasText = widget.initialValue!.isNotEmpty;
    }
    
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSubmitted: (_) => widget.onSearch?.call(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint ?? '검색어를 입력하세요',
        prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
        suffixIcon: _hasText ? IconButton(
          onPressed: _onClear,
          icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
        ) : null,
        filled: true,
        fillColor: AppTheme.background,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppTheme.textTertiary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

/// 다중 라인 텍스트 입력 필드
class EmotiMultilineTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const EmotiMultilineTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.maxLines = 3,
    this.maxLength,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return EmotiTextField(
      label: label,
      hint: hint,
      helperText: helperText,
      errorText: errorText,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      validator: validator,
      keyboardType: TextInputType.multiline,
    );
  }
}
