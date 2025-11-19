// lib/src/screens/admin/studio/popup_block_list.dart
// PopupBlockList - Liste complète des popups et roulette pour Studio Builder
// Material 3 + Pizza Deli'Zza Brand Guidelines

import 'package:flutter/material.dart';
import '../../../models/popup_config.dart';
import '../../../services/popup_service.dart';
import '../../../services/roulette_rules_service.dart';
import '../../../design_system/app_theme.dart';
import 'popup_block_editor.dart';

/// Liste complète des popups et configuration de la roulette
/// Conforme Material 3 et Brand Guidelines Pizza Deli'Zza
class PopupBlockList extends StatefulWidget {
  const PopupBlockList({super.key});

  @override
  State<PopupBlockList> createState() => _PopupBlockListState();
}

class _PopupBlockListState extends State<PopupBlockList> {
  final PopupService _popupService = PopupService();
  final RouletteRulesService _rouletteRulesService = RouletteRulesService();

  List<PopupConfig> _popups = [];
  RouletteRules? _rouletteRules;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Charge les popups et les règles de la roulette
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final popups = await _popupService.getAllPopups();
      final rules = await _rouletteRulesService.getRules();

      // Si aucune règle n'existe, créer les règles par défaut
      if (rules == null) {
        const defaultRules = RouletteRules();
        await _rouletteRulesService.saveRules(defaultRules);
        setState(() {
          _popups = popups;
          _rouletteRules = defaultRules;
        });
      } else {
        setState(() {
          _popups = popups;
          _rouletteRules = rules;
        });
      }
    } catch (e) {
      _showSnackBar('Erreur lors du chargement: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Popups & Roulette',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.paddingMD,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section Popups
                    _buildPopupsSection(),
                    SizedBox(height: AppSpacing.lg),
                    // Section Roulette
                    _buildRouletteSection(),
                  ],
                ),
              ),
            ),
    );
  }

  /// Section des popups
  Widget _buildPopupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // En-tête avec bouton créer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popups promotionnelles',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            FilledButton.icon(
              onPressed: _createPopup,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Créer une popup'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),

        // Liste des popups
        if (_popups.isEmpty)
          _buildEmptyState(
            icon: Icons.notifications_outlined,
            title: 'Aucune popup',
            subtitle: 'Créez des popups pour communiquer avec vos clients',
          )
        else
          ..._popups.map((popup) => _buildPopupCard(popup)),
      ],
    );
  }

  /// Section de la roulette
  Widget _buildRouletteSection() {
    final rules = _rouletteRules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // En-tête
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Roulette de la chance',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (rules != null)
              FilledButton.icon(
                onPressed: () => _editRoulette(rules),
                icon: const Icon(Icons.edit, size: 20),
                label: const Text('Modifier'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.md),

        // Card de la roulette
        if (rules != null) _buildRouletteCard(rules),
      ],
    );
  }

  /// Card d'une popup
  Widget _buildPopupCard(PopupConfig popup) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(
          color: popup.isEnabled
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.outline,
          width: 1,
        ),
      ),
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec titre et switch
            Row(
              children: [
                // Icône de type
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: popup.isEnabled
                        ? AppColors.primaryContainer
                        : AppColors.surfaceContainer,
                    borderRadius: AppRadius.radiusSmall,
                  ),
                  child: Icon(
                    _getPopupIcon(popup.type ?? 'info'),
                    color: popup.isEnabled
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                // Titre
                Expanded(
                  child: Text(
                    popup.title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                // Switch de visibilité
                Switch(
                  value: popup.isEnabled,
                  onChanged: (value) => _togglePopupVisibility(popup, value),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),

            // Message
            Text(
              popup.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSpacing.sm),

            // Méta-informations
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                _buildChip(
                  label: popup.type ?? 'info',
                  color: AppColors.primaryContainer,
                ),
                if (popup.targetAudience != null)
                  _buildChip(
                    label: popup.targetAudience!,
                    color: AppColors.secondaryContainer,
                  ),
                _buildChip(
                  label: popup.isEnabled ? 'Actif' : 'Inactif',
                  color: popup.isEnabled
                      ? AppColors.successContainer
                      : AppColors.surfaceContainer,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _editPopup(popup),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Modifier'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                TextButton.icon(
                  onPressed: () => _deletePopup(popup),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Supprimer'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Card de la roulette
  Widget _buildRouletteCard(RouletteRules rules) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(
          color: rules.isEnabled
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.outline,
          width: 1,
        ),
      ),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: rules.isEnabled
                        ? AppColors.primaryContainer
                        : AppColors.surfaceContainer,
                    borderRadius: AppRadius.radiusSmall,
                  ),
                  child: Icon(
                    Icons.casino,
                    color: rules.isEnabled
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Roulette de la chance',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Switch(
                  value: rules.isEnabled,
                  onChanged: (value) => _toggleRouletteVisibility(rules, value),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            // Informations
            _buildInfoRow('Délai entre tirages', '${rules.cooldownHours}h'),
            _buildInfoRow('Max utilisations/jour', '${rules.maxPlaysPerDay}'),
            _buildInfoRow('Horaires autorisés', '${rules.allowedStartHour}h-${rules.allowedEndHour}h'),
            SizedBox(height: AppSpacing.sm),

            // Statut
            _buildChip(
              label: rules.isEnabled ? 'Active' : 'Inactive',
              color: rules.isEnabled
                  ? AppColors.successContainer
                  : AppColors.surfaceContainer,
            ),
          ],
        ),
      ),
    );
  }

  /// État vide
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: AppSpacing.paddingXXL,
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Ligne d'information
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Chip stylisé
  Widget _buildChip({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  /// Icône selon le type de popup
  IconData _getPopupIcon(String type) {
    switch (type) {
      case 'promo':
        return Icons.local_offer;
      case 'info':
        return Icons.info;
      case 'fidelite':
        return Icons.loyalty;
      case 'systeme':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  /// Créer une nouvelle popup
  Future<void> _createPopup() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const PopupBlockEditor(),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  /// Éditer une popup
  Future<void> _editPopup(PopupConfig popup) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PopupBlockEditor(existingPopup: popup),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  /// Éditer la roulette
  Future<void> _editRoulette(RouletteRules rules) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PopupBlockEditor(
          isRouletteMode: true,
          existingRouletteRules: rules,
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  /// Basculer la visibilité d'une popup
  Future<void> _togglePopupVisibility(PopupConfig popup, bool isEnabled) async {
    final updated = popup.copyWith(isEnabled: isEnabled);
    final success = await _popupService.updatePopup(updated);

    if (success) {
      _loadData();
      _showSnackBar(
        'Popup ${isEnabled ? 'activée' : 'désactivée'}',
      );
    } else {
      _showSnackBar('Erreur lors de la mise à jour', isError: true);
    }
  }

  /// Basculer la visibilité de la roulette
  Future<void> _toggleRouletteVisibility(
    RouletteRules rules,
    bool isEnabled,
  ) async {
    try {
      final updated = rules.copyWith(isEnabled: isEnabled);
      await _rouletteRulesService.saveRules(updated);
      
      _loadData();
      _showSnackBar(
        'Roulette ${isEnabled ? 'activée' : 'désactivée'}',
      );
    } catch (e) {
      _showSnackBar('Erreur lors de la mise à jour: $e', isError: true);
    }
  }

  /// Supprimer une popup
  Future<void> _deletePopup(PopupConfig popup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.dialog,
        ),
        title: Text(
          'Supprimer la popup ?',
          style: AppTextStyles.headlineMedium,
        ),
        content: Text(
          'Cette action est irréversible. Voulez-vous continuer ?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _popupService.deletePopup(popup.id);
      if (success) {
        _loadData();
        _showSnackBar('Popup supprimée');
      } else {
        _showSnackBar('Erreur lors de la suppression', isError: true);
      }
    }
  }

  /// Afficher un snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.snackbar,
        ),
      ),
    );
  }
}
