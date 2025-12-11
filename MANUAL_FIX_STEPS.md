# Manual Fix for OneDrive Build Lock Issue

## The Problem
OneDrive is syncing/locking your `build` folder, preventing Flutter from running properly.

## ✅ SOLUTION: Exclude Build Folder from OneDrive (5 minutes)

### Step 1: Pause OneDrive Sync
1. Look for the **OneDrive icon** in your system tray (bottom right, near the clock)
2. **Right-click** on it
3. Click **"Pause syncing"** → Select **"2 hours"**

### Step 2: Close All Browsers
- Close Chrome/Edge completely (check Task Manager if needed)
- Close any Flutter processes

### Step 3: Delete Build Folder Manually
1. Open File Explorer
2. Navigate to: `C:\Users\nunus\OneDrive\Desktop\Study-verse`
3. **Right-click** on the `build` folder
4. Select **"Delete"** (or press Delete key)
5. If it says "File in use", restart your computer and try again

### Step 4: Exclude Build Folder from OneDrive
1. **Right-click** on the `build` folder (or create it if deleted)
2. Select **"OneDrive"** → **"Always keep on this device"**
   - OR go to OneDrive Settings → Sync → Advanced → Exclude folders
   - Add `build` folder to exclusion list

### Step 5: Run Flutter
```powershell
flutter clean
flutter pub get
flutter run -d chrome
```

## Alternative: Move Project Outside OneDrive (Best Solution)

### Quick Move (Recommended)
```powershell
# 1. Create Dev folder
New-Item -ItemType Directory -Force -Path C:\Dev

# 2. Copy project (keeps original as backup)
Copy-Item -Path "C:\Users\nunus\OneDrive\Desktop\Study-verse" -Destination "C:\Dev\Study-verse" -Recurse

# 3. Work from new location
cd C:\Dev\Study-verse
flutter clean
flutter pub get
flutter run -d chrome
```

**Benefits:**
- ✅ No more OneDrive conflicts
- ✅ Faster builds
- ✅ Better for development
- ✅ Original stays in OneDrive as backup

## If Still Not Working

### Option A: Use Release Mode
```bash
flutter build web --release
cd build/web
# Then open index.html in browser, or use a local server
```

### Option B: Use Different Port
```bash
flutter run -d chrome --web-port=8080 --web-hostname=localhost
```

### Option C: Check Task Manager
1. Press `Ctrl + Shift + Esc`
2. End any `dart.exe`, `flutter.exe`, or browser processes
3. Try again

## Why This Happens
OneDrive syncs files in real-time. When Flutter tries to modify files in `build`, OneDrive may have them locked for syncing, causing permission errors.

## Prevention
- **Always** exclude `build/` folders from OneDrive sync
- Keep Flutter projects outside OneDrive for development
- Use OneDrive only for final backups, not active development

