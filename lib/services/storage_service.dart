import 'dart:io';
import '../config/app_config.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload Media
  Future<String> uploadMedia(File file, String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload media: $e');
    }
  }

  Future<String> uploadImage(File file, String userId) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = '${AppConfig.mediaPath}/images/$userId/$fileName';
      return await uploadMedia(file, path);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> uploadVideo(File file, String userId) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final String path = '${AppConfig.mediaPath}/videos/$userId/$fileName';
      return await uploadMedia(file, path);
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  Future<String> uploadStory(File file, String userId) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      final String path = '${AppConfig.storiesPath}/$userId/$fileName';
      return await uploadMedia(file, path);
    } catch (e) {
      throw Exception('Failed to upload story: $e');
    }
  }

  // Delete Media
  Future<void> deleteMedia(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete media: $e');
    }
  }

  Future<void> deleteUserMedia(String userId) async {
    try {
      final Reference userRef = _storage.ref().child('${AppConfig.mediaPath}/$userId');
      await userRef.delete();
    } catch (e) {
      throw Exception('Failed to delete user media: $e');
    }
  }

  // Get Media URL
  Future<String> getMediaUrl(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get media URL: $e');
    }
  }

  // Get Media Metadata
  Future<Map<String, dynamic>> getMediaMetadata(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      final FullMetadata metadata = await ref.getMetadata();
      return {
        'contentType': metadata.contentType,
        'size': metadata.size,
        'timeCreated': metadata.timeCreated?.toIso8601String(),
        'updated': metadata.updated?.toIso8601String(),
        'md5Hash': metadata.md5Hash,
      };
    } catch (e) {
      throw Exception('Failed to get media metadata: $e');
    }
  }

  // Upload Progress
  Stream<double> getUploadProgress(UploadTask task) {
    return task.snapshotEvents.map((TaskSnapshot snapshot) {
      return snapshot.bytesTransferred / snapshot.totalBytes;
    });
  }

  // Cache Management
  Future<void> clearCache() async {
    try {
      await _storage.ref().child('cache').delete();
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  // Content Management
  Future<void> uploadContent({
    required File file,
    required String userId,
    required String type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      String url;
      switch (type) {
        case 'image':
          url = await uploadImage(file, userId);
          break;
        case 'video':
          url = await uploadVideo(file, userId);
          break;
        case 'story':
          url = await uploadStory(file, userId);
          break;
        default:
          throw Exception('Unsupported content type: $type');
      }

      // Store content metadata in Firestore
      // This would be handled by a separate service
    } catch (e) {
      throw Exception('Failed to upload content: $e');
    }
  }

  // Content Processing
  Future<String> processContent({
    required File file,
    required String type,
    Map<String, dynamic>? options,
  }) async {
    try {
      // This would handle content processing like:
      // - Image compression
      // - Video transcoding
      // - Format conversion
      // - Metadata extraction
      throw UnimplementedError('Content processing not yet implemented');
    } catch (e) {
      throw Exception('Failed to process content: $e');
    }
  }

  // Content Delivery
  Future<String> getContentUrl(String contentId) async {
    try {
      // This would handle content delivery optimization like:
      // - CDN selection
      // - Quality adaptation
      // - Region-based routing
      throw UnimplementedError('Content delivery not yet implemented');
    } catch (e) {
      throw Exception('Failed to get content URL: $e');
    }
  }

  // Storage Management
  Future<Map<String, dynamic>> getStorageUsage(String userId) async {
    try {
      final Reference userRef = _storage.ref().child('${AppConfig.mediaPath}/$userId');
      final ListResult result = await userRef.listAll();
      
      int totalSize = 0;
      int fileCount = 0;
      
      for (var item in result.items) {
        final metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
        fileCount++;
      }

      return {
        'totalSize': totalSize,
        'fileCount': fileCount,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get storage usage: $e');
    }
  }

  // Backup and Restore
  Future<void> backupUserContent(String userId) async {
    try {
      // This would handle content backup like:
      // - Creating a backup archive
      // - Uploading to backup storage
      // - Managing backup versions
      throw UnimplementedError('Content backup not yet implemented');
    } catch (e) {
      throw Exception('Failed to backup user content: $e');
    }
  }

  Future<void> restoreUserContent(String userId, String backupId) async {
    try {
      // This would handle content restoration like:
      // - Downloading backup archive
      // - Restoring files
      // - Verifying integrity
      throw UnimplementedError('Content restoration not yet implemented');
    } catch (e) {
      throw Exception('Failed to restore user content: $e');
    }
  }
} 