// lib/src/screens/admin/promotions_admin_screen.dart
// Écran d'administration du module promotions

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../design_system/app_theme.dart';
import '../../models/promotion.dart';
import '../../services/promotion_service.dart';
import 'promotion_form_screen.dart';

/// Écran d'administration pour gérer les promotions
class PromotionsAdminScreen extends StatefulWidget {
  const PromotionsAdminScreen({super.key});

  @override
  State<PromotionsAdminScreen> createState() => _PromotionsAdminScreenState();
}

class _PromotionsAdminScreenState extends State<PromotionsAdminScreen> {
  final PromotionService _promotionService = PromotionService();
  List<Promotion> _promotions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    setState(() => _isLoading = true);
    final promotions = await _promotionService.getAllPromotions();
    setState(() {
      _promotions = promotions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Promotions'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPromotionsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToPromotionForm,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle promotion'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildPromotionsList() {
    if (_promotions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.discount_outlined,
              size: 80,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune promotion',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Créez votre première promotion',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final activePromotions = _promotions.where((p) => p.isActive && p.isCurrentlyActive).toList();
    final scheduledPromotions = _promotions.where((p) => p.isActive && !p.isCurrentlyActive && p.startDate.isAfter(DateTime.now())).toList();
    final inactivePromotions = _promotions.where((p) => !p.isActive || (p.endDate != null && p.endDate!.isBefore(DateTime.now()))).toList();

    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        // Statistiques
        _buildStatsCard(activePromotions.length, scheduledPromotions.length, inactivePromotions.length),
        SizedBox(height: AppSpacing.lg),
        
        // Promotions actives
        if (activePromotions.isNotEmpty) ...[
          _buildSectionHeader('Promotions actives (${activePromotions.length})'),
          SizedBox(height: AppSpacing.sm),
          ...activePromotions.map((promo) => _buildPromotionCard(promo, isActive: true)),
          SizedBox(height: AppSpacing.lg),
        ],
        
        // Promotions planifiées
        if (scheduledPromotions.isNotEmpty) ...[
          _buildSectionHeader('Promotions planifiées (${scheduledPromotions.length})'),
          SizedBox(height: AppSpacing.sm),
          ...scheduledPromotions.map((promo) => _buildPromotionCard(promo, isScheduled: true)),
          SizedBox(height: AppSpacing.lg),
        ],
        
        // Promotions inactives
        if (inactivePromotions.isNotEmpty) ...[
          _buildSectionHeader('Promotions inactives (${inactivePromotions.length})'),
          SizedBox(height: AppSpacing.sm),
          ...inactivePromotions.map((promo) => _buildPromotionCard(promo, isActive: false)),
        ],
      ],
    );
  }

  Widget _buildStatsCard(int active, int scheduled, int inactive) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Actives',
                active.toString(),
                Icons.check_circle,
                AppColors.primary,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.outlineVariant,
            ),
            Expanded(
              child: _buildStatItem(
                'Planifiées',
                scheduled.toString(),
                Icons.schedule,
                AppColors.secondary,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.outlineVariant,
            ),
            Expanded(
              child: _buildStatItem(
                'Inactives',
                inactive.toString(),
                Icons.cancel,
                AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPromotionCard(Promotion promotion, {bool isActive = false, bool isScheduled = false}) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: InkWell(
        onTap: () => _navigateToPromotionForm(promotion),
        borderRadius: AppRadius.card,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Statut badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryContainer
                          : isScheduled
                              ? AppColors.secondaryContainer
                              : AppColors.errorContainer,
                      borderRadius: AppRadius.small,
                    ),
                    child: Text(
                      isActive
                          ? 'Active'
                          : isScheduled
                              ? 'Planifiée'
                              : 'Inactive',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isActive
                            ? AppColors.onPrimaryContainer
                            : isScheduled
                                ? AppColors.onSecondaryContainer
                                : AppColors.onErrorContainer,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Discount
                  Text(
                    promotion.discountType == 'percentage'
                        ? '-${promotion.discountValue.toInt()}%'
                        : '-${promotion.discountValue.toStringAsFixed(2)}€',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              // Titre
              Text(
                promotion.title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              // Description
              Text(
                promotion.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSpacing.sm),
              // Dates
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${_formatDate(promotion.startDate)} - ${promotion.endDate != null ? _formatDate(promotion.endDate!) : 'Illimité'}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              // Usage indicators
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  if (promotion.showOnHomeBanner)
                    _buildUsageChip('Bannière', Icons.flag),
                  if (promotion.showInPromoBlock)
                    _buildUsageChip('Bloc promo', Icons.grid_view),
                  if (promotion.useInRoulette)
                    _buildUsageChip('Roulette', Icons.casino),
                  if (promotion.useInMailing)
                    _buildUsageChip('Mailing', Icons.email),
                ],
              ),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      promotion.isActive ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () => _togglePromotionStatus(promotion),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _navigateToPromotionForm(promotion),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _confirmDelete(promotion),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageChip(String label, IconData icon) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      visualDensity: VisualDensity.compact,
      labelStyle: AppTextStyles.labelSmall,
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _togglePromotionStatus(Promotion promotion) async {
    final success = await _promotionService.togglePromotionStatus(promotion.id);
    if (success && mounted) {
      _loadPromotions();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            promotion.isActive ? 'Promotion désactivée' : 'Promotion activée',
          ),
        ),
      );
    }
  }

  void _confirmDelete(Promotion promotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${promotion.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePromotion(promotion);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePromotion(Promotion promotion) async {
    final success = await _promotionService.deletePromotion(promotion.id);
    if (success && mounted) {
      _loadPromotions();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Promotion supprimée')),
      );
    }
  }

  void _navigateToPromotionForm([Promotion? promotion]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PromotionFormScreen(promotion: promotion),
      ),
    );

    if (result == true && mounted) {
      _loadPromotions();
    }
  }
}
