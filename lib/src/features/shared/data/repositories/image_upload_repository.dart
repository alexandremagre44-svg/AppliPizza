// lib/src/features/shared/data/repositories/image_upload_repository.dart
// Service for uploading images to Firebase Storage

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

/// Service for handling image uploads to Firebase Storage
class ImageUploadRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Pick an image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  /// Upload an image to Firebase Storage and return its download URL
  /// 
  /// [imageFile] - The image file to upload
  /// [path] - The storage path (e.g., 'home/hero', 'products/pizza')
  /// 
  /// Returns the download URL as a String, or null if upload fails
  Future<String?> uploadImage(File imageFile, String path) async {
    try {
      // Generate unique filename
      final uuid = const Uuid().v4();
      final extension = imageFile.path.split('.').last;
      final fileName = '$uuid.$extension';
      final fullPath = '$path/$fileName';

      // Create reference to the file location
      final Reference ref = _storage.ref().child(fullPath);

      // Upload file with metadata
      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/${extension.toLowerCase()}',
          customMetadata: {
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Delete an image from Firebase Storage
  /// 
  /// [imageUrl] - The download URL of the image to delete
  /// 
  /// Returns true if deletion was successful, false otherwise
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('Image deleted successfully: $imageUrl');
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Show image source selection dialog
  /// Returns the selected File or null if cancelled
  Future<File?> selectImageSource() async {
    // This method should be called from UI context
    // The UI should show a dialog to select between camera and gallery
    // For now, we'll default to gallery
    return await pickImageFromGallery();
  }

  /// Upload image with progress callback
  /// 
  /// [imageFile] - The image file to upload
  /// [path] - The storage path
  /// [onProgress] - Callback function to track upload progress (0.0 to 1.0)
  Future<String?> uploadImageWithProgress(
    File imageFile,
    String path, {
    Function(double)? onProgress,
  }) async {
    try {
      final uuid = const Uuid().v4();
      final extension = imageFile.path.split('.').last;
      final fileName = '$uuid.$extension';
      final fullPath = '$path/$fileName';

      final Reference ref = _storage.ref().child(fullPath);

      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/${extension.toLowerCase()}',
        ),
      );

      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image with progress: $e');
      return null;
    }
  }

  /// Get file size in MB
  double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  /// Validate image file
  bool isValidImage(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    final validExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
    
    if (!validExtensions.contains(extension)) {
      return false;
    }

    // Check file size (max 10MB)
    final sizeInMB = getFileSizeInMB(file);
    if (sizeInMB > 10) {
      return false;
    }

    return true;
  }
}
