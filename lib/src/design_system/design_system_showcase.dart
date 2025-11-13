// lib/src/design_system/design_system_showcase.dart
// Showcase du Design System - Exemples d'utilisation

import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Écran de démonstration du design system
/// 
/// Pour tester: Créer une route vers DesignSystemShowcase() dans l'app
class DesignSystemShowcase extends StatelessWidget {
  const DesignSystemShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Showcase'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════ COLORS ═══════
            SectionHeader(
              title: 'Couleurs',
              subtitle: 'Palette complète Pizza Deli\'Zza',
              showDivider: true,
            ),
            AppSpacing.verticalSpaceMD,
            _buildColorSection(),
            
            AppSpacing.verticalSpaceXL,
            
            // ═══════ TYPOGRAPHY ═══════
            SectionHeader(
              title: 'Typographie',
              subtitle: 'Hiérarchie des textes',
              showDivider: true,
            ),
            AppSpacing.verticalSpaceMD,
            _buildTypographySection(),
            
            AppSpacing.verticalSpaceXL,
            
            // ═══════ BUTTONS ═══════
            SectionHeader(
              title: 'Boutons',
              subtitle: 'Tous les types de boutons',
              showDivider: true,
            ),
            AppSpacing.verticalSpaceMD,
            _buildButtonsSection(),
            
            AppSpacing.verticalSpaceXL,
            
            // ═══════ INPUTS ═══════
            SectionHeader(
              title: 'Champs de formulaire',
              subtitle: 'Inputs et contrôles',
              showDivider: true,
            ),
            AppSpacing.verticalSpaceMD,
            _buildInputsSection(),
            
            AppSpacing.verticalSpaceXL,
            
            // ═══════ CARDS ═══════
            SectionHeader(
              title: 'Cartes',
              subtitle: 'Différents types de cartes',
              showDivider: true,
            ),
            AppSpacing.verticalSpaceMD,
            _buildCardsSection(),
            
            AppSpacing.verticalSpaceXL,
            
            // ═══════ BADGES ═══════
            SectionHeader(
              title: 'Badges',
              subtitle: 'Badges et tags',
              showDivider: true,
            ),
            AppSpacing.verticalSpaceMD,
            _buildBadgesSection(),
            
            AppSpacing.verticalSpaceXL,
            
            // ═══════ RESPONSIVE ═══════
            SectionHeader(
              title: 'Responsive',
              subtitle: 'Layouts adaptatifs',
              showDivider: true,
            ),
            AppSpacing.verticalSpaceMD,
            _buildResponsiveSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _colorCard('Primary', AppColors.primary),
        _colorCard('Primary Light', AppColors.primaryLight),
        _colorCard('Primary Dark', AppColors.primaryDark),
        _colorCard('Success', AppColors.success),
        _colorCard('Warning', AppColors.warning),
        _colorCard('Danger', AppColors.danger),
        _colorCard('Info', AppColors.info),
        _colorCard('Neutral 100', AppColors.neutral100),
        _colorCard('Neutral 500', AppColors.neutral500),
        _colorCard('Neutral 900', AppColors.neutral900),
      ],
    );
  }

  Widget _colorCard(String name, Color color) {
    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          name,
          style: AppTextStyles.captionSmall.copyWith(
            color: _getContrastColor(color),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildTypographySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Display Large', style: AppTextStyles.displayLarge),
        AppSpacing.verticalSpaceXS,
        Text('Headline Large (H1)', style: AppTextStyles.h1),
        AppSpacing.verticalSpaceXS,
        Text('Headline Medium (H2)', style: AppTextStyles.h2),
        AppSpacing.verticalSpaceXS,
        Text('Headline Small (H3)', style: AppTextStyles.h3),
        AppSpacing.verticalSpaceXS,
        Text('Title Large', style: AppTextStyles.titleLarge),
        AppSpacing.verticalSpaceXS,
        Text('Title Medium', style: AppTextStyles.titleMedium),
        AppSpacing.verticalSpaceXS,
        Text('Body Large', style: AppTextStyles.bodyLarge),
        AppSpacing.verticalSpaceXS,
        Text('Body Medium', style: AppTextStyles.bodyMedium),
        AppSpacing.verticalSpaceXS,
        Text('Body Small', style: AppTextStyles.bodySmall),
        AppSpacing.verticalSpaceXS,
        Text('Label Large', style: AppTextStyles.labelLarge),
        AppSpacing.verticalSpaceXS,
        Text('Caption', style: AppTextStyles.captionLarge),
      ],
    );
  }

  Widget _buildButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton.primary(text: 'Primary', onPressed: () {}),
            AppButton.secondary(text: 'Secondary', onPressed: () {}),
            AppButton.outline(text: 'Outline', onPressed: () {}),
            AppButton.ghost(text: 'Ghost', onPressed: () {}),
            AppButton.danger(text: 'Danger', onPressed: () {}),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton.primary(
              text: 'Avec icône',
              icon: Icons.add,
              onPressed: () {},
            ),
            AppButton.primary(
              text: 'Loading',
              isLoading: true,
              onPressed: () {},
            ),
            AppButton.primary(
              text: 'Disabled',
              onPressed: null,
            ),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            AppIconButton.primary(icon: Icons.edit, onPressed: () {}),
            AppSpacing.horizontalSpaceSM,
            AppIconButton.secondary(icon: Icons.delete, onPressed: () {}),
            AppSpacing.horizontalSpaceSM,
            AppIconButton.ghost(icon: Icons.more_vert, onPressed: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildInputsSection() {
    return Column(
      children: [
        const AppTextField(
          label: 'Nom',
          hint: 'Entrez votre nom',
        ),
        AppSpacing.verticalSpaceMD,
        const AppTextFieldWithIcon(
          label: 'Email',
          hint: 'email@example.com',
          icon: Icons.email,
        ),
        AppSpacing.verticalSpaceMD,
        AppDropdown<String>(
          label: 'Catégorie',
          hint: 'Sélectionner',
          items: const [
            DropdownMenuItem(value: 'pizza', child: Text('Pizza')),
            DropdownMenuItem(value: 'boisson', child: Text('Boisson')),
            DropdownMenuItem(value: 'dessert', child: Text('Dessert')),
          ],
          onChanged: (value) {},
        ),
        AppSpacing.verticalSpaceMD,
        const AppCheckbox(
          label: 'J\'accepte les conditions',
          value: false,
        ),
      ],
    );
  }

  Widget _buildCardsSection() {
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Carte Standard', style: AppTextStyles.titleMedium),
              AppSpacing.verticalSpaceXS,
              Text(
                'Une carte simple avec padding et ombre',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        AppSpacing.verticalSpaceMD,
        AppSectionCard(
          title: 'Carte avec Section',
          subtitle: 'Section avec titre',
          child: Text(
            'Contenu de la carte avec header stylisé',
            style: AppTextStyles.bodyMedium,
          ),
        ),
        AppSpacing.verticalSpaceMD,
        AppStatCard(
          title: 'Commandes',
          value: '42',
          icon: Icons.shopping_bag,
          subtitle: '+12% ce mois',
        ),
        AppSpacing.verticalSpaceMD,
        AppEmptyCard(
          icon: Icons.inbox,
          title: 'Aucun élément',
          subtitle: 'Commencez par ajouter votre premier élément',
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        AppBadge.success(text: 'Succès'),
        AppBadge.warning(text: 'Attention'),
        AppBadge.danger(text: 'Danger'),
        AppBadge.info(text: 'Info'),
        AppBadge.primary(text: 'Primary'),
        ProductTag.bestSeller(),
        ProductTag.nouveau(),
        ProductTag.specialiteChef(),
        StatusBadge(text: 'En ligne', type: BadgeType.success),
        StatusBadge(text: 'Hors ligne', type: BadgeType.danger),
        const CountBadge(count: 5),
        const CountBadge(count: 123),
        const PriceBadge(price: 12.50),
      ],
    );
  }

  Widget _buildResponsiveSection() {
    return Column(
      children: [
        TwoColumnLayout(
          left: AppCard(
            child: Text('Colonne 1', style: AppTextStyles.titleMedium),
          ),
          right: AppCard(
            child: Text('Colonne 2', style: AppTextStyles.titleMedium),
          ),
        ),
        AppSpacing.verticalSpaceMD,
        ResponsiveGrid(
          children: List.generate(
            6,
            (index) => AppCard(
              child: Center(
                child: Text(
                  'Card ${index + 1}',
                  style: AppTextStyles.titleSmall,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
