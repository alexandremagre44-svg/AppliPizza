// lib/src/screens/admin/mailing_admin_screen.dart
// Écran d'administration du module mailing

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../models/subscriber.dart';
import '../../services/mailing_service.dart';

/// Écran d'administration pour gérer la mailing list et envoyer des campagnes
class MailingAdminScreen extends StatefulWidget {
  const MailingAdminScreen({super.key});

  @override
  State<MailingAdminScreen> createState() => _MailingAdminScreenState();
}

class _MailingAdminScreenState extends State<MailingAdminScreen> with SingleTickerProviderStateMixin {
  final MailingService _mailingService = MailingService();
  late TabController _tabController;
  List<Subscriber> _subscribers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSubscribers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscribers() async {
    setState(() => _isLoading = true);
    final subscribers = await _mailingService.loadSubscribers();
    setState(() {
      _subscribers = subscribers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Mailing'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Abonnés'),
            Tab(icon: Icon(Icons.campaign), text: 'Campagnes'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSubscribersTab(),
                _buildCampaignsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tabController.index == 0 ? _addSubscriber : _createCampaign,
        icon: Icon(_tabController.index == 0 ? Icons.person_add : Icons.email),
        label: Text(_tabController.index == 0 ? 'Ajouter abonné' : 'Nouvelle campagne'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSubscribersTab() {
    final activeSubscribers = _subscribers.where((s) => s.status == 'active').toList();
    final inactiveSubscribers = _subscribers.where((s) => s.status != 'active').toList();

    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        // Statistiques
        _buildStatsCard(activeSubscribers.length, inactiveSubscribers.length),
        SizedBox(height: AppSpacing.lg),
        
        // Liste des abonnés actifs
        _buildSectionHeader('Abonnés actifs (${activeSubscribers.length})'),
        SizedBox(height: AppSpacing.sm),
        ...activeSubscribers.map((subscriber) => _buildSubscriberCard(subscriber)),
        
        if (inactiveSubscribers.isNotEmpty) ...[
          SizedBox(height: AppSpacing.lg),
          _buildSectionHeader('Abonnés inactifs (${inactiveSubscribers.length})'),
          SizedBox(height: AppSpacing.sm),
          ...inactiveSubscribers.map((subscriber) => _buildSubscriberCard(subscriber)),
        ],
      ],
    );
  }

  Widget _buildCampaignsTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.email_outlined,
              size: 80,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Campagnes Email',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Créez et envoyez des campagnes email à vos abonnés',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _createCampaign,
              icon: const Icon(Icons.add),
              label: const Text('Créer une campagne'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(int active, int inactive) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Actifs',
                active.toString(),
                Icons.check_circle,
                AppColors.primary,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.outlineVariant,
            ),
            Expanded(
              child: _buildStatItem(
                'Inactifs',
                inactive.toString(),
                Icons.cancel,
                AppColors.error,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.outlineVariant,
            ),
            Expanded(
              child: _buildStatItem(
                'Total',
                _subscribers.length.toString(),
                Icons.people,
                AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubscriberCard(Subscriber subscriber) {
    final isActive = subscriber.status == 'active';
    
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? AppColors.primaryContainer : AppColors.errorContainer,
          child: Icon(
            isActive ? Icons.person : Icons.person_off,
            color: isActive ? AppColors.onPrimaryContainer : AppColors.onErrorContainer,
          ),
        ),
        title: Text(
          subscriber.email,
          style: AppTextStyles.bodyLarge,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              'Inscrit le ${_formatDate(subscriber.dateInscription)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (subscriber.tags.isNotEmpty) ...[
              SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: subscriber.tags.map((tag) {
                  return Chip(
                    label: Text(
                      tag,
                      style: AppTextStyles.labelSmall,
                    ),
                    padding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleSubscriberAction(value, subscriber),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(isActive ? Icons.block : Icons.check_circle),
                  const SizedBox(width: 8),
                  Text(isActive ? 'Désactiver' : 'Activer'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Supprimer', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleSubscriberAction(String action, Subscriber subscriber) async {
    switch (action) {
      case 'toggle':
        final newStatus = subscriber.status == 'active' ? 'unsubscribed' : 'active';
        final updated = subscriber.copyWith(status: newStatus);
        await _mailingService.updateSubscriber(updated);
        _loadSubscribers();
        break;
      case 'delete':
        await _mailingService.deleteSubscriber(subscriber.id);
        _loadSubscribers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abonné supprimé')),
        );
        break;
    }
  }

  void _addSubscriber() {
    showDialog(
      context: context,
      builder: (context) => _AddSubscriberDialog(
        onSubscriberAdded: () {
          _loadSubscribers();
        },
      ),
    );
  }

  void _createCampaign() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle campagne'),
        content: const Text(
          'Fonctionnalité de création de campagne email.\n\n'
          'Pour implémenter:\n'
          '- Créer un formulaire de campagne\n'
          '- Intégrer un service d\'envoi d\'emails\n'
          '- Utiliser les templates existants',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

/// Dialog pour ajouter un nouvel abonné
class _AddSubscriberDialog extends StatefulWidget {
  final VoidCallback onSubscriberAdded;

  const _AddSubscriberDialog({required this.onSubscriberAdded});

  @override
  State<_AddSubscriberDialog> createState() => _AddSubscriberDialogState();
}

class _AddSubscriberDialogState extends State<_AddSubscriberDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final MailingService _mailingService = MailingService();
  bool _isSaving = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un abonné'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'exemple@email.com',
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email requis';
            }
            if (!value.contains('@')) {
              return 'Email invalide';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _saveSubscriber,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Ajouter'),
        ),
      ],
    );
  }

  Future<void> _saveSubscriber() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final subscriber = Subscriber(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: _emailController.text.trim(),
      status: 'active',
      tags: ['client'],
      consent: true,
      dateInscription: DateTime.now(),
      unsubscribeToken: _mailingService.generateUnsubscribeToken(),
    );

    final success = await _mailingService.addSubscriber(subscriber);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        widget.onSubscriberAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abonné ajouté avec succès')),
        );
      } else {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cet email est déjà inscrit'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
