# Fix OneDrive Build Directory Lock Issue

## The Problem
Your project is in OneDrive (`C:\Users\nunus\OneDrive\Desktop\Study-verse`), and OneDrive is syncing/locking the `build` folder, preventing Flutter from cleaning it.

## ✅ Quick Fix (Choose One)

### Option 1: Exclude build folder from OneDrive Sync (Easiest)

1. Open File Explorer
2. Navigate to `C:\Users\nunus\OneDrive\Desktop\Study-verse`
3. Right-click on the `build` folder
4. Select **"Always keep on this device"** (this prevents OneDrive from syncing it)
5. Try `flutter clean` again

### Option 2: Move Project Outside OneDrive (Best Long-term)

**Recommended location:** `C:\Dev\` or `C:\Projects\`

```powershell
# Create Dev folder if it doesn't exist
New-Item -ItemType Directory -Force -Path C:\Dev

# Copy project (not move, to be safe)
Copy-Item -Path "C:\Users\nunus\OneDrive\Desktop\Study-verse" -Destination "C:\Dev\Study-verse" -Recurse

# Then work from C:\Dev\Study-verse
cd C:\Dev\Study-verse
flutter clean
flutter pub get
flutter run -d chrome
```

### Option 3: Pause OneDrive Temporarily

1. Right-click OneDrive icon in system tray (bottom right)
2. Click **Settings** → **Pause syncing** → **2 hours**
3. Run:
   ```bash
   flutter clean
   flutter run -d chrome
   ```
4. Re-enable OneDrive when done

### Option 4: Add .gitignore-style exclusion

Create a file `build/.onedriveignore` (if OneDrive supports it) or configure OneDrive to exclude the build folder.

## Why This Happens

OneDrive syncs files in real-time. When Flutter tries to delete/modify files in the `build` folder, OneDrive may have them locked for syncing, causing permission errors.

## ✅ What I Fixed

1. ✅ Created missing `assets/images/` directory
2. ✅ Created missing `assets/animations/` directory  
3. ✅ Fixed `pubspec.yaml` asset references

## Next Steps

1. **Try running the app anyway** - Sometimes Flutter works even if `clean` fails:
   ```bash
   flutter run -d chrome
   ```

2. **If it still fails**, use Option 1 or 2 above to fix the OneDrive issue.

3. **For future projects**: Keep Flutter projects outside OneDrive or exclude `build/` folders from sync.

## Test After Fix

Once you've applied a fix:
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

The app should launch in Chrome! 🎉

