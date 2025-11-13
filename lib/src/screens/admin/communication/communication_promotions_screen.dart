// lib/src/screens/admin/communication/communication_promotions_screen.dart
// Screen for managing promotions with multi-channel targeting

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/promotion.dart';
import '../../../services/promotion_service.dart';
import '../../../theme/app_theme.dart';

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
                      onPressed: () {
                        // Edit functionality would go here
                      },
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
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final valueController = TextEditingController();
    String selectedType = 'percent_discount';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouvelle promotion'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Valeur',
                  border: OutlineInputBorder(),
                ),
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
              final newPromo = Promotion(
                id: const Uuid().v4(),
                name: nameController.text,
                description: descController.text,
                type: selectedType,
                value: double.tryParse(valueController.text),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              
              await _service.createPromotion(newPromo);
              _loadPromotions();
              Navigator.pop(context);
              _showSnackBar('Promotion créée');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
            ),
            child: Text('Créer'),
          ),
        ],
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
    );
  }
}
