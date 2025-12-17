/// lib/superadmin/pages/restaurant_theme_page.dart
///
/// PHASE 3 - Éditeur de Thème White-Label pour SuperAdmin
///
/// Permet de modifier le thème d'un restaurant en temps réel.
/// Modifications appliquées immédiatement sur Admin, POS et Client.
/// Le Builder n'est PAS impacté.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../white_label/theme/theme_settings.dart';
import '../../white_label/theme/unified_theme_provider.dart';
import '../services/restaurant_plan_service.dart';
import '../providers/superadmin_restaurants_provider.dart';

/// Page d'édition du thème d'un restaurant (SuperAdmin).
class RestaurantThemePage extends ConsumerStatefulWidget {
  /// Identifiant du restaurant.
  final String restaurantId;

  /// Nom du restaurant (optionnel, pour affichage).
  final String? restaurantName;

  const RestaurantThemePage({
    super.key,
    required this.restaurantId,
    this.restaurantName,
  });

  @override
  ConsumerState<RestaurantThemePage> createState() => _RestaurantThemePageState();
}

class _RestaurantThemePageState extends ConsumerState<RestaurantThemePage> {
  final _service = RestaurantPlanService();
  
  // Constantes pour la validation
  static const int _hexColorLength = 6; // RRGGBB (sans le #)
  static const double _minBorderRadius = 4.0;
  static const double _maxBorderRadius = 32.0;
  static const double _nestedBorderRadiusRatio = 0.67; // Pour les éléments imbriqués
  
  // Controllers pour les couleurs
  late TextEditingController _primaryColorController;
  late TextEditingController _secondaryColorController;
  late TextEditingController _backgroundColorController;
  late TextEditingController _surfaceColorController;
  
  // Slider value pour borderRadius
  late double _borderRadius;
  
  // État de sauvegarde
  bool _isSaving = false;
  String? _saveError;
  
  @override
  void initState() {
    super.initState();
    
    // Initialiser avec les valeurs par défaut (sans le # car le prefixText l'ajoute)
    final defaults = ThemeSettings.defaultConfig();
    _primaryColorController = TextEditingController(
      text: _removeHashPrefix(defaults.primaryColor),
    );
    _secondaryColorController = TextEditingController(
      text: _removeHashPrefix(defaults.secondaryColor),
    );
    _backgroundColorController = TextEditingController(
      text: _removeHashPrefix(defaults.backgroundColor),
    );
    _surfaceColorController = TextEditingController(
      text: _removeHashPrefix(defaults.surfaceColor),
    );
    _borderRadius = defaults.radiusBase;
  }
  
  /// Enlève le préfixe # d'une couleur hex.
  String _removeHashPrefix(String hex) {
    return hex.startsWith('#') ? hex.substring(1) : hex;
  }
  
  /// Ajoute le préfixe # à une couleur hex si nécessaire.
  String _ensureHashPrefix(String hex) {
    return hex.startsWith('#') ? hex : '#$hex';
  }
  
  @override
  void dispose() {
    _primaryColorController.dispose();
    _secondaryColorController.dispose();
    _backgroundColorController.dispose();
    _surfaceColorController.dispose();
    super.dispose();
  }
  
  /// Parse une couleur hex de manière sûre.
  Color _parseColor(String hex) {
    try {
      final cleaned = hex.replaceAll('#', '');
      if (cleaned.length == 6) {
        return Color(int.parse('FF$cleaned', radix: 16));
      } else if (cleaned.length == 8) {
        return Color(int.parse(cleaned, radix: 16));
      }
    } catch (_) {}
    return Colors.grey;
  }
  
  /// Valide une couleur hex.
  bool _isValidHex(String hex) {
    try {
      final cleaned = hex.replaceAll('#', '');
      if (cleaned.length != 6 && cleaned.length != 8) return false;
      int.parse(cleaned, radix: 16);
      return true;
    } catch (_) {
      return false;
    }
  }
  
  /// Sauvegarde le thème dans Firestore.
  Future<void> _saveTheme() async {
    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    
    try {
      // Ajouter le # pour la validation et la sauvegarde
      final primaryColor = _ensureHashPrefix(_primaryColorController.text);
      final secondaryColor = _ensureHashPrefix(_secondaryColorController.text);
      final backgroundColor = _ensureHashPrefix(_backgroundColorController.text);
      final surfaceColor = _ensureHashPrefix(_surfaceColorController.text);
      
      // Valider les couleurs
      if (!_isValidHex(primaryColor)) {
        throw Exception('Couleur primaire invalide');
      }
      if (!_isValidHex(secondaryColor)) {
        throw Exception('Couleur secondaire invalide');
      }
      if (!_isValidHex(backgroundColor)) {
        throw Exception('Couleur de fond invalide');
      }
      if (!_isValidHex(surfaceColor)) {
        throw Exception('Couleur de surface invalide');
      }
      
      // Créer les settings (utiliser les valeurs par défaut pour les champs non exposés)
      final defaults = ThemeSettings.defaultConfig();
      final settings = ThemeSettings(
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        surfaceColor: surfaceColor,
        backgroundColor: backgroundColor,
        textPrimary: defaults.textPrimary, // Valeurs par défaut pour Phase 3
        textSecondary: defaults.textSecondary,
        radiusBase: _borderRadius,
        spacingBase: defaults.spacingBase,
        typographyScale: defaults.typographyScale,
        updatedAt: DateTime.now(),
      );
      
      // Valider les settings
      if (!settings.validate()) {
        throw Exception('Configuration de thème invalide');
      }
      
      // Sauvegarder dans Firestore
      await _service.updateModuleSettings(
        widget.restaurantId,
        'theme',
        settings.toJson(),
      );
      
      // Activer le module theme s'il ne l'est pas déjà
      await _service.updateModule(widget.restaurantId, 'theme', true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Thème sauvegardé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _saveError = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  
  /// Réinitialise le thème aux valeurs par défaut.
  Future<void> _resetTheme() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser le thème'),
        content: const Text(
          'Voulez-vous vraiment réinitialiser le thème aux valeurs par défaut ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    
    try {
      final defaults = ThemeSettings.defaultConfig();
      
      // Mettre à jour les controllers (sans le # car le prefixText l'ajoute)
      _primaryColorController.text = _removeHashPrefix(defaults.primaryColor);
      _secondaryColorController.text = _removeHashPrefix(defaults.secondaryColor);
      _backgroundColorController.text = _removeHashPrefix(defaults.backgroundColor);
      _surfaceColorController.text = _removeHashPrefix(defaults.surfaceColor);
      _borderRadius = defaults.radiusBase;
      
      // Sauvegarder dans Firestore
      await _service.updateModuleSettings(
        widget.restaurantId,
        'theme',
        defaults.toJson(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Thème réinitialisé aux valeurs par défaut'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _saveError = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planAsync = ref.watch(superAdminRestaurantUnifiedPlanProvider(widget.restaurantId));
    
    return Scaffold(
      body: planAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/superadmin/restaurants'),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
        data: (plan) {
          // Charger les valeurs depuis le plan si elles existent
          if (plan != null && plan.theme != null && plan.theme!.enabled) {
            final settings = ThemeSettings.fromJson(plan.theme!.settings);
            
            // Mettre à jour les controllers si nécessaire (sans le # car le prefixText l'ajoute)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final primaryWithoutHash = _removeHashPrefix(settings.primaryColor);
              final secondaryWithoutHash = _removeHashPrefix(settings.secondaryColor);
              final backgroundWithoutHash = _removeHashPrefix(settings.backgroundColor);
              final surfaceWithoutHash = _removeHashPrefix(settings.surfaceColor);
              
              if (_primaryColorController.text != primaryWithoutHash) {
                _primaryColorController.text = primaryWithoutHash;
              }
              if (_secondaryColorController.text != secondaryWithoutHash) {
                _secondaryColorController.text = secondaryWithoutHash;
              }
              if (_backgroundColorController.text != backgroundWithoutHash) {
                _backgroundColorController.text = backgroundWithoutHash;
              }
              if (_surfaceColorController.text != surfaceWithoutHash) {
                _surfaceColorController.text = surfaceWithoutHash;
              }
              if (_borderRadius != settings.radiusBase) {
                setState(() {
                  _borderRadius = settings.radiusBase;
                });
              }
            });
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => context.go('/superadmin/restaurants/${widget.restaurantId}'),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Retour'),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.restaurantName ?? 'Restaurant',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Text(' › '),
                    Text(
                      'Thème',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Éditeur de Thème White-Label',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Personnalisez l\'apparence de votre application. '
                  'Les modifications sont appliquées immédiatement sur Admin, POS et App Client.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Contenu principal
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Panneau de configuration
                      Expanded(
                        flex: 2,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section Couleurs
                                Text(
                                  'Couleurs',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                _buildColorField(
                                  label: 'Couleur Primaire',
                                  controller: _primaryColorController,
                                  theme: theme,
                                ),
                                const SizedBox(height: 16),
                                
                                _buildColorField(
                                  label: 'Couleur Secondaire',
                                  controller: _secondaryColorController,
                                  theme: theme,
                                ),
                                const SizedBox(height: 16),
                                
                                _buildColorField(
                                  label: 'Couleur de Fond',
                                  controller: _backgroundColorController,
                                  theme: theme,
                                ),
                                const SizedBox(height: 16),
                                
                                _buildColorField(
                                  label: 'Couleur de Surface',
                                  controller: _surfaceColorController,
                                  theme: theme,
                                ),
                                
                                const SizedBox(height: 32),
                                const Divider(),
                                const SizedBox(height: 32),
                                
                                // Section Forme
                                Text(
                                  'Forme',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                Text(
                                  'Rayon des Bordures: ${_borderRadius.toInt()}px',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Slider(
                                  value: _borderRadius,
                                  min: _minBorderRadius,
                                  max: _maxBorderRadius,
                                  divisions: (_maxBorderRadius - _minBorderRadius).toInt(),
                                  label: '${_borderRadius.toInt()}px',
                                  onChanged: (value) {
                                    setState(() {
                                      _borderRadius = value;
                                    });
                                  },
                                ),
                                
                                const SizedBox(height: 32),
                                
                                // Error message
                                if (_saveError != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: theme.colorScheme.error,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _saveError!,
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                const SizedBox(height: 24),
                                
                                // Actions
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _isSaving ? null : _saveTheme,
                                        icon: _isSaving
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Icon(Icons.save),
                                        label: Text(_isSaving ? 'Sauvegarde...' : 'Enregistrer'),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    OutlinedButton.icon(
                                      onPressed: _isSaving ? null : _resetTheme,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Réinitialiser'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 24),
                      
                      // Panneau d'aperçu
                      Expanded(
                        flex: 1,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '👁️ Aperçu',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Preview des couleurs
                                _buildColorPreview(
                                  'Primaire',
                                  _parseColor(_ensureHashPrefix(_primaryColorController.text)),
                                ),
                                const SizedBox(height: 12),
                                
                                _buildColorPreview(
                                  'Secondaire',
                                  _parseColor(_ensureHashPrefix(_secondaryColorController.text)),
                                ),
                                const SizedBox(height: 12),
                                
                                _buildColorPreview(
                                  'Fond',
                                  _parseColor(_ensureHashPrefix(_backgroundColorController.text)),
                                ),
                                const SizedBox(height: 12),
                                
                                _buildColorPreview(
                                  'Surface',
                                  _parseColor(_ensureHashPrefix(_surfaceColorController.text)),
                                ),
                                
                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 24),
                                
                                // Preview du borderRadius
                                Text(
                                  'Exemple de carte',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _parseColor(_ensureHashPrefix(_surfaceColorController.text)),
                                    borderRadius: BorderRadius.circular(_borderRadius),
                                    border: Border.all(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _parseColor(_ensureHashPrefix(_primaryColorController.text)),
                                          borderRadius: BorderRadius.circular(_borderRadius * _nestedBorderRadiusRatio),
                                        ),
                                        child: const Text(
                                          'Bouton',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Rayon: ${_borderRadius.toInt()}px',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  /// Widget pour un champ de couleur.
  Widget _buildColorField({
    required String label,
    required TextEditingController controller,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Preview de la couleur
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _parseColor(_ensureHashPrefix(controller.text)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // TextField pour le hex
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'RRGGBB',
                  prefixText: '#',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: !_isValidHex(_ensureHashPrefix(controller.text))
                      ? 'Format invalide'
                      : null,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f]')),
                  LengthLimitingTextInputFormatter(_hexColorLength), // RRGGBB (without #)
                ],
                onChanged: (value) {
                  setState(() {}); // Rebuild pour mettre à jour le preview
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// Widget pour afficher un aperçu de couleur.
  Widget _buildColorPreview(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
