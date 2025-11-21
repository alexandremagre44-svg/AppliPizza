// lib/src/studio/widgets/media/image_selector_widget.dart
// Image selector widget for use in all Studio modules

import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../models/media_asset_model.dart';
import '../../services/media_manager_service.dart';

/// Image selector widget
/// Returns selected image URL and size
class ImageSelectorWidget extends StatelessWidget {
  final MediaFolder? filterFolder;
  final String? currentUrl;
  final Function(String url, ImageSize size) onImageSelected;

  const ImageSelectorWidget({
    super.key,
    this.filterFolder,
    this.currentUrl,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showImagePicker(context),
      icon: const Icon(Icons.photo_library),
      label: Text(currentUrl != null ? 'Changer l\'image' : 'Sélectionner une image'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _showImagePicker(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ImagePickerDialog(
        filterFolder: filterFolder,
        currentUrl: currentUrl,
      ),
    );

    if (result != null) {
      onImageSelected(
        result['url'] as String,
        result['size'] as ImageSize,
      );
    }
  }
}

/// Image picker dialog
class _ImagePickerDialog extends StatefulWidget {
  final MediaFolder? filterFolder;
  final String? currentUrl;

  const _ImagePickerDialog({
    this.filterFolder,
    this.currentUrl,
  });

  @override
  State<_ImagePickerDialog> createState() => _ImagePickerDialogState();
}

class _ImagePickerDialogState extends State<_ImagePickerDialog> {
  final _mediaService = MediaManagerService();
  MediaFolder? _selectedFolder;
  ImageSize _selectedSize = ImageSize.medium;
  String? _selectedAssetId;
  MediaAsset? _selectedAsset;

  @override
  void initState() {
    super.initState();
    _selectedFolder = widget.filterFolder;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 900,
        height: 700,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(),
            
            // Toolbar
            _buildToolbar(),
            
            // Content
            Expanded(
              child: Row(
                children: [
                  // Folder sidebar
                  if (widget.filterFolder == null) _buildFolderSidebar(),
                  
                  // Image grid
                  Expanded(child: _buildImageGrid()),
                ],
              ),
            ),
            
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
          const Icon(Icons.photo_library, color: Colors.white),
          const SizedBox(width: 12),
          const Text(
            'Sélectionner une image',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Taille:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          SegmentedButton<ImageSize>(
            segments: const [
              ButtonSegment(
                value: ImageSize.small,
                label: Text('Small (200px)'),
              ),
              ButtonSegment(
                value: ImageSize.medium,
                label: Text('Medium (600px)'),
              ),
              ButtonSegment(
                value: ImageSize.full,
                label: Text('Full'),
              ),
            ],
            selected: {_selectedSize},
            onSelectionChanged: (Set<ImageSize> newSelection) {
              setState(() => _selectedSize = newSelection.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFolderSidebar() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Dossiers',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildFolderItem(null, 'Tous', Icons.folder_open),
                ...MediaFolder.values.map((folder) {
                  return _buildFolderItem(
                    folder,
                    folder.displayName,
                    _getFolderIcon(folder),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderItem(MediaFolder? folder, String label, IconData icon) {
    final isSelected = _selectedFolder == folder;
    
    return ListTile(
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : Colors.grey.shade600,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : Colors.black,
        ),
      ),
      onTap: () => setState(() => _selectedFolder = folder),
    );
  }

  Widget _buildImageGrid() {
    return StreamBuilder<List<MediaAsset>>(
      stream: _selectedFolder != null
          ? _mediaService.streamAssetsByFolder(_selectedFolder!)
          : _mediaService.streamAssets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final assets = snapshot.data ?? [];

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
                  'Aucune image disponible',
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
            maxCrossAxisExtent: 150,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: assets.length,
          itemBuilder: (context, index) {
            final asset = assets[index];
            final isSelected = _selectedAssetId == asset.id;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAssetId = asset.id;
                  _selectedAsset = asset;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        asset.urlSmall,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                      if (isSelected)
                        Container(
                          color: AppColors.primary.withOpacity(0.3),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          if (_selectedAsset != null) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedAsset!.originalFilename,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_selectedAsset!.dimensions} • ${_selectedAsset!.formattedSize}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ] else
            const Expanded(
              child: Text('Aucune image sélectionnée'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _selectedAsset != null
                ? () {
                    final url = _selectedAsset!.getUrl(_selectedSize);
                    Navigator.pop(context, {
                      'url': url,
                      'size': _selectedSize,
                      'asset': _selectedAsset,
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sélectionner'),
          ),
        ],
      ),
    );
  }

  IconData _getFolderIcon(MediaFolder folder) {
    switch (folder) {
      case MediaFolder.hero:
        return Icons.image;
      case MediaFolder.promos:
        return Icons.local_offer;
      case MediaFolder.produits:
        return Icons.shopping_bag;
      case MediaFolder.studio:
        return Icons.auto_awesome;
      case MediaFolder.misc:
        return Icons.folder;
    }
  }
}
