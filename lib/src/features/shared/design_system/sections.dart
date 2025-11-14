// lib/src/design_system/sections.dart
// Composants de sections - Design System Pizza Deli'Zza

import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';
import 'spacing.dart';

// ═══════════════════════════════════════════════════════════════
// SECTION TITLE - Titre de section
// ═══════════════════════════════════════════════════════════════

/// Titre de section avec style cohérent
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsets? padding;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? AppSpacing.paddingVerticalMD,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SECTION SUBTITLE - Sous-titre de section
// ═══════════════════════════════════════════════════════════════

/// Sous-titre de section
class SectionSubtitle extends StatelessWidget {
  final String subtitle;
  final EdgeInsets? padding;

  const SectionSubtitle({
    super.key,
    required this.subtitle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? AppSpacing.paddingVerticalSM,
      child: Text(
        subtitle,
        style: AppTextStyles.titleMedium,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SECTION HEADER - En-tête de section avec actions
// ═══════════════════════════════════════════════════════════════

/// En-tête de section avec titre et actions
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final EdgeInsets? padding;
  final bool showDivider;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.padding,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding ?? AppSpacing.paddingVerticalMD,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.headlineMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: AppColors.borderSubtle),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SECTION CARD GROUP - Groupe de cartes avec titre
// ═══════════════════════════════════════════════════════════════

/// Groupe de cartes avec titre de section
class SectionCardGroup extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsets? padding;
  final Widget? trailing;

  const SectionCardGroup({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.crossAxisCount = 3,
    this.mainAxisSpacing = AppSpacing.md,
    this.crossAxisSpacing = AppSpacing.md,
    this.childAspectRatio = 1.0,
    this.padding,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          padding: padding,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive: ajuster le nombre de colonnes selon la largeur
            int columns = crossAxisCount;
            if (constraints.maxWidth < 600) {
              columns = 1;
            } else if (constraints.maxWidth < 900) {
              columns = 2;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: mainAxisSpacing,
                crossAxisSpacing: crossAxisSpacing,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: children.length,
              itemBuilder: (context, index) => children[index],
            );
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SECTION DIVIDER - Séparateur de section
// ═══════════════════════════════════════════════════════════════

/// Séparateur de section avec ou sans label
class SectionDivider extends StatelessWidget {
  final String? label;
  final EdgeInsets? padding;

  const SectionDivider({
    super.key,
    this.label,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return Padding(
        padding: padding ?? AppSpacing.paddingVerticalLG,
        child: Row(
          children: [
            const Expanded(
              child: Divider(color: AppColors.border, thickness: 1),
            ),
            Padding(
              padding: AppSpacing.paddingHorizontalMD,
              child: Text(
                label!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: AppColors.border, thickness: 1),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: padding ?? AppSpacing.paddingVerticalLG,
      child: const Divider(color: AppColors.border, thickness: 1),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SECTION CONTAINER - Container de section avec background
// ═══════════════════════════════════════════════════════════════

/// Container de section avec background et padding
class SectionContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const SectionContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? AppSpacing.sectionPadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
      ),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// RESPONSIVE GRID - Grille responsive pour cartes
// ═══════════════════════════════════════════════════════════════

/// Grille responsive qui s'adapte automatiquement
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final EdgeInsets? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 300,
    this.spacing = AppSpacing.md,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculer le nombre de colonnes
          final columns = (constraints.maxWidth / minItemWidth).floor();
          final effectiveColumns = columns < 1 ? 1 : columns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: children.map((child) {
              final itemWidth = (constraints.maxWidth - (spacing * (effectiveColumns - 1))) / effectiveColumns;
              return SizedBox(
                width: itemWidth,
                child: child,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TWO COLUMN LAYOUT - Layout 2 colonnes responsive
// ═══════════════════════════════════════════════════════════════

/// Layout 2 colonnes qui devient 1 colonne sur mobile
class TwoColumnLayout extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double spacing;
  final double breakpoint;
  final int leftFlex;
  final int rightFlex;

  const TwoColumnLayout({
    super.key,
    required this.left,
    required this.right,
    this.spacing = AppSpacing.md,
    this.breakpoint = 768,
    this.leftFlex = 1,
    this.rightFlex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          // Mobile: 1 colonne
          return Column(
            children: [
              left,
              SizedBox(height: spacing),
              right,
            ],
          );
        }

        // Desktop: 2 colonnes
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: leftFlex, child: left),
            SizedBox(width: spacing),
            Expanded(flex: rightFlex, child: right),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// THREE COLUMN LAYOUT - Layout 3 colonnes responsive
// ═══════════════════════════════════════════════════════════════

/// Layout 3 colonnes qui s'adapte (3 → 2 → 1)
class ThreeColumnLayout extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double breakpointTablet;
  final double breakpointMobile;

  const ThreeColumnLayout({
    super.key,
    required this.children,
    this.spacing = AppSpacing.md,
    this.breakpointTablet = 900,
    this.breakpointMobile = 600,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 3;
        if (constraints.maxWidth < breakpointMobile) {
          columns = 1;
        } else if (constraints.maxWidth < breakpointTablet) {
          columns = 2;
        }

        if (columns == 1) {
          return Column(
            children: _intersperse(
              children,
              SizedBox(height: spacing),
            ),
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += columns) {
          final rowChildren = children.skip(i).take(columns).toList();
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _intersperse(
                rowChildren.map((child) => Expanded(child: child)).toList(),
                SizedBox(width: spacing),
              ),
            ),
          );
        }

        return Column(
          children: _intersperse(
            rows,
            SizedBox(height: spacing),
          ),
        );
      },
    );
  }

  List<Widget> _intersperse(List<Widget> list, Widget separator) {
    if (list.isEmpty) return [];
    return list
        .expand((item) => [item, separator])
        .toList()
        ..removeLast();
  }
}
