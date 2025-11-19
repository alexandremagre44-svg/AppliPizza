// lib/src/design_system/cards.dart
// Composants cartes réutilisables - Design System Pizza Deli'Zza Material 3 (2025)

import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';
import 'spacing.dart';
import 'radius.dart';
import 'shadows.dart';

// ═══════════════════════════════════════════════════════════════
// CARTE STANDARD - AppCard
// ═══════════════════════════════════════════════════════════════

/// Carte standard Material 3 avec padding et ombre
/// 
/// Material 3:
/// - Background: surfaceContainerLow (#F5F5F5)
/// - Radius: 16px
/// - Shadow: light (0 1px 2px rgba(0,0,0,0.08))
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool interactive;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.boxShadow,
    this.borderRadius,
    this.onTap,
    this.interactive = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerLow, // Material 3: #F5F5F5
        borderRadius: borderRadius ?? AppRadius.card, // Material 3: 16px
        boxShadow: boxShadow ?? AppShadows.small, // Material 3: light shadow
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: child,
    );

    if (onTap != null || interactive) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? AppRadius.card,
          hoverColor: AppColors.neutral50,
          child: card,
        ),
      );
    }

    return card;
  }
}

// ═══════════════════════════════════════════════════════════════
// CARTE AVEC SECTION - AppSectionCard
// ═══════════════════════════════════════════════════════════════

/// Carte avec titre de section et contenu
class AppSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets? padding;
  final bool collapsible;
  final bool initiallyExpanded;
  final VoidCallback? onHeaderTap;

  const AppSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.padding,
    this.collapsible = false,
    this.initiallyExpanded = true,
    this.onHeaderTap,
  });

  @override
  Widget build(BuildContext context) {
    if (collapsible) {
      return _buildCollapsibleCard();
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: padding ?? AppSpacing.cardPadding,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: onHeaderTap,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppRadius.small),
        topRight: Radius.circular(AppRadius.small),
      ),
      child: Container(
        padding: AppSpacing.paddingMD,
        decoration: const BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.small),
            topRight: Radius.circular(AppRadius.small),
          ),
          border: Border(
            bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleCard() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text(title, style: AppTextStyles.titleMedium),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: trailing,
        initiallyExpanded: initiallyExpanded,
        backgroundColor: AppColors.white,
        collapsedBackgroundColor: AppColors.white,
        tilePadding: AppSpacing.paddingMD,
        childrenPadding: padding ?? AppSpacing.cardPadding,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
        ),
        children: [child],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CARTE INTERACTIVE - AppInteractiveCard
// ═══════════════════════════════════════════════════════════════

/// Carte avec hover/focus pour sélection
class AppInteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool selected;
  final EdgeInsets? padding;

  const AppInteractiveCard({
    super.key,
    required this.child,
    required this.onTap,
    this.selected = false,
    this.padding,
  });

  @override
  State<AppInteractiveCard> createState() => _AppInteractiveCardState();
}

class _AppInteractiveCardState extends State<AppInteractiveCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: widget.padding ?? AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: widget.selected
              ? AppColors.primaryContainer // Material 3: #F9DEDE
              : (_isHovering ? AppColors.surfaceContainerLow : AppColors.surface),
          borderRadius: AppRadius.card, // Material 3: 16px
          boxShadow: _isHovering || widget.selected
              ? AppShadows.medium
              : AppShadows.small,
          border: Border.all(
            color: widget.selected
                ? AppColors.primary
                : (_isHovering ? AppColors.outline : AppColors.outlineVariant),
            width: widget.selected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: AppRadius.card,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CARTE LISTE/TABLEAU - AppListCard
// ═══════════════════════════════════════════════════════════════

/// Carte pour affichage liste avec hover sur les lignes
class AppListCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsets? itemPadding;
  final bool showDividers;

  const AppListCard({
    super.key,
    this.title,
    required this.children,
    this.itemPadding,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: AppSpacing.paddingMD,
              child: Text(title!, style: AppTextStyles.titleMedium),
            ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            separatorBuilder: (context, index) {
              return showDividers
                  ? const Divider(height: 1, color: AppColors.borderSubtle)
                  : const SizedBox.shrink();
            },
            itemBuilder: (context, index) {
              return _ListCardItem(
                padding: itemPadding ?? AppSpacing.paddingMD,
                child: children[index],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ListCardItem extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;

  const _ListCardItem({
    required this.child,
    required this.padding,
  });

  @override
  State<_ListCardItem> createState() => _ListCardItemState();
}

class _ListCardItemState extends State<_ListCardItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _isHovering ? AppColors.neutral50 : Colors.transparent,
        padding: widget.padding,
        child: widget.child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CARTE STATISTIQUE - AppStatCard
// ═══════════════════════════════════════════════════════════════

/// Carte pour afficher une statistique avec icône
class AppStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AppStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      interactive: onTap != null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.1),
              borderRadius: AppRadius.radiusSmall,
            ),
            child: Icon(
              icon,
              size: 24,
              color: iconColor ?? AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(value, style: AppTextStyles.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    style: AppTextStyles.captionLarge.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CARTE AVEC IMAGE - AppImageCard
// ═══════════════════════════════════════════════════════════════

/// Carte avec image en haut et contenu en bas
class AppImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double imageHeight;

  const AppImageCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.imageHeight = 180,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      interactive: onTap != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.small),
              topRight: Radius.circular(AppRadius.small),
            ),
            child: Image.network(
              imageUrl,
              height: imageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: imageHeight,
                  color: AppColors.neutral100,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: AppColors.neutral400,
                    ),
                  ),
                );
              },
            ),
          ),
          // Contenu
          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: AppTextStyles.titleMedium),
                          if (subtitle != null) ...[
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              subtitle!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CARTE VIDE - AppEmptyCard
// ═══════════════════════════════════════════════════════════════

/// Carte pour état vide avec icône et message
class AppEmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const AppEmptyCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.paddingXL,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
