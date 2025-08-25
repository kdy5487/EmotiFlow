import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_provider.dart';

/// 테마를 적용하는 래퍼 위젯
class ThemeWrapper extends ConsumerWidget {
  final Widget child;
  final bool useScaffold;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  const ThemeWrapper({
    super.key,
    required this.child,
    this.useScaffold = true,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    if (!useScaffold) {
      return child;
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.background,
      appBar: appBar,
      body: child,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

/// 테마를 적용하는 카드 위젯
class ThemedCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;

  const ThemedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return Card(
      color: color ?? Theme.of(context).colorScheme.surface,
      elevation: elevation ?? 0,
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        side: border?.top ?? BorderSide.none,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

/// 테마를 적용하는 컨테이너 위젯
class ThemedContainer extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final BoxShadow? boxShadow;

  const ThemedContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border,
        boxShadow: boxShadow != null ? [boxShadow!] : null,
      ),
      child: child,
    );
  }
}

/// 테마를 적용하는 텍스트 위젯
class ThemedText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const ThemedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return Text(
      text,
      style: style ?? Theme.of(context).textTheme.bodyMedium,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

/// 테마를 적용하는 아이콘 위젯
class ThemedIcon extends ConsumerWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const ThemedIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return Icon(
      icon,
      size: size,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }
}

/// 테마를 적용하는 버튼 위젯
class ThemedElevatedButton extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final bool? autofocus;
  final Clip? clipBehavior;
  final FocusNode? focusNode;

  const ThemedElevatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.style,
    this.autofocus,
    this.clipBehavior,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return ElevatedButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: style ?? ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      autofocus: autofocus ?? false,
      clipBehavior: clipBehavior ?? Clip.none,
      focusNode: focusNode,
      child: child,
    );
  }
}

/// 테마를 적용하는 아웃라인 버튼 위젯
class ThemedOutlinedButton extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final bool? autofocus;
  final Clip? clipBehavior;
  final FocusNode? focusNode;

  const ThemedOutlinedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.style,
    this.autofocus,
    this.clipBehavior,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return OutlinedButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: style ?? OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      autofocus: autofocus ?? false,
      clipBehavior: clipBehavior ?? Clip.none,
      focusNode: focusNode,
      child: child,
    );
  }
}
