// lib/builder/page_list/new_page_dialog_v2.dart
// Enhanced dialog for creating new Builder pages
// Supports both template and blank page creation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../../white_label/core/module_id.dart';
import '../../src/providers/restaurant_plan_provider.dart';

/// Template definition for page creation
class PageTemplate {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const PageTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Available templates for page creation
/// 
/// FIX N1 / Fix 6: Removed system page templates (cart_template, profile_template, roulette_template)
/// These templates were removed because:
/// - They suggest creating system pages which could cause collision/confusion
/// - System pages (cart, profile, roulette) should only be edited, not created from templates
/// - The remaining templates (home, menu, promo, about, contact) generate CUSTOM pages
///   with unique pageKeys derived from user-provided names, never matching system pages
const List<PageTemplate> availableTemplates = [
  PageTemplate(
    id: 'home_template',
    name: 'Accueil',
    description: 'Page d\'accueil avec hero banner et produits',
    icon: Icons.home,
    color: Colors.blue,
  ),
  PageTemplate(
    id: 'menu_template',
    name: 'Menu',
    description: 'Catalogue de produits avec catégories',
    icon: Icons.restaurant_menu,
    color: Colors.orange,
  ),
  PageTemplate(
    id: 'promo_template',
    name: 'Promotions',
    description: 'Page des offres et promotions',
    icon: Icons.local_offer,
    color: Colors.red,
  ),
  PageTemplate(
    id: 'about_template',
    name: 'À propos',
    description: 'Présentation du restaurant',
    icon: Icons.info,
    color: Colors.teal,
  ),
  PageTemplate(
    id: 'contact_template',
    name: 'Contact',
    description: 'Coordonnées et formulaire',
    icon: Icons.contact_mail,
    color: Colors.green,
  ),
  // FIX N1: Removed cart_template, roulette_template, profile_template
  // These system pages should be edited via the system page editor, not created from templates
];

/// Mapping des templates vers leur ModuleId requis
/// 
/// Détermine quel module WL doit être activé pour qu'un template soit disponible.
/// null = toujours disponible (pas de restriction)
const Map<String, ModuleId?> templateRequiredModules = {
  'home_template': null, // Toujours disponible
  'menu_template': ModuleId.ordering, // Nécessite module commande
  'promo_template': ModuleId.promotions, // Nécessite module promotions
  'about_template': null, // Toujours disponible
  'contact_template': null, // Toujours disponible
};

/// Enhanced dialog for creating new Builder pages
/// 
/// Features:
/// - Choice between Template or Blank page
/// - Template list with icons and descriptions
/// - Calls createPageFromTemplate or createBlankPage
/// - **Filters templates based on restaurant's white-label plan**
///   - Only shows templates for which the required modules are activated
///   - Templates without module requirements are always shown
///   - Falls back to showing all templates if plan is not loaded
class NewPageDialogV2 extends ConsumerStatefulWidget {
  final String appId;
  final Function(BuilderPage) onPageCreated;

  const NewPageDialogV2({
    super.key,
    required this.appId,
    required this.onPageCreated,
  });

  @override
  ConsumerState<NewPageDialogV2> createState() => _NewPageDialogV2State();
}

class _NewPageDialogV2State extends ConsumerState<NewPageDialogV2> {
  final BuilderPageService _pageService = BuilderPageService();
  
  // Step 1: Choose type (template or blank)
  // Step 2a: If template, choose template
  // Step 2b: If blank, enter name
  int _currentStep = 0;
  bool _isTemplate = true;
  PageTemplate? _selectedTemplate;
  
  final _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    _currentStep == 0 
                        ? Icons.add_circle 
                        : _isTemplate 
                            ? Icons.dashboard 
                            : Icons.description,
                    color: Colors.blue,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getStepTitle(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: _buildStepContent(),
              ),
              
              const SizedBox(height: 16),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton.icon(
                      onPressed: () => setState(() => _currentStep = 0),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Retour'),
                    )
                  else
                    const SizedBox.shrink(),
                  if (_currentStep == 1 || _currentStep == 2)
                    ElevatedButton.icon(
                      onPressed: _isCreating ? null : _createPage,
                      icon: _isCreating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                      label: Text(_isCreating ? 'Création...' : 'Créer la page'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Créer une nouvelle page';
      case 1:
        return 'Choisir un template';
      case 2:
        return 'Page vierge';
      default:
        return 'Nouvelle page';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildTypeChoice();
      case 1:
        return _buildTemplateList();
      case 2:
        return _buildBlankPageForm();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTypeChoice() {
    return Column(
      children: [
        const Text(
          'Quel type de page voulez-vous créer ?',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        
        // Template option
        _buildTypeCard(
          icon: Icons.dashboard,
          title: '⚡ Page à partir d\'un template',
          description: 'Commencez avec une structure prédéfinie',
          color: Colors.blue,
          onTap: () {
            setState(() {
              _isTemplate = true;
              _currentStep = 1;
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // Blank option
        _buildTypeCard(
          icon: Icons.description,
          title: '🧾 Page vierge',
          description: 'Créez une page vide à personnaliser',
          color: Colors.teal,
          onTap: () {
            setState(() {
              _isTemplate = false;
              _currentStep = 2;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateList() {
    // Get restaurant plan for filtering templates
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    
    // Use .when() to properly handle loading/error/data states
    return planAsync.when(
      loading: () => _buildTemplateListLoading(),
      error: (e, _) => _buildTemplateListContent(null), // Fallback: show all templates
      data: (plan) => _buildTemplateListContent(plan),
    );
  }

  /// Build loading indicator for template list
  Widget _buildTemplateListLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Build template list content with plan data (or null for fallback)
  Widget _buildTemplateListContent(RestaurantPlanUnified? plan) {
    // Filter templates based on required modules
    final filteredTemplates = availableTemplates.where((template) {
      final requiredModule = templateRequiredModules[template.id];
      // If no required module or plan is null, template is available
      if (requiredModule == null || plan == null) return true;
      // Check if plan has the required module
      return plan.hasModule(requiredModule);
    }).toList();
    
    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredTemplates.length,
      itemBuilder: (context, index) {
        final template = filteredTemplates[index];
        final isSelected = _selectedTemplate?.id == template.id;
        
        return Card(
          elevation: isSelected ? 4 : 1,
          color: isSelected ? template.color.withOpacity(0.1) : null,
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              setState(() => _selectedTemplate = template);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: template.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(template.icon, color: template.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? template.color : null,
                          ),
                        ),
                        Text(
                          template.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: template.color, size: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlankPageForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Donnez un nom à votre page',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nom de la page',
            hintText: 'Ex: Ma nouvelle page',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        // FIX F3: Informational note about reserved page IDs
        // Note: The actual collision prevention is handled by _generatePageId() in BuilderPageService (FIX F1)
        // which adds a unique suffix (custom_xxx_12345) when the name matches a system page
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Note: Si vous nommez votre page "Menu", "Home", "Cart", "Profile", etc., '
                  'l\'ID sera automatiquement modifié pour éviter les conflits avec les pages système.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'La page sera créée vide et vous pourrez ajouter des blocs depuis l\'éditeur.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _createPage() async {
    if (_isTemplate && _selectedTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un template')),
      );
      return;
    }
    
    if (!_isTemplate && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un nom pour la page')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      BuilderPage page;
      
      if (_isTemplate) {
        page = await _pageService.createPageFromTemplate(
          _selectedTemplate!.id,
          appId: widget.appId,
          name: _selectedTemplate!.name,
          description: _selectedTemplate!.description,
        );
      } else {
        page = await _pageService.createBlankPage(
          appId: widget.appId,
          name: _nameController.text.trim(),
        );
      }
      
      widget.onPageCreated(page);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}
