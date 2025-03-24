import '../config/app_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Data
  Future<void> createUserProfile({
    required String userId,
    required String username,
    required String email,
    String? photoURL,
    String? bio,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'username': username,
        'email': email,
        'photoURL': photoURL,
        'bio': bio,
        'preferences': preferences ?? {
          'theme': 'system',
          'notifications': true,
          'privacy': {
            'profileVisibility': false,
            'activityVisibility': true,
            'locationEnabled': false,
          },
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'stats': {
          'posts': 0,
          'followers': 0,
          'following': 0,
        },
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? username,
    String? photoURL,
    String? bio,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (username != null) updates['username'] = username;
      if (photoURL != null) updates['photoURL'] = photoURL;
      if (bio != null) updates['bio'] = bio;

      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // User Preferences
  Future<void> updateUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'preferences': preferences,
      });
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  Future<Map<String, dynamic>> getUserPreferences(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data() as Map<String, dynamic>?;
      return data?['preferences'] ?? {};
    } catch (e) {
      throw Exception('Failed to get user preferences: $e');
    }
  }

  // User Stats
  Future<void> updateUserStats({
    required String userId,
    required String stat,
    required int value,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'stats.$stat': FieldValue.increment(value),
      });
    } catch (e) {
      throw Exception('Failed to update user stats: $e');
    }
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data() as Map<String, dynamic>?;
      return data?['stats'] ?? {};
    } catch (e) {
      throw Exception('Failed to get user stats: $e');
    }
  }

  // User Activity
  Future<void> updateLastActive(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update last active: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserActivity(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('activity')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Failed to get user activity: $e');
    }
  }

  // User Connections
  Future<void> followUser(String followerId, String followedId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Add to follower's following list
        transaction.update(
          _firestore.collection('users').doc(followerId),
          {'following': FieldValue.increment(1)},
        );

        // Add to followed's followers list
        transaction.update(
          _firestore.collection('users').doc(followedId),
          {'followers': FieldValue.increment(1)},
        );

        // Create follow relationship
        transaction.set(
          _firestore
              .collection('users')
              .doc(followerId)
              .collection('following')
              .doc(followedId),
          {'timestamp': FieldValue.serverTimestamp()},
        );

        transaction.set(
          _firestore
              .collection('users')
              .doc(followedId)
              .collection('followers')
              .doc(followerId),
          {'timestamp': FieldValue.serverTimestamp()},
        );
      });
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  Future<void> unfollowUser(String followerId, String followedId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Remove from follower's following list
        transaction.update(
          _firestore.collection('users').doc(followerId),
          {'following': FieldValue.increment(-1)},
        );

        // Remove from followed's followers list
        transaction.update(
          _firestore.collection('users').doc(followedId),
          {'followers': FieldValue.increment(-1)},
        );

        // Remove follow relationship
        transaction.delete(
          _firestore
              .collection('users')
              .doc(followerId)
              .collection('following')
              .doc(followedId),
        );

        transaction.delete(
          _firestore
              .collection('users')
              .doc(followedId)
              .collection('followers')
              .doc(followerId),
        );
      });
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  // User Search
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: query + '\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // User Data Export
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Get user's posts
      final QuerySnapshot postsSnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .get();

      // Get user's stories
      final QuerySnapshot storiesSnapshot = await _firestore
          .collection('stories')
          .where('userId', isEqualTo: userId)
          .get();

      // Get user's activity
      final QuerySnapshot activitySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('activity')
          .get();

      return {
        'profile': userData,
        'posts': postsSnapshot.docs.map((doc) => doc.data()).toList(),
        'stories': storiesSnapshot.docs.map((doc) => doc.data()).toList(),
        'activity': activitySnapshot.docs.map((doc) => doc.data()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to export user data: $e');
    }
  }
} 