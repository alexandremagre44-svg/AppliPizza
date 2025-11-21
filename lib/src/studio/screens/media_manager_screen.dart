// lib/src/studio/screens/media_manager_screen.dart
// Media Manager PRO - Professional media management screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/app_theme.dart';
import '../models/media_asset_model.dart';
import '../services/media_manager_service.dart';
import '../widgets/media/media_upload_widget.dart';
import '../widgets/media/media_gallery_widget.dart';
import '../../providers/auth_provider.dart';

/// Media Manager Screen
/// Professional media management with upload, gallery, and organization
class MediaManagerScreen extends ConsumerStatefulWidget {
  const MediaManagerScreen({super.key});

  @override
  ConsumerState<MediaManagerScreen> createState() => _MediaManagerScreenState();
}

class _MediaManagerScreenState extends ConsumerState<MediaManagerScreen> {
  final _mediaService = MediaManagerService();
  
  MediaFolder _selectedFolder = MediaFolder.misc;
  String _searchQuery = '';
  SortOption _sortBy = SortOption.date;
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.userId ?? 'unknown';
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Media Manager PRO'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Search
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
            tooltip: 'Rechercher',
          ),
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          _buildToolbar(),
          
          // Content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar (folders)
                _buildSidebar(),
                
                // Main content
                Expanded(
                  child: Column(
                    children: [
                      // Upload area
                      MediaUploadWidget(
                        folder: _selectedFolder,
                        userId: userId,
                        onUploadComplete: () => setState(() {}),
                      ),
                      
                      // Gallery
                      Expanded(
                        child: MediaGalleryWidget(
                          folder: _selectedFolder,
                          searchQuery: _searchQuery,
                          sortBy: _sortBy,
                          onAssetDeleted: () => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          // Sort dropdown
          const Text('Trier par: ', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          DropdownButton<SortOption>(
            value: _sortBy,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(
                value: SortOption.date,
                child: Text('Date'),
              ),
              DropdownMenuItem(
                value: SortOption.name,
                child: Text('Nom'),
              ),
              DropdownMenuItem(
                value: SortOption.size,
                child: Text('Taille'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _sortBy = value);
              }
            },
          ),
          
          const Spacer(),
          
          // Stats
          StreamBuilder<List<MediaAsset>>(
            stream: _mediaService.streamAssets(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              
              final assets = snapshot.data!;
              final totalSize = assets.fold<int>(
                0,
                (sum, asset) => sum + asset.sizeBytes,
              );
              
              return Text(
                '${assets.length} images • ${_formatBytes(totalSize)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Folders header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Dossiers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          
          // Folder list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: MediaFolder.values.map((folder) {
                return _buildFolderItem(folder);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderItem(MediaFolder folder) {
    final isSelected = _selectedFolder == folder;
    
    return StreamBuilder<List<MediaAsset>>(
      stream: _mediaService.streamAssetsByFolder(folder),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.length : 0;
        
        return ListTile(
          selected: isSelected,
          selectedTileColor: AppColors.primary.withOpacity(0.1),
          leading: Icon(
            _getFolderIcon(folder),
            color: isSelected ? AppColors.primary : Colors.grey.shade600,
          ),
          title: Text(
            folder.displayName,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : Colors.grey.shade800,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () => setState(() => _selectedFolder = folder),
        );
      },
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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nom de fichier, tags...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            setState(() => _searchQuery = value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.pop(context);
            },
            child: const Text('Effacer'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Sort options for media gallery
enum SortOption {
  date,
  name,
  size,
}
