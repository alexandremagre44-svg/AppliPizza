// lib/builder/debug/diagnostic_dialog.dart
// UI Dialog pour afficher les résultats du diagnostic Builder ↔ White-Label

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../src/providers/restaurant_provider.dart';
import '../../src/providers/restaurant_plan_provider.dart';
import 'builder_wl_diagnostic.dart';

/// Dialog de diagnostic pour Builder ↔ White-Label
class BuilderDiagnosticDialog extends ConsumerStatefulWidget {
  /// App ID optionnel pour override (utile pour tests multi-tenant)
  final String? appIdOverride;

  const BuilderDiagnosticDialog({
    super.key,
    this.appIdOverride,
  });

  /// Afficher le dialog
  static Future<void> show(
    BuildContext context, {
    String? appIdOverride,
  }) {
    return showDialog(
      context: context,
      builder: (context) => BuilderDiagnosticDialog(
        appIdOverride: appIdOverride,
      ),
    );
  }

  @override
  ConsumerState<BuilderDiagnosticDialog> createState() =>
      _BuilderDiagnosticDialogState();
}

class _BuilderDiagnosticDialogState
    extends ConsumerState<BuilderDiagnosticDialog> {
  final _diagnosticService = BuilderWLDiagnosticService();
  List<DiagnosticTestResult>? _results;
  bool _isRunning = false;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostic();
  }

  Future<void> _runDiagnostic() async {
    setState(() {
      _isRunning = true;
      _results = null;
    });

    final restaurantConfig = ref.read(currentRestaurantProvider);
    final planAsync = ref.read(restaurantPlanUnifiedProvider);

    final plan = planAsync.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );

    final results = await _diagnosticService.runAllTests(
      restaurantConfig: restaurantConfig,
      plan: plan,
    );

    if (mounted) {
      setState(() {
        _results = results;
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final restaurantConfig = ref.watch(currentRestaurantProvider);

    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bug_report,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Diagnostic Builder ↔ White-Label',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Restaurant: ${restaurantConfig.id}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isRunning
                  ? const Center(child: CircularProgressIndicator())
                  : _results == null
                      ? const Center(child: Text('Aucun résultat'))
                      : _buildResultsContent(),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isRunning ? null : _runDiagnostic,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Relancer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _showDetails = !_showDetails);
                      },
                      icon: Icon(_showDetails
                          ? Icons.visibility_off
                          : Icons.visibility),
                      label: Text(_showDetails
                          ? 'Masquer détails'
                          : 'Afficher détails'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsContent() {
    if (_results == null) return const SizedBox();

    final passedCount = _results!.where((r) => r.passed).length;
    final totalCount = _results!.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          _buildSummaryCard(passedCount, totalCount),
          const SizedBox(height: 16),

          // Test results
          ...List.generate(_results!.length, (index) {
            final result = _results![index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTestResultCard(result),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int passedCount, int totalCount) {
    final theme = Theme.of(context);
    final allPassed = passedCount == totalCount;
    final color = allPassed ? Colors.green : Colors.orange;

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              allPassed ? Icons.check_circle : Icons.warning,
              color: color,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Résumé',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$passedCount/$totalCount tests réussis',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultCard(DiagnosticTestResult result) {
    final theme = Theme.of(context);

    return Card(
      child: ExpansionTile(
        leading: Text(
          result.statusEmoji,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          result.testName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: result.passed ? Colors.green : Colors.red,
          ),
        ),
        subtitle: Text(
          result.message,
          style: theme.textTheme.bodySmall,
        ),
        initiallyExpanded: !result.passed || _showDetails,
        children: [
          if (result.details != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détails:',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: SelectableText(
                      _formatDetails(result.details!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDetails(Map<String, dynamic> details) {
    final buffer = StringBuffer();
    _formatMap(details, buffer, 0);
    return buffer.toString();
  }

  void _formatMap(Map<String, dynamic> map, StringBuffer buffer, int indent) {
    final indentStr = '  ' * indent;
    for (final entry in map.entries) {
      buffer.write(indentStr);
      buffer.write('${entry.key}: ');
      
      if (entry.value is Map) {
        buffer.writeln('{');
        _formatMap(entry.value as Map<String, dynamic>, buffer, indent + 1);
        buffer.writeln('$indentStr}');
      } else if (entry.value is List) {
        buffer.writeln('[');
        for (final item in entry.value as List) {
          buffer.write('$indentStr  ');
          if (item is Map) {
            buffer.writeln('{');
            _formatMap(item as Map<String, dynamic>, buffer, indent + 2);
            buffer.writeln('$indentStr  }');
          } else {
            buffer.writeln(item);
          }
        }
        buffer.writeln('$indentStr]');
      } else {
        buffer.writeln(entry.value);
      }
    }
  }
}
