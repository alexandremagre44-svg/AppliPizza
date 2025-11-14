// lib/src/screens/admin/communication/communication_promotions_screen.dart
// Screen for managing promotions with multi-channel targeting

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/promotion.dart';
import 'package:pizza_delizza/src/services/promotion_service.dart';
import '../../../shared/theme/app_theme.dart';

class CommunicationPromotionsScreen extends StatefulWidget {
  const CommunicationPromotionsScreen({super.key});

  @override
  State<CommunicationPromotionsScreen> createState() =>
      _CommunicationPromotionsScreenState();
}

class _CommunicationPromotionsScreenState
    extends State<CommunicationPromotionsScreen> {
  final PromotionService _service = PromotionService();
  
  List<Promotion> _promotions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    setState(() => _isLoading = true);
    
    final promotions = await _service.getAllPromotions();
    
    setState(() {
      _promotions = promotions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotions'),
        backgroundColor: AppColors.primaryRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPromotionDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: AppSpacing.paddingLG,
              children: [
                Card(
                  elevation: 2,
                  color: AppColors.primaryRed.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.cardLarge),
                  child: Padding(
                    padding: AppSpacing.paddingMD,
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primaryRed),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            '${_promotions.length} promotion(s) configurée(s)',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                
                if (_promotions.isEmpty)
                  Center(
                    child: Padding(
                      padding: AppSpacing.paddingXXL,
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            size: 80,
                            color: AppColors.textLight,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Aucune promotion',
                            style: AppTextStyles.titleLarge,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'Créez des promotions pour attirer vos clients',
                            style: AppTextStyles.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._promotions.map((promo) => _buildPromotionCard(promo)),
              ],
            ),
    );
  }

  Widget _buildPromotionCard(Promotion promo) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: promo.isActive
                ? AppColors.primaryRed.withOpacity(0.1)
                : AppColors.textLight.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_offer,
            color: promo.isActive ? AppColors.primaryRed : AppColors.textLight,
          ),
        ),
        title: Text(promo.name, style: AppTextStyles.titleMedium),
        subtitle: Text(
          '${promo.type} • ${promo.formattedValue}',
          style: AppTextStyles.bodySmall,
        ),
        trailing: Icon(
          promo.isActive ? Icons.check_circle : Icons.circle_outlined,
          color:
              promo.isActive ? AppColors.successGreen : AppColors.textLight,
        ),
        children: [
          Padding(
            padding: AppSpacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promo.description, style: AppTextStyles.bodyMedium),
                SizedBox(height: AppSpacing.md),
                
                Text('Canaux d\'utilisation', style: AppTextStyles.labelLarge),
                SizedBox(height: AppSpacing.sm),
                
                _buildChannelChip('Bannière accueil', promo.showOnHomeBanner),
                _buildChannelChip('Bloc promo', promo.showInPromoBlock),
                _buildChannelChip('Roulette', promo.useInRoulette),
                _buildChannelChip('Popup', promo.useInPopup),
                _buildChannelChip('Mailing', promo.useInMailing),
                
                SizedBox(height: AppSpacing.md),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Modifier'),
                      onPressed: () => _showEditPromotionDialog(promo),
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.delete, size: 18),
                      label: Text('Supprimer'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                      ),
                      onPressed: () => _deletePromotion(promo.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelChip(String label, bool isActive) {
    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.xs, bottom: AppSpacing.xs),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.white : AppColors.textMedium,
          ),
        ),
        backgroundColor: isActive
            ? AppColors.primaryRed
            : AppColors.backgroundLight,
        side: BorderSide.none,
      ),
    );
  }

  void _showAddPromotionDialog() {
    _showPromotionDialog();
  }

  void _showEditPromotionDialog(Promotion promo) {
    _showPromotionDialog(existingPromo: promo);
  }

  void _showPromotionDialog({Promotion? existingPromo}) {
    final isEditing = existingPromo != null;
    final nameController = TextEditingController(text: existingPromo?.name);
    final descController = TextEditingController(text: existingPromo?.description);
    final valueController = TextEditingController(
      text: existingPromo?.value?.toString() ?? '',
    );
    
    String selectedType = existingPromo?.type ?? 'percent_discount';
    bool isActive = existingPromo?.isActive ?? true;
    bool showOnHomeBanner = existingPromo?.showOnHomeBanner ?? false;
    bool showInPromoBlock = existingPromo?.showInPromoBlock ?? true;
    bool useInRoulette = existingPromo?.useInRoulette ?? false;
    bool useInPopup = existingPromo?.useInPopup ?? false;
    bool useInMailing = existingPromo?.useInMailing ?? false;
    DateTime? startDate = existingPromo?.startDate;
    DateTime? endDate = existingPromo?.endDate;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Modifier la promotion' : 'Nouvelle promotion'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom*',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description*',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type de promotion',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'percent_discount', child: Text('Réduction en %')),
                    DropdownMenuItem(value: 'fixed_discount', child: Text('Réduction fixe')),
                    DropdownMenuItem(value: 'free_item', child: Text('Produit offert')),
                    DropdownMenuItem(value: 'buy_x_get_y', child: Text('Achetez X obtenez Y')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                SizedBox(height: AppSpacing.md),
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: selectedType == 'percent_discount' ? 'Valeur (%)' : 'Valeur (€)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Text('Canaux d\'utilisation', style: AppTextStyles.labelLarge),
                SizedBox(height: AppSpacing.xs),
                CheckboxListTile(
                  dense: true,
                  title: Text('Bannière accueil'),
                  value: showOnHomeBanner,
                  onChanged: (value) {
                    setState(() => showOnHomeBanner = value ?? false);
                  },
                ),
                CheckboxListTile(
                  dense: true,
                  title: Text('Bloc promo'),
                  value: showInPromoBlock,
                  onChanged: (value) {
                    setState(() => showInPromoBlock = value ?? false);
                  },
                ),
                CheckboxListTile(
                  dense: true,
                  title: Text('Roulette'),
                  value: useInRoulette,
                  onChanged: (value) {
                    setState(() => useInRoulette = value ?? false);
                  },
                ),
                CheckboxListTile(
                  dense: true,
                  title: Text('Popup'),
                  value: useInPopup,
                  onChanged: (value) {
                    setState(() => useInPopup = value ?? false);
                  },
                ),
                CheckboxListTile(
                  dense: true,
                  title: Text('Mailing'),
                  value: useInMailing,
                  onChanged: (value) {
                    setState(() => useInMailing = value ?? false);
                  },
                ),
                SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  title: Text('Promotion active'),
                  value: isActive,
                  activeColor: AppColors.primaryRed,
                  onChanged: (value) {
                    setState(() => isActive = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validation
                if (nameController.text.trim().isEmpty) {
                  _showSnackBar('Le nom est requis', isError: true);
                  return;
                }
                if (descController.text.trim().isEmpty) {
                  _showSnackBar('La description est requise', isError: true);
                  return;
                }
                
                final value = double.tryParse(valueController.text);
                if (value == null) {
                  _showSnackBar('La valeur doit être un nombre', isError: true);
                  return;
                }
                
                final promo = isEditing
                    ? existingPromo.copyWith(
                        name: nameController.text.trim(),
                        description: descController.text.trim(),
                        type: selectedType,
                        value: value,
                        isActive: isActive,
                        showOnHomeBanner: showOnHomeBanner,
                        showInPromoBlock: showInPromoBlock,
                        useInRoulette: useInRoulette,
                        useInPopup: useInPopup,
                        useInMailing: useInMailing,
                        updatedAt: DateTime.now(),
                      )
                    : Promotion(
                        id: const Uuid().v4(),
                        name: nameController.text.trim(),
                        description: descController.text.trim(),
                        type: selectedType,
                        value: value,
                        isActive: isActive,
                        showOnHomeBanner: showOnHomeBanner,
                        showInPromoBlock: showInPromoBlock,
                        useInRoulette: useInRoulette,
                        useInPopup: useInPopup,
                        useInMailing: useInMailing,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                
                final success = isEditing
                    ? await _service.updatePromotion(promo)
                    : await _service.createPromotion(promo);
                
                if (success) {
                  _loadPromotions();
                  Navigator.pop(context);
                  _showSnackBar(isEditing ? 'Promotion modifiée' : 'Promotion créée');
                } else {
                  _showSnackBar('Erreur lors de l\'enregistrement', isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Modifier' : 'Créer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePromotion(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la promotion ?'),
        content: Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _service.deletePromotion(id);
      _loadPromotions();
      _showSnackBar('Promotion supprimée');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
    );
  }
}
