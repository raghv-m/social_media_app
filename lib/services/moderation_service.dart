import '../config/app_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModerationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Content Moderation
  Future<bool> isContentAppropriate(String content) async {
    try {
      // This would integrate with a content moderation API
      // For now, we'll implement basic checks
      final List<String> inappropriateWords = [
        'hate',
        'violence',
        'spam',
        'scam',
        // Add more inappropriate words
      ];

      final String lowercaseContent = content.toLowerCase();
      return !inappropriateWords.any((word) => lowercaseContent.contains(word));
    } catch (e) {
      throw Exception('Failed to check content appropriateness: $e');
    }
  }

  Future<bool> isImageAppropriate(String imageUrl) async {
    try {
      // This would integrate with an image moderation API
      // For now, we'll return true
      return true;
    } catch (e) {
      throw Exception('Failed to check image appropriateness: $e');
    }
  }

  Future<bool> isVideoAppropriate(String videoUrl) async {
    try {
      // This would integrate with a video moderation API
      // For now, we'll return true
      return true;
    } catch (e) {
      throw Exception('Failed to check video appropriateness: $e');
    }
  }

  // User Reporting
  Future<void> reportContent({
    required String contentId,
    required String reporterId,
    required String reason,
    String? description,
  }) async {
    try {
      await _firestore.collection('reports').add({
        'contentId': contentId,
        'reporterId': reporterId,
        'reason': reason,
        'description': description,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to report content: $e');
    }
  }

  Future<void> reportUser({
    required String reportedUserId,
    required String reporterId,
    required String reason,
    String? description,
  }) async {
    try {
      await _firestore.collection('user_reports').add({
        'reportedUserId': reportedUserId,
        'reporterId': reporterId,
        'reason': reason,
        'description': description,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to report user: $e');
    }
  }

  // Content Filtering
  Future<List<String>> filterInappropriateWords(String content) async {
    try {
      // This would integrate with a profanity filter API
      // For now, we'll implement basic filtering
      final List<String> inappropriateWords = [
        'hate',
        'violence',
        'spam',
        'scam',
        // Add more inappropriate words
      ];

      final List<String> words = content.split(' ');
      return words.where((word) => inappropriateWords.contains(word.toLowerCase())).toList();
    } catch (e) {
      throw Exception('Failed to filter inappropriate words: $e');
    }
  }

  // User Safety
  Future<void> blockUser(String blockerId, String blockedId) async {
    try {
      await _firestore.collection('users').doc(blockerId).update({
        'blockedUsers': FieldValue.arrayUnion([blockedId]),
      });
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  Future<void> unblockUser(String blockerId, String blockedId) async {
    try {
      await _firestore.collection('users').doc(blockerId).update({
        'blockedUsers': FieldValue.arrayRemove([blockedId]),
      });
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  Future<bool> isUserBlocked(String userId, String targetId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      final List<dynamic> blockedUsers = data?['blockedUsers'] ?? [];
      return blockedUsers.contains(targetId);
    } catch (e) {
      throw Exception('Failed to check if user is blocked: $e');
    }
  }

  // Content Safety
  Future<void> markContentAsSensitive(String contentId, String reason) async {
    try {
      await _firestore.collection('content').doc(contentId).update({
        'isSensitive': true,
        'sensitivityReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark content as sensitive: $e');
    }
  }

  Future<void> addContentWarning(String contentId, String warning) async {
    try {
      await _firestore.collection('content').doc(contentId).update({
        'warnings': FieldValue.arrayUnion([warning]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add content warning: $e');
    }
  }

  // Safety Settings
  Future<void> updateSafetySettings({
    required String userId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'safetySettings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update safety settings: $e');
    }
  }

  Future<Map<String, dynamic>> getSafetySettings(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      return data?['safetySettings'] ?? {
        'showSensitiveContent': false,
        'filterInappropriateContent': true,
        'blockedUsers': [],
        'reportingEnabled': true,
      };
    } catch (e) {
      throw Exception('Failed to get safety settings: $e');
    }
  }

  // Content Review
  Future<void> reviewContent({
    required String contentId,
    required String reviewerId,
    required String decision,
    String? reason,
  }) async {
    try {
      await _firestore.collection('content_reviews').add({
        'contentId': contentId,
        'reviewerId': reviewerId,
        'decision': decision,
        'reason': reason,
        'reviewedAt': FieldValue.serverTimestamp(),
      });

      if (decision == 'remove') {
        await _firestore.collection('content').doc(contentId).update({
          'status': 'removed',
          'removedAt': FieldValue.serverTimestamp(),
          'removedBy': reviewerId,
          'removalReason': reason,
        });
      }
    } catch (e) {
      throw Exception('Failed to review content: $e');
    }
  }

  // Safety Analytics
  Future<Map<String, dynamic>> getSafetyAnalytics(String userId) async {
    try {
      final QuerySnapshot reportsSnapshot = await _firestore
          .collection('reports')
          .where('reporterId', isEqualTo: userId)
          .get();

      final QuerySnapshot userReportsSnapshot = await _firestore
          .collection('user_reports')
          .where('reporterId', isEqualTo: userId)
          .get();

      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      final Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      final List<dynamic> blockedUsers = userData?['blockedUsers'] ?? [];

      return {
        'contentReports': reportsSnapshot.docs.length,
        'userReports': userReportsSnapshot.docs.length,
        'blockedUsers': blockedUsers.length,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get safety analytics: $e');
    }
  }
} 