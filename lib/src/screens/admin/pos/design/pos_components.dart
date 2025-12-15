// lib/src/screens/admin/pos/design/pos_components.dart
// Composants réutilisables POS - ShopCaisse Theme

import 'package:flutter/material.dart';
import 'pos_theme.dart';

/// Variants de bouton POS
enum PosButtonVariant { primary, secondary, success, danger, ghost }

/// Tailles de bouton POS
enum PosButtonSize { small, medium, large }

/// Bouton premium POS avec variants et tailles
class PosButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final PosButtonVariant variant;
  final PosButtonSize size;
  final IconData? icon;
  final bool fullWidth;
  final bool loading;

  const PosButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.variant = PosButtonVariant.primary,
    this.size = PosButtonSize.medium,
    this.icon,
    this.fullWidth = false,
    this.loading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, gradient) = _getColors();
    final (fontSize, height, padding) = _getSizes();
    
    final isDisabled = onPressed == null || loading;

    Widget buttonChild = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: fontSize,
            height: fontSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        else if (icon != null)
          Icon(icon, size: fontSize * 1.2),
        if ((icon != null || loading) && label.isNotEmpty) SizedBox(width: PosSpacing.xs),
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: fgColor,
              letterSpacing: 0.3,
            ),
          ),
      ],
    );

    return Container(
      decoration: gradient != null && !isDisabled
          ? BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(PosRadii.md),
              boxShadow: _getShadow(),
            )
          : null,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: gradient == null ? bgColor : Colors.transparent,
          foregroundColor: fgColor,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
          minimumSize: Size(fullWidth ? double.infinity : 0, height),
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PosRadii.md),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: buttonChild,
      ),
    );
  }

  (Color, Color, LinearGradient?) _getColors() {
    switch (variant) {
      case PosButtonVariant.primary:
        return (PosColors.primary, PosColors.onPrimary, PosColors.primaryGradient);
      case PosButtonVariant.secondary:
        return (PosColors.surfaceVariant, PosColors.textPrimary, null);
      case PosButtonVariant.success:
        return (
          PosColors.success,
          Colors.white,
          LinearGradient(
            colors: [PosColors.success, PosColors.success.withOpacity(0.8)],
          ),
        );
      case PosButtonVariant.danger:
        return (
          PosColors.danger,
          Colors.white,
          LinearGradient(
            colors: [PosColors.danger, PosColors.danger.withOpacity(0.8)],
          ),
        );
      case PosButtonVariant.ghost:
        return (Colors.transparent, PosColors.primary, null);
    }
  }

  (double, double, double) _getSizes() {
    switch (size) {
      case PosButtonSize.small:
        return (12.0, 36.0, PosSpacing.sm);
      case PosButtonSize.medium:
        return (16.0, 48.0, PosSpacing.md);
      case PosButtonSize.large:
        return (18.0, 64.0, PosSpacing.lg);
    }
  }

  List<BoxShadow>? _getShadow() {
    if (variant == PosButtonVariant.primary) {
      return PosShadows.primaryGlow;
    } else if (variant == PosButtonVariant.success) {
      return PosShadows.successGlow;
    }
    return null;
  }
}

/// Carte premium POS
class PosCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final bool withShadow;
  final bool withBorder;
  final VoidCallback? onTap;

  const PosCard({
    Key? key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.withShadow = true,
    this.withBorder = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardChild = Container(
      padding: padding ?? EdgeInsets.all(PosSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? PosColors.surface,
        borderRadius: BorderRadius.circular(PosRadii.md),
        border: withBorder ? Border.all(color: PosColors.border) : null,
        boxShadow: withShadow ? PosShadows.card : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PosRadii.md),
        child: cardChild,
      );
    }

    return cardChild;
  }
}

/// Chip/Tag pour sélection (catégories, types de commande)
class PosChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const PosChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PosRadii.md),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: PosSpacing.md,
          vertical: PosSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? PosColors.primaryGradient : null,
          color: isSelected ? null : PosColors.surface,
          borderRadius: BorderRadius.circular(PosRadii.md),
          border: Border.all(
            color: isSelected ? PosColors.primary : PosColors.border,
            width: isSelected ? 2 : 1.5,
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
                color: isSelected ? PosColors.onPrimary : PosColors.primary,
              ),
              SizedBox(width: PosSpacing.xs),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? PosColors.onPrimary : PosColors.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Titre de section avec icône optionnelle
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: PosSpacing.sm),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: PosColors.primary, size: 24),
            SizedBox(width: PosSpacing.sm),
          ],
          Expanded(
            child: Text(
              title,
              style: PosTextStyles.h3,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// État vide premium (icône dans cercle gris, titre, subtitle, action optionnelle)
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
            padding: EdgeInsets.all(PosSpacing.xl),
            decoration: BoxDecoration(
              color: PosColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 72,
              color: PosColors.textTertiary,
            ),
          ),
          SizedBox(height: PosSpacing.lg),
          Text(
            title,
            style: PosTextStyles.h3.copyWith(
              color: PosColors.textSecondary,
            ),
          ),
          SizedBox(height: PosSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: PosTextStyles.bodyMedium.copyWith(
              color: PosColors.textTertiary,
            ),
          ),
          if (action != null) ...[
            SizedBox(height: PosSpacing.xl),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Affichage prix avec fond primaryContainer
class PosPriceTag extends StatelessWidget {
  final double price;
  final TextStyle? style;
  final bool large;

  const PosPriceTag({
    Key? key,
    required this.price,
    this.style,
    this.large = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? PosSpacing.md : PosSpacing.sm,
        vertical: large ? PosSpacing.sm : PosSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: PosColors.primaryContainer,
        borderRadius: BorderRadius.circular(PosRadii.sm),
        border: Border.all(
          color: PosColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        '${price.toStringAsFixed(2)} €',
        style: style ??
            (large ? PosTextStyles.priceDisplay : PosTextStyles.priceMedium),
      ),
    );
  }
}
