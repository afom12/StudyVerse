# Configure Firebase for Study-verse Project

## Step-by-Step Guide

### Method 1: Using FlutterFire CLI (Interactive)

1. **Run the configuration command:**
   ```bash
   flutterfire configure
   ```

2. **You'll see a menu like this:**
   ```
   ? Select a Firebase project:
   > Study-verse
     [Other projects if you have them]
   ```

3. **Use arrow keys to select "Study-verse" and press Enter**

4. **Select platforms (use Space to select, Enter to confirm):**
   ```
   ? Which platforms should be configured?
   > [✓] web
     [✓] android  
     [ ] ios
   ```
   - At minimum, select **web** (required for Chrome/Edge)
   - Select **android** if you plan to build Android app
   - Select **ios** if you plan to build iOS app

5. **The tool will automatically:**
   - Generate `lib/firebase_options.dart`
   - Configure your project
   - Set up platform-specific configs

### Method 2: Manual Configuration (If CLI doesn't work)

If the interactive menu doesn't show your project, you can manually create the config file.

1. **Get your Firebase config from Firebase Console:**
   - Go to https://console.firebase.google.com/
   - Select your "Study-verse" project
   - Go to Project Settings (gear icon)
   - Scroll to "Your apps" section
   - Click on Web app (or create one)
   - Copy the `firebaseConfig` object

2. **Create `lib/firebase_options.dart` manually** (I can help with this)

### After Configuration

Once configured, run:
```bash
flutter run -d chrome
```

Authentication should now work! 🎉

## Troubleshooting

### If "Study-verse" project doesn't appear:
- Make sure you're logged in: `firebase login`
- Check you have access to the project in Firebase Console
- Try refreshing: `firebase projects:list`

### If you get permission errors:
- Make sure you're the owner/admin of the Firebase project
- Or ask the project owner to add you as a collaborator

