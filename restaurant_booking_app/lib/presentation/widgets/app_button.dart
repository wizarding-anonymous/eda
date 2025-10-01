import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonType { primary, secondary, outline }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final Widget? icon;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color textColor;
    double height;
    TextStyle textStyle;
    BorderSide? borderSide;

    // Определяем размер
    switch (size) {
      case AppButtonSize.small:
        height = 36;
        textStyle = AppTextStyles.buttonSmall;
        break;
      case AppButtonSize.medium:
        height = 44;
        textStyle = AppTextStyles.buttonMedium;
        break;
      case AppButtonSize.large:
        height = 52;
        textStyle = AppTextStyles.buttonLarge;
        break;
    }

    // Определяем цвета по типу
    switch (type) {
      case AppButtonType.primary:
        backgroundColor =
            isDark ? AppColors.darkButtonPrimary : AppColors.lightButtonPrimary;
        textColor =
            isDark ? AppColors.darkTextOnDark : AppColors.lightTextOnDark;
        break;
      case AppButtonType.secondary:
        backgroundColor = isDark
            ? AppColors.darkButtonSecondary
            : AppColors.lightButtonSecondary;
        textColor =
            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        break;
      case AppButtonType.outline:
        backgroundColor = Colors.transparent;
        textColor =
            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        borderSide = BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        );
        break;
    }

    if (onPressed == null && !isLoading) {
      backgroundColor =
          isDark ? AppColors.darkButtonDisabled : AppColors.lightButtonDisabled;
      textColor =
          isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    }

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(text, style: textStyle.copyWith(color: textColor)),
            ],
          );

    return SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderSide ?? BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: fullWidth ? 24 : 16,
            vertical: 0,
          ),
        ),
        child: buttonChild,
      ),
    );
  }
}

// Специализированные кнопки для авторизации
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isSecondary;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      type: isSecondary ? AppButtonType.outline : AppButtonType.primary,
      size: AppButtonSize.large,
    );
  }
}
