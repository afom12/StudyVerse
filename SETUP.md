# StudyVerse Setup Guide

## Prerequisites

1. **Flutter SDK**: Install Flutter SDK (3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Firebase Account**: Create a Firebase project
   - Go to: https://console.firebase.google.com/
   - Create a new project

3. **Development Tools**:
   - Android Studio / VS Code with Flutter extensions
   - Xcode (for iOS development on Mac)

## Installation Steps

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Firebase Setup

#### Android Setup:
1. Go to Firebase Console → Project Settings
2. Add Android app with package name: `com.studyverse.app` (or your preferred package name)
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`
5. Update `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
6. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### iOS Setup:
1. Go to Firebase Console → Project Settings
2. Add iOS app with bundle ID
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`
5. Open `ios/Runner.xcworkspace` in Xcode
6. Add the file to the Runner target

#### Enable Authentication:
1. Firebase Console → Authentication → Sign-in method
2. Enable Email/Password
3. Enable Google Sign-In
4. Add your OAuth client IDs

#### Firestore Setup:
1. Firebase Console → Firestore Database
2. Create database in test mode (for development)
3. Set up security rules (see `firestore.rules` example below)

### 3. Configure Firebase Options

Create `lib/firebase_options.dart` using FlutterFire CLI:

```bash
flutterfire configure
```

Or manually create the file based on your Firebase project settings.

### 4. Run the App

```bash
flutter run
```

## Firestore Security Rules (Example)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Courses
    match /courses/{courseId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      request.resource.data.ownerId == request.auth.uid;
    }
    
    // Notes
    match /notes/{noteId} {
      allow read, write: if request.auth != null && 
                            request.resource.data.ownerId == request.auth.uid;
    }
    
    // Flashcard Decks
    match /flashcardDecks/{deckId} {
      allow read, write: if request.auth != null && 
                            request.resource.data.ownerId == request.auth.uid;
    }
    
    // Flashcards
    match /flashcards/{cardId} {
      allow read, write: if request.auth != null;
    }
    
    // Study Groups
    match /studyGroups/{groupId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      (request.resource.data.createdBy == request.auth.uid ||
                       request.auth.uid in request.resource.data.members);
    }
    
    // Group Messages
    match /groupMessages/{messageId} {
      allow read, write: if request.auth != null;
    }
    
    // PDFs
    match /pdfs/{pdfId} {
      allow read, write: if request.auth != null;
    }
    
    // Tasks
    match /tasks/{taskId} {
      allow read, write: if request.auth != null && 
                            request.resource.data.ownerId == request.auth.uid;
    }
  }
}
```

## Firebase Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /pdfs/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /notes/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Project Structure

```
lib/
├── core/
│   ├── models/          # Data models
│   ├── services/        # Core services (SRS, etc.)
│   ├── theme/           # App theme
│   ├── utils/           # Utilities
│   └── widgets/         # Reusable widgets
├── features/
│   ├── auth/            # Authentication
│   ├── dashboard/       # Dashboard
│   ├── courses/         # Courses management
│   ├── notes/           # Notes feature
│   ├── flashcards/      # Flashcards & SRS
│   ├── groups/          # Study groups
│   ├── planner/         # Planner & Pomodoro
│   └── pdf/             # PDF viewer
├── routes/              # App routing
├── services/            # Firebase services
└── main.dart            # App entry point
```

## Next Steps

1. **Implement Data Repositories**: Connect screens to Firestore
2. **Add Offline Support**: Implement Hive caching
3. **Complete Features**: Fill in TODO comments in screens
4. **Add Tests**: Unit and widget tests
5. **Polish UI**: Add animations and improve UX

## Troubleshooting

### Common Issues:

1. **Package errors**: Run `flutter clean` then `flutter pub get`
2. **Firebase not initialized**: Check `firebase_options.dart` exists
3. **Build errors**: Ensure Android/iOS setup is complete
4. **Google Sign-In fails**: Verify OAuth client IDs are configured

## Development Tips

- Use `flutter run --debug` for hot reload
- Check Firebase Console for data
- Use Flutter DevTools for debugging
- Test on both Android and iOS devices/emulators

