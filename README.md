# StudyVerse 📚

A mobile-first collaborative learning hub for students: notes, PDFs, flashcards, study groups, planner, and analytics.

## Features

- 📝 **Rich Text Notes** - Take beautiful notes with formatting, images, and more
- 🎴 **Smart Flashcards** - Spaced repetition system for effective learning
- 📄 **PDF Study Center** - Upload, annotate, and extract flashcards from PDFs
- 👥 **Study Groups** - Collaborate with classmates in real-time
- 📅 **Study Planner** - Organize tasks with Pomodoro timer
- 📊 **Analytics** - Track your learning progress
- ☁️ **Cloud Sync** - Access your data anywhere with offline support

## Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Local Storage**: Hive
- **Rich Editor**: Flutter Quill
- **PDF Viewer**: Syncfusion PDF Viewer

## Getting Started

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Set up Firebase:
   - Create a Firebase project
   - Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update Firebase configuration

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
  core/
    utils/
    widgets/
    theme/
  features/
    auth/
      data/
      domain/
      presentation/
    notes/
    flashcards/
    pdf/
    groups/
    planner/
  services/
  routes/
  main.dart
```

## License

MIT

