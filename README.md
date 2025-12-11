# StudyVerse 📚

<div align="center">

![StudyVerse Logo](https://img.shields.io/badge/StudyVerse-Learning%20Hub-blue?style=for-the-badge)

**A comprehensive, mobile-first collaborative learning platform designed to help students organize, study, and excel.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Features](#-features) • [Getting Started](#-getting-started) • [Tech Stack](#-tech-stack) • [Project Structure](#-project-structure) • [Contributing](#-contributing)

</div>

---

## ✨ Features

### 📝 Rich Text Notes
- **Beautiful Editor**: Powered by Flutter Quill for a seamless writing experience
- **Course Organization**: Organize notes by course for easy access
- **Rich Formatting**: Bold, italic, lists, headings, and more
- **Auto-save**: Never lose your work with automatic saving
- **Offline Support**: Access and edit notes even without internet
- **Unsaved Changes Warning**: Get notified before leaving with unsaved changes

### 🎴 Smart Flashcards
- **Spaced Repetition System (SRS)**: SM-2 algorithm for optimal learning retention
- **Deck Management**: Create and organize flashcard decks by course
- **Review System**: Track your progress with quality ratings (Again, Hard, Good, Easy)
- **Due Cards Tracking**: See how many cards are due for review on your dashboard
- **Progress Indicators**: Visual feedback on your learning journey
- **Smart Scheduling**: Automatically calculates next review dates based on performance

### 📄 PDF Study Center
- **PDF Upload**: Upload and store PDF documents from your device
- **PDF Viewer**: Built-in viewer powered by Syncfusion with smooth scrolling
- **Course Organization**: Attach PDFs to specific courses for better organization
- **Cloud Storage**: Secure storage with Firebase Storage
- **Offline Access**: Download PDFs for offline viewing
- **File Management**: Easy upload, view, and delete functionality

### 👥 Study Groups
- **Group Creation**: Create study groups with unique invite codes
- **Real-time Messaging**: Chat with group members instantly
- **Member Management**: See who's in your group and manage members
- **Collaborative Learning**: Share notes and flashcards with groups
- **Offline Messages**: Messages cached locally for offline access
- **Group Details**: View group information, members, and shared files

### 📅 Study Planner
- **Task Management**: Create, edit, and organize tasks with ease
- **Priority Levels**: Set low, medium, or high priority for better organization
- **Due Date Tracking**: Never miss a deadline with due date reminders
- **Today's Overview**: Quick view of today's tasks on the dashboard
- **Completion Tracking**: Mark tasks as done and track your progress
- **Course Integration**: Link tasks to specific courses

### ⏱️ Pomodoro Timer
- **Focus Sessions**: 25-minute focused study sessions
- **Break Management**: Short breaks (5 min) and long breaks (15 min)
- **Session Tracking**: Track completed pomodoros
- **Visual Feedback**: Beautiful UI with state indicators (running, paused, break)
- **Play/Pause/Reset**: Full control over your timer
- **Session History**: View your completed pomodoro sessions

### 🔍 Universal Search
- **Cross-Content Search**: Search across notes, courses, flashcards, tasks, and PDFs
- **Category Filters**: Filter by content type (All, Notes, Courses, Flashcards, Tasks, PDFs)
- **Quick Access**: Jump directly to search results with one tap
- **Real-time Results**: Instant search as you type
- **Smart Matching**: Searches titles, descriptions, and content

### ⚙️ Settings & Customization
- **Profile Management**: View and manage your profile information
- **Theme Support**: Choose between Light, Dark, or System Default theme
- **Sync Status**: Check cloud sync status and connectivity
- **Data Management**: Export data and clear local cache
- **Privacy Controls**: Manage your data and privacy settings
- **Sign Out**: Secure sign out functionality

### ☁️ Cloud Sync & Offline Support
- **Offline-First Architecture**: Works seamlessly offline
- **Automatic Sync**: Syncs when online automatically
- **Local Caching**: Hive for fast local storage
- **Real-time Updates**: Live updates across devices
- **Conflict Resolution**: Smart merging of changes
- **Data Persistence**: Your data is safe even when offline

### 🎨 Modern UI/UX
- **Material Design 3**: Beautiful, modern interface
- **Smooth Animations**: Polished transitions and animations
- **Responsive Design**: Works great on all screen sizes
- **Onboarding Experience**: Interactive onboarding for new users
- **Google Fonts**: Beautiful typography throughout the app
- **Color-Coded Features**: Intuitive color coding for different features

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (3.0.0 or higher)
- **Dart SDK** (3.0.0 or higher)
- **Firebase account** (for cloud features)
- **Android Studio / Xcode** (for mobile development)
- **VS Code / Android Studio** (recommended IDE)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/studyverse.git
   cd studyverse
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   
   a. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   
   b. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
   
   c. Configure Firebase:
   ```bash
   flutterfire configure
   ```
   
   d. Follow the prompts to select your Firebase project and platforms (Android, iOS, Web)

4. **Configure Firebase Services**
   
   - **Enable Authentication**:
     - Go to Firebase Console → Authentication
     - Enable Email/Password and Google Sign-In providers
   
   - **Create Firestore Database**:
     - Go to Firebase Console → Firestore Database
     - Create database in production mode (or test mode for development)
     - Set up security rules (see below)
   
   - **Set up Storage**:
     - Go to Firebase Console → Storage
     - Create storage bucket
     - Set up security rules (see below)

5. **Run the app**
   ```bash
   flutter run
   ```

### Firebase Security Rules

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Notes collection
    match /notes/{noteId} {
      allow read, write: if request.auth != null && 
        resource.data.ownerId == request.auth.uid;
    }
    
    // Courses collection
    match /courses/{courseId} {
      allow read, write: if request.auth != null && 
        resource.data.ownerId == request.auth.uid;
    }
    
    // Flashcard decks
    match /flashcardDecks/{deckId} {
      allow read, write: if request.auth != null && 
        resource.data.ownerId == request.auth.uid;
    }
    
    // Flashcards
    match /flashcards/{cardId} {
      allow read, write: if request.auth != null;
    }
    
    // Tasks
    match /tasks/{taskId} {
      allow read, write: if request.auth != null && 
        resource.data.ownerId == request.auth.uid;
    }
    
    // PDFs
    match /pdfs/{pdfId} {
      allow read, write: if request.auth != null && 
        resource.data.ownerId == request.auth.uid;
    }
    
    // Study Groups
    match /groups/{groupId} {
      allow read: if request.auth != null && 
        request.auth.uid in resource.data.memberIds;
      allow write: if request.auth != null && 
        request.auth.uid in resource.data.memberIds;
    }
    
    // Group Messages
    match /groups/{groupId}/messages/{messageId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /pdfs/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🛠️ Tech Stack

### Frontend
- **Flutter**: Cross-platform UI framework
- **Riverpod**: State management (providers, streams, futures)
- **GoRouter**: Declarative navigation and routing
- **Material Design 3**: Modern UI components

### Backend & Services
- **Firebase Authentication**: User authentication (Email/Password, Google Sign-In)
- **Cloud Firestore**: NoSQL database for real-time data
- **Firebase Storage**: File storage for PDFs
- **Hive**: Local NoSQL database for offline caching

### Key Packages
- `flutter_quill`: Rich text editor for notes
- `syncfusion_flutter_pdfviewer`: PDF viewing capabilities
- `file_picker`: File selection for PDF uploads
- `google_fonts`: Custom typography
- `hive_flutter`: Local storage and caching
- `shared_preferences`: Theme and settings persistence
- `uuid`: Unique ID generation
- `intl`: Internationalization and date formatting

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── models/          # Data models (Note, Course, Flashcard, Task, PDF, Group)
│   ├── theme/           # App theme and styling (AppTheme)
│   ├── utils/           # Utility functions
│   └── widgets/         # Reusable widgets
│
├── features/
│   ├── auth/            # Authentication (providers, repositories)
│   ├── dashboard/       # Dashboard screen with overview
│   ├── notes/           # Notes feature (CRUD, rich text editor)
│   ├── flashcards/      # Flashcards feature (decks, SRS review)
│   ├── pdf/             # PDF feature (upload, view)
│   ├── groups/          # Study groups (creation, messaging)
│   ├── planner/         # Task planner & Pomodoro timer
│   ├── courses/         # Course management
│   ├── search/          # Universal search functionality
│   ├── settings/        # Settings screen (theme, profile, cache)
│   └── onboarding/      # Onboarding experience
│
├── services/
│   └── firebase_service.dart  # Firebase initialization and access
│
├── routes/
│   └── app_router.dart  # Navigation configuration (GoRouter)
│
└── main.dart           # App entry point
```

<<<<<<< HEAD
### Architecture

The app follows a **feature-based architecture** with clear separation of concerns:
=======
>>>>>>> ea3345300d2ca921ed07c1dd8fb2a3a60631c042

- **Data Layer**: Repositories handle data access (local + cloud)
  - Each feature has its own repository (e.g., `NoteRepository`, `TaskRepository`)
  - Repositories manage both Hive (local) and Firestore (cloud) operations
  - Automatic sync when online

- **Domain Layer**: Business logic and models
  - Models define data structures (`NoteModel`, `TaskModel`, etc.)
  - Services for business logic (e.g., `SRSService` for spaced repetition)

- **Presentation Layer**: UI components and state management (Riverpod)
  - Providers for state management
  - Screens for UI
  - Widgets for reusable components

---

## 🎯 Key Features Implementation

### Offline-First Architecture
- All data is cached locally using Hive
- Changes sync to Firestore when online
- Works seamlessly offline
- Automatic conflict resolution

### Spaced Repetition System
- Implements SM-2 algorithm
- Tracks review intervals and ease factors
- Calculates next review dates automatically
- Quality ratings affect scheduling

### Real-time Synchronization
- Stream providers for live updates
- Automatic conflict resolution
- Efficient data synchronization
- Background sync when online

---

## 📱 Screenshots

<div align="center">

<table>
<tr>
  <th>Onboarding</th>
  <th>Onboarding</th>
  <th>Onboarding</th>
  <th>Onboarding</th>
</tr>
<tr>
  <td><img src="https://github.com/user-attachments/assets/7b946e8c-7a18-46de-8843-0b1b6d34258d" width="220" /></td>
  <td><img src="https://github.com/user-attachments/assets/87a7540e-931e-4d8f-bf3b-706ccc62222a" width="220" /></td>
  <td><img src="https://github.com/user-attachments/assets/a227c019-4156-46f5-bbdd-92a16951c506" width="220" /></td>
  <td><img src="https://github.com/user-attachments/assets/ac57ae88-66d4-4bf1-8684-ff3018960d25" width="220" /></td>
</tr>
</table>

<br/>

<table>
<tr>
  <th>Dashboard</th>
  <th>Dashboard</th>
</tr>
<tr>
  <td><img src="https://github.com/user-attachments/assets/9cbdce4b-f01e-4968-852f-068c98a8eb17" width="300" /></td>
  <td><img src="https://github.com/user-attachments/assets/4d07e64e-f5dc-4db6-9fad-1193ce323a09" width="300" /></td>
</tr>
</table>

</div>


---

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

---

## 📝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features
- Ensure all features work offline

### Pull Request Guidelines
- Provide a clear description of changes
- Include screenshots for UI changes
- Ensure all tests pass
- Update documentation if needed

---

## 🗺️ Roadmap

### Phase 1 ✅ (Completed)
- [x] Dashboard with Today Overview
- [x] Rich Text Notes with course organization
- [x] Flashcard deck CRUD and SRS review
- [x] PDF upload/view/highlight
- [x] Study Groups with messaging
- [x] Task Planner with Pomodoro timer
- [x] Cloud sync + offline cache
- [x] Universal search
- [x] Settings screen with theme switching
- [x] Interactive onboarding

### Phase 2 🚧 (In Progress)
- [ ] Spaced repetition tuning & analytics
- [ ] Convert notes → flashcards
- [ ] Search across notes & PDFs content (full-text search)
- [ ] Share notes/flashcards to groups
- [ ] Better PDF annotation tools
- [ ] Enhanced theming & customization
- [ ] Export data functionality
- [ ] Notification system

### Phase 3 🔮 (Future)
- [ ] AI features (summaries, auto-flashcards)
- [ ] Real-time collaborative editing
- [ ] Voice-notes → transcription
- [ ] Leaderboards & gamification
- [ ] Premium features & subscription
- [ ] Mobile apps (iOS & Android)
- [ ] Desktop support (Windows, macOS, Linux)

---

## 🐛 Known Issues

- PDF highlighting is basic (Phase 2 enhancement planned)
- Full-text search in PDFs not yet implemented
- Export data feature coming in Phase 2

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for backend services
- All open-source contributors and package maintainers
- The study community for inspiration

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/studyverse/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/studyverse/discussions)
- **Email**: support@studyverse.app

---

## 🌟 Show Your Support

If you find this project helpful, please consider:

- ⭐ Starring this repository
- 🐛 Reporting bugs
- 💡 Suggesting new features
- 🔄 Contributing code
- 📢 Sharing with others

---

<div align="center">

**Made with ❤️ for students everywhere**

⭐ Star this repo if you find it helpful!

[⬆ Back to Top](#studyverse-)

</div>
