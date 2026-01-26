import 'package:flutter/material.dart';
import '../../../../../shared/widgets/inputs/emoti_text_field.dart';

class DiarySearchSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const DiarySearchSection({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark 
            ? theme.colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outline.withOpacity(0.2)
              : Colors.transparent,
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: EmotiTextField(
        controller: controller,
        focusNode: focusNode,
        hintText: '제목, 내용, 태그로 검색',
        prefixIcon: Icon(
          Icons.search, 
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear, 
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: onClear,
              )
            : null,
        onChanged: onChanged,
        onSubmitted: onChanged,
      ),
    );
  }
}


