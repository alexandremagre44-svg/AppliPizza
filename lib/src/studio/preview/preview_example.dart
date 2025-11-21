// lib/src/studio/preview/preview_example.dart
// Example integration of AdminHomePreviewAdvanced widget
// This file demonstrates how to use the preview in a Studio module

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_home_preview_advanced.dart';
import '../providers/banner_provider.dart';
import '../../models/banner_config.dart';

/// Example screen showing how to integrate the preview widget
/// This demonstrates a typical Studio module with editor + preview layout
class PreviewExampleScreen extends ConsumerStatefulWidget {
  const PreviewExampleScreen({super.key});

  @override
  ConsumerState<PreviewExampleScreen> createState() => _PreviewExampleScreenState();
}

class _PreviewExampleScreenState extends ConsumerState<PreviewExampleScreen> {
  @override
  void initState() {
    super.initState();
    // Clear draft state when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(draftBannersProvider.notifier).state = null;
      ref.read(hasUnsavedBannerChangesProvider.notifier).state = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch for draft state
    final draftBanners = ref.watch(draftBannersProvider);
    final hasUnsavedChanges = ref.watch(hasUnsavedBannerChangesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio Preview Example'),
        actions: [
          // Discard button
          if (hasUnsavedChanges)
            TextButton.icon(
              onPressed: _discardChanges,
              icon: const Icon(Icons.cancel, color: Colors.white),
              label: const Text(
                'Discard',
                style: TextStyle(color: Colors.white),
              ),
            ),
          const SizedBox(width: 8),
          // Publish button
          if (hasUnsavedChanges)
            ElevatedButton.icon(
              onPressed: _publishChanges,
              icon: const Icon(Icons.publish),
              label: const Text('Publish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Editor panel (left side)
          Expanded(
            flex: 2,
            child: _buildEditorPanel(),
          ),
          
          // Divider
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Colors.grey.shade300,
          ),
          
          // Preview panel (right side)
          Expanded(
            flex: 1,
            child: AdminHomePreviewAdvanced(
              draftBanners: draftBanners,
              // Add other draft states as needed:
              // draftHomeLayout: ...,
              // draftPopups: ...,
              // draftTheme: ...,
            ),
          ),
        ],
      ),
    );
  }

  /// Editor panel - replace with your actual editor
  Widget _buildEditorPanel() {
    final bannersAsync = ref.watch(bannersProvider);
    final draftBanners = ref.watch(draftBannersProvider);

    // Use draft if available, otherwise use published banners
    final effectiveBanners = draftBanners ?? bannersAsync.value ?? [];

    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Editor header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Text(
                  'Banner Editor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${effectiveBanners.length} banner(s)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Editor content
          Expanded(
            child: bannersAsync.when(
              data: (_) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Add new banner button
                  ElevatedButton.icon(
                    onPressed: _addNewBanner,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Banner'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Banner list
                  ...effectiveBanners.asMap().entries.map((entry) {
                    final index = entry.key;
                    final banner = entry.value;
                    return _buildBannerCard(banner, index);
                  }).toList(),
                  
                  // Helper text
                  if (effectiveBanners.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.campaign_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No banners yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Click "Add Banner" to create your first banner',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build banner card in editor
  Widget _buildBannerCard(BannerConfig banner, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  banner.iconData ?? Icons.campaign,
                  size: 20,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    banner.text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _deleteBanner(index),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusChip(
                  banner.isEnabled ? 'Enabled' : 'Disabled',
                  banner.isEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  'Order: ${banner.order}',
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color.shade700,
        ),
      ),
    );
  }

  /// Add a new banner to draft
  void _addNewBanner() {
    final current = ref.read(draftBannersProvider) ?? 
                   ref.read(bannersProvider).value ?? [];
    
    final newBanner = BannerConfig.defaultBanner(
      order: current.length,
    );
    
    ref.read(draftBannersProvider.notifier).state = [...current, newBanner];
    ref.read(hasUnsavedBannerChangesProvider.notifier).state = true;
  }

  /// Delete a banner from draft
  void _deleteBanner(int index) {
    final current = ref.read(draftBannersProvider) ?? 
                   ref.read(bannersProvider).value ?? [];
    
    final updated = List<BannerConfig>.from(current)..removeAt(index);
    
    ref.read(draftBannersProvider.notifier).state = updated;
    ref.read(hasUnsavedBannerChangesProvider.notifier).state = true;
  }

  /// Discard draft changes
  void _discardChanges() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('All unsaved changes will be lost. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(draftBannersProvider.notifier).state = null;
              ref.read(hasUnsavedBannerChangesProvider.notifier).state = false;
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Changes discarded')),
              );
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  /// Publish draft changes to Firestore
  Future<void> _publishChanges() async {
    final draftBanners = ref.read(draftBannersProvider);
    if (draftBanners == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Save to Firestore
      final service = ref.read(bannerServiceProvider);
      await service.saveAllBanners(draftBanners);

      // Clear draft state
      ref.read(draftBannersProvider.notifier).state = null;
      ref.read(hasUnsavedBannerChangesProvider.notifier).state = false;

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Banners published successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
