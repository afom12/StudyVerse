import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_options.dart'; // make sure this path is correct

class FirebaseService {
  // Tracks if Firebase has been initialized
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  // Firebase instances (nullable until initialized)
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;

  // Getters that return non-null only when initialized
  static FirebaseAuth get auth {
    if (!_isInitialized || _auth == null) {
      throw Exception('Firebase is not initialized. Call FirebaseService.initialize() first.');
    }
    return _auth!;
  }

  static FirebaseFirestore get firestore {
    if (!_isInitialized || _firestore == null) {
      throw Exception('Firebase is not initialized. Call FirebaseService.initialize() first.');
    }
    return _firestore!;
  }

  static FirebaseStorage get storage {
    if (!_isInitialized || _storage == null) {
      throw Exception('Firebase is not initialized. Call FirebaseService.initialize() first.');
    }
    return _storage!;
  }

  // Current user stream
  static Stream<User?> get authStateChanges {
    if (!_isInitialized || _auth == null) {
      return Stream.value(null);
    }
    return _auth!.authStateChanges();
  }

  static User? get currentUser {
    if (!_isInitialized || _auth == null) {
      return null;
    }
    return _auth!.currentUser;
  }

  // Initialize Firebase
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      
      // Check if Firebase is configured (not using placeholder values)
      if (options.apiKey.contains('YOUR_') || 
          options.appId.contains('YOUR_') ||
          options.messagingSenderId.contains('YOUR_')) {
        _isInitialized = false;
        print('ERROR: Firebase is not properly configured. Please run: flutterfire configure');
        print('Current API Key: ${options.apiKey}');
        throw Exception(
          'Firebase is not properly configured. Please run: flutterfire configure\n'
          'The firebase_options.dart file contains placeholder values that need to be replaced with your actual Firebase credentials.'
        );
      }

      // Initialize Firebase
      await Firebase.initializeApp(
        options: options,
      );

      // Assign instances
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;

      _isInitialized = true;
      print('Firebase initialized successfully');
    } catch (e) {
      _isInitialized = false;
      print('Firebase initialization failed: $e');
      // Re-throw if it's a configuration error
      if (e.toString().contains('not properly configured')) {
        rethrow;
      }
      // For other errors, log but don't crash the app
      print('Warning: Firebase initialization failed, but app will continue. Some features may not work.');
    }
  }
}
