// lib/superadmin/pages/wl_diagnostic_page.dart
// Page SuperAdmin pour diagnostiquer un restaurant et modifier ses modules

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../white_label/core/module_id.dart';
import '../../white_label/restaurant/restaurant_plan_unified.dart';

/// Page de diagnostic White-Label pour SuperAdmin
class WLDiagnosticPage extends ConsumerStatefulWidget {
  final String restaurantId;

  const WLDiagnosticPage({
    super.key,
    required this.restaurantId,
  });

  @override
  ConsumerState<WLDiagnosticPage> createState() => _WLDiagnosticPageState();
}

class _WLDiagnosticPageState extends ConsumerState<WLDiagnosticPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RestaurantPlanUnified? _plan;
  Map<String, dynamic>? _rawData;
  bool _isLoading = true;
  String? _error;
  Set<String> _selectedModules = {};

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
      final docRef = _firestore
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('plan')
          .doc('unified');

      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        setState(() {
          _error = 'Document plan/unified n\'existe pas';
          _isLoading = false;
        });
        return;
      }

      final data = snapshot.data()!;
      final plan = RestaurantPlanUnified.fromJson(data);

      setState(() {
        _plan = plan;
        _rawData = data;
        _selectedModules = plan.activeModules.toSet();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _savePlan() async {
    if (_plan == null) return;

    setState(() => _isLoading = true);

    try {
      final activeModules = _selectedModules.toList();

      final updatedPlan = _plan!.copyWith(
        activeModules: activeModules,
        updatedAt: DateTime.now(),
      );

      final docRef = _firestore
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('plan')
          .doc('unified');

      await docRef.update(updatedPlan.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Plan mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _loadPlan();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Diagnostic WL - ${widget.restaurantId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recharger',
            onPressed: _loadPlan,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Sauvegarder',
            onPressed: _isLoading || _plan == null ? null : _savePlan,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildContent(theme),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPlan,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: activeModules
          _buildActiveModulesSection(theme),
          const SizedBox(height: 24),

          // Section: tous les ModuleId
          _buildAllModulesSection(theme),
          const SizedBox(height: 24),

          // Section: JSON brut
          _buildRawJsonSection(theme),
        ],
      ),
    );
  }

  Widget _buildActiveModulesSection(ThemeData theme) {
    if (_plan == null) return const SizedBox();

    final activeModules = _plan!.activeModules;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Modules actifs (${activeModules.length})',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activeModules.isEmpty)
              Text(
                'Aucun module actif',
                style: TextStyle(color: Colors.grey[600]),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: activeModules.map((module) {
                  ModuleId? moduleId;
                  try {
                    moduleId = ModuleId.values.firstWhere(
                      (m) => m.code == module,
                    );
                  } catch (_) {
                    // Unknown module code - display it as-is
                  }
                  return Chip(
                    avatar: const Icon(Icons.check, size: 16),
                    label: Text(moduleId?.label ?? '⚠️ $module (unknown)'),
                    backgroundColor: moduleId != null
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllModulesSection(ThemeData theme) {
    final allModules = ModuleId.values;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.toggle_on, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Tous les modules (${allModules.length})',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...allModules.map((module) {
              final isActive = _selectedModules.contains(module.code);
              return SwitchListTile(
                title: Text(module.label),
                subtitle: Text(module.code),
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      _selectedModules.add(module.code);
                    } else {
                      _selectedModules.remove(module.code);
                    }
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRawJsonSection(ThemeData theme) {
    if (_rawData == null) return const SizedBox();

    final jsonString = const JsonEncoder.withIndent('  ').convert(_rawData);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.code, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Document JSON brut',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copier JSON',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: jsonString));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('JSON copié dans le presse-papiers'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonString,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
