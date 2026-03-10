# Step 1: Clean Flutter build
flutter clean

# Step 2: Get Flutter packages
flutter pub get

# Step 3: Extract version from pubspec.yaml
$pubspec = Get-Content pubspec.yaml
$versionLine = $pubspec | Select-String -Pattern '^version: '
$version = $versionLine -replace 'version: ', ''

# Step 4: Detect environment from main.dart
$mainFile = Get-Content .\lib\main.dart

$isLive = $mainFile | Select-String -Pattern 'bool isLive\s*=\s*true'
$isDev  = $mainFile | Select-String -Pattern 'bool isDev\s*=\s*true'

if ($isLive) {
    $envName = "Live"
} elseif ($isDev) {
    $envName = "Dev"
} else {
    $envName = "Local"
}

# Step 5: Build APK release
flutter build apk --release

# Step 6: Define output paths
$apkSource = "build\app\outputs\flutter-apk\app-release.apk"
$apkName = "Panamera-$version($envName).apk"
$outputDir = "C:\Users\$env:USERNAME\OneDrive\Desktop\Panamera Builds"

# Step 7: Ensure APK was built
if (!(Test-Path $apkSource)) {
    Write-Host "❌ APK build failed or path not found!"
    exit 1
}

# Step 8: Move the APK to Desktop and rename
$apkDestination = Join-Path $outputDir $apkName
Move-Item -Path $apkSource -Destination $apkDestination -Force

Write-Host "✅ APK built and moved to Desktop: $apkDestination"

# Run the script in PowerShell using below command at the root of the Flutter project
# .\build_apk_release.ps1
