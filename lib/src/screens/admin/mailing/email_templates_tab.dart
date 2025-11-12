// lib/src/screens/admin/mailing/email_templates_tab.dart
// Onglet pour gérer les modèles d'emails

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/email_template.dart';
import '../../../services/email_template_service.dart';
import '../../../theme/app_theme.dart';
import '../../../core/constants.dart';
import 'email_template_preview_dialog.dart';

class EmailTemplatesTab extends StatefulWidget {
  const EmailTemplatesTab({super.key});

  @override
  State<EmailTemplatesTab> createState() => _EmailTemplatesTabState();
}

class _EmailTemplatesTabState extends State<EmailTemplatesTab> {
  final EmailTemplateService _templateService = EmailTemplateService();
  final TextEditingController _searchController = TextEditingController();
  List<EmailTemplate> _templates = [];
  List<EmailTemplate> _filteredTemplates = [];
  bool _isLoading = true;
  String _sortBy = 'name'; // 'name', 'date'

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    final templates = await _templateService.loadTemplates();
    setState(() {
      _templates = templates;
      _applyFiltersAndSort();
      _isLoading = false;
    });
  }

  void _applyFiltersAndSort() {
    List<EmailTemplate> filtered = _templates;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((template) {
        return template.name.toLowerCase().contains(query) ||
            template.subject.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'date':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    _filteredTemplates = filtered;
  }

  Future<void> _duplicateTemplate(EmailTemplate template) async {
    final newTemplate = EmailTemplate(
      id: const Uuid().v4(),
      name: '${template.name} (Copie)',
      subject: template.subject,
      htmlBody: template.htmlBody,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ctaText: template.ctaText,
      ctaUrl: template.ctaUrl,
      bannerUrl: template.bannerUrl,
    );

    final success = await _templateService.addTemplate(newTemplate);
    if (success) {
      _loadTemplates();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Modèle dupliqué avec succès')),
        );
      }
    }
  }

  Future<void> _showTemplateDialog({EmailTemplate? template}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: template?.name ?? '');
    final subjectController =
        TextEditingController(text: template?.subject ?? '');
    final htmlController = TextEditingController(text: template?.htmlBody ?? '');
    final ctaTextController =
        TextEditingController(text: template?.ctaText ?? 'Commander maintenant');
    final ctaUrlController =
        TextEditingController(text: template?.ctaUrl ?? '');
    final bannerUrlController =
        TextEditingController(text: template?.bannerUrl ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        template == null
                            ? 'Nouveau Modèle'
                            : 'Modifier Modèle',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Form content
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Nom du template *',
                            hintText: 'Ex: Promo Weekend',
                            prefixIcon: Icon(Icons.label,
                                color: AppTheme.primaryRed),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nom requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: subjectController,
                          decoration: InputDecoration(
                            labelText: 'Sujet de l\'email *',
                            hintText: 'Ex: -20% sur toutes les pizzas',
                            prefixIcon: Icon(Icons.subject,
                                color: AppTheme.primaryRed),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Sujet requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: ctaTextController,
                          decoration: InputDecoration(
                            labelText: 'Texte du bouton CTA',
                            hintText: 'Ex: Commander maintenant',
                            prefixIcon:
                                Icon(Icons.touch_app, color: AppTheme.primaryRed),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: ctaUrlController,
                          decoration: InputDecoration(
                            labelText: 'URL du bouton CTA',
                            hintText: 'https://delizza.fr/commander',
                            prefixIcon:
                                Icon(Icons.link, color: AppTheme.primaryRed),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: bannerUrlController,
                          decoration: InputDecoration(
                            labelText: 'URL de la bannière',
                            hintText: 'https://...',
                            prefixIcon:
                                Icon(Icons.image, color: AppTheme.primaryRed),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: htmlController,
                          decoration: InputDecoration(
                            labelText: 'Code HTML *',
                            hintText: 'Collez votre template HTML ici...',
                            prefixIcon:
                                Icon(Icons.code, color: AppTheme.primaryRed),
                            helperText:
                                'Variables disponibles: {{subject}}, {{content}}, {{ctaUrl}}, {{ctaText}}, {{bannerUrl}}, {{unsubUrl}}',
                            helperMaxLines: 3,
                          ),
                          maxLines: 8,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Code HTML requis';
                            }
                            return null;
                          },
                        ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final newTemplate = EmailTemplate(
                            id: template?.id ?? const Uuid().v4(),
                            name: nameController.text.trim(),
                            subject: subjectController.text.trim(),
                            htmlBody: htmlController.text.trim(),
                            createdAt: template?.createdAt ?? DateTime.now(),
                            updatedAt: DateTime.now(),
                            ctaText: ctaTextController.text.trim(),
                            ctaUrl: ctaUrlController.text.trim(),
                            bannerUrl: bannerUrlController.text.trim(),
                          );

                          bool success;
                          if (template == null) {
                            success = await _templateService.addTemplate(newTemplate);
                          } else {
                            success =
                                await _templateService.updateTemplate(newTemplate);
                          }

                          if (success && context.mounted) {
                            Navigator.pop(context, true);
                          }
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Sauvegarder'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      _loadTemplates();
    }
  }

  Future<void> _deleteTemplate(EmailTemplate template) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${template.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _templateService.deleteTemplate(template.id);
      if (success) {
        _loadTemplates();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template supprimé avec succès')),
          );
        }
      }
    }
  }

  void _previewTemplate(EmailTemplate template) {
    showDialog(
      context: context,
      builder: (context) => EmailTemplatePreviewDialog(template: template),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.description, size: 80, color: AppTheme.primaryRed),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun modèle d\'email',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Les modèles vous permettent de créer des emails personnalisés réutilisables pour vos campagnes',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showTemplateDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Créer mon premier modèle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with search and actions
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${_filteredTemplates.length} modèle(s)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showTemplateDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Nouveau'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search and sort bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un modèle...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _applyFiltersAndSort());
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _applyFiltersAndSort());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.sort, size: 20),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                    onSelected: (value) {
                      setState(() {
                        _sortBy = value;
                        _applyFiltersAndSort();
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'name',
                        child: Text('Trier par nom'),
                      ),
                      const PopupMenuItem(
                        value: 'date',
                        child: Text('Trier par date'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // Templates list
        Expanded(
          child: _filteredTemplates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun modèle trouvé',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Essayez de modifier vos critères de recherche',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(VisualConstants.paddingMedium),
                  itemCount: _filteredTemplates.length,
                  itemBuilder: (context, index) {
                    final template = _filteredTemplates[index];
                    return _buildTemplateCard(template);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(EmailTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showTemplateDialog(template: template),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.description,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template.subject,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.visibility, color: AppTheme.primaryRed),
                    onPressed: () => _previewTemplate(template),
                    tooltip: 'Prévisualiser',
                  ),
                  IconButton(
                    icon: Icon(Icons.content_copy, color: Colors.blue),
                    onPressed: () => _duplicateTemplate(template),
                    tooltip: 'Dupliquer',
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: AppTheme.primaryRed),
                    onPressed: () => _showTemplateDialog(template: template),
                    tooltip: 'Modifier',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: AppTheme.errorRed),
                    onPressed: () => _deleteTemplate(template),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    'Créé le ${_formatDate(template.createdAt)}',
                    Icons.calendar_today,
                  ),
                  if (template.updatedAt != null)
                    _buildInfoChip(
                      'Modifié le ${_formatDate(template.updatedAt!)}',
                      Icons.edit_calendar,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppTheme.textMedium),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppTheme.backgroundLight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
