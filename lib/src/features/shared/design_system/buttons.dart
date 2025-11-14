// lib/src/design_system/buttons.dart
// Composants boutons réutilisables - Design System Pizza Deli'Zza

import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';
import 'spacing.dart';
import 'radius.dart';
import 'shadows.dart';

/// Énumération des tailles de bouton
enum ButtonSize {
  small,
  medium,
  large,
}

/// Énumération des variantes de bouton
enum ButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  danger,
}

// ═══════════════════════════════════════════════════════════════
// BOUTON PRINCIPAL - AppButton
// ═══════════════════════════════════════════════════════════════

/// Bouton principal avec toutes les variantes
/// 
/// Variantes:
/// - Primary: Fond rouge, texte blanc
/// - Secondary: Fond gris clair, texte noir
/// - Outline: Bordure rouge, fond transparent
/// - Ghost: Transparent, texte rouge
/// - Danger: Fond rouge danger, texte blanc
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  // Primary button factory
  factory AppButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.primary,
      size: size,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }

  // Secondary button factory
  factory AppButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.secondary,
      size: size,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }

  // Outline button factory
  factory AppButton.outline({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.outline,
      size: size,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }

  // Ghost button factory
  factory AppButton.ghost({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.ghost,
      size: size,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }

  // Danger button factory
  factory AppButton.danger({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.danger,
      size: size,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final textStyle = _getTextStyle();
    final padding = _getPadding();
    final iconSize = _getIconSize();

    Widget buttonChild;
    
    if (isLoading) {
      buttonChild = SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getLoadingColor(),
          ),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize),
          const SizedBox(width: AppSpacing.xs),
          Text(text, style: textStyle),
        ],
      );
    } else {
      buttonChild = Text(text, style: textStyle);
    }

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle.copyWith(
        padding: MaterialStateProperty.all(padding),
      ),
      child: buttonChild,
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          disabledBackgroundColor: AppColors.neutral300,
          disabledForegroundColor: AppColors.neutral500,
        );
      
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.neutral100,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          disabledBackgroundColor: AppColors.neutral200,
          disabledForegroundColor: AppColors.neutral400,
        );
      
      case ButtonVariant.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.neutral400,
        );
      
      case ButtonVariant.ghost:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.neutral400,
        );
      
      case ButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: AppColors.danger.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          disabledBackgroundColor: AppColors.neutral300,
          disabledForegroundColor: AppColors.neutral500,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return AppTextStyles.buttonSmall;
      case ButtonSize.medium:
        return AppTextStyles.button;
      case ButtonSize.large:
        return AppTextStyles.buttonLarge;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return AppSpacing.buttonPaddingSmall;
      case ButtonSize.medium:
        return AppSpacing.buttonPadding;
      case ButtonSize.large:
        return AppSpacing.buttonPaddingLarge;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  Color _getLoadingColor() {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.danger:
        return AppColors.white;
      case ButtonVariant.secondary:
        return AppColors.textPrimary;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return AppColors.primary;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// BOUTON ICÔNE - AppIconButton
// ═══════════════════════════════════════════════════════════════

/// Bouton icône carré ou circulaire
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isCircular;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isCircular = true,
    this.tooltip,
  });

  factory AppIconButton.primary({
    Key? key,
    required IconData icon,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isCircular = true,
    String? tooltip,
  }) {
    return AppIconButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      variant: ButtonVariant.primary,
      size: size,
      isCircular: isCircular,
      tooltip: tooltip,
    );
  }

  factory AppIconButton.secondary({
    Key? key,
    required IconData icon,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isCircular = true,
    String? tooltip,
  }) {
    return AppIconButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      variant: ButtonVariant.secondary,
      size: size,
      isCircular: isCircular,
      tooltip: tooltip,
    );
  }

  factory AppIconButton.ghost({
    Key? key,
    required IconData icon,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isCircular = true,
    String? tooltip,
  }) {
    return AppIconButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      variant: ButtonVariant.ghost,
      size: size,
      isCircular: isCircular,
      tooltip: tooltip,
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = _getIconSize();
    final buttonSize = _getButtonSize();
    final colors = _getColors();

    final button = Material(
      color: colors.background,
      shape: isCircular
          ? const CircleBorder()
          : RoundedRectangleBorder(borderRadius: AppRadius.button),
      child: InkWell(
        onTap: onPressed,
        customBorder: isCircular
            ? const CircleBorder()
            : RoundedRectangleBorder(borderRadius: AppRadius.button),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: iconSize,
            color: colors.foreground,
          ),
        ),
      ),
    );

    return tooltip != null
        ? Tooltip(message: tooltip!, child: button)
        : button;
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getButtonSize() {
    switch (size) {
      case ButtonSize.small:
        return 32;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.large:
        return 48;
    }
  }

  ({Color background, Color foreground}) _getColors() {
    switch (variant) {
      case ButtonVariant.primary:
        return (
          background: AppColors.primary,
          foreground: AppColors.white,
        );
      case ButtonVariant.secondary:
        return (
          background: AppColors.neutral100,
          foreground: AppColors.textPrimary,
        );
      case ButtonVariant.ghost:
        return (
          background: Colors.transparent,
          foreground: AppColors.primary,
        );
      case ButtonVariant.outline:
        return (
          background: Colors.transparent,
          foreground: AppColors.primary,
        );
      case ButtonVariant.danger:
        return (
          background: AppColors.danger,
          foreground: AppColors.white,
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// BOUTON PLEINE LARGEUR - AppFullWidthButton (alias)
// ═══════════════════════════════════════════════════════════════

/// Bouton pleine largeur (alias de AppButton avec fullWidth: true)
class AppFullWidthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;

  const AppFullWidthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: variant,
      size: size,
      icon: icon,
      isLoading: isLoading,
      fullWidth: true,
    );
  }
}
