import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage (skip on web)
  if (!kIsWeb) {
    try {
      await Hive.initFlutter();
    } catch (e) {
      print('Hive initialization error: $e');
    }
  }
  
  // Initialize Firebase
  try {
    await FirebaseService.initialize();
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue even if Firebase fails for now (for testing without Firebase setup)
  }
  
  runApp(
    const ProviderScope(
      child: StudyVerseApp(),
    ),
  );
}

class StudyVerseApp extends StatelessWidget {
  const StudyVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'StudyVerse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}

