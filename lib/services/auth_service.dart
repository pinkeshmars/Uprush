import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uprush/firestore/firestore_data_schema.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      // Create user document in Firestore
      if (credential.user != null) {
        await _createUserDocument(credential.user!);
      }
      
      return credential;
    } catch (e) {
      throw Exception('Account creation failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    final now = DateTime.now();
    final firestoreUser = FirestoreUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore
        .collection(FirestoreSchema.usersCollection)
        .doc(user.uid)
        .set(firestoreUser.toJson());
  }

  // Update user profile
  Future<void> updateUserProfile({String? displayName}) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      if (displayName != null) {
        await user.updateDisplayName(displayName);
        
        // Update Firestore document
        await _firestore
            .collection(FirestoreSchema.usersCollection)
            .doc(user.uid)
            .update({
          'display_name': displayName,
          'updated_at': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }
}