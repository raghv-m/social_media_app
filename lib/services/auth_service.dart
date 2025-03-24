import '../config/app_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email & Password Authentication
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    String? photoUrl,
  }) async {
    try {
      // Create user with email and password
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'username': username,
        'email': email,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'isOnline': true,
        'status': 'active',
      });

      return credential;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last active timestamp
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastActive': FieldValue.serverTimestamp(),
        'isOnline': true,
      });

      return credential;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // Google Authentication
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if user profile exists
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Create new user profile
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'photoUrl': userCredential.user!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
          'isOnline': true,
          'status': 'active',
        });
      } else {
        // Update last active timestamp
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastActive': FieldValue.serverTimestamp(),
          'isOnline': true,
        });
      }

      return userCredential;
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // Phone Authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneCodeSent onCodeSent,
    required PhoneCodeAutoRetrievalTimeout onCodeAutoRetrievalTimeout,
    required PhoneVerificationCompleted onVerificationCompleted,
    required PhoneVerificationFailed onVerificationFailed,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      );
    } catch (e) {
      throw Exception('Failed to verify phone number: $e');
    }
  }

  Future<UserCredential> signInWithPhone({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if user profile exists
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Create new user profile
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'phoneNumber': userCredential.user!.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
          'isOnline': true,
          'status': 'active',
        });
      } else {
        // Update last active timestamp
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastActive': FieldValue.serverTimestamp(),
          'isOnline': true,
        });
      }

      return userCredential;
    } catch (e) {
      throw Exception('Failed to sign in with phone: $e');
    }
  }

  // Profile Management
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      await currentUser?.updatePhotoURL(photoURL);

      // Update Firestore profile
      await _firestore.collection('users').doc(currentUser!.uid).update({
        if (displayName != null) 'username': displayName,
        if (photoURL != null) 'photoUrl': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> updateUserStatus({
    required String status,
    String? statusMessage,
  }) async {
    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'status': status,
        if (statusMessage != null) 'statusMessage': statusMessage,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  // Session Management
  Future<void> signOut() async {
    try {
      // Update user status to offline
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser!.uid).update({
          'isOnline': false,
          'lastActive': FieldValue.serverTimestamp(),
        });
      }

      // Sign out from all providers
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      // Delete user data from Firestore
      await _firestore.collection('users').doc(currentUser!.uid).delete();

      // Delete user account
      await currentUser?.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Security
  Future<void> reauthenticateUser(String password) async {
    try {
      final AuthCredential authCredential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );
      await currentUser?.reauthenticateWithCredential(authCredential);
    } catch (e) {
      throw Exception('Failed to reauthenticate user: $e');
    }
  }

  Future<void> enableTwoFactorAuth() async {
    try {
      // This would integrate with a 2FA service
      // For now, we'll just update the user's security settings
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'twoFactorEnabled': true,
        'securityUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to enable two-factor authentication: $e');
    }
  }

  Future<void> disableTwoFactorAuth() async {
    try {
      // This would integrate with a 2FA service
      // For now, we'll just update the user's security settings
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'twoFactorEnabled': false,
        'securityUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to disable two-factor authentication: $e');
    }
  }

  // Error Handling
  String getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
} 