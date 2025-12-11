# Firebase Setup Guide for StudyVerse

## Current Status
✅ App runs without Firebase (UI works, auth features disabled)
⚠️ To enable authentication and data features, set up Firebase

## Quick Setup (5 minutes)

### Step 1: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Step 2: Login to Firebase
```bash
firebase login
```

### Step 3: Configure Firebase for Your Project
```bash
flutterfire configure
```

**When prompted:**
1. Select your Firebase project (or create a new one)
2. Select platforms: **web**, **android**, **ios** (select at least web)
3. The tool will generate `lib/firebase_options.dart` automatically

### Step 4: Enable Authentication Methods

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Authentication** → **Sign-in method**
4. Enable:
   - ✅ **Email/Password**
   - ✅ **Google** (add your OAuth client IDs)

### Step 5: Set Up Firestore Database

1. In Firebase Console → **Firestore Database**
2. Click **Create database**
3. Start in **test mode** (for development)
4. Choose a location (closest to your users)

### Step 6: Run the App Again
```bash
flutter run -d chrome
```

Now authentication will work! 🎉

## What Works Without Firebase

- ✅ All UI screens
- ✅ Navigation
- ✅ Theme (light/dark mode)
- ✅ App structure

## What Needs Firebase

- ❌ User authentication (sign up/login)
- ❌ Data storage (notes, flashcards, etc.)
- ❌ Cloud sync
- ❌ Study groups

## Firestore Security Rules (After Setup)

Add these rules in Firebase Console → Firestore → Rules:

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
    
    // Study Groups
    match /studyGroups/{groupId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      (request.resource.data.createdBy == request.auth.uid ||
                       request.auth.uid in request.resource.data.members);
    }
  }
}
```

## Troubleshooting

### Error: "No Firebase App '[DEFAULT]' has been created"
- Run `flutterfire configure` to generate `firebase_options.dart`
- Make sure the file exists in `lib/firebase_options.dart`

### Error: "Firebase not configured"
- This is normal if you haven't run `flutterfire configure` yet
- The app will still run, just without Firebase features

### Google Sign-In Not Working
- Make sure you've enabled Google sign-in in Firebase Console
- Add OAuth client IDs for web platform

## Next Steps

1. Set up Firebase using the steps above
2. Test authentication (sign up/login)
3. Test creating notes and flashcards
4. Set up Firestore security rules for production

