import 'dart:io';
import '../config/app_config.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MediaService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Image Processing
  Future<String> uploadImage({
    required File imageFile,
    required String userId,
    String? folder,
  }) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final String storagePath = 'users/$userId/${folder ?? 'images'}/$fileName';
      final Reference ref = _storage.ref().child(storagePath);

      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Store metadata in Firestore
      await _firestore.collection('media').add({
        'userId': userId,
        'type': 'image',
        'url': downloadUrl,
        'path': storagePath,
        'fileName': fileName,
        'size': snapshot.bytesTransferred,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<File?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? quality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Video Processing
  Future<String> uploadVideo({
    required File videoFile,
    required String userId,
    String? folder,
  }) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(videoFile.path)}';
      final String storagePath = 'users/$userId/${folder ?? 'videos'}/$fileName';
      final Reference ref = _storage.ref().child(storagePath);

      final UploadTask uploadTask = ref.putFile(videoFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Store metadata in Firestore
      await _firestore.collection('media').add({
        'userId': userId,
        'type': 'video',
        'url': downloadUrl,
        'path': storagePath,
        'fileName': fileName,
        'size': snapshot.bytesTransferred,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  Future<File?> pickVideo({
    required ImageSource source,
    Duration? maxDuration,
  }) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick video: $e');
    }
  }

  Future<VideoPlayerController> getVideoController(String videoUrl) async {
    try {
      final VideoPlayerController controller = VideoPlayerController.network(videoUrl);
      await controller.initialize();
      return controller;
    } catch (e) {
      throw Exception('Failed to initialize video controller: $e');
    }
  }

  // Story Processing
  Future<String> uploadStory({
    required File mediaFile,
    required String userId,
    required String type,
    Duration? duration,
  }) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(mediaFile.path)}';
      final String storagePath = 'users/$userId/stories/$fileName';
      final Reference ref = _storage.ref().child(storagePath);

      final UploadTask uploadTask = ref.putFile(mediaFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Store metadata in Firestore
      await _firestore.collection('stories').add({
        'userId': userId,
        'type': type,
        'url': downloadUrl,
        'path': storagePath,
        'fileName': fileName,
        'size': snapshot.bytesTransferred,
        'duration': duration?.inSeconds,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(hours: 24)),
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload story: $e');
    }
  }

  // Media Management
  Future<void> deleteMedia(String mediaId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('media').doc(mediaId).get();
      final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      
      if (data != null) {
        // Delete from Storage
        final Reference ref = _storage.ref().child(data['path']);
        await ref.delete();

        // Delete from Firestore
        await _firestore.collection('media').doc(mediaId).delete();
      }
    } catch (e) {
      throw Exception('Failed to delete media: $e');
    }
  }

  Future<void> deleteUserMedia(String userId) async {
    try {
      // Delete all media from Storage
      final Reference userRef = _storage.ref().child('users/$userId');
      final ListResult result = await userRef.listAll();
      
      for (var item in result.items) {
        await item.delete();
      }

      // Delete all media metadata from Firestore
      final QuerySnapshot mediaSnapshot = await _firestore
          .collection('media')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in mediaSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete user media: $e');
    }
  }

  // Media Retrieval
  Future<List<Map<String, dynamic>>> getUserMedia(String userId) async {
    try {
      final QuerySnapshot mediaSnapshot = await _firestore
          .collection('media')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return mediaSnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user media: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserStories(String userId) async {
    try {
      final QuerySnapshot storiesSnapshot = await _firestore
          .collection('stories')
          .where('userId', isEqualTo: userId)
          .where('expiresAt', isGreaterThan: DateTime.now())
          .orderBy('createdAt', descending: true)
          .get();

      return storiesSnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user stories: $e');
    }
  }

  // Storage Management
  Future<Map<String, dynamic>> getStorageUsage(String userId) async {
    try {
      final QuerySnapshot mediaSnapshot = await _firestore
          .collection('media')
          .where('userId', isEqualTo: userId)
          .get();

      num totalSize = 0;
      int fileCount = 0;

      for (var doc in mediaSnapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalSize += data['size'] ?? 0;
        fileCount++;
      }

      return {
        'totalSize': totalSize.toInt(),
        'fileCount': fileCount,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get storage usage: $e');
    }
  }

  Future<void> clearStorageCache() async {
    try {
      await _storage.ref().child('cache').delete();
    } catch (e) {
      throw Exception('Failed to clear storage cache: $e');
    }
  }

  // Media Processing
  Future<File> compressImage(File imageFile, {int quality = 85}) async {
    try {
      // This would integrate with an image compression library
      // For now, we'll return the original file
      return imageFile;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  Future<File> compressVideo(File videoFile, {int quality = 85}) async {
    try {
      // This would integrate with a video compression library
      // For now, we'll return the original file
      return videoFile;
    } catch (e) {
      throw Exception('Failed to compress video: $e');
    }
  }

  Future<Map<String, dynamic>> getMediaMetadata(File mediaFile) async {
    try {
      // This would integrate with a media metadata library
      // For now, we'll return basic information
      return {
        'size': await mediaFile.length(),
        'path': mediaFile.path,
        'name': path.basename(mediaFile.path),
        'extension': path.extension(mediaFile.path),
        'lastModified': mediaFile.lastModifiedSync().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get media metadata: $e');
    }
  }

  // Image Processing
  Future<File> processImage(File imageFile, {
    double? brightness,
    double? contrast,
    double? saturation,
    double? blur,
    bool pixelate = false,
  }) async {
    try {
      final img.Image? image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) throw Exception('Failed to decode image');

      // Apply effects
      if (brightness != null) {
        img.adjustColor(image, brightness: brightness);
      }
      if (contrast != null) {
        img.adjustColor(image, contrast: contrast);
      }
      if (saturation != null) {
        img.adjustColor(image, saturation: saturation);
      }
      if (blur != null) {
        img.gaussianBlur(image, radius: blur.toInt());
      }
      if (pixelate) {
        _pixelateImage(image);
      }

      // Save processed image
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File processedFile = File(tempPath);
      await processedFile.writeAsBytes(img.encodeJpg(image));

      return processedFile;
    } catch (e) {
      throw Exception('Failed to process image: $e');
    }
  }

  void _pixelateImage(img.Image image) {
    final int pixelSize = 8;
    final int width = image.width;
    final int height = image.height;

    for (int y = 0; y < height; y += pixelSize) {
      for (int x = 0; x < width; x += pixelSize) {
        int r = 0, g = 0, b = 0;
        int count = 0;

        // Calculate average color in pixel block
        for (int py = y; py < (y + pixelSize).clamp(0, height); py++) {
          for (int px = x; px < (x + pixelSize).clamp(0, width); px++) {
            final pixel = image.getPixel(px, py);
            r += pixel.r.toInt();
            g += pixel.g.toInt();
            b += pixel.b.toInt();
            count++;
          }
        }

        // Apply average color to pixel block
        if (count > 0) {
          r = (r / count).round();
          g = (g / count).round();
          b = (b / count).round();
          final color = img.ColorRgba8(r, g, b, 255);

          for (int py = y; py < (y + pixelSize).clamp(0, height); py++) {
            for (int px = x; px < (x + pixelSize).clamp(0, width); px++) {
              image.setPixel(px, py, color);
            }
          }
        }
      }
    }
  }

  // Video Processing
  Future<File> processVideo(File videoFile, {
    double? brightness,
    double? contrast,
    double? saturation,
    bool pixelate = false,
  }) async {
    try {
      // TODO: Implement video processing using FFmpeg
      // This is a placeholder for future implementation
      throw UnimplementedError('Video processing not yet implemented');
    } catch (e) {
      throw Exception('Failed to process video: $e');
    }
  }

  // AR Effects
  Future<File> applyAREffect(File mediaFile, String effectType) async {
    try {
      // TODO: Implement AR effects using ARKit/ARCore
      // This is a placeholder for future implementation
      throw UnimplementedError('AR effects not yet implemented');
    } catch (e) {
      throw Exception('Failed to apply AR effect: $e');
    }
  }

  // Media Validation
  bool validateMedia(File file) {
    final String extension = file.path.split('.').last.toLowerCase();
    final int fileSize = file.lengthSync();

    if (extension.startsWith('jpg') || extension.startsWith('jpeg') || extension == 'png') {
      return fileSize <= AppConfig.maxImageSize &&
          AppConfig.allowedImageTypes.contains(extension);
    } else if (extension == 'mp4' || extension == 'mov') {
      return fileSize <= AppConfig.maxVideoSize &&
          AppConfig.allowedVideoTypes.contains(extension);
    }

    return false;
  }

  // Media Compression
  Future<File> compressMedia(File file) async {
    try {
      final String extension = file.path.split('.').last.toLowerCase();
      
      if (extension.startsWith('jpg') || extension.startsWith('jpeg') || extension == 'png') {
        return await _compressImage(file);
      } else if (extension == 'mp4' || extension == 'mov') {
        return await _compressVideo(file);
      }

      throw Exception('Unsupported file type: $extension');
    } catch (e) {
      throw Exception('Failed to compress media: $e');
    }
  }

  Future<File> _compressImage(File file) async {
    try {
      final img.Image? image = img.decodeImage(await file.readAsBytes());
      if (image == null) throw Exception('Failed to decode image');

      // Resize if too large
      if (image.width > 1920 || image.height > 1080) {
        final double ratio = image.width / image.height;
        final int newWidth = ratio > 1 ? 1920 : (1080 * ratio).round();
        final int newHeight = ratio > 1 ? (1920 / ratio).round() : 1080;
        img.copyResize(image, width: newWidth, height: newHeight);
      }

      // Save compressed image
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File compressedFile = File(tempPath);
      await compressedFile.writeAsBytes(img.encodeJpg(image, quality: 85));

      return compressedFile;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  Future<File> _compressVideo(File file) async {
    try {
      // TODO: Implement video compression using FFmpeg
      // This is a placeholder for future implementation
      throw UnimplementedError('Video compression not yet implemented');
    } catch (e) {
      throw Exception('Failed to compress video: $e');
    }
  }
} 