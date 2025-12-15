// lib/src/design_system/pos_components.dart
/// 
/// Composants réutilisables POS - Theme ShopCaisse Premium
library;

import 'package:flutter/material.dart';
import 'pos_design_system.dart';

// =============================================
// POS BUTTON
// =============================================

enum PosButtonVariant { primary, secondary, outline, text, danger, success }
enum PosButtonSize { small, medium, large }

/// Bouton POS premium
class PosButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final PosButtonVariant variant;
  final PosButtonSize size;
  final IconData? icon;
  final bool fullWidth;
  final bool loading;

  const PosButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
    this.variant = PosButtonVariant.primary,
    this.size = PosButtonSize.medium,
    this.icon,
    this.fullWidth = false,
    this.loading = false,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || loading;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: _getButtonStyle(),
        child: loading
            ? SizedBox(
                width: _getIconSize(),
                height: _getIconSize(),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor()),
                ),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (child != null) return child!;

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: PosSpacing.sm),
          Text(text!, style: PosTypography.button),
        ],
      );
    }

    return Text(text!, style: PosTypography.button);
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case PosButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: PosColors.primary,
          foregroundColor: PosColors.textOnPrimary,
          disabledBackgroundColor: PosColors.primary.withOpacity(0.5),
          disabledForegroundColor: PosColors.textOnPrimary.withOpacity(0.7),
          elevation: PosElevation.low,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: PosRadii.mdRadius,
          ),
        );
      case PosButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: PosColors.surfaceVariant,
          foregroundColor: PosColors.textPrimary,
          disabledBackgroundColor: PosColors.surfaceVariant.withOpacity(0.5),
          elevation: 0,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: PosRadii.mdRadius,
          ),
        );
      case PosButtonVariant.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: PosColors.primary,
          disabledForegroundColor: PosColors.textTertiary,
          padding: _getPadding(),
          side: const BorderSide(color: PosColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: PosRadii.mdRadius,
          ),
        );
      case PosButtonVariant.text:
        return TextButton.styleFrom(
          foregroundColor: PosColors.primary,
          disabledForegroundColor: PosColors.textTertiary,
          padding: _getPadding(),
        );
      case PosButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: PosColors.error,
          foregroundColor: PosColors.textOnPrimary,
          disabledBackgroundColor: PosColors.error.withOpacity(0.5),
          elevation: PosElevation.low,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: PosRadii.mdRadius,
          ),
        );
      case PosButtonVariant.success:
        return ElevatedButton.styleFrom(
          backgroundColor: PosColors.success,
          foregroundColor: PosColors.textOnPrimary,
          disabledBackgroundColor: PosColors.success.withOpacity(0.5),
          elevation: PosElevation.low,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: PosRadii.mdRadius,
          ),
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case PosButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: PosSpacing.md, vertical: PosSpacing.sm);
      case PosButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: PosSpacing.lg, vertical: PosSpacing.md);
      case PosButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: PosSpacing.xl, vertical: PosSpacing.lg);
    }
  }

  double _getHeight() {
    switch (size) {
      case PosButtonSize.small:
        return 32;
      case PosButtonSize.medium:
        return 44;
      case PosButtonSize.large:
        return 56;
    }
  }

  double _getIconSize() {
    switch (size) {
      case PosButtonSize.small:
        return PosIconSize.xs;
      case PosButtonSize.medium:
        return PosIconSize.sm;
      case PosButtonSize.large:
        return PosIconSize.md;
    }
  }

  Color _getLoadingColor() {
    switch (variant) {
      case PosButtonVariant.primary:
      case PosButtonVariant.danger:
      case PosButtonVariant.success:
        return PosColors.textOnPrimary;
      case PosButtonVariant.secondary:
      case PosButtonVariant.outline:
      case PosButtonVariant.text:
        return PosColors.primary;
    }
  }
}

// =============================================
// POS CARD
// =============================================

/// Carte POS premium avec ombre légère
class PosCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool selected;
  final Color? color;

  const PosCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.selected = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(PosSpacing.md),
      decoration: BoxDecoration(
        color: color ?? PosColors.surface,
        borderRadius: PosRadii.mdRadius,
        border: Border.all(
          color: selected ? PosColors.primary : PosColors.border,
          width: selected ? 2 : 1,
        ),
        boxShadow: selected ? PosShadows.md : PosShadows.sm,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: PosRadii.mdRadius,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

// =============================================
// POS CHIP
// =============================================

enum PosChipVariant { primary, success, warning, error, info, neutral }

/// Chip POS pour statuts et tags
class PosChip extends StatelessWidget {
  final String label;
  final PosChipVariant variant;
  final IconData? icon;

  const PosChip({
    super.key,
    required this.label,
    this.variant = PosChipVariant.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PosSpacing.sm,
        vertical: PosSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: PosRadii.smRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: PosIconSize.xs, color: colors['foreground']),
            const SizedBox(width: PosSpacing.xs),
          ],
          Text(
            label,
            style: PosTypography.labelSmall.copyWith(
              color: colors['foreground'],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getColors() {
    switch (variant) {
      case PosChipVariant.primary:
        return {
          'background': PosColors.primary.withOpacity(0.1),
          'foreground': PosColors.primary,
        };
      case PosChipVariant.success:
        return {
          'background': PosColors.successLight,
          'foreground': PosColors.success,
        };
      case PosChipVariant.warning:
        return {
          'background': PosColors.warningLight,
          'foreground': PosColors.warning,
        };
      case PosChipVariant.error:
        return {
          'background': PosColors.errorLight,
          'foreground': PosColors.error,
        };
      case PosChipVariant.info:
        return {
          'background': PosColors.infoLight,
          'foreground': PosColors.info,
        };
      case PosChipVariant.neutral:
        return {
          'background': PosColors.surfaceVariant,
          'foreground': PosColors.textSecondary,
        };
    }
  }
}

// =============================================
// POS SECTION HEADER
// =============================================

/// En-tête de section POS
class PosSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsets? padding;

  const PosSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: PosSpacing.md, vertical: PosSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: PosTypography.headingSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: PosSpacing.xs),
                  Text(
                    subtitle!,
                    style: PosTypography.bodySmall.copyWith(
                      color: PosColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// =============================================
// POS EMPTY STATE
// =============================================

/// État vide premium
class PosEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const PosEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PosSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(PosSpacing.lg),
              decoration: BoxDecoration(
                color: PosColors.surfaceVariant,
                borderRadius: PosRadii.fullRadius,
              ),
              child: Icon(
                icon,
                size: PosIconSize.xl,
                color: PosColors.textTertiary,
              ),
            ),
            const SizedBox(height: PosSpacing.lg),
            Text(
              title,
              style: PosTypography.headingMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: PosSpacing.sm),
              Text(
                subtitle!,
                style: PosTypography.bodyMedium.copyWith(
                  color: PosColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: PosSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================
// POS LOADING STATE
// =============================================

/// État de chargement premium
class PosLoadingState extends StatelessWidget {
  final String? message;

  const PosLoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(PosColors.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: PosSpacing.lg),
            Text(
              message!,
              style: PosTypography.bodyMedium.copyWith(
                color: PosColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================
// POS ERROR STATE
// =============================================

/// État d'erreur premium
class PosErrorState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  const PosErrorState({
    super.key,
    required this.title,
    this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PosSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(PosSpacing.lg),
              decoration: BoxDecoration(
                color: PosColors.errorLight,
                borderRadius: PosRadii.fullRadius,
              ),
              child: const Icon(
                Icons.error_outline,
                size: PosIconSize.xl,
                color: PosColors.error,
              ),
            ),
            const SizedBox(height: PosSpacing.lg),
            Text(
              title,
              style: PosTypography.headingMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: PosSpacing.sm),
              Text(
                subtitle!,
                style: PosTypography.bodyMedium.copyWith(
                  color: PosColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: PosSpacing.lg),
              PosButton(
                text: 'Réessayer',
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
