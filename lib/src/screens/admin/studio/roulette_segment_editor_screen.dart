// lib/src/screens/admin/studio/roulette_segment_editor_screen.dart
// Editor screen for creating/editing roulette segments - Material 3 + Pizza Deli'Zza

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';
import '../../../models/roulette_config.dart';
import '../../../models/product.dart';
import '../../../services/roulette_segment_service.dart';
import '../../../services/firestore_product_service.dart';
import '../../../design_system/app_theme.dart';

/// Screen to create or edit a roulette segment
/// Follows Material 3 and Pizza Deli'Zza Brand Guidelines
class RouletteSegmentEditorScreen extends StatefulWidget {
  final RouletteSegment? segment;

  const RouletteSegmentEditorScreen({super.key, this.segment});

  @override
  State<RouletteSegmentEditorScreen> createState() => _RouletteSegmentEditorScreenState();
}

class _RouletteSegmentEditorScreenState extends State<RouletteSegmentEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final RouletteSegmentService _service = RouletteSegmentService();
  final FirestoreProductService _productService = createFirestoreProductService();

  // Form controllers
  late TextEditingController _labelController;
  late TextEditingController _descriptionController;
  late TextEditingController _rewardValueController;
  late TextEditingController _probabilityController;

  // Form values
  RewardType _selectedRewardType = RewardType.none;
  String? _selectedProductId;
  String _selectedIcon = 'stars';
  Color _selectedColor = const Color(0xFFD32F2F);
  bool _isActive = true;
  int _position = 0;

  // Products for selection
  List<Product> _products = [];
  List<Product> _drinks = [];
  bool _isLoading = false;
  bool _isSaving = false;

  // Predefined colors
  final List<Color> _predefinedColors = [
    const Color(0xFFD32F2F), // Red
    const Color(0xFFFFD700), // Gold
    const Color(0xFF4ECDC4), // Teal
    const Color(0xFF3498DB), // Blue
    const Color(0xFF9B59B6), // Purple
    const Color(0xFF95A5A6), // Gray
    const Color(0xFFE91E63), // Pink
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFF00BCD4), // Cyan
  ];

  // Predefined icons
  final Map<String, IconData> _predefinedIcons = {
    'local_pizza': Icons.local_pizza,
    'local_drink': Icons.local_drink,
    'cake': Icons.cake,
    'stars': Icons.stars,
    'percent': Icons.percent,
    'euro': Icons.euro,
    'close': Icons.close,
    'card_giftcard': Icons.card_giftcard,
  };

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadProducts();
  }

  /// Initialize form controllers
  void _initializeControllers() {
    if (widget.segment != null) {
      // Editing existing segment
      final segment = widget.segment!;
      _labelController = TextEditingController(text: segment.label);
      _descriptionController = TextEditingController(text: segment.description ?? '');
      _rewardValueController = TextEditingController(
        text: segment.rewardValue?.toString() ?? '',
      );
      _probabilityController = TextEditingController(
        text: segment.probability.toString(),
      );
      _selectedRewardType = segment.rewardType;
      _selectedProductId = segment.productId;
      _selectedIcon = segment.iconName ?? 'stars';
      _selectedColor = segment.color;
      _isActive = segment.isActive;
      _position = segment.position;
    } else {
      // Creating new segment
      _labelController = TextEditingController();
      _descriptionController = TextEditingController();
      _rewardValueController = TextEditingController();
      _probabilityController = TextEditingController(text: '10.0');
    }
  }

  /// Load products and drinks for selection
  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      final allProducts = await _productService.getAllProducts();
      setState(() {
        _products = allProducts.where((p) => 
          p.category == ProductCategory.pizza || 
          p.category == ProductCategory.desserts
        ).toList();
        _drinks = allProducts.where((p) => 
          p.category == ProductCategory.boissons
        ).toList();
      });
    } catch (e) {
      _showSnackBar('Erreur lors du chargement des produits: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _descriptionController.dispose();
    _rewardValueController.dispose();
    _probabilityController.dispose();
    super.dispose();
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
          widget.segment == null ? 'Nouveau segment' : 'Modifier le segment',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.segment != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _deleteSegment,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppSpacing.paddingMD,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Label field
                    _buildTextField(
                      controller: _labelController,
                      label: 'Label',
                      hint: 'Ex: Pizza offerte',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le label est obligatoire';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Description field
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description (optionnelle)',
                      hint: 'Ex: Une pizza gratuite au choix',
                      maxLines: 2,
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Reward type dropdown
                    _buildRewardTypeDropdown(),
                    SizedBox(height: AppSpacing.md),

                    // Reward value field (conditional)
                    if (_selectedRewardType == RewardType.bonusPoints ||
                        _selectedRewardType == RewardType.percentageDiscount ||
                        _selectedRewardType == RewardType.fixedAmountDiscount) ...[
                      _buildTextField(
                        controller: _rewardValueController,
                        label: _selectedRewardType == RewardType.bonusPoints
                            ? 'Points'
                            : _selectedRewardType == RewardType.percentageDiscount
                            ? 'Pourcentage (%)'
                            : 'Montant (€)',
                        hint: _selectedRewardType == RewardType.bonusPoints
                            ? 'Ex: 100'
                            : _selectedRewardType == RewardType.percentageDiscount
                            ? 'Ex: 10'
                            : 'Ex: 5.00',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La valeur est obligatoire';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Valeur invalide';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.md),
                    ],

                    // Product selector (conditional)
                    if (_selectedRewardType == RewardType.freeProduct ||
                        _selectedRewardType == RewardType.freePizza ||
                        _selectedRewardType == RewardType.freeDessert)
                      _buildProductSelector(),
                    if (_selectedRewardType == RewardType.freeDrink)
                      _buildDrinkSelector(),
                    if (_selectedRewardType == RewardType.freeProduct ||
                        _selectedRewardType == RewardType.freePizza ||
                        _selectedRewardType == RewardType.freeDessert ||
                        _selectedRewardType == RewardType.freeDrink)
                      SizedBox(height: AppSpacing.md),

                    // Probability field
                    _buildTextField(
                      controller: _probabilityController,
                      label: 'Probabilité (%)',
                      hint: 'Ex: 10.0',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La probabilité est obligatoire';
                        }
                        final prob = double.tryParse(value);
                        if (prob == null || prob < 0 || prob > 100) {
                          return 'Valeur entre 0 et 100';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Color picker
                    _buildColorPicker(),
                    SizedBox(height: AppSpacing.md),

                    // Icon selector
                    _buildIconSelector(),
                    SizedBox(height: AppSpacing.md),

                    // Active switch
                    _buildActiveSwitch(),
                    SizedBox(height: AppSpacing.xl),

                    // Save button
                    FilledButton(
                      onPressed: _isSaving ? null : _saveSegment,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : const Text('Sauvegarder'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Build text field
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
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  /// Build reward type dropdown
  Widget _buildRewardTypeDropdown() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type de gain',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<RewardType>(
              value: _selectedRewardType,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.input,
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
              ),
              items: RewardType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getRewardTypeLabel(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRewardType = value!;
                  // Reset related fields
                  _rewardValueController.clear();
                  _selectedProductId = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build product selector
  Widget _buildProductSelector() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produit à offrir',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _selectedProductId,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.input,
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                hintText: 'Sélectionner un produit',
              ),
              items: _products.map((product) {
                return DropdownMenuItem(
                  value: product.id,
                  child: Text(product.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProductId = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build drink selector
  Widget _buildDrinkSelector() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Boisson à offrir',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _selectedProductId,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.input,
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                hintText: 'Sélectionner une boisson',
              ),
              items: _drinks.map((drink) {
                return DropdownMenuItem(
                  value: drink.id,
                  child: Text(drink.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProductId = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build color picker
  Widget _buildColorPicker() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Couleur du segment',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _predefinedColors.map((color) {
                final isSelected = _selectedColor.value == color.value;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = color),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.outline,
                        width: isSelected ? 3 : 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: AppColors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: _showCustomColorPicker,
              icon: const Icon(Icons.palette),
              label: const Text('Couleur personnalisée'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build icon selector
  Widget _buildIconSelector() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Icône',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _predefinedIcons.entries.map((entry) {
                final isSelected = _selectedIcon == entry.key;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = entry.key),
                  borderRadius: AppRadius.badge,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : AppColors.surfaceContainerLow,
                      borderRadius: AppRadius.badge,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.outline,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      entry.value,
                      color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build active switch
  Widget _buildActiveSwitch() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Segment actif',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Le segment apparaîtra sur la roue',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  /// Show custom color picker
  void _showCustomColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        Color pickerColor = _selectedColor;
        return AlertDialog(
          title: const Text('Choisir une couleur'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => _selectedColor = pickerColor);
                Navigator.pop(context);
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  /// Get reward type label
  String _getRewardTypeLabel(RewardType type) {
    switch (type) {
      case RewardType.none:
        return 'Aucun gain';
      case RewardType.bonusPoints:
        return 'Points bonus';
      case RewardType.percentageDiscount:
        return 'Réduction en %';
      case RewardType.fixedAmountDiscount:
        return 'Réduction fixe (€)';
      case RewardType.freeProduct:
        return 'Produit gratuit';
      case RewardType.freePizza:
        return 'Pizza gratuite';
      case RewardType.freeDrink:
        return 'Boisson gratuite';
      case RewardType.freeDessert:
        return 'Dessert gratuit';
    }
  }

  /// Save segment
  Future<void> _saveSegment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate product selection if needed
    if ((_selectedRewardType == RewardType.freeProduct ||
            _selectedRewardType == RewardType.freeDrink) &&
        _selectedProductId == null) {
      _showSnackBar('Veuillez sélectionner un produit', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final segment = RouletteSegment(
        id: widget.segment?.id ?? const Uuid().v4(),
        label: _labelController.text.trim(),
        rewardId: _selectedRewardType.value,
        probability: double.parse(_probabilityController.text),
        color: _selectedColor,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        rewardType: _selectedRewardType,
        rewardValue: _rewardValueController.text.isEmpty
            ? null
            : double.parse(_rewardValueController.text),
        productId: _selectedProductId,
        iconName: _selectedIcon,
        isActive: _isActive,
        position: _position,
      );

      final success = widget.segment == null
          ? await _service.createSegment(segment)
          : await _service.updateSegment(segment);

      if (success) {
        _showSnackBar('Segment sauvegardé avec succès', isError: false);
        Navigator.pop(context, true);
      } else {
        _showSnackBar('Erreur lors de la sauvegarde', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Delete segment
  Future<void> _deleteSegment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le segment'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce segment ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm == true && widget.segment != null) {
      final success = await _service.deleteSegment(widget.segment!.id);
      if (success) {
        _showSnackBar('Segment supprimé', isError: false);
        Navigator.pop(context, true);
      } else {
        _showSnackBar('Erreur lors de la suppression', isError: true);
      }
    }
  }

  /// Show snackbar
  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
