// lib/src/screens/admin/mailing/subscribers_tab.dart
// Onglet pour gérer les abonnés

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import '../../../models/subscriber.dart';
import '../../../services/mailing_service.dart';
import '../../../theme/app_theme.dart';
import '../../../core/constants.dart';

class SubscribersTab extends StatefulWidget {
  const SubscribersTab({super.key});

  @override
  State<SubscribersTab> createState() => _SubscribersTabState();
}

class _SubscribersTabState extends State<SubscribersTab> {
  final MailingService _mailingService = MailingService();
  final TextEditingController _searchController = TextEditingController();
  List<Subscriber> _subscribers = [];
  List<Subscriber> _filteredSubscribers = [];
  bool _isLoading = true;
  String _filterStatus = 'all';
  String _filterTag = 'all';
  String _sortBy = 'date'; // 'date', 'email'
  Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadSubscribers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscribers() async {
    setState(() => _isLoading = true);
    final subscribers = await _mailingService.loadSubscribers();
    setState(() {
      _subscribers = subscribers;
      _applyFiltersAndSort();
      _isLoading = false;
    });
  }

  void _applyFiltersAndSort() {
    List<Subscriber> filtered = _subscribers;

    // Apply status filter
    if (_filterStatus != 'all') {
      filtered = filtered.where((sub) => sub.status == _filterStatus).toList();
    }

    // Apply tag filter
    if (_filterTag != 'all') {
      filtered = filtered.where((sub) => sub.tags.contains(_filterTag)).toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((sub) {
        return sub.email.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'email':
        filtered.sort((a, b) => a.email.compareTo(b.email));
        break;
      case 'date':
        filtered.sort((a, b) => b.dateInscription.compareTo(a.dateInscription));
        break;
    }

    _filteredSubscribers = filtered;
  }

  Map<String, int> _getStatistics() {
    return {
      'total': _subscribers.length,
      'active': _subscribers.where((s) => s.status == 'active').length,
      'unsubscribed': _subscribers.where((s) => s.status == 'unsubscribed').length,
      'vip': _subscribers.where((s) => s.tags.contains('vip')).length,
    };
  }

  Future<void> _exportToCSV() async {
    if (_filteredSubscribers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun abonné à exporter')),
      );
      return;
    }

    // Create CSV data
    List<List<dynamic>> rows = [];
    
    // Header row
    rows.add(['Email', 'Statut', 'Tags', 'Consentement', 'Date d\'inscription']);
    
    // Data rows
    for (var subscriber in _filteredSubscribers) {
      rows.add([
        subscriber.email,
        subscriber.status,
        subscriber.tags.join(', '),
        subscriber.consent ? 'Oui' : 'Non',
        _formatDate(subscriber.dateInscription),
      ]);
    }

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(rows);
    
    // In a real app, you would save this file or share it
    // For now, show the data in a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export CSV'),
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
        content: Text('Export de ${_filteredSubscribers.length} abonné(s) généré'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
  }

  Future<void> _bulkDelete() async {
    if (_selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ${_selectedIds.length} abonné(s) ?'),
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
      for (final id in _selectedIds) {
        await _mailingService.deleteSubscriber(id);
      }
      _selectedIds.clear();
      _loadSubscribers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abonnés supprimés avec succès')),
        );
      }
    }
  }

  Future<void> _showSubscriberDialog({Subscriber? subscriber}) async {
    final formKey = GlobalKey<FormState>();
    final emailController =
        TextEditingController(text: subscriber?.email ?? '');
    List<String> selectedTags =
        List<String>.from(subscriber?.tags ?? ['client']);
    String status = subscriber?.status ?? 'active';
    bool consent = subscriber?.consent ?? true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
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
                        child: const Icon(Icons.person_add,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          subscriber == null
                              ? 'Nouvel Abonné'
                              : 'Modifier Abonné',
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
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email *',
                              hintText: 'exemple@email.com',
                              prefixIcon: Icon(Icons.email,
                                  color: AppTheme.accentGreen),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            enabled: subscriber == null,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email requis';
                              }
                              if (!value.contains('@')) {
                                return 'Email invalide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Statut',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: status,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.check_circle,
                                  color: AppTheme.accentGreen),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'active', child: Text('Actif')),
                              DropdownMenuItem(
                                  value: 'unsubscribed',
                                  child: Text('Désinscrit')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() => status = value);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Tags',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              'client',
                              'vip',
                              'nouveautes',
                              'promotions'
                            ].map((tag) {
                              final isSelected = selectedTags.contains(tag);
                              return FilterChip(
                                label: Text(tag),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setDialogState(() {
                                    if (selected) {
                                      selectedTags.add(tag);
                                    } else {
                                      selectedTags.remove(tag);
                                    }
                                  });
                                },
                                selectedColor:
                                    AppTheme.accentGreen.withOpacity(0.3),
                                checkmarkColor: AppTheme.accentGreen,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          SwitchListTile(
                            title: const Text('Consentement'),
                            subtitle: const Text(
                                'L\'abonné accepte de recevoir des emails'),
                            value: consent,
                            onChanged: (value) {
                              setDialogState(() => consent = value);
                            },
                            activeColor: AppTheme.accentGreen,
                            tileColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                            final newSubscriber = Subscriber(
                              id: subscriber?.id ?? const Uuid().v4(),
                              email: emailController.text.trim(),
                              status: status,
                              tags: selectedTags,
                              consent: consent,
                              dateInscription: subscriber?.dateInscription ??
                                  DateTime.now(),
                              unsubscribeToken:
                                  subscriber?.unsubscribeToken ??
                                      _mailingService.generateUnsubscribeToken(),
                            );

                            bool success;
                            if (subscriber == null) {
                              success = await _mailingService
                                  .addSubscriber(newSubscriber);
                            } else {
                              success = await _mailingService
                                  .updateSubscriber(newSubscriber);
                            }

                            if (success && context.mounted) {
                              Navigator.pop(context, true);
                            } else if (!success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Cet email est déjà inscrit'),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Sauvegarder'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
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
      _loadSubscribers();
    }
  }

  Future<void> _deleteSubscriber(Subscriber subscriber) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${subscriber.email}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _mailingService.deleteSubscriber(subscriber.id);
      if (success) {
        _loadSubscribers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Abonné supprimé avec succès')),
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
                _buildStatCard('Total', stats['total']!, Icons.people, Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard('Actifs', stats['active']!, Icons.check_circle, Colors.green),
                const SizedBox(width: 12),
                _buildStatCard('VIP', stats['vip']!, Icons.star, Colors.amber),
                const SizedBox(width: 12),
                _buildStatCard('Désinscrits', stats['unsubscribed']!, Icons.cancel, Colors.red),
              ],
            ),
          ),
        ),
        // Filter bar
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
                      '${_filteredSubscribers.length} abonné(s)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_selectedIds.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: _bulkDelete,
                      icon: const Icon(Icons.delete),
                      label: Text('Supprimer (${_selectedIds.length})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  if (_selectedIds.isEmpty) ...[
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: _exportToCSV,
                      tooltip: 'Exporter CSV',
                      color: AppTheme.accentGreen,
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showSubscriberDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Nouveau'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              // Search and sort
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher par email...',
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
                        value: 'email',
                        child: Text('Trier par email'),
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
                    _buildFilterChip('Tous', 'all', _filterStatus, (value) {
                      setState(() {
                        _filterStatus = value;
                        _applyFiltersAndSort();
                      });
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('Actifs', 'active', _filterStatus, (value) {
                      setState(() {
                        _filterStatus = value;
                        _applyFiltersAndSort();
                      });
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('Désinscrits', 'unsubscribed', _filterStatus, (value) {
                      setState(() {
                        _filterStatus = value;
                        _applyFiltersAndSort();
                      });
                    }),
                    const SizedBox(width: 16),
                    Container(
                      width: 1,
                      height: 24,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 16),
                    _buildFilterChip('Tous tags', 'all', _filterTag, (value) {
                      setState(() {
                        _filterTag = value;
                        _applyFiltersAndSort();
                      });
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('VIP', 'vip', _filterTag, (value) {
                      setState(() {
                        _filterTag = value;
                        _applyFiltersAndSort();
                      });
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('Nouveautés', 'nouveautes', _filterTag, (value) {
                      setState(() {
                        _filterTag = value;
                        _applyFiltersAndSort();
                      });
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('Promotions', 'promotions', _filterTag, (value) {
                      setState(() {
                        _filterTag = value;
                        _applyFiltersAndSort();
                      });
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Subscribers list
        Expanded(
          child: _filteredSubscribers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _subscribers.isEmpty ? Icons.people : Icons.search_off,
                          size: 80,
                          color: AppTheme.accentGreen,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _subscribers.isEmpty ? 'Aucun abonné' : 'Aucun abonné trouvé',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _subscribers.isEmpty
                              ? 'Construisez votre liste d\'abonnés pour communiquer avec vos clients'
                              : 'Essayez de modifier vos filtres ou votre recherche',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textMedium,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_subscribers.isEmpty)
                        ElevatedButton.icon(
                          onPressed: () => _showSubscriberDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter mon premier abonné'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentGreen,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.all(VisualConstants.paddingMedium),
                  itemCount: _filteredSubscribers.length,
                  itemBuilder: (context, index) {
                    final subscriber = _filteredSubscribers[index];
                    return _buildSubscriberCard(subscriber);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSubscriberCard(Subscriber subscriber) {
    final isActive = subscriber.status == 'active';
    final isSelected = _selectedIds.contains(subscriber.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showSubscriberDialog(subscriber: subscriber),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedIds.add(subscriber.id);
                        } else {
                          _selectedIds.remove(subscriber.id);
                        }
                      });
                    },
                    activeColor: AppTheme.accentGreen,
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isActive ? Icons.person : Icons.person_off,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscriber.email,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Inscrit le ${_formatDate(subscriber.dateInscription)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: isActive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'Actif' : 'Désinscrit',
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...subscriber.tags.map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: AppTheme.backgroundLight,
                        labelStyle: const TextStyle(fontSize: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      )),
                  if (!subscriber.consent)
                    Chip(
                      label: const Text('Sans consentement'),
                      backgroundColor: Colors.red.shade50,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade900,
                      ),
                      avatar:
                          Icon(Icons.warning, size: 16, color: Colors.red),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: AppTheme.accentGreen),
                    onPressed: () =>
                        _showSubscriberDialog(subscriber: subscriber),
                    tooltip: 'Modifier',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: AppTheme.errorRed),
                    onPressed: () => _deleteSubscriber(subscriber),
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

  Widget _buildFilterChip(String label, String value, String currentValue, Function(String) onSelected) {
    final isSelected = currentValue == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onSelected(value);
        }
      },
      selectedColor: AppTheme.accentGreen.withOpacity(0.2),
      checkmarkColor: AppTheme.accentGreen,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.accentGreen : AppTheme.textMedium,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
      ),
    );
  }
}
