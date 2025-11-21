// lib/src/studio/widgets/media/media_upload_widget.dart
// Drag & drop upload widget for Media Manager PRO

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../design_system/app_theme.dart';
import '../../models/media_asset_model.dart';
import '../../services/media_manager_service.dart';

/// Media upload widget with drag & drop and button
class MediaUploadWidget extends StatefulWidget {
  final MediaFolder folder;
  final String userId;
  final VoidCallback onUploadComplete;

  const MediaUploadWidget({
    super.key,
    required this.folder,
    required this.userId,
    required this.onUploadComplete,
  });

  @override
  State<MediaUploadWidget> createState() => _MediaUploadWidgetState();
}

class _MediaUploadWidgetState extends State<MediaUploadWidget> {
  final _mediaService = MediaManagerService();
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadingFileName;

  Future<void> _handleUpload() async {
    // Pick image
    final pickedFile = await _mediaService.pickImage();
    if (pickedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadingFileName = pickedFile.name;
    });

    try {
      // Upload with progress
      final asset = await _mediaService.uploadImage(
        imageFile: pickedFile,
        folder: widget.folder,
        uploadedBy: widget.userId,
        onProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );

      if (asset != null) {
        // Success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image uploadée: ${pickedFile.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
        widget.onUploadComplete();
      } else {
        // Failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'upload'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
          _uploadingFileName = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isUploading ? AppColors.primary : Colors.grey.shade300,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: _isUploading ? _buildUploadingState() : _buildIdleState(),
    );
  }

  Widget _buildIdleState() {
    return Column(
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 64,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          'Glissez-déposez vos images ici',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ou',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _handleUpload,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Choisir une image'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Formats: JPEG, PNG, WebP • Max: 10 MB',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        Text(
          'Compression automatique à 80% • 3 tailles générées',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadingState() {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Upload en cours...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _uploadingFileName ?? '',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: _uploadProgress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          '${(_uploadProgress * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
