// MIGRATED to WL V2 Theme - Uses theme colors
/// lib/superadmin/pages/migration_page.dart
///
/// Page SuperAdmin pour lancer les migrations Firestore.
/// Permet d'exécuter les migrations en mode dry-run ou live.
library;

import 'package:flutter/material.dart';

import '../../migration/firestore_migration_service.dart';
import '../../migration/migration_report.dart';

/// Page SuperAdmin pour gérer les migrations Firestore.
///
/// Cette page permet de:
/// - Lancer toutes les migrations
/// - Exécuter en mode dry-run (simulation)
/// - Afficher le rapport de migration en temps réel
class MigrationPage extends StatefulWidget {
  const MigrationPage({super.key});

  @override
  State<MigrationPage> createState() => _MigrationPageState();
}

class _MigrationPageState extends State<MigrationPage> {
  bool _isRunning = false;
  bool _isDryRun = true;
  MigrationReport? _report;
  final List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Migration'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(),
            const SizedBox(height: 24),

            // Description
            _buildDescription(),
            const SizedBox(height: 32),

            // Options
            _buildOptions(),
            const SizedBox(height: 32),

            // Boutons d'action
            _buildActions(),
            const SizedBox(height: 32),

            // Rapport
            if (_report != null) _buildReport(),
            const SizedBox(height: 24),

            // Logs
            if (_logs.isNotEmpty) _buildLogs(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔧 Migration Firestore',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Correction des incohérences de la base de données',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.surfaceVariant // was Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Migrations disponibles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildMigrationItem(
              '1. Documents plan/unified manquants',
              'Crée le document plan/unified pour chaque restaurant existant',
            ),
            _buildMigrationItem(
              '2. Normalisation des restaurants',
              'Normalise les champs id et status (en majuscules)',
            ),
            _buildMigrationItem(
              '3. Migration des roulette_settings',
              'Copie les settings de marketing/roulette_settings vers plan/unified',
            ),
            _buildMigrationItem(
              '4. Normalisation des utilisateurs',
              'Normalise les champs name/displayName et isAdmin',
            ),
            _buildMigrationItem(
              '5. Migration des loyalty_settings',
              'Copie loyalty_settings/main vers builder_settings de chaque restaurant',
            ),
            _buildMigrationItem(
              '6. Migration des roulette_segments',
              'Copie les segments de la racine vers chaque restaurant',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMigrationItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 20, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(color: context.colorScheme.surfaceVariant // was Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Card(
      color: context.primaryColor[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Mode Dry-Run (simulation)'),
              subtitle: const Text(
                'Simule les migrations sans modifier la base de données',
              ),
              value: _isDryRun,
              onChanged: _isRunning
                  ? null
                  : (value) {
                      setState(() {
                        _isDryRun = value;
                      });
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _isRunning ? null : _runMigration,
          icon: _isRunning
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.onPrimary,
                  ),
                )
              : const Icon(Icons.play_arrow),
          label: Text(_isRunning ? 'Migration en cours...' : 'Lancer la migration'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isDryRun ? AppColors.warning : AppColors.error,
            foregroundColor: context.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        if (_report != null) ...[
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _clearReport,
            icon: const Icon(Icons.clear),
            label: const Text('Effacer le rapport'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReport() {
    if (_report == null) return const SizedBox.shrink();

    return Card(
      color: _report!.isSuccess ? AppColors.success[50] : AppColors.error[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _report!.isSuccess ? Icons.check_circle : Icons.error,
                  color: _report!.isSuccess ? AppColors.success : AppColors.error,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  _report!.isSuccess
                      ? 'Migration réussie ✓'
                      : 'Migration avec erreurs ✗',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _report!.isSuccess ? AppColors.success[800] : AppColors.error[800],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildReportRow('Mode', _report!.isDryRun ? 'DRY-RUN (simulation)' : 'LIVE'),
            _buildReportRow('Durée', '${_report!.duration.inSeconds}s'),
            _buildReportRow('Plans créés', '${_report!.restaurantPlansCreated}'),
            _buildReportRow('Restaurants normalisés', '${_report!.restaurantsNormalized}'),
            _buildReportRow('Roulette migrés', '${_report!.rouletteSettingsMigrated}'),
            _buildReportRow('Utilisateurs normalisés', '${_report!.usersNormalized}'),
            _buildReportRow('Loyalty settings migrés', '${_report!.loyaltySettingsMigrated}'),
            _buildReportRow('Segments roulette migrés', '${_report!.rouletteSegmentsMigrated}'),
            _buildReportRow(
              'Total modifié',
              '${_report!.totalDocumentsModified}',
              isTotal: true,
            ),
            if (_report!.errors.isNotEmpty) ...[
              const Divider(),
              Text(
                'Erreurs (${_report!.errors.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              ..._report!.errors.map((error) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      '• $error',
                      style: TextStyle(color: AppColors.error[700]),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogs() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logs détaillés',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceVariant // was Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _logs
                      .map((log) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              log,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runMigration() async {
    setState(() {
      _isRunning = true;
      _report = null;
      _logs.clear();
    });

    try {
      // Créer un service avec un logger qui met à jour l'UI
      final service = FirestoreMigrationService(
        logger: (message) {
          setState(() {
            _logs.add(message);
          });
        },
      );

      final report = await service.runAllMigrations(dryRun: _isDryRun);

      setState(() {
        _report = report;
        _isRunning = false;
      });

      // Afficher un snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              report.isSuccess
                  ? 'Migration terminée avec succès'
                  : 'Migration terminée avec ${report.errors.length} erreur(s)',
            ),
            backgroundColor: report.isSuccess ? AppColors.success : AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRunning = false;
        _logs.add('ERREUR: $e');
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la migration: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _clearReport() {
    setState(() {
      _report = null;
      _logs.clear();
    });
  }
}
