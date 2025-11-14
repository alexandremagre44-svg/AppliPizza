// lib/src/design_system/badges.dart
// Composants badges et tags - Design System Pizza Deli'Zza

import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';
import 'spacing.dart';
import 'radius.dart';

/// Type de badge
enum BadgeType {
  success,
  warning,
  danger,
  info,
  neutral,
  primary,
}

/// Taille de badge
enum BadgeSize {
  small,
  medium,
  large,
}

// ═══════════════════════════════════════════════════════════════
// BADGE STANDARD - AppBadge
// ═══════════════════════════════════════════════════════════════

/// Badge avec différents types et tailles
class AppBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final BadgeSize size;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.text,
    this.type = BadgeType.neutral,
    this.size = BadgeSize.medium,
    this.icon,
  });

  // Factory constructors pour chaque type
  factory AppBadge.success({
    Key? key,
    required String text,
    BadgeSize size = BadgeSize.medium,
    IconData? icon,
  }) {
    return AppBadge(
      key: key,
      text: text,
      type: BadgeType.success,
      size: size,
      icon: icon,
    );
  }

  factory AppBadge.warning({
    Key? key,
    required String text,
    BadgeSize size = BadgeSize.medium,
    IconData? icon,
  }) {
    return AppBadge(
      key: key,
      text: text,
      type: BadgeType.warning,
      size: size,
      icon: icon,
    );
  }

  factory AppBadge.danger({
    Key? key,
    required String text,
    BadgeSize size = BadgeSize.medium,
    IconData? icon,
  }) {
    return AppBadge(
      key: key,
      text: text,
      type: BadgeType.danger,
      size: size,
      icon: icon,
    );
  }

  factory AppBadge.info({
    Key? key,
    required String text,
    BadgeSize size = BadgeSize.medium,
    IconData? icon,
  }) {
    return AppBadge(
      key: key,
      text: text,
      type: BadgeType.info,
      size: size,
      icon: icon,
    );
  }

  factory AppBadge.primary({
    Key? key,
    required String text,
    BadgeSize size = BadgeSize.medium,
    IconData? icon,
  }) {
    return AppBadge(
      key: key,
      text: text,
      type: BadgeType.primary,
      size: size,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final textStyle = _getTextStyle();
    final padding = _getPadding();
    final iconSize = _getIconSize();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.badge,
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: colors.text),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            text,
            style: textStyle.copyWith(color: colors.text),
          ),
        ],
      ),
    );
  }

  ({Color background, Color text, Color border}) _getColors() {
    switch (type) {
      case BadgeType.success:
        return (
          background: AppColors.successLight,
          text: AppColors.successDark,
          border: AppColors.success.withOpacity(0.3),
        );
      case BadgeType.warning:
        return (
          background: AppColors.warningLight,
          text: AppColors.warningDark,
          border: AppColors.warning.withOpacity(0.3),
        );
      case BadgeType.danger:
        return (
          background: AppColors.dangerLight,
          text: AppColors.dangerDark,
          border: AppColors.danger.withOpacity(0.3),
        );
      case BadgeType.info:
        return (
          background: AppColors.infoLight,
          text: AppColors.infoDark,
          border: AppColors.info.withOpacity(0.3),
        );
      case BadgeType.primary:
        return (
          background: AppColors.primaryLighter,
          text: AppColors.primaryDark,
          border: AppColors.primary.withOpacity(0.3),
        );
      case BadgeType.neutral:
        return (
          background: AppColors.neutral100,
          text: AppColors.neutral700,
          border: AppColors.neutral300,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case BadgeSize.small:
        return AppTextStyles.labelSmall;
      case BadgeSize.medium:
        return AppTextStyles.labelMedium;
      case BadgeSize.large:
        return AppTextStyles.labelLarge;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case BadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case BadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case BadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }

  double _getIconSize() {
    switch (size) {
      case BadgeSize.small:
        return 12;
      case BadgeSize.medium:
        return 14;
      case BadgeSize.large:
        return 16;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// TAGS PRODUITS - ProductTag
// ═══════════════════════════════════════════════════════════════

/// Type de tag produit
enum ProductTagType {
  bestSeller,
  nouveau,
  specialiteChef,
  promo,
  vegetarien,
  vegan,
  sansGluten,
  epice,
}

/// Tag pour produits avec types prédéfinis
class ProductTag extends StatelessWidget {
  final ProductTagType type;
  final BadgeSize size;

  const ProductTag({
    super.key,
    required this.type,
    this.size = BadgeSize.medium,
  });

  factory ProductTag.bestSeller({
    Key? key,
    BadgeSize size = BadgeSize.medium,
  }) {
    return ProductTag(key: key, type: ProductTagType.bestSeller, size: size);
  }

  factory ProductTag.nouveau({
    Key? key,
    BadgeSize size = BadgeSize.medium,
  }) {
    return ProductTag(key: key, type: ProductTagType.nouveau, size: size);
  }

  factory ProductTag.specialiteChef({
    Key? key,
    BadgeSize size = BadgeSize.medium,
  }) {
    return ProductTag(key: key, type: ProductTagType.specialiteChef, size: size);
  }

  factory ProductTag.promo({
    Key? key,
    BadgeSize size = BadgeSize.medium,
  }) {
    return ProductTag(key: key, type: ProductTagType.promo, size: size);
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    
    return AppBadge(
      text: config.label,
      type: config.badgeType,
      size: size,
      icon: config.icon,
    );
  }

  ({String label, BadgeType badgeType, IconData icon}) _getConfig() {
    switch (type) {
      case ProductTagType.bestSeller:
        return (
          label: 'Best Seller',
          badgeType: BadgeType.primary,
          icon: Icons.star,
        );
      case ProductTagType.nouveau:
        return (
          label: 'Nouveau',
          badgeType: BadgeType.info,
          icon: Icons.fiber_new,
        );
      case ProductTagType.specialiteChef:
        return (
          label: 'Spécialité Chef',
          badgeType: BadgeType.warning,
          icon: Icons.restaurant,
        );
      case ProductTagType.promo:
        return (
          label: 'Promo',
          badgeType: BadgeType.danger,
          icon: Icons.local_offer,
        );
      case ProductTagType.vegetarien:
        return (
          label: 'Végétarien',
          badgeType: BadgeType.success,
          icon: Icons.eco,
        );
      case ProductTagType.vegan:
        return (
          label: 'Vegan',
          badgeType: BadgeType.success,
          icon: Icons.spa,
        );
      case ProductTagType.sansGluten:
        return (
          label: 'Sans Gluten',
          badgeType: BadgeType.info,
          icon: Icons.no_meals,
        );
      case ProductTagType.epice:
        return (
          label: 'Épicé',
          badgeType: BadgeType.danger,
          icon: Icons.local_fire_department,
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// BADGE STATUT - StatusBadge
// ═══════════════════════════════════════════════════════════════

/// Badge de statut avec point coloré
class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final bool showDot;
  final BadgeSize size;

  const StatusBadge({
    super.key,
    required this.text,
    this.type = BadgeType.neutral,
    this.showDot = true,
    this.size = BadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final textStyle = _getTextStyle();
    final padding = _getPadding();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.badge,
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.dot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            text,
            style: textStyle.copyWith(color: colors.text),
          ),
        ],
      ),
    );
  }

  ({Color background, Color text, Color border, Color dot}) _getColors() {
    switch (type) {
      case BadgeType.success:
        return (
          background: AppColors.successLight,
          text: AppColors.successDark,
          border: AppColors.success.withOpacity(0.3),
          dot: AppColors.success,
        );
      case BadgeType.warning:
        return (
          background: AppColors.warningLight,
          text: AppColors.warningDark,
          border: AppColors.warning.withOpacity(0.3),
          dot: AppColors.warning,
        );
      case BadgeType.danger:
        return (
          background: AppColors.dangerLight,
          text: AppColors.dangerDark,
          border: AppColors.danger.withOpacity(0.3),
          dot: AppColors.danger,
        );
      case BadgeType.info:
        return (
          background: AppColors.infoLight,
          text: AppColors.infoDark,
          border: AppColors.info.withOpacity(0.3),
          dot: AppColors.info,
        );
      case BadgeType.primary:
        return (
          background: AppColors.primaryLighter,
          text: AppColors.primaryDark,
          border: AppColors.primary.withOpacity(0.3),
          dot: AppColors.primary,
        );
      case BadgeType.neutral:
        return (
          background: AppColors.neutral100,
          text: AppColors.neutral700,
          border: AppColors.neutral300,
          dot: AppColors.neutral600,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case BadgeSize.small:
        return AppTextStyles.labelSmall;
      case BadgeSize.medium:
        return AppTextStyles.labelMedium;
      case BadgeSize.large:
        return AppTextStyles.labelLarge;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case BadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case BadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case BadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// BADGE COMPTEUR - CountBadge
// ═══════════════════════════════════════════════════════════════

/// Badge compteur circulaire (notification)
class CountBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final BadgeSize size;

  const CountBadge({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.size = BadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final displayCount = count > 99 ? '99+' : count.toString();
    final bgColor = backgroundColor ?? AppColors.primary;
    final fgColor = textColor ?? AppColors.white;
    final badgeSize = _getSize();
    final textStyle = _getTextStyle();

    return Container(
      constraints: BoxConstraints(
        minWidth: badgeSize,
        minHeight: badgeSize,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(badgeSize / 2),
      ),
      child: Center(
        child: Text(
          displayCount,
          style: textStyle.copyWith(color: fgColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  double _getSize() {
    switch (size) {
      case BadgeSize.small:
        return 16;
      case BadgeSize.medium:
        return 20;
      case BadgeSize.large:
        return 24;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case BadgeSize.small:
        return AppTextStyles.captionSmall.copyWith(fontWeight: FontWeight.w600);
      case BadgeSize.medium:
        return AppTextStyles.captionMedium.copyWith(fontWeight: FontWeight.w600);
      case BadgeSize.large:
        return AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// BADGE PRIX - PriceBadge
// ═══════════════════════════════════════════════════════════════

/// Badge pour afficher un prix avec style accentué
class PriceBadge extends StatelessWidget {
  final double price;
  final bool showEuro;
  final BadgeSize size;

  const PriceBadge({
    super.key,
    required this.price,
    this.showEuro = true,
    this.size = BadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final priceText = showEuro ? '${price.toStringAsFixed(2)} €' : price.toStringAsFixed(2);
    final textStyle = _getTextStyle();

    return Container(
      padding: _getPadding(),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: AppRadius.badge,
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Text(
        priceText,
        style: textStyle.copyWith(color: AppColors.primary),
      ),
    );
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case BadgeSize.small:
        return AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700);
      case BadgeSize.medium:
        return AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700);
      case BadgeSize.large:
        return AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700);
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case BadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case BadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case BadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }
}
