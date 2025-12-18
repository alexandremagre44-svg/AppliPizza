// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/screens/admin/studio/roulette_segments_list_screen.dart
// List screen for managing roulette segments - Material 3 + Pizza Deli'Zza


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/roulette_config.dart';
import '../../../services/roulette_segment_service.dart';
import '../../../design_system/app_theme.dart'; // Keep for AppSpacing, AppRadius, AppTextStyles
import '../../../../white_label/theme/theme_extensions.dart';
import 'roulette_segment_editor_screen.dart';

/// Screen to list and manage all roulette segments
/// Follows Material 3 and Pizza Deli'Zza Brand Guidelines
class RouletteSegmentsListScreen extends ConsumerStatefulWidget {
  const RouletteSegmentsListScreen({super.key});

  @override
  ConsumerState<RouletteSegmentsListScreen> createState() => _RouletteSegmentsListScreenState();
}

class _RouletteSegmentsListScreenState extends ConsumerState<RouletteSegmentsListScreen> {
  // Use getter to access service via provider
  RouletteSegmentService get _service => ref.read(rouletteSegmentServiceProvider);
  List<RouletteSegment> _segments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSegments();
  }

  /// Load all segments from Firestore
  Future<void> _loadSegments() async {
    setState(() => _isLoading = true);

    try {
      final segments = await _service.getAllSegments();
      
      if (segments.isEmpty) {
        // Initialize with default segments if empty
        await _service.initializeDefaultSegments();
        final newSegments = await _service.getAllSegments();
        setState(() {
          _segments = newSegments;
        });
      } else {
        setState(() {
          _segments = segments;
        });
      }
    } catch (e) {
      _showSnackBar('Erreur lors du chargement: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Segments de la roue',
          style: AppTextStyles.headlineMedium.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSegments,
              child: _segments.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSpacing.paddingMD,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header with info
                          _buildHeaderInfo(),
                          SizedBox(height: AppSpacing.md),
                          
                          // Segments list
                          ..._segments.map((segment) => Padding(
                                padding: EdgeInsets.only(bottom: AppSpacing.md),
                                child: _buildSegmentCard(segment),
                              )),
                        ],
                      ),
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createSegment,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau segment'),
      ),
    );
  }

  /// Header info section
  Widget _buildHeaderInfo() {
    final colorScheme = Theme.of(context).colorScheme;
    final totalProbability = _segments.fold<double>(
      0,
      (sum, segment) => sum + segment.probability,
    );
    final activeCount = _segments.where((s) => s.isActive).length;

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Informations',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Segments: $activeCount actifs / ${_segments.length} total',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            Text(
              'Probabilité totale: ${totalProbability.toStringAsFixed(1)}%',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            if (totalProbability != 100.0) ...[
              SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: AppRadius.badge,
                ),
                child: Text(
                  '⚠ La somme devrait être 100%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build a segment card
  Widget _buildSegmentCard(RouletteSegment segment) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      child: InkWell(
        onTap: () => _editSegment(segment),
        borderRadius: AppRadius.card,
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Row(
            children: [
              // Color preview circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: segment.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: segment.iconName != null
                    ? Icon(
                        _getIconData(segment.iconName!),
                        color: context.onPrimary,
                        size: 20,
                      )
                    : null,
              ),
              SizedBox(width: AppSpacing.md),

              // Segment info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      segment.label,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      _getRewardTypeLabel(segment.rewardType),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (segment.description != null) ...[
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        segment.description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Probability badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: AppRadius.badge,
                    ),
                    child: Text(
                      '${segment.probability.toStringAsFixed(0)}%',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  // Active switch
                  Switch(
                    value: segment.isActive,
                    onChanged: (value) => _toggleSegmentActive(segment, value),
                    activeColor: colorScheme.primary,
                  ),
                ],
              ),

              // Edit button
              SizedBox(width: AppSpacing.xs),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: colorScheme.onSurfaceVariant,
                onPressed: () => _editSegment(segment),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.casino_outlined,
              size: 80,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucun segment',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Créez des segments pour configurer\nla roue de la chance',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Get reward type label
  String _getRewardTypeLabel(RewardType type) {
    switch (type) {
      case RewardType.none:
        return 'Aucun gain';
      case RewardType.bonusPoints:
        return 'Points bonus';
      case RewardType.percentageDiscount:
        return 'Réduction en %';
      case RewardType.fixedAmountDiscount:
        return 'Réduction fixe';
      case RewardType.freeProduct:
        return 'Produit gratuit';
      case RewardType.freeDrink:
        return 'Boisson gratuite';
      case RewardType.freePizza:
        return 'Pizza offerte';
      case RewardType.freeDessert:
        return 'Dessert offert';
    }
  }

  /// Get icon data from name
  IconData _getIconData(String name) {
    switch (name) {
      case 'local_pizza':
        return Icons.local_pizza;
      case 'local_drink':
        return Icons.local_drink;
      case 'cake':
        return Icons.cake;
      case 'stars':
        return Icons.stars;
      case 'percent':
        return Icons.percent;
      case 'euro':
        return Icons.euro;
      case 'close':
        return Icons.close;
      default:
        return Icons.help_outline;
    }
  }

  /// Create a new segment
  void _createSegment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RouletteSegmentEditorScreen(),
      ),
    );

    if (result == true) {
      _loadSegments();
    }
  }

  /// Edit an existing segment
  void _editSegment(RouletteSegment segment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RouletteSegmentEditorScreen(segment: segment),
      ),
    );

    if (result == true) {
      _loadSegments();
    }
  }

  /// Toggle segment active state
  Future<void> _toggleSegmentActive(RouletteSegment segment, bool value) async {
    final updatedSegment = segment.copyWith(isActive: value);
    final success = await _service.updateSegment(updatedSegment);

    if (success) {
      _loadSegments();
      _showSnackBar(
        value ? 'Segment activé' : 'Segment désactivé',
        isError: false,
      );
    } else {
      _showSnackBar('Erreur lors de la mise à jour', isError: true);
    }
  }

  /// Show snackbar
  void _showSnackBar(String message, {required bool isError}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
