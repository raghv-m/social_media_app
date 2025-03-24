import 'dart:io';
import 'package:image/image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChattrBackend {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ 1. User Authentication (Signup, Login, Logout)
  Future<User?> signUp(String email, String password, String username, String name, String phone, DateTime dateOfBirth) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'username': username,
          'name': name,
          'phone': phone,
          'dateOfBirth': dateOfBirth.toIso8601String(),
          'followers': [],
          'following': [],
          'bio': '',
          'profilePic': '',
        });
        return user;
      }
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
    return null;
  }

  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  /// ✅ 2. Follow / Unfollow Users
  Future<void> followUser(String currentUserId, String targetUserId) async {
    await _firestore.collection('users').doc(currentUserId).update({
      'following': FieldValue.arrayUnion([targetUserId]),
    });

    await _firestore.collection('users').doc(targetUserId).update({
      'followers': FieldValue.arrayUnion([currentUserId]),
    });
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    await _firestore.collection('users').doc(currentUserId).update({
      'following': FieldValue.arrayRemove([targetUserId]),
    });

    await _firestore.collection('users').doc(targetUserId).update({
      'followers': FieldValue.arrayRemove([currentUserId]),
    });
  }

  /// ✅ 3. Search Users
  Future<QuerySnapshot> searchUsers(String query) {
    return _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
  }

  /// ✅ 4. Create Posts (Images & Blogs)
  Future<void> createPost(String userId, String username, String content, String? imageUrl, bool isBlog) async {
    await _firestore.collection('posts').add({
      'userId': userId,
      'username': username,
      'content': content,
      'imageUrl': imageUrl ?? '',
      'isBlog': isBlog,
      'likes': [],
      'dislikes': [],
      'comments': [],
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// ✅ 5. Like / Dislike a Post
  Future<void> likePost(String postId, String userId) async {
    await _firestore.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> dislikePost(String postId, String userId) async {
    await _firestore.collection('posts').doc(postId).update({
      'dislikes': FieldValue.arrayUnion([userId]),
    });
  }

  /// ✅ 6. Comment on a Post
  Future<void> addComment(String postId, String userId, String comment) async {
    await _firestore.collection('posts').doc(postId).update({
      'comments': FieldValue.arrayUnion([{
        'userId': userId,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      }]),
    });
  }

  /// ✅ 7. Fetch Feed (Sort by Engagement)
  Stream<QuerySnapshot> fetchSortedPosts() {
    return _firestore.collection('posts')
        .orderBy('likes.length', descending: true)
        .orderBy('comments.length', descending: true)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// ✅ 8. Messaging System (Send & Receive)
  Future<void> sendMessage(String senderId, String receiverId, String message) async {
    await _firestore.collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> fetchMessages(String senderId, String receiverId) {
    return _firestore.collection('messages')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// ✅ 9. Notifications (Real-Time)
  Future<void> sendNotification(String userId, String message) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// ✅ 10. Suggested Users Based on Mutual Friends
  Future<List<String>> suggestUsers(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final List<dynamic> following = userDoc['following'];

    final mutualFriends = await _firestore.collection('users')
        .where('followers', arrayContainsAny: following)
        .limit(5)
        .get();

    return mutualFriends.docs.map((doc) => doc.id).toList();
  }

  /// ✅ 11. Image Compression (Before Upload)
  Future<void> compressImage(File file) async {
    final image = decodeImage(await file.readAsBytes());
    final compressedImage = encodeJpg(image!, quality: 70);
    await file.writeAsBytes(compressedImage);
  }

  /// ✅ 12. Change Password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    // Reauthenticate user
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Change password
    await user.updatePassword(newPassword);
  }

  /// ✅ 13. Update User Profile
  Future<void> updateProfile({
    String? username,
    String? name,
    String? bio,
    String? profilePic,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (name != null) updates['name'] = name;
    if (bio != null) updates['bio'] = bio;
    if (profilePic != null) updates['profilePic'] = profilePic;

    await _firestore.collection('users').doc(user.uid).update(updates);
  }

  /// ✅ 14. Delete Account
  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    // Reauthenticate user
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);

    // Delete user data from Firestore
    await _firestore.collection('users').doc(user.uid).delete();

    // Delete user account
    await user.delete();
  }

  /// ✅ 15. Report User
  Future<void> reportUser(String reportedUserId, String reason) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _firestore.collection('reports').add({
      'reporterId': user.uid,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// ✅ 16. Block User
  Future<void> blockUser(String blockedUserId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _firestore.collection('users').doc(user.uid).update({
      'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
    });
  }

  /// ✅ 17. Unblock User
  Future<void> unblockUser(String blockedUserId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _firestore.collection('users').doc(user.uid).update({
      'blockedUsers': FieldValue.arrayRemove([blockedUserId]),
    });
  }

  /// ✅ 18. Get User Settings
  Future<Map<String, dynamic>> getUserSettings() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data() ?? {};
  }

  /// ✅ 19. Update User Settings
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _firestore.collection('users').doc(user.uid).update({
      'settings': settings,
    });
  }

  /// ✅ 20. Get User Activity
  Stream<QuerySnapshot> getUserActivity(String userId) {
    return _firestore
        .collection('activity')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
