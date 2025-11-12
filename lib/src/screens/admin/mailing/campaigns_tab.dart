// lib/src/screens/admin/mailing/campaigns_tab.dart
// Onglet pour gérer les campagnes d'emailing

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:csv/csv.dart';
import '../../../models/campaign.dart';
import '../../../models/email_template.dart';
import '../../../services/campaign_service.dart';
import '../../../services/email_template_service.dart';
import '../../../services/mailing_service.dart';
import '../../../theme/app_theme.dart';
import '../../../core/constants.dart';

class CampaignsTab extends StatefulWidget {
  const CampaignsTab({super.key});

  @override
  State<CampaignsTab> createState() => _CampaignsTabState();
}

class _CampaignsTabState extends State<CampaignsTab> {
  final CampaignService _campaignService = CampaignService();
  final EmailTemplateService _templateService = EmailTemplateService();
  final MailingService _mailingService = MailingService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Campaign> _campaigns = [];
  List<Campaign> _filteredCampaigns = [];
  List<EmailTemplate> _templates = [];
  bool _isLoading = true;
  String _filterStatus = 'all';
  String _sortBy = 'date'; // 'date', 'name'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final campaigns = await _campaignService.loadCampaigns();
    final templates = await _templateService.loadTemplates();
    setState(() {
      _campaigns = campaigns;
      _templates = templates;
      _applyFiltersAndSort();
      _isLoading = false;
    });
  }

  void _applyFiltersAndSort() {
    List<Campaign> filtered = _campaigns;

    // Apply status filter
    if (_filterStatus != 'all') {
      filtered = filtered.where((c) => c.status == _filterStatus).toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((campaign) {
        return campaign.name.toLowerCase().contains(query);
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

    _filteredCampaigns = filtered;
  }

  Map<String, int> _getStatistics() {
    return {
      'total': _campaigns.length,
      'sent': _campaigns.where((c) => c.status == 'sent').length,
      'scheduled': _campaigns.where((c) => c.status == 'scheduled').length,
      'draft': _campaigns.where((c) => c.status == 'draft').length,
      'failed': _campaigns.where((c) => c.status == 'failed').length,
    };
  }

  Future<void> _exportCampaignsToCSV() async {
    if (_filteredCampaigns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune campagne à exporter')),
      );
      return;
    }

    // Create CSV data
    List<List<dynamic>> rows = [];
    
    // Header row
    rows.add(['Nom', 'Statut', 'Segment', 'Date création', 'Date envoi', 'Envoyés', 'Ouverts', 'Clics']);
    
    // Data rows
    for (var campaign in _filteredCampaigns) {
      rows.add([
        campaign.name,
        _getStatusLabel(campaign.status),
        _getSegmentLabel(campaign.segment),
        _formatDate(campaign.createdAt),
        campaign.sentAt != null ? _formatDate(campaign.sentAt!) : '-',
        campaign.stats?.sent ?? 0,
        campaign.stats?.opened ?? 0,
        campaign.stats?.clicked ?? 0,
      ]);
    }

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(rows);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export CSV - Campagnes'),
        content: SingleChildScrollView(
          child: SelectableText(
            csv,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export de ${_filteredCampaigns.length} campagne(s) généré'),
        backgroundColor: AppTheme.primaryRed,
      ),
    );
  }

  Future<void> _sendTestEmail(Campaign campaign) async {
    final emailController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Envoyer un email de test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Campagne: ${campaign.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email de destination',
                hintText: 'votre.email@exemple.com',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.contains('@')) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );

    if (result == true && emailController.text.isNotEmpty) {
      // Simulate sending test email
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email de test envoyé à ${emailController.text}'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
    }
  }

  Future<void> _showCampaignDialog({Campaign? campaign}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: campaign?.name ?? '');
    
    // Validate that selectedTemplateId exists in the templates list
    String selectedTemplateId = '';
    if (campaign?.templateId != null && _templates.any((t) => t.id == campaign!.templateId)) {
      selectedTemplateId = campaign!.templateId;
    } else if (_templates.isNotEmpty) {
      selectedTemplateId = _templates.first.id;
    }
    
    String selectedSegment = campaign?.segment ?? 'all';
    DateTime? scheduleDate = campaign?.scheduleAt;
    bool sendNow = campaign?.scheduleAt == null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.campaign, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          campaign == null ? 'Nouvelle Campagne' : 'Modifier Campagne',
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Nom de la campagne *',
                              hintText: 'Ex: Promo Weekend',
                              prefixIcon: Icon(Icons.label, color: AppTheme.primaryRed),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nom requis';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Modèle d\'email',
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _templates.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.orange.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning, color: Colors.orange.shade700),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Aucun modèle disponible',
                                          style: TextStyle(color: Colors.orange.shade900),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : DropdownButtonFormField<String>(
                                  value: selectedTemplateId.isEmpty ? null : selectedTemplateId,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.description, color: AppTheme.primaryRed),
                                  ),
                                  items: _templates.map((template) {
                                    return DropdownMenuItem(
                                      value: template.id,
                                      child: Text(template.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setDialogState(() => selectedTemplateId = value);
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Sélectionnez un modèle';
                                    }
                                    return null;
                                  },
                                ),
                          const SizedBox(height: 20),
                          Text(
                            'Segment de destinataires',
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedSegment,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.people, color: AppTheme.primaryRed),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('Tous les abonnés actifs')),
                              DropdownMenuItem(value: 'vip', child: Text('Clients VIP')),
                              DropdownMenuItem(value: 'nouveautes', child: Text('Intéressés par les nouveautés')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() => selectedSegment = value);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Planification',
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            title: const Text('Envoyer immédiatement'),
                            subtitle: const Text('L\'email sera envoyé dès maintenant'),
                            value: sendNow,
                            onChanged: (value) {
                              setDialogState(() => sendNow = value);
                            },
                            activeColor: AppTheme.primaryRed,
                          ),
                          if (!sendNow) ...[
                            const SizedBox(height: 12),
                            ListTile(
                              leading: Icon(Icons.calendar_today, color: AppTheme.primaryRed),
                              title: Text(
                                scheduleDate != null
                                    ? 'Envoi prévu le ${_formatDate(scheduleDate!)}'
                                    : 'Sélectionner une date',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: scheduleDate ?? DateTime.now().add(const Duration(days: 1)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (time != null) {
                                    setDialogState(() {
                                      scheduleDate = DateTime(
                                        date.year,
                                        date.month,
                                        date.day,
                                        time.hour,
                                        time.minute,
                                      );
                                    });
                                  }
                                }
                              },
                              tileColor: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
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
                            if (!sendNow && scheduleDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sélectionnez une date d\'envoi')),
                              );
                              return;
                            }

                            final newCampaign = Campaign(
                              id: campaign?.id ?? const Uuid().v4(),
                              name: nameController.text.trim(),
                              templateId: selectedTemplateId,
                              segment: selectedSegment,
                              scheduleAt: sendNow ? null : scheduleDate,
                              status: sendNow ? 'sending' : 'scheduled',
                              createdAt: campaign?.createdAt ?? DateTime.now(),
                            );

                            bool success;
                            if (campaign == null) {
                              success = await _campaignService.addCampaign(newCampaign);
                              
                              // Si envoi immédiat, simuler l'envoi
                              if (sendNow && success) {
                                final subscribers = await _mailingService.getSubscribersBySegment(selectedSegment);
                                await _campaignService.sendCampaign(newCampaign.id, subscribers.length);
                              }
                            } else {
                              success = await _campaignService.updateCampaign(newCampaign);
                            }

                            if (success && context.mounted) {
                              Navigator.pop(context, true);
                            }
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: Text(sendNow ? 'Créer et Envoyer' : 'Planifier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _deleteCampaign(Campaign campaign) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${campaign.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _campaignService.deleteCampaign(campaign.id);
      if (success) {
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Campagne supprimée avec succès')),
          );
        }
      }
    }
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
            Icon(Icons.warning, size: 80, color: Colors.orange[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun modèle disponible',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Créez d\'abord un modèle d\'email'),
          ],
        ),
      );
    }

    if (_campaigns.isEmpty) {
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
              child: Icon(Icons.campaign, size: 80, color: AppTheme.primaryRed),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune campagne',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Créez des campagnes d\'emailing pour communiquer avec vos abonnés. Planifiez, envoyez et suivez vos résultats.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCampaignDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Créer ma première campagne'),
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

    final stats = _getStatistics();

    return Column(
      children: [
        // Statistics cards
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatCard('Total', stats['total']!, Icons.campaign, Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard('Envoyées', stats['sent']!, Icons.check_circle, Colors.green),
                const SizedBox(width: 12),
                _buildStatCard('Planifiées', stats['scheduled']!, Icons.schedule, Colors.orange),
                const SizedBox(width: 12),
                _buildStatCard('Brouillons', stats['draft']!, Icons.drafts, Colors.grey),
              ],
            ),
          ),
        ),
        // Header with search and actions
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${_filteredCampaigns.length} campagne(s)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: _exportCampaignsToCSV,
                    tooltip: 'Exporter CSV',
                    color: AppTheme.primaryRed,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showCampaignDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Nouvelle'),
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
              // Search and filters
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher une campagne...',
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
                        fillColor: Colors.grey.shade50,
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
                        color: Colors.grey.shade50,
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
                        value: 'date',
                        child: Text('Trier par date'),
                      ),
                      const PopupMenuItem(
                        value: 'name',
                        child: Text('Trier par nom'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Status filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Toutes', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Envoyées', 'sent'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Planifiées', 'scheduled'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Brouillons', 'draft'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Échouées', 'failed'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Campaigns list
        Expanded(
          child: _filteredCampaigns.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune campagne trouvée',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Essayez de modifier vos filtres ou votre recherche',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(VisualConstants.paddingMedium),
                  itemCount: _filteredCampaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = _filteredCampaigns[index];
                    return _buildCampaignCard(campaign);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCampaignCard(Campaign campaign) {
    final statusColor = _getStatusColor(campaign.status);
    final statusLabel = _getStatusLabel(campaign.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showCampaignDialog(campaign: campaign),
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
                    child: const Icon(Icons.campaign, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.name,
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Segment: ${_getSegmentLabel(campaign.segment)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    'Créé le ${_formatDate(campaign.createdAt)}',
                    Icons.calendar_today,
                  ),
                  if (campaign.scheduleAt != null)
                    _buildInfoChip(
                      'Envoi prévu: ${_formatDate(campaign.scheduleAt!)}',
                      Icons.schedule,
                    ),
                  if (campaign.sentAt != null)
                    _buildInfoChip(
                      'Envoyé le ${_formatDate(campaign.sentAt!)}',
                      Icons.check_circle,
                    ),
                ],
              ),
              if (campaign.stats != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Envoyés', campaign.stats!.sent, Icons.send),
                      _buildStatItem('Ouverts', campaign.stats!.opened, Icons.mark_email_read),
                      _buildStatItem('Clics', campaign.stats!.clicked, Icons.touch_app),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (campaign.status != 'sent')
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.blue),
                      onPressed: () => _sendTestEmail(campaign),
                      tooltip: 'Tester',
                    ),
                  IconButton(
                    icon: Icon(Icons.edit, color: AppTheme.primaryRed),
                    onPressed: () => _showCampaignDialog(campaign: campaign),
                    tooltip: 'Modifier',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: AppTheme.errorRed),
                    onPressed: () => _deleteCampaign(campaign),
                    tooltip: 'Supprimer',
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

  Widget _buildStatItem(String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppTheme.primaryRed),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textMedium,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'scheduled':
        return Colors.blue;
      case 'sending':
        return Colors.orange;
      case 'sent':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Brouillon';
      case 'scheduled':
        return 'Planifiée';
      case 'sending':
        return 'Envoi en cours';
      case 'sent':
        return 'Envoyée';
      case 'failed':
        return 'Échouée';
      default:
        return status;
    }
  }

  String _getSegmentLabel(String segment) {
    switch (segment) {
      case 'all':
        return 'Tous les abonnés';
      case 'vip':
        return 'Clients VIP';
      case 'nouveautes':
        return 'Intéressés par les nouveautés';
      default:
        return segment;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
          _applyFiltersAndSort();
        });
      },
      selectedColor: AppTheme.primaryRed.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryRed,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryRed : AppTheme.textMedium,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
      ),
    );
  }
}
