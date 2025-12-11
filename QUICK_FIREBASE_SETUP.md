# Quick Firebase Setup - Select "Study-verse" Project

## Run This Command:

```bash
flutterfire configure
```

## What You'll See:

1. **First, it will ask you to select your Firebase project:**
   ```
   ? Select a Firebase project:
   > Study-verse          ← Use arrow keys to select this
     [Other projects...]
   ```
   - Use **↑↓ arrow keys** to navigate
   - Press **Enter** to select "Study-verse"

2. **Then select platforms:**
   ```
   ? Which platforms should be configured? (Press <space> to select, <a> to toggle all, <i> to invert selection)
   > [✓] web              ← Select this (required)
     [ ] android
     [ ] ios
   ```
   - Press **Space** to select/deselect
   - At minimum, select **web** (for Chrome/Edge)
   - Press **Enter** when done

3. **It will automatically generate `lib/firebase_options.dart`**

4. **Done!** Now run:
   ```bash
   flutter run -d chrome
   ```

## If "Study-verse" Doesn't Appear:

1. Make sure you're logged into Firebase:
   - Go to https://console.firebase.google.com/
   - Verify you can see your "Study-verse" project

2. If you need to login via browser:
   - The `flutterfire configure` command will open a browser
   - Login with your Google account
   - Grant permissions
   - Return to terminal

## After Configuration:

✅ Your app will be connected to Firebase
✅ Authentication will work
✅ You can sign up/login
✅ Data will sync to Firestore

## Need Help?

If the interactive menu doesn't work, I can help you create `firebase_options.dart` manually using your Firebase project config.

