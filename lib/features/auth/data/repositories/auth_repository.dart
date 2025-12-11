import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/models/user_model.dart';
import '../../../../services/firebase_service.dart';

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<firebase_auth.User?> get authStateChanges {
    if (!FirebaseService.isInitialized) {
      // Return empty stream if Firebase is not initialized
      return Stream.value(null);
    }
    return FirebaseService.auth.authStateChanges();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!FirebaseService.isInitialized) {
      throw Exception('Firebase is not configured. Please run: flutterfire configure');
    }
    
    final auth = FirebaseService.auth;
    final firestore = FirebaseService.firestore;
    
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        try {
          await credential.user!.updateDisplayName(name);
        } catch (e) {
          // Log but don't fail if display name update fails
          print('Warning: Failed to update display name: $e');
        }
        
        // Create user document in Firestore
        try {
          final userModel = UserModel(
            id: credential.user!.uid,
            name: name,
            email: email,
            createdAt: DateTime.now(),
          );

          await firestore
              .collection('users')
              .doc(credential.user!.uid)
              .set(userModel.toJson());
        } catch (e) {
          // Log Firestore error but don't fail signup
          print('Warning: Failed to create user document in Firestore: $e');
          // User is still created in Firebase Auth, just Firestore doc failed
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Preserve Firebase Auth specific error messages
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled. Please contact support.';
          break;
        default:
          errorMessage = e.message ?? 'Sign up failed: ${e.code}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // For other errors, include the original error message
      final errorMessage = e.toString();
      if (errorMessage.contains('YOUR_') || errorMessage.contains('API_KEY')) {
        throw Exception('Firebase is not properly configured. Please run: flutterfire configure');
      }
      throw Exception('Sign up failed: $errorMessage');
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (!FirebaseService.isInitialized) {
      throw Exception('Firebase is not configured. Please run: flutterfire configure');
    }
    
    final auth = FirebaseService.auth;
    
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Preserve Firebase Auth specific error messages
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please try again later.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled. Please contact support.';
          break;
        default:
          errorMessage = e.message ?? 'Sign in failed: ${e.code}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('YOUR_') || errorMessage.contains('API_KEY')) {
        throw Exception('Firebase is not properly configured. Please run: flutterfire configure');
      }
      throw Exception('Sign in failed: $errorMessage');
    }
  }

  Future<void> signInWithGoogle() async {
    if (!FirebaseService.isInitialized) {
      throw Exception('Firebase is not configured. Please run: flutterfire configure');
    }
    
    final auth = FirebaseService.auth;
    final firestore = FirebaseService.firestore;
    
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user document exists, if not create it
        final userDoc = await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          final userModel = UserModel(
            id: userCredential.user!.uid,
            name: userCredential.user!.displayName ?? 'User',
            email: userCredential.user!.email ?? '',
            avatar: userCredential.user!.photoURL,
            createdAt: DateTime.now(),
          );

          await firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userModel.toJson());
        }
      }
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      if (FirebaseService.isInitialized) {
        await Future.wait([
          FirebaseService.auth.signOut(),
          _googleSignIn.signOut(),
        ]);
      } else {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Future<UserModel?> getUser(String uid) async {
    if (!FirebaseService.isInitialized) {
      return null;
    }
    
    final firestore = FirebaseService.firestore;
    
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> updateProfile({
    String? university,
    String? department,
    String? year,
    String? avatar,
  }) async {
    if (!FirebaseService.isInitialized) {
      throw Exception('Firebase is not configured. Please run: flutterfire configure');
    }
    
    final auth = FirebaseService.auth;
    final firestore = FirebaseService.firestore;
    
    try {
      final user = auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      final updates = <String, dynamic>{};
      if (university != null) updates['university'] = university;
      if (department != null) updates['department'] = department;
      if (year != null) updates['year'] = year;
      if (avatar != null) updates['avatar'] = avatar;

      await firestore.collection('users').doc(user.uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}

