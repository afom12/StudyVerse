# Web Platform Troubleshooting Guide

## Common Issues and Solutions

### Issue 1: "Device found but not supported"

**Solution**: Web support needs to be enabled. Run:
```bash
flutter create --platforms=web .
```

### Issue 2: Firebase Not Initialized Error

**Solution**: For web development without Firebase setup, the app will continue but Firebase features won't work. To fully set up Firebase:

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase:
```bash
flutterfire configure
```

3. Select your Firebase project and enable web platform

### Issue 3: Hive Initialization Error on Web

**Solution**: Hive is automatically skipped on web. The app uses conditional initialization.

### Issue 4: Package Compatibility Issues

Some packages may have web compatibility issues:

1. **file_picker**: Works on web but may show warnings (safe to ignore)
2. **syncfusion_flutter_pdfviewer**: Should work on web
3. **hive_flutter**: Automatically skipped on web

### Issue 5: Running on Edge/Chrome

**To run on Chrome:**
```bash
flutter run -d chrome
```

**To run on Edge:**
```bash
flutter run -d edge
```

**To run on Windows Desktop:**
```bash
flutter run -d windows
```

### Issue 6: Build Errors

If you encounter build errors:

1. Clean the project:
```bash
flutter clean
```

2. Get dependencies:
```bash
flutter pub get
```

3. Try running again:
```bash
flutter run -d chrome
```

### Issue 7: Firebase Web Configuration

For web, Firebase can be initialized in two ways:

**Option 1: Using FlutterFire (Recommended)**
- Run `flutterfire configure`
- Select web platform
- Firebase will be auto-configured

**Option 2: Manual Configuration**
- Add Firebase config to `web/index.html`
- Update `lib/firebase_options.dart` with web config

### Testing Without Firebase

The app is designed to run without Firebase for initial testing. You'll see:
- UI screens working
- Navigation working
- Firebase features disabled (auth, database, etc.)

To test Firebase features, complete the Firebase setup first.

## Quick Start for Web

1. **Enable web support** (if not done):
```bash
flutter create --platforms=web .
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Run on Chrome**:
```bash
flutter run -d chrome
```

4. **Or run on Edge**:
```bash
flutter run -d edge
```

## Platform-Specific Notes

### Web Limitations:
- Some native features won't work (camera, file system access)
- Hive is skipped (use SharedPreferences or IndexedDB for web)
- Firebase Messaging has limited web support

### Recommended Development Flow:
1. Start with web for quick UI testing
2. Test on mobile (Android/iOS) for full feature testing
3. Use Firebase for production features

## Getting Help

If you encounter specific errors:

1. Check the error message carefully
2. Run `flutter doctor -v` for detailed diagnostics
3. Check package documentation for web compatibility
4. Review Firebase setup documentation

## Next Steps

Once the app runs on web:
1. Test UI navigation
2. Set up Firebase for full functionality
3. Test on mobile devices for complete feature set

