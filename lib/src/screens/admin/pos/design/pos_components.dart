// lib/src/screens/admin/pos/design/pos_components.dart
/// POS Reusable Components - ShopCaisse Theme
/// 
/// Premium UI components for Point of Sale interface

library;

import 'package:flutter/material.dart';
import 'pos_theme.dart';

// ═══════════════════════════════════════════════════════════════
// BUTTON COMPONENT
// ═══════════════════════════════════════════════════════════════

/// Button variant types
enum PosButtonVariant {
  primary,
  secondary,
  success,
  danger,
  ghost,
}

/// Button sizes
enum PosButtonSize {
  small,
  medium,
  large,
}

/// Premium POS Button with variants and sizes
class PosButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final PosButtonVariant variant;
  final PosButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const PosButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.variant = PosButtonVariant.primary,
    this.size = PosButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final padding = _getPadding();
    final textStyle = _getTextStyle();
    final borderRadius = _getBorderRadius();

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.background,
          foregroundColor: colors.foreground,
          disabledBackgroundColor: colors.background.withOpacity(0.5),
          disabledForegroundColor: colors.foreground.withOpacity(0.5),
          padding: padding,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: variant == PosButtonVariant.ghost
                ? BorderSide(color: colors.background, width: 1.5)
                : BorderSide.none,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            colors.foreground.withOpacity(0.1),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.foreground),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: _getIconSize()),
                    SizedBox(width: size == PosButtonSize.small ? 6 : 8),
                  ],
                  Text(label, style: textStyle),
                ],
              ),
      ),
    );
  }

  _ButtonColors _getColors() {
    switch (variant) {
      case PosButtonVariant.primary:
        return _ButtonColors(
          background: PosColors.primary,
          foreground: PosColors.textOnPrimary,
        );
      case PosButtonVariant.secondary:
        return _ButtonColors(
          background: PosColors.surfaceVariant,
          foreground: PosColors.textPrimary,
        );
      case PosButtonVariant.success:
        return _ButtonColors(
          background: PosColors.success,
          foreground: Colors.white,
        );
      case PosButtonVariant.danger:
        return _ButtonColors(
          background: PosColors.danger,
          foreground: Colors.white,
        );
      case PosButtonVariant.ghost:
        return _ButtonColors(
          background: PosColors.textPrimary,
          foreground: PosColors.textPrimary,
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case PosButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case PosButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case PosButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = size == PosButtonSize.large
        ? PosTextStyles.buttonLarge
        : PosTextStyles.buttonMedium;
    return baseStyle.copyWith(
      color: variant == PosButtonVariant.ghost
          ? PosColors.textPrimary
          : PosColors.textOnPrimary,
    );
  }

  double _getBorderRadius() {
    switch (size) {
      case PosButtonSize.small:
        return PosRadii.sm;
      case PosButtonSize.medium:
        return PosRadii.md;
      case PosButtonSize.large:
        return PosRadii.lg;
    }
  }

  double _getIconSize() {
    switch (size) {
      case PosButtonSize.small:
        return 16;
      case PosButtonSize.medium:
        return 18;
      case PosButtonSize.large:
        return 20;
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;

  _ButtonColors({required this.background, required this.foreground});
}

// ═══════════════════════════════════════════════════════════════
// CARD COMPONENT
// ═══════════════════════════════════════════════════════════════

/// Premium card with subtle shadow and border
class PosCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool hasBorder;

  const PosCard({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.hasBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? const EdgeInsets.all(PosSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? PosColors.surface,
        borderRadius: BorderRadius.circular(PosRadii.md),
        border: hasBorder ? Border.all(color: PosColors.border, width: 1) : null,
        boxShadow: PosShadows.card,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PosRadii.md),
        child: content,
      );
    }

    return content;
  }
}

// ═══════════════════════════════════════════════════════════════
// CHIP COMPONENT
// ═══════════════════════════════════════════════════════════════

/// Selection chip for categories and filters
class PosChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const PosChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PosRadii.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PosSpacing.md,
            vertical: PosSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? PosColors.primary : PosColors.surface,
            borderRadius: BorderRadius.circular(PosRadii.lg),
            border: Border.all(
              color: isSelected ? PosColors.primary : PosColors.border,
              width: 1.5,
            ),
            boxShadow: isSelected ? PosShadows.primaryGlow : PosShadows.subtle,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? PosColors.textOnPrimary : PosColors.textPrimary,
                ),
                const SizedBox(width: PosSpacing.xs),
              ],
              Text(
                label,
                style: PosTextStyles.labelMedium.copyWith(
                  color: isSelected ? PosColors.textOnPrimary : PosColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SECTION HEADER COMPONENT
// ═══════════════════════════════════════════════════════════════

/// Section header with optional icon
class PosSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;

  const PosSectionHeader({
    Key? key,
    required this.title,
    this.icon,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(PosSpacing.xs),
            decoration: BoxDecoration(
              color: PosColors.primaryContainer,
              borderRadius: BorderRadius.circular(PosRadii.sm),
            ),
            child: Icon(icon, size: 20, color: PosColors.primary),
          ),
          const SizedBox(width: PosSpacing.sm),
        ],
        Expanded(
          child: Text(title, style: PosTextStyles.h3),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EMPTY STATE COMPONENT
// ═══════════════════════════════════════════════════════════════

/// Premium empty state with icon, title, subtitle and optional action
class PosEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const PosEmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(PosSpacing.xl),
            decoration: BoxDecoration(
              color: PosColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: PosColors.textTertiary,
            ),
          ),
          const SizedBox(height: PosSpacing.lg),
          Text(
            title,
            style: PosTextStyles.h3.copyWith(
              color: PosColors.textSecondary,
            ),
          ),
          const SizedBox(height: PosSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: PosTextStyles.bodyMedium.copyWith(
              color: PosColors.textTertiary,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: PosSpacing.xl),
            action!,
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PRICE TAG COMPONENT
// ═══════════════════════════════════════════════════════════════

/// Price display with primary container background
class PosPriceTag extends StatelessWidget {
  final double price;
  final bool isLarge;

  const PosPriceTag({
    Key? key,
    required this.price,
    this.isLarge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? PosSpacing.md : PosSpacing.sm,
        vertical: isLarge ? PosSpacing.sm : PosSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: PosColors.primaryContainer,
        borderRadius: BorderRadius.circular(PosRadii.sm),
        border: Border.all(
          color: PosColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        '${price.toStringAsFixed(2)} €',
        style: isLarge ? PosTextStyles.priceDisplay : PosTextStyles.priceMedium,
      ),
    );
  }
}
