// lib/src/screens/admin/mailing/campaigns_tab.dart
// Onglet pour gérer les campagnes d'emailing

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
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
  
  List<Campaign> _campaigns = [];
  List<EmailTemplate> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final campaigns = await _campaignService.loadCampaigns();
    final templates = await _templateService.loadTemplates();
    setState(() {
      _campaigns = campaigns;
      _templates = templates;
      _isLoading = false;
    });
  }

  Future<void> _showCampaignDialog({Campaign? campaign}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: campaign?.name ?? '');
    String selectedTemplateId = campaign?.templateId ?? (_templates.isNotEmpty ? _templates.first.id : '');
    String selectedSegment = campaign?.segment ?? 'all';
    DateTime? scheduleDate = campaign?.scheduleAt;
    bool sendNow = campaign?.scheduleAt == null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 650),
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
                              prefixIcon: Icon(Icons.label, color: AppTheme.accentOrange),
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
                          DropdownButtonFormField<String>(
                            value: selectedTemplateId,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.description, color: AppTheme.accentOrange),
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
                              prefixIcon: Icon(Icons.people, color: AppTheme.accentOrange),
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
                            activeColor: AppTheme.accentOrange,
                          ),
                          if (!sendNow) ...[
                            const SizedBox(height: 12),
                            ListTile(
                              leading: Icon(Icons.calendar_today, color: AppTheme.accentOrange),
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
                          backgroundColor: AppTheme.accentOrange,
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
            Icon(Icons.campaign, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune campagne',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Créez votre première campagne d\'emailing'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCampaignDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle campagne'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentOrange,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_campaigns.length} campagne(s)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton.icon(
                onPressed: () => _showCampaignDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Nouvelle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(VisualConstants.paddingMedium),
            itemCount: _campaigns.length,
            itemBuilder: (context, index) {
              final campaign = _campaigns[index];
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
                    color: AppTheme.backgroundCream,
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
                  IconButton(
                    icon: Icon(Icons.edit, color: AppTheme.accentOrange),
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
      backgroundColor: AppTheme.backgroundCream,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppTheme.accentOrange),
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
}
