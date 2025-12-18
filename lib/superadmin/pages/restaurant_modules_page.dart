// MIGRATED to WL V2 Theme - Uses theme colors
/// lib/superadmin/pages/restaurant_modules_page.dart
///
/// Page de gestion des modules d'un restaurant.
/// Permet d'activer/désactiver les modules et de les configurer.
library;

import 'package:flutter/material.dart';
import '../../src/design_system/colors.dart';
import '../../white_label/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../white_label/core/module_category.dart';
import '../../white_label/core/module_config.dart';
import '../../white_label/core/module_definition.dart';
import '../../white_label/core/module_registry.dart';
import '../../white_label/restaurant/restaurant_plan.dart';
import '../../src/providers/restaurant_plan_provider.dart';
import '../services/restaurant_plan_service.dart';

/// Page de gestion des modules pour un restaurant spécifique.
class RestaurantModulesPage extends ConsumerStatefulWidget {
  /// Identifiant du restaurant.
  final String restaurantId;

  /// Nom du restaurant (optionnel, pour l'affichage).
  final String? restaurantName;

  const RestaurantModulesPage({
    super.key,
    required this.restaurantId,
    this.restaurantName,
  });

  @override
  ConsumerState<RestaurantModulesPage> createState() => _RestaurantModulesPageState();
}

class _RestaurantModulesPageState extends ConsumerState<RestaurantModulesPage> {
  final RestaurantPlanService _planService = RestaurantPlanService();

  RestaurantPlan? _plan;
  Map<String, bool> _pendingChanges = {};
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final plan = await _planService.loadPlan(widget.restaurantId);
      setState(() {
        _plan = plan;
        _pendingChanges = {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement: $e';
        _isLoading = false;
      });
    }
  }

  bool _isModuleEnabled(String id) {
    // D'abord vérifier les changements en attente
    if (_pendingChanges.containsKey(id)) {
      return _pendingChanges[id]!;
    }
    // Sinon utiliser la valeur du plan
    return _plan?.hasModule(id) ?? false;
  }

  void _toggleModule(String id, bool enabled) {
    final definition = ModuleRegistry.of(id);
    if (definition == null) return;

    // Vérifier les dépendances si on active
    if (enabled) {
      final missingDeps = <String>[];
      for (final d in definition.dependencies) {
        if (!_isModuleEnabled(d)) {
          missingDeps.add(d);
        }
      }

      if (missingDeps.isNotEmpty) {
        _showDependencyDialog(id, missingDeps);
        return;
      }
    } else {
      // Vérifier si d'autres modules dépendent de celui-ci
      final dependents = <String>[];
      // Check all modules in the registry
      for (final entry in ModuleRegistry.definitions.entries) {
        final moduleCode = entry.key;
        if (_isModuleEnabled(moduleCode)) {
          final def = entry.value;
          if (def.dependencies.any((d) => d == id)) {
            dependents.add(moduleCode);
          }
        }
      }

      if (dependents.isNotEmpty) {
        _showDependentModulesDialog(id, dependents);
        return;
      }
    }

    setState(() {
      _pendingChanges[id] = enabled;
    });
  }

  void _showDependencyDialog(String moduleId, List<String> missingDeps) {
    final moduleDef = ModuleRegistry.of(moduleId);
    if (moduleDef == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dépendances requises'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pour activer "${moduleDef.name}", '
              'vous devez d\'abord activer :',
            ),
            const SizedBox(height: 12),
            ...missingDeps.map((dep) {
              final depDef = ModuleRegistry.of(dep);
              return Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.subdirectory_arrow_right, size: 18),
                    const SizedBox(width: 8),
                    Text(depDef?.name ?? dep),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Activer toutes les dépendances puis le module
              for (final dep in missingDeps) {
                _pendingChanges[dep] = true;
              }
              _pendingChanges[moduleId] = true;
              setState(() {});
            },
            child: const Text('Tout activer'),
          ),
        ],
      ),
    );
  }

  void _showDependentModulesDialog(String moduleId, List<String> dependents) {
    final moduleDef = ModuleRegistry.of(moduleId);
    if (moduleDef == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modules dépendants'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Les modules suivants dépendent de "${moduleDef.name}" '
              'et seront désactivés :',
            ),
            const SizedBox(height: 12),
            ...dependents.map((dep) {
              final depDef = ModuleRegistry.of(dep);
              return Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.subdirectory_arrow_right, size: 18),
                    const SizedBox(width: 8),
                    Text(depDef?.name ?? dep),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(context).pop();
              // Désactiver le module et tous ses dépendants
              for (final dep in dependents) {
                _pendingChanges[dep] = false;
              }
              _pendingChanges[moduleId] = false;
              setState(() {});
            },
            child: const Text('Tout désactiver'),
          ),
        ],
      ),
    );
  }

  bool get _hasChanges => _pendingChanges.isNotEmpty;

  Future<void> _saveChanges() async {
    if (!_hasChanges || _plan == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Appliquer les changements au plan en utilisant le nouveau service
      for (final entry in _pendingChanges.entries) {
        final moduleId = entry.key;
        final enabled = entry.value;
        await _planService.updateModule(widget.restaurantId, moduleId, enabled);
      }

      // PATCH 1: Invalidate Riverpod providers for instant WL plan refresh
      // This ensures the runtime reloads immediately without Flutter restart
      ref.invalidate(restaurantPlanProvider);
      ref.invalidate(restaurantPlanUnifiedProvider);
      ref.invalidate(restaurantFeatureFlagsUnifiedProvider);

      // Recharger le plan
      try {
        await _loadPlan();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Configuration enregistrée avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        // Failed to reload, but changes were saved
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Modifications enregistrées mais erreur lors du rechargement: $e'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        setState(() {
          _isSaving = false;
        });
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _discardChanges() {
    setState(() {
      _pendingChanges = {};
    });
  }

  String _getModuleName(String moduleCode) {
    return ModuleRegistry.of(moduleCode)?.name ?? moduleCode;
  }

  Color _getCategoryColor(ModuleCategory category) {
    switch (category) {
      case ModuleCategory.system:
        return AppColors.error;
      case ModuleCategory.business:
        return Colors.indigo;
      case ModuleCategory.visual:
        return Colors.purple;
      case ModuleCategory.core:
        return context.primaryColor;
      case ModuleCategory.payment:
        return AppColors.success;
      case ModuleCategory.marketing:
        return AppColors.warning;
      case ModuleCategory.operations:
        return Colors.brown;
      case ModuleCategory.appearance:
        return Colors.pink;
      case ModuleCategory.staff:
        return Colors.teal;
      case ModuleCategory.analytics:
        return Colors.deepPurple;
    }
  }

  IconData _getCategoryIcon(ModuleCategory category) {
    switch (category) {
      case ModuleCategory.system:
        return Icons.settings_system_daydream;
      case ModuleCategory.business:
        return Icons.business_center;
      case ModuleCategory.visual:
        return Icons.palette;
      case ModuleCategory.core:
        return Icons.shopping_cart;
      case ModuleCategory.payment:
        return Icons.payment;
      case ModuleCategory.marketing:
        return Icons.campaign;
      case ModuleCategory.operations:
        return Icons.restaurant;
      case ModuleCategory.appearance:
        return Icons.color_lens;
      case ModuleCategory.staff:
        return Icons.people;
      case ModuleCategory.analytics:
        return Icons.analytics;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPlan,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    // Grouper les modules par catégorie
    final modulesByCategory = <ModuleCategory, List<ModuleDefinition>>{};
    for (final category in ModuleCategory.values) {
      final modules = ModuleRegistry.byCategory(category);
      if (modules.isNotEmpty) {
        modulesByCategory[category] = modules;
      }
    }

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.onPrimary,
              border: Border(
                bottom: BorderSide(color: context.colorScheme.surfaceVariant),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        if (_hasChanges) {
                          _showDiscardDialog();
                        } else {
                          context.go('/superadmin/restaurants/${widget.restaurantId}');
                        }
                      },
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Retour'),
                    ),
                    const Spacer(),
                    if (_hasChanges) ...[
                      TextButton(
                        onPressed: _discardChanges,
                        child: const Text('Annuler les modifications'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveChanges,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.onPrimary,
                                ),
                              )
                            : const Icon(Icons.save, size: 18),
                        label: Text(_isSaving ? 'Enregistrement...' : 'Enregistrer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: context.onPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.primaryColor.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.extension,
                        size: 32,
                        color: context.primaryColor.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestion des modules',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: context.colorScheme.surfaceVariant ,
                            ),
                          ),
                          if (widget.restaurantName != null)
                            Text(
                              widget.restaurantName!,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.colorScheme.surfaceVariant ,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_hasChanges)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.warning),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.pending,
                              size: 16,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_pendingChanges.length} modification(s)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Modules list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: modulesByCategory.entries.map((entry) {
                  return _buildCategorySection(entry.key, entry.value);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    ModuleCategory category,
    List<ModuleDefinition> modules,
  ) {
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.surfaceVariant ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.surfaceVariant ,
                        ),
                      ),
                      Text(
                        category.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colorScheme.surfaceVariant ,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Modules list
          ...modules.map((module) => _buildModuleTile(module, color)),
        ],
      ),
    );
  }

  Widget _buildModuleTile(ModuleDefinition module, Color categoryColor) {
    final moduleId = module.id;
    final isEnabled = _isModuleEnabled(moduleId);
    final hasChange = _pendingChanges.containsKey(moduleId);
    final hasDependencies = module.dependencies.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.colorScheme.surfaceVariant ),
        ),
        color: hasChange ? Colors.yellow.shade50 : null,
      ),
      child: Row(
        children: [
          // Module info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      module.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.surfaceVariant ,
                      ),
                    ),
                    if (module.isPremium) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ],
                    if (hasChange) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'MODIFIÉ',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  module.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colorScheme.surfaceVariant ,
                  ),
                ),
                if (hasDependencies) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.link,
                        size: 12,
                        color: context.colorScheme.surfaceVariant ,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Dépend de: ${module.dependencies.map((d) => _getModuleName(d)).join(", ")}',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: context.colorScheme.surfaceVariant ,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Toggle switch
          Switch(
            value: isEnabled,
            onChanged: (value) => _toggleModule(moduleId, value),
            activeColor: categoryColor,
          ),
        ],
      ),
    );
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifications non enregistrées'),
        content: const Text(
          'Vous avez des modifications non enregistrées. '
          'Voulez-vous les perdre ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuer à éditer'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/superadmin/restaurants/${widget.restaurantId}');
            },
            child: const Text('Quitter sans enregistrer'),
          ),
        ],
      ),
    );
  }
}
