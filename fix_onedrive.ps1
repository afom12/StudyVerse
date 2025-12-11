# PowerShell script to fix OneDrive build folder lock issue
# Run this script as Administrator if needed

Write-Host "Fixing OneDrive build folder lock..." -ForegroundColor Yellow

# Step 1: Stop OneDrive sync temporarily
Write-Host "`nStep 1: Stopping OneDrive sync..." -ForegroundColor Cyan
$onedriveProcess = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue
if ($onedriveProcess) {
    Write-Host "OneDrive is running. Please pause syncing manually:" -ForegroundColor Yellow
    Write-Host "1. Right-click OneDrive icon in system tray" -ForegroundColor White
    Write-Host "2. Select 'Pause syncing' -> '2 hours'" -ForegroundColor White
    Write-Host "3. Press Enter when done..." -ForegroundColor White
    Read-Host
}

# Step 2: Remove read-only attributes from build folder
Write-Host "`nStep 2: Removing read-only attributes..." -ForegroundColor Cyan
if (Test-Path "build") {
    Get-ChildItem -Path "build" -Recurse -Force | ForEach-Object {
        $_.Attributes = 'Normal'
    }
    Write-Host "✓ Attributes removed" -ForegroundColor Green
} else {
    Write-Host "Build folder doesn't exist yet" -ForegroundColor Gray
}

# Step 3: Try to delete build folder
Write-Host "`nStep 3: Attempting to clean build folder..." -ForegroundColor Cyan
try {
    if (Test-Path "build") {
        Remove-Item -Path "build" -Recurse -Force -ErrorAction Stop
        Write-Host "✓ Build folder deleted successfully" -ForegroundColor Green
    } else {
        Write-Host "Build folder already deleted" -ForegroundColor Gray
    }
} catch {
    Write-Host "Could not delete build folder: $_" -ForegroundColor Red
    Write-Host "`nManual fix required:" -ForegroundColor Yellow
    Write-Host "1. Close all Flutter/Chrome/Edge processes" -ForegroundColor White
    Write-Host "2. Pause OneDrive syncing" -ForegroundColor White
    Write-Host "3. Manually delete the build folder" -ForegroundColor White
    Write-Host "4. Run: flutter clean" -ForegroundColor White
}

# Step 4: Create .gitignore for build folder
Write-Host "`nStep 4: Creating .gitignore entry..." -ForegroundColor Cyan
if (Test-Path ".gitignore") {
    $gitignoreContent = Get-Content ".gitignore" -Raw
    if ($gitignoreContent -notmatch "build/") {
        Add-Content -Path ".gitignore" -Value "`n# Build folder`nbuild/`n"
        Write-Host "✓ Added build/ to .gitignore" -ForegroundColor Green
    } else {
        Write-Host "build/ already in .gitignore" -ForegroundColor Gray
    }
}

Write-Host "`nDone! Now try running:" -ForegroundColor Green
Write-Host "flutter clean" -ForegroundColor Cyan
Write-Host "flutter pub get" -ForegroundColor Cyan
Write-Host "flutter run -d chrome" -ForegroundColor Cyan

