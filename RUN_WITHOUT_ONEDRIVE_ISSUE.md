# Running StudyVerse Without OneDrive Issues

## Current Status
Your app is trying to launch but getting stuck because OneDrive is locking the `build` folder.

## Quick Solutions

### Solution 1: Run with Release Mode (Bypasses Some Build Issues)
```bash
flutter run -d chrome --release
```

### Solution 2: Use Flutter Web Server Directly
```bash
# Build for web first
flutter build web

# Then serve it
cd build/web
python -m http.server 8080
# Or if you have Node.js:
npx http-server -p 8080
```

### Solution 3: Move Project Outside OneDrive (Best Long-term)

**Step 1: Create a new location**
```powershell
# Create Dev folder
New-Item -ItemType Directory -Force -Path C:\Dev
```

**Step 2: Copy project (not move, to keep original safe)**
```powershell
Copy-Item -Path "C:\Users\nunus\OneDrive\Desktop\Study-verse" -Destination "C:\Dev\Study-verse" -Recurse
```

**Step 3: Work from new location**
```powershell
cd C:\Dev\Study-verse
flutter clean
flutter pub get
flutter run -d chrome
```

### Solution 4: Exclude Build Folder from OneDrive

1. Open File Explorer
2. Navigate to `C:\Users\nunus\OneDrive\Desktop\Study-verse`
3. Right-click the `build` folder
4. Select **"Always keep on this device"** (prevents OneDrive from syncing it)
5. Try running again:
```bash
flutter run -d chrome
```

### Solution 5: Pause OneDrive Temporarily

1. Right-click OneDrive icon in system tray (bottom right)
2. Click **Settings** → **Pause syncing** → **2 hours**
3. Run:
```bash
flutter clean
flutter run -d chrome
```

## Check if App Actually Opened

Even with the error, Chrome might have opened. Check:
- Look for a Chrome window with "StudyVerse" or "localhost"
- Check the URL bar - it should show something like `http://localhost:xxxxx`

## If Chrome Opened Successfully

If Chrome opened and shows your app, the error is just a warning and you can ignore it! The app should work fine.

## Recommended Action

**I recommend Solution 3** (moving project outside OneDrive) because:
- ✅ No more OneDrive sync conflicts
- ✅ Faster builds (no sync overhead)
- ✅ Better for development
- ✅ Prevents future issues

You can keep your original in OneDrive as backup and work from `C:\Dev\Study-verse`.

