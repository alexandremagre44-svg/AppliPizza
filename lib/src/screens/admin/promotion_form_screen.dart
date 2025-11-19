// lib/src/screens/admin/promotion_form_screen.dart
// Formulaire de création/modification de promotion

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../design_system/app_theme.dart';
import '../../models/promotion.dart';
import '../../services/promotion_service.dart';

/// Écran de formulaire pour créer ou modifier une promotion
class PromotionFormScreen extends StatefulWidget {
  final Promotion? promotion;

  const PromotionFormScreen({super.key, this.promotion});

  @override
  State<PromotionFormScreen> createState() => _PromotionFormScreenState();
}

class _PromotionFormScreenState extends State<PromotionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minOrderAmountController = TextEditingController();
  
  final PromotionService _promotionService = PromotionService();
  final _uuid = const Uuid();
  
  String _discountType = 'percentage';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isActive = true;
  bool _showOnHomeBanner = false;
  bool _showInPromoBlock = false;
  bool _useInRoulette = false;
  bool _useInMailing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.promotion != null) {
      final promo = widget.promotion!;
      _titleController.text = promo.title ?? promo.name;
      _descriptionController.text = promo.description;
      _codeController.text = promo.code ?? '';
      _discountType = promo.discountType ?? promo.type;
      _discountValueController.text = (promo.discountValue ?? promo.value ?? 0).toString();
      _minOrderAmountController.text = promo.minOrderAmount?.toString() ?? '';
      _startDate = promo.startDate ?? DateTime.now();
      _endDate = promo.endDate;
      _isActive = promo.isActive;
      _showOnHomeBanner = promo.showOnHomeBanner;
      _showInPromoBlock = promo.showInPromoBlock;
      _useInRoulette = promo.useInRoulette;
      _useInMailing = promo.useInMailing;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    _discountValueController.dispose();
    _minOrderAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.promotion != null;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la promotion' : 'Nouvelle promotion'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            // Informations de base
            _buildSectionTitle('Informations de base'),
            _buildTextField(
              controller: _titleController,
              label: 'Titre',
              hint: 'Ex: Promotion du mois',
              validator: (value) => value?.isEmpty ?? true ? 'Titre requis' : null,
            ),
            SizedBox(height: AppSpacing.md),
            
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Décrivez la promotion',
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? 'Description requise' : null,
            ),
            SizedBox(height: AppSpacing.md),
            
            _buildTextField(
              controller: _codeController,
              label: 'Code promo (optionnel)',
              hint: 'Ex: PROMO20',
            ),
            SizedBox(height: AppSpacing.lg),
            
            // Réduction
            _buildSectionTitle('Réduction'),
            _buildDiscountTypeSelector(),
            SizedBox(height: AppSpacing.md),
            
            _buildTextField(
              controller: _discountValueController,
              label: _discountType == 'percentage' ? 'Pourcentage (%)' : 'Montant (€)',
              hint: _discountType == 'percentage' ? '20' : '5.00',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Valeur requise';
                if (double.tryParse(value!) == null) return 'Valeur invalide';
                return null;
              },
            ),
            SizedBox(height: AppSpacing.md),
            
            _buildTextField(
              controller: _minOrderAmountController,
              label: 'Montant minimum de commande (optionnel)',
              hint: '30.00',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: AppSpacing.lg),
            
            // Période de validité
            _buildSectionTitle('Période de validité'),
            _buildDateSelector(
              label: 'Date de début',
              date: _startDate,
              onDateSelected: (date) => setState(() => _startDate = date),
            ),
            SizedBox(height: AppSpacing.md),
            
            _buildDateSelector(
              label: 'Date de fin (optionnel)',
              date: _endDate,
              onDateSelected: (date) => setState(() => _endDate = date),
              allowNull: true,
            ),
            SizedBox(height: AppSpacing.lg),
            
            // Options d'affichage
            _buildSectionTitle('Options d\'affichage'),
            _buildSwitchTile(
              'Promotion active',
              _isActive,
              (value) => setState(() => _isActive = value),
            ),
            _buildSwitchTile(
              'Afficher sur la bannière d\'accueil',
              _showOnHomeBanner,
              (value) => setState(() => _showOnHomeBanner = value),
            ),
            _buildSwitchTile(
              'Afficher dans le bloc promotions',
              _showInPromoBlock,
              (value) => setState(() => _showInPromoBlock = value),
            ),
            _buildSwitchTile(
              'Utiliser dans la roulette',
              _useInRoulette,
              (value) => setState(() => _useInRoulette = value),
            ),
            _buildSwitchTile(
              'Utiliser dans le mailing',
              _useInMailing,
              (value) => setState(() => _useInMailing = value),
            ),
            
            SizedBox(height: AppSpacing.xl),
            
            // Bouton de sauvegarde
            FilledButton(
              onPressed: _isSaving ? null : _savePromotion,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.primary,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isEditing ? 'Enregistrer les modifications' : 'Créer la promotion',
                      style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusSmall,
          borderSide: BorderSide.none,
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDiscountTypeSelector() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type de réduction', style: AppTextStyles.labelLarge),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Pourcentage (%)'),
                    selected: _discountType == 'percentage',
                    onSelected: (selected) {
                      if (selected) setState(() => _discountType = 'percentage');
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Montant fixe (€)'),
                    selected: _discountType == 'fixed',
                    onSelected: (selected) {
                      if (selected) setState(() => _discountType = 'fixed');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onDateSelected,
    bool allowNull = false,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: ListTile(
        title: Text(label, style: AppTextStyles.bodyMedium),
        subtitle: Text(
          date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Non définie',
          style: AppTextStyles.labelLarge,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (allowNull && date != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _endDate = null),
              ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDate(date ?? DateTime.now(), onDateSelected),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(DateTime initialDate, ValueChanged<DateTime> onDateSelected) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (date != null) {
      onDateSelected(date);
    }
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: SwitchListTile(
        title: Text(title, style: AppTextStyles.bodyMedium),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Future<void> _savePromotion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final titleText = _titleController.text.trim();
      final promotion = Promotion(
        id: widget.promotion?.id ?? _uuid.v4(),
        name: titleText,
        description: _descriptionController.text.trim(),
        type: _discountType,
        value: double.parse(_discountValueController.text.trim()),
        code: _codeController.text.trim().isNotEmpty ? _codeController.text.trim() : null,
        title: titleText,
        discountType: _discountType,
        discountValue: double.parse(_discountValueController.text.trim()),
        minOrderAmount: _minOrderAmountController.text.trim().isNotEmpty
            ? double.parse(_minOrderAmountController.text.trim())
            : null,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        showOnHomeBanner: _showOnHomeBanner,
        showInPromoBlock: _showInPromoBlock,
        useInRoulette: _useInRoulette,
        useInMailing: _useInMailing,
        createdAt: widget.promotion?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = widget.promotion != null
          ? await _promotionService.updatePromotion(promotion)
          : await _promotionService.createPromotion(promotion);

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.promotion != null
                    ? 'Promotion modifiée avec succès'
                    : 'Promotion créée avec succès',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la sauvegarde'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
