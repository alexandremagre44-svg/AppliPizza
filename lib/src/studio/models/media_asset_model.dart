// lib/src/studio/models/media_asset_model.dart
// Media asset model for Media Manager PRO

/// Virtual folders for organizing media assets
enum MediaFolder {
  hero,      // Hero section images
  promos,    // Promotional images
  produits,  // Product images
  studio,    // Studio/general images
  misc,      // Miscellaneous images
}

/// Image size variant
enum ImageSize {
  small,   // 200px
  medium,  // 600px
  full,    // Original (compressed)
}

/// Media asset model
/// Represents an uploaded image with multiple size variants
class MediaAsset {
  final String id;
  final String originalFilename;
  final MediaFolder folder;
  
  // URLs for different sizes
  final String urlSmall;   // 200px
  final String urlMedium;  // 600px
  final String urlFull;    // Original compressed
  
  // Metadata
  final int sizeBytes;     // Size of full image in bytes
  final int width;         // Original width
  final int height;        // Original height
  final String mimeType;   // e.g., 'image/webp', 'image/jpeg'
  
  // Timestamps
  final DateTime uploadedAt;
  final String uploadedBy;
  
  // Optional metadata
  final String? description;
  final List<String> tags;
  
  // Usage tracking (references to this image)
  final List<String> usedIn; // List of document IDs where this image is used

  MediaAsset({
    required this.id,
    required this.originalFilename,
    required this.folder,
    required this.urlSmall,
    required this.urlMedium,
    required this.urlFull,
    required this.sizeBytes,
    required this.width,
    required this.height,
    required this.mimeType,
    required this.uploadedAt,
    required this.uploadedBy,
    this.description,
    this.tags = const [],
    this.usedIn = const [],
  });

  /// Convert to Firestore map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalFilename': originalFilename,
      'folder': folder.name,
      'urlSmall': urlSmall,
      'urlMedium': urlMedium,
      'urlFull': urlFull,
      'sizeBytes': sizeBytes,
      'width': width,
      'height': height,
      'mimeType': mimeType,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
      'description': description,
      'tags': tags,
      'usedIn': usedIn,
    };
  }

  /// Create from Firestore document
  factory MediaAsset.fromJson(Map<String, dynamic> json) {
    return MediaAsset(
      id: json['id'] as String,
      originalFilename: json['originalFilename'] as String,
      folder: _parseFolder(json['folder'] as String?),
      urlSmall: json['urlSmall'] as String,
      urlMedium: json['urlMedium'] as String,
      urlFull: json['urlFull'] as String,
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      mimeType: json['mimeType'] as String? ?? 'image/jpeg',
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'] as String)
          : DateTime.now(),
      uploadedBy: json['uploadedBy'] as String? ?? 'unknown',
      description: json['description'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : [],
      usedIn: json['usedIn'] != null
          ? List<String>.from(json['usedIn'] as List)
          : [],
    );
  }

  static MediaFolder _parseFolder(String? value) {
    switch (value) {
      case 'hero':
        return MediaFolder.hero;
      case 'promos':
        return MediaFolder.promos;
      case 'produits':
        return MediaFolder.produits;
      case 'studio':
        return MediaFolder.studio;
      case 'misc':
        return MediaFolder.misc;
      default:
        return MediaFolder.misc;
    }
  }

  /// Copy with method for immutable updates
  MediaAsset copyWith({
    String? id,
    String? originalFilename,
    MediaFolder? folder,
    String? urlSmall,
    String? urlMedium,
    String? urlFull,
    int? sizeBytes,
    int? width,
    int? height,
    String? mimeType,
    DateTime? uploadedAt,
    String? uploadedBy,
    String? description,
    List<String>? tags,
    List<String>? usedIn,
  }) {
    return MediaAsset(
      id: id ?? this.id,
      originalFilename: originalFilename ?? this.originalFilename,
      folder: folder ?? this.folder,
      urlSmall: urlSmall ?? this.urlSmall,
      urlMedium: urlMedium ?? this.urlMedium,
      urlFull: urlFull ?? this.urlFull,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      mimeType: mimeType ?? this.mimeType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      usedIn: usedIn ?? this.usedIn,
    );
  }

  /// Get file size in human-readable format
  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Get image dimensions as string
  String get dimensions => '${width}x$height';

  /// Check if image is in use
  bool get isInUse => usedIn.isNotEmpty;

  /// Get URL for specific size
  String getUrl(ImageSize size) {
    switch (size) {
      case ImageSize.small:
        return urlSmall;
      case ImageSize.medium:
        return urlMedium;
      case ImageSize.full:
        return urlFull;
    }
  }
}

/// Helper extensions for MediaFolder
extension MediaFolderExtension on MediaFolder {
  String get displayName {
    switch (this) {
      case MediaFolder.hero:
        return 'Hero';
      case MediaFolder.promos:
        return 'Promotions';
      case MediaFolder.produits:
        return 'Produits';
      case MediaFolder.studio:
        return 'Studio';
      case MediaFolder.misc:
        return 'Divers';
    }
  }

  String get storagePath {
    return 'studio/media/${name}';
  }
}
