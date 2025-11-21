// lib/src/studio/widgets/media/media_gallery_widget.dart
// Gallery widget for Media Manager PRO

import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../models/media_asset_model.dart';
import '../../services/media_manager_service.dart';
import '../../screens/media_manager_screen.dart';

/// Media gallery widget with thumbnails and sorting
class MediaGalleryWidget extends StatelessWidget {
  final MediaFolder folder;
  final String searchQuery;
  final SortOption sortBy;
  final VoidCallback onAssetDeleted;

  const MediaGalleryWidget({
    super.key,
    required this.folder,
    required this.searchQuery,
    required this.sortBy,
    required this.onAssetDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final mediaService = MediaManagerService();

    return StreamBuilder<List<MediaAsset>>(
      stream: mediaService.streamAssetsByFolder(folder),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur: ${snapshot.error}'),
          );
        }

        var assets = snapshot.data ?? [];

        // Apply search filter
        if (searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          assets = assets.where((asset) {
            return asset.originalFilename.toLowerCase().contains(query) ||
                   asset.tags.any((tag) => tag.toLowerCase().contains(query)) ||
                   (asset.description?.toLowerCase().contains(query) ?? false);
          }).toList();
        }

        // Apply sorting
        assets = _sortAssets(assets, sortBy);

        if (assets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty
                      ? 'Aucune image dans ce dossier'
                      : 'Aucun résultat pour "$searchQuery"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: assets.length,
          itemBuilder: (context, index) {
            return _MediaThumbnail(
              asset: assets[index],
              onDeleted: onAssetDeleted,
            );
          },
        );
      },
    );
  }

  List<MediaAsset> _sortAssets(List<MediaAsset> assets, SortOption sortBy) {
    final sorted = List<MediaAsset>.from(assets);
    
    switch (sortBy) {
      case SortOption.date:
        sorted.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
        break;
      case SortOption.name:
        sorted.sort((a, b) => a.originalFilename.compareTo(b.originalFilename));
        break;
      case SortOption.size:
        sorted.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
        break;
    }
    
    return sorted;
  }
}

/// Media thumbnail card
class _MediaThumbnail extends StatelessWidget {
  final MediaAsset asset;
  final VoidCallback onDeleted;

  const _MediaThumbnail({
    required this.asset,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showAssetDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    asset.urlSmall,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey.shade400,
                          size: 48,
                        ),
                      );
                    },
                  ),
                  
                  // Usage indicator
                  if (asset.isInUse)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.link,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Info footer
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.originalFilename,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        asset.formattedSize,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '•',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        asset.dimensions,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssetDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AssetDetailsDialog(
        asset: asset,
        onDeleted: onDeleted,
      ),
    );
  }
}

/// Asset details dialog
class _AssetDetailsDialog extends StatelessWidget {
  final MediaAsset asset;
  final VoidCallback onDeleted;

  const _AssetDetailsDialog({
    required this.asset,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Détails de l\'image',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview image
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          asset.urlMedium,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Details
                    _buildDetailRow('Nom', asset.originalFilename),
                    _buildDetailRow('Taille', asset.formattedSize),
                    _buildDetailRow('Dimensions', asset.dimensions),
                    _buildDetailRow('Format', asset.mimeType),
                    _buildDetailRow(
                      'Uploadé le',
                      _formatDate(asset.uploadedAt),
                    ),
                    _buildDetailRow('Dossier', asset.folder.displayName),
                    
                    if (asset.isInUse) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Cette image est utilisée dans ${asset.usedIn.length} élément(s)',
                                style: TextStyle(color: Colors.orange.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // URLs
                    const SizedBox(height: 24),
                    const Text(
                      'URLs disponibles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildUrlRow('Small (200px)', asset.urlSmall),
                    _buildUrlRow('Medium (600px)', asset.urlMedium),
                    _buildUrlRow('Full', asset.urlFull),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _handleDelete(context),
                    icon: const Icon(Icons.delete),
                    label: const Text('Supprimer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlRow(String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: SelectableText(
              url,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleDelete(BuildContext context) async {
    // Check if in use
    if (asset.isInUse) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Impossible de supprimer'),
          content: Text(
            'Cette image est utilisée dans ${asset.usedIn.length} élément(s). '
            'Veuillez d\'abord retirer les références avant de la supprimer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Confirm deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer "${asset.originalFilename}" ?\n\n'
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Delete
    final mediaService = MediaManagerService();
    final success = await mediaService.deleteAsset(asset.id);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close dialog
        onDeleted();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
