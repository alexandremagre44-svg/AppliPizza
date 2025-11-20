// lib/src/studio/widgets/modules/studio_banners_v2.dart
// Banners module V2 - Professional multi-banner CRUD with scheduling

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/banner_config.dart';

class StudioBannersV2 extends StatefulWidget {
  final List<BannerConfig> banners;
  final Function(List<BannerConfig>) onUpdate;

  const StudioBannersV2({
    super.key,
    required this.banners,
    required this.onUpdate,
  });

  @override
  State<StudioBannersV2> createState() => _StudioBannersV2State();
}

class _StudioBannersV2State extends State<StudioBannersV2> {
  @override
  Widget build(BuildContext context) {
    // Sort banners by order
    final sortedBanners = List<BannerConfig>.from(widget.banners)
      ..sort((a, b) => a.order.compareTo(b.order));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bandeaux',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gérez vos bandeaux d\'information programmables',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _addBanner,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Nouveau bandeau'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Banners list or empty state
          if (sortedBanners.isEmpty)
            _buildEmptyState()
          else
            ...sortedBanners.map((banner) => _buildBannerCard(banner)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun bandeau configuré',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez votre premier bandeau pour informer vos clients',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _addBanner,
              icon: const Icon(Icons.add),
              label: const Text('Créer un bandeau'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCard(BannerConfig banner) {
    final now = DateTime.now();
    final isScheduled = banner.startDate != null && banner.startDate!.isAfter(now);
    final isExpired = banner.endDate != null && banner.endDate!.isBefore(now);
    final isActive = banner.isEnabled && !isExpired;

    String statusText;
    Color statusColor;
    if (isExpired) {
      statusText = 'Expiré';
      statusColor = Colors.grey;
    } else if (isScheduled) {
      statusText = 'Planifié';
      statusColor = Colors.orange;
    } else if (isActive) {
      statusText = 'Actif';
      statusColor = Colors.green;
    } else {
      statusText = 'Désactivé';
      statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _editBanner(banner),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getColorFromHex(banner.backgroundColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        banner.iconData ?? Icons.campaign,
                        color: _getColorFromHex(banner.backgroundColor),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              // Date badges
                              if (banner.startDate != null) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(banner.startDate!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                              if (banner.endDate != null) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward, size: 12, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(banner.endDate!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: banner.isEnabled,
                          onChanged: (value) {
                            _toggleBanner(banner, value);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showBannerMenu(banner),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addBanner() {
    final newBanner = BannerConfig.defaultBanner(order: widget.banners.length);
    _editBanner(newBanner, isNew: true);
  }

  void _editBanner(BannerConfig banner, {bool isNew = false}) {
    showDialog(
      context: context,
      builder: (context) => _BannerEditDialog(
        banner: banner,
        isNew: isNew,
        onSave: (updatedBanner) {
          setState(() {
            if (isNew) {
              widget.onUpdate([...widget.banners, updatedBanner]);
            } else {
              final updated = widget.banners.map((b) {
                return b.id == updatedBanner.id ? updatedBanner : b;
              }).toList();
              widget.onUpdate(updated);
            }
          });
        },
      ),
    );
  }

  void _toggleBanner(BannerConfig banner, bool value) {
    final updated = widget.banners.map((b) {
      return b.id == banner.id ? b.copyWith(isEnabled: value) : b;
    }).toList();
    widget.onUpdate(updated);
  }

  void _showBannerMenu(BannerConfig banner) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                _editBanner(banner);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteBanner(banner);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text('Déplacer vers le haut'),
              enabled: banner.order > 0,
              onTap: banner.order > 0
                  ? () {
                      Navigator.pop(context);
                      _moveBanner(banner, -1);
                    }
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text('Déplacer vers le bas'),
              enabled: banner.order < widget.banners.length - 1,
              onTap: banner.order < widget.banners.length - 1
                  ? () {
                      Navigator.pop(context);
                      _moveBanner(banner, 1);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _deleteBanner(BannerConfig banner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer le bandeau ?'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${banner.text}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final updated = widget.banners.where((b) => b.id != banner.id).toList();
              // Reorder remaining banners
              for (var i = 0; i < updated.length; i++) {
                updated[i] = updated[i].copyWith(order: i);
              }
              widget.onUpdate(updated);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _moveBanner(BannerConfig banner, int direction) {
    final sorted = List<BannerConfig>.from(widget.banners)
      ..sort((a, b) => a.order.compareTo(b.order));
    
    final currentIndex = sorted.indexWhere((b) => b.id == banner.id);
    final newIndex = currentIndex + direction;
    
    if (newIndex < 0 || newIndex >= sorted.length) return;
    
    // Swap orders
    final temp = sorted[currentIndex];
    sorted[currentIndex] = sorted[newIndex].copyWith(order: currentIndex);
    sorted[newIndex] = temp.copyWith(order: newIndex);
    
    widget.onUpdate(sorted);
  }

  Color _getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      }
      return AppColors.primary;
    } catch (e) {
      return AppColors.primary;
    }
  }
}

// Banner Edit Dialog
class _BannerEditDialog extends StatefulWidget {
  final BannerConfig banner;
  final bool isNew;
  final Function(BannerConfig) onSave;

  const _BannerEditDialog({
    required this.banner,
    required this.isNew,
    required this.onSave,
  });

  @override
  State<_BannerEditDialog> createState() => _BannerEditDialogState();
}

class _BannerEditDialogState extends State<_BannerEditDialog> {
  late TextEditingController _textController;
  late TextEditingController _iconController;
  late BannerConfig _editedBanner;

  @override
  void initState() {
    super.initState();
    _editedBanner = widget.banner;
    _textController = TextEditingController(text: widget.banner.text);
    _iconController = TextEditingController(text: widget.banner.icon ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.isNew ? 'Nouveau bandeau' : 'Modifier le bandeau',
                      style: const TextStyle(
                        fontSize: 24,
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
              const SizedBox(height: 24),

              // Text field
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Texte du bandeau *',
                  helperText: 'Message affiché dans le bandeau',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) {
                  setState(() {
                    _editedBanner = _editedBanner.copyWith(text: value);
                  });
                },
              ),
              const SizedBox(height: 16),

              // Icon field
              TextField(
                controller: _iconController,
                decoration: const InputDecoration(
                  labelText: 'Icône (nom Material)',
                  helperText: 'Ex: campaign, star, local_offer',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _editedBanner = _editedBanner.copyWith(icon: value);
                  });
                },
              ),
              const SizedBox(height: 16),

              // Color variant (simplified)
              DropdownButtonFormField<String>(
                value: _editedBanner.backgroundColor,
                decoration: const InputDecoration(
                  labelText: 'Variante de couleur',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '#D32F2F', child: Text('🔴 Attention (Rouge)')),
                  DropdownMenuItem(value: '#1976D2', child: Text('🔵 Info (Bleu)')),
                  DropdownMenuItem(value: '#388E3C', child: Text('🟢 Succès (Vert)')),
                  DropdownMenuItem(value: '#F57C00', child: Text('🟠 Avertissement (Orange)')),
                  DropdownMenuItem(value: '#616161', child: Text('⚫ Neutre (Gris)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _editedBanner = _editedBanner.copyWith(
                        backgroundColor: value,
                        textColor: '#FFFFFF',
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Start date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: const Text('Date de début'),
                subtitle: _editedBanner.startDate != null
                    ? Text(DateFormat('dd/MM/yyyy HH:mm').format(_editedBanner.startDate!))
                    : const Text('Aucune date définie'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_editedBanner.startDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _editedBanner = _editedBanner.copyWith(startDate: null);
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit_calendar),
                      onPressed: _selectStartDate,
                    ),
                  ],
                ),
              ),

              // End date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_busy),
                title: const Text('Date de fin'),
                subtitle: _editedBanner.endDate != null
                    ? Text(DateFormat('dd/MM/yyyy HH:mm').format(_editedBanner.endDate!))
                    : const Text('Aucune date définie'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_editedBanner.endDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _editedBanner = _editedBanner.copyWith(endDate: null);
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit_calendar),
                      onPressed: _selectEndDate,
                    ),
                  ],
                ),
              ),

              // Enabled switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Bandeau activé'),
                subtitle: const Text('Désactivez pour masquer temporairement'),
                value: _editedBanner.isEnabled,
                onChanged: (value) {
                  setState(() {
                    _editedBanner = _editedBanner.copyWith(isEnabled: value);
                  });
                },
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _textController.text.isEmpty ? null : _save,
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _editedBanner.startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_editedBanner.startDate ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _editedBanner = _editedBanner.copyWith(
            startDate: DateTime(date.year, date.month, date.day, time.hour, time.minute),
          );
        });
      }
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _editedBanner.endDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_editedBanner.endDate ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _editedBanner = _editedBanner.copyWith(
            endDate: DateTime(date.year, date.month, date.day, time.hour, time.minute),
          );
        });
      }
    }
  }

  void _save() {
    final finalBanner = _editedBanner.copyWith(
      text: _textController.text,
      icon: _iconController.text.isEmpty ? null : _iconController.text,
      updatedAt: DateTime.now(),
    );
    widget.onSave(finalBanner);
    Navigator.pop(context);
  }
}
