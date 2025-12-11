# Fixing Build Directory Permission Issues

## Problem
You're seeing errors like:
```
Flutter failed to delete a directory at "build". The flutter tool cannot access the file or directory.
```

This is typically caused by **OneDrive sync** locking files in the build directory.

## Solutions

### Solution 1: Exclude build directory from OneDrive (Recommended)

1. Right-click on the `build` folder
2. Select "OneDrive" → "Always keep on this device" or "Free up space"
3. Or exclude the entire project folder from OneDrive sync

### Solution 2: Move Project Outside OneDrive

Move your project to a location NOT synced by OneDrive:
```powershell
# Example: Move to C:\Dev\Study-verse
Move-Item -Path "C:\Users\nunus\OneDrive\Desktop\Study-verse" -Destination "C:\Dev\Study-verse"
```

### Solution 3: Close OneDrive Temporarily

1. Right-click OneDrive icon in system tray
2. Select "Pause syncing" → "2 hours"
3. Run `flutter clean` and `flutter run`
4. Re-enable OneDrive when done

### Solution 4: Manual Build Cleanup

If files are locked, try:
```powershell
# Stop any running Flutter processes
taskkill /F /IM dart.exe
taskkill /F /IM flutter.exe

# Then try cleaning
flutter clean
```

## Quick Fix Applied

✅ Created missing asset directories (`assets/images/` and `assets/animations/`)
✅ Fixed pubspec.yaml asset references

## Next Steps

1. Try running again:
```bash
flutter run -d chrome
```

2. If you still get build directory errors, use Solution 1 or 2 above.

3. The `file_picker` warnings are safe to ignore - they're just informational.

