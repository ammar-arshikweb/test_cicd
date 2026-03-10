# Panamera Mobile Application

[![Flutter](https://img.shields.io/badge/Flutter-3.7.2+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7.2+-0175C2?logo=dart)](https://dart.dev)
[![Version](https://img.shields.io/badge/version-1.0.18+33-blue)](./pubspec.yaml)

Panamera is a comprehensive cross-platform mobile application built with Flutter for workforce and customer management. The app provides distinct experiences for employees and customers, featuring attendance tracking, AMC (Annual Maintenance Contract) job management, project oversight, real-time notifications, and more. It leverages Firebase for push notifications, supports biometric authentication, and delivers a modern, responsive UI with multi-language support.

---

## 📱 Features

### Core Functionality
- **Dual User Modes**: 
  - **Employee Portal**: Attendance tracking, job management, notifications
  - **Customer Portal**: Project viewing, feedback submission, AMC calendar access
- **Secure Authentication**: 
  - Biometric authentication (Face ID, Touch ID, Fingerprint)
  - Captcha protection (Math-based)
  - Forgot password recovery
  - Guest mode for viewing project images
- **Role-Based Access Control**: Dynamic functionality access based on user permissions

### Employee Features
- **Attendance Management**: 
  - Clock in/out with location tracking
  - Break in/out functionality
  - Overtime requests and approvals
  - Early leave requests
  - Comprehensive attendance history
  - Supervisor dashboard for team management
- **AMC Job Management**: 
  - View and manage assigned jobs
  - Task and sub-task tracking
  - Job detail views with status updates
  - Audio recording capabilities for job notes
- **Notifications**: Real-time push notifications via Firebase Cloud Messaging
- **Home Dashboard**: Overview of attendance, jobs, and quick actions

### Customer Features
- **Project Management**: View assigned projects and project details
- **Feedback System**: Submit and track feedback
- **AMC Calendar**: View scheduled maintenance activities
- **Guest Access**: Browse project galleries without authentication

### Technical Features
- **Localization**: Multi-language support (English, Swedish) with easy extensibility
- **Modern UI/UX**: 
  - Responsive design adapting to all screen sizes
  - Lottie animations for loading states and empty views
  - SVG support for scalable icons
  - Custom Inter font family
  - Material Design principles
- **State Management**: Provider pattern for scalable and maintainable state management
- **Offline Support**: 
  - SQLite local database for offline data persistence
  - Automatic sync when connectivity is restored
  - Internet connectivity monitoring
- **Media Handling**:
  - Image picker for photos from camera/gallery
  - Audio recording and playback with waveform visualization
  - Cached network images for optimal performance
- **Location Services**: 
  - GPS tracking for attendance
  - Google Maps integration
  - Geocoding and reverse geocoding
- **App Updates**: In-app update prompts for new versions
- **Platform Support**: Fully optimized for Android and iOS with platform-specific configurations

---

## 🔐 Functionality Access Control

The application implements a robust functionality access control system to manage feature availability per user:

- **Dynamic Feature Access**: After login, the backend provides functionality keys that determine accessible modules
- **Role-Based Permissions**: Different user roles (employee, supervisor, customer) have distinct feature sets
- **Granular Control**: Access to attendance, AMC, projects, notifications, and other modules is controlled individually
- **Backend-Driven**: Functionality keys are managed server-side, enabling access changes without app updates
- **Secure Navigation**: UI elements and routes are dynamically shown/hidden based on user permissions

**How it works:**
1. User authenticates through the login screen
2. Backend returns user details including functionality access keys
3. App provider stores and checks these keys throughout the session
4. Features, navigation items, and screens are conditionally rendered
5. Unauthorized access attempts are blocked at both UI and API levels

---

## 📂 Project Structure

```
lib/
├── features/                    # Feature modules (feature-first architecture)
│   ├── app_update/             # In-app update notifications
│   │   ├── model/              # Update data models
│   │   ├── repo/               # Update repository
│   │   └── view/               # Update dialog UI
│   ├── customer/               # Customer-facing features
│   │   ├── home/               # Customer dashboard
│   │   │   ├── model/          # AMC calendar, projects, tasks models
│   │   │   ├── repository/     # Data layer
│   │   │   ├── view/           # Screens (home, feedback, project details)
│   │   │   └── view_model/     # Business logic
│   │   ├── main_page/          # Customer main navigation
│   │   └── notifications/      # Customer notifications
│   ├── employee/               # Employee-facing features
│   │   ├── amc/                # AMC job management
│   │   ├── attendance/         # Attendance tracking
│   │   ├── home/               # Employee dashboard
│   │   ├── main_page/          # Employee main navigation
│   │   └── notifications/      # Employee notifications
│   ├── login/                  # Authentication
│   │   ├── model/              # Login request/response models
│   │   ├── repository/         # Auth repository
│   │   ├── view/               # Login, forgot password, guest screens
│   │   └── view_model/         # Authentication logic
│   └── splash/                 # Splash screen with initialization
├── comman_widget/              # Reusable UI components
│   ├── audio_player_widget.dart
│   ├── confirmation_dialog.dart
│   ├── custom_date_range_picker.dart
│   ├── custom_dropdown.dart
│   ├── custom_loader.dart
│   └── image_widgets.dart
├── gen/                        # Auto-generated assets (flutter_gen)
│   ├── assets.gen.dart         # Type-safe asset references
│   └── fonts.gen.dart          # Font definitions
├── l10n/                       # Localization files
│   ├── app_en.arb              # English translations
│   ├── app_sv.arb              # Swedish translations
│   └── app_localizations*.dart # Generated localization classes
├── providers/                  # State management
│   ├── app_provider.dart       # Global app state
│   └── provider_list.dart      # Provider configuration
├── repositories/               # Base repository classes
│   └── base_api_model.dart     # Common API response model
├── responsive/                 # Responsive design utilities
│   ├── responsive.dart         # Responsive widget builder
│   └── screen_size_config.dart # Screen dimension calculations
├── services/                   # Core services
│   ├── api_constant.dart       # API endpoints and constants
│   ├── database_constants.dart # SQLite table schemas
│   ├── database_service.dart   # Local database management
│   ├── dio_client.dart         # HTTP client configuration
│   └── network_service.dart    # Connectivity monitoring
├── utils/                      # Utility functions and helpers
│   ├── app_tracking_transparancy.dart
│   ├── constant.dart           # App-wide constants
│   ├── dialog_utils.dart       # Dialog helpers
│   ├── helpers.dart            # Common helper functions
│   ├── log_utils.dart          # Logging utilities
│   ├── net_util.dart           # Network utilities
│   ├── preference.dart         # SharedPreferences wrapper
│   ├── routes.dart             # Navigation routes
│   ├── snackbar_messages.dart  # Toast/snackbar helpers
│   ├── system_ui_manager.dart  # Status bar/navigation bar styling
│   ├── time_utils.dart         # Date/time utilities
│   └── utils.dart              # General utilities
├── values/                     # Design tokens
│   ├── colors.dart             # Color palette
│   ├── key.dart                # Constant keys
│   └── styles.dart             # Text styles and themes
├── app_initializer.dart        # App initialization logic
├── firebase_options.dart       # Firebase configuration
└── main.dart                   # App entry point

assets/
├── animations/                 # Lottie JSON animations
├── images/                     # PNG/JPG images
└── logo/                       # App icons

android/                        # Android-specific configuration
ios/                           # iOS-specific configuration
fonts/                         # Inter font family files
```

### Architecture Highlights
- **Clean Architecture**: Separation of concerns with model-repository-view-viewmodel layers
- **Feature-First Organization**: Code organized by features for better scalability
- **Type-Safe Assets**: Auto-generated asset references prevent runtime errors
- **Modular Services**: Isolated services for database, networking, and platform APIs

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed:

- **Flutter SDK**: Version 3.7.2 or higher
  ```powershell
  flutter --version
  ```
- **Dart SDK**: Version 3.7.2 or higher (comes with Flutter)
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA
- **Platform Tools**:
  - **Android**: Android Studio, Android SDK, Java/Kotlin
  - **iOS**: Xcode (macOS only), CocoaPods
- **Git**: For version control

### Installation

1. **Clone the Repository**
   ```powershell
   git clone <repository-url>
   cd panamera_app
   ```

2. **Install Dependencies**
   ```powershell
   flutter pub get
   ```

3. **Generate Assets**
   ```powershell
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure Firebase**
   - Place `google-services.json` in `android/app/` directory
   - Place `GoogleService-Info.plist` in `ios/Runner/` directory
   - Ensure Firebase is properly configured in both Firebase console and project

5. **Configure Environment**
   - Edit `lib/main.dart` to set environment flags:
     ```dart
     bool isLive = true;  // Set false for development environment
     bool isDev = true;   // Set false for production builds
     ```

6. **Run the App**
   ```powershell
   # Run on connected device/emulator
   flutter run

   # Run in debug mode
   flutter run --debug

   # Run in profile mode (for performance testing)
   flutter run --profile

   # Run in release mode
   flutter run --release
   ```

### Platform-Specific Setup

#### Android
1. **Minimum SDK**: API 21 (Android 5.0)
2. **Permissions**: Configured in `android/app/src/main/AndroidManifest.xml`
3. **Google Services**: Ensure `google-services.json` is present
4. **Signing Configuration**: Configure signing keys for release builds in `android/app/build.gradle.kts`

#### iOS
1. **Minimum iOS**: 12.0
2. **Permissions**: Configured in `ios/Runner/Info.plist`
3. **CocoaPods**: Install dependencies
   ```bash
   cd ios
   pod install
   ```
4. **Signing**: Configure team and provisioning profiles in Xcode

---

## 🏗️ Building for Release

### Android APK
```powershell
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Using provided PowerShell script
.\build_apk_release.ps1
```

Output location: `build/app/outputs/flutter-apk/` or `build/app/outputs/bundle/`

### iOS IPA
```bash
# Build iOS release
flutter build ios --release

# Open in Xcode for archiving and distribution
open ios/Runner.xcworkspace
```

Then use Xcode's Product → Archive for App Store submission.

### Build Configuration
- Version is managed in `pubspec.yaml`: `version: 1.0.18+33`
- Update version before each release build
- Format: `major.minor.patch+buildNumber`

---

## ⚙️ Configuration

### Firebase Setup
1. **Create Firebase Project**: Go to [Firebase Console](https://console.firebase.google.com/)
2. **Add Android/iOS Apps**: Register your app package/bundle ID
3. **Download Config Files**:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
4. **Enable Services**:
   - Firebase Cloud Messaging (FCM) for push notifications
   - Firebase Analytics (optional)

### API Configuration
- **Base URLs**: Configure in `lib/services/api_constant.dart`
- **Environment Switching**: Use `isLive` and `isDev` flags in `main.dart`

### Permissions
The app requires the following permissions:

**Android** (`AndroidManifest.xml`):
- `INTERNET` - Network access
- `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` - GPS for attendance
- `CAMERA` - Photo capture
- `RECORD_AUDIO` - Audio recording
- `READ_EXTERNAL_STORAGE` / `WRITE_EXTERNAL_STORAGE` - File access
- `USE_BIOMETRIC` / `USE_FINGERPRINT` - Biometric authentication

**iOS** (`Info.plist`):
- `NSCameraUsageDescription` - Camera access
- `NSMicrophoneUsageDescription` - Microphone access
- `NSLocationWhenInUseUsageDescription` - Location access
- `NSPhotoLibraryUsageDescription` - Photo library access
- `NSFaceIDUsageDescription` - Face ID usage

All permissions are requested at runtime with proper user prompts.

---

## 🎨 Customization

### Localization
1. **Add New Language**:
   - Create new ARB file in `lib/l10n/` (e.g., `app_de.arb` for German)
   - Copy structure from `app_en.arb`
   - Add translations for all keys
   - Run code generation: `flutter pub get`

2. **Edit Existing Translations**:
   - Modify `lib/l10n/app_en.arb` or `lib/l10n/app_sv.arb`
   - Save and rebuild

3. **Usage in Code**:
   ```dart
   Text(AppLocalizations.of(context)!.yourTranslationKey)
   ```

### Theming
- **Colors**: Edit `lib/values/colors.dart` to update the color palette
- **Text Styles**: Modify `lib/values/styles.dart` for typography
- **Theme Configuration**: Update theme in `lib/main.dart` MaterialApp

### Assets
1. **Add Images/Animations**:
   - Place files in `assets/images/` or `assets/animations/`
   - Update `pubspec.yaml` if needed
   - Run `flutter packages pub run build_runner build` to regenerate asset references

2. **Use Type-Safe Assets**:
   ```dart
   Image.asset(Assets.images.yourImage.path)
   Lottie.asset(Assets.animations.loader.path)
   ```

### Custom Fonts
- Font files located in `fonts/` directory
- Configure in `pubspec.yaml` under `fonts` section
- Current: Inter font family (Regular, Medium, Bold, ExtraBold)

---

## 🧪 Testing

### Run Tests
```powershell
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Test Structure
- **Unit Tests**: Test individual functions and classes
- **Widget Tests**: Test UI components in isolation
- **Integration Tests**: Test complete user flows (use `flutter_driver`)

### Testing Tools
- `test`: Core testing framework
- `flutter_test`: Widget testing utilities
- `flutter_driver`: End-to-end testing

---

## 📦 Key Dependencies

### State Management & Architecture
- **provider** `^6.1.5` - State management solution
- **page_transition** `^2.1.0` - Smooth page transitions

### Networking & Data
- **dio** `^5.9.0` - HTTP client for API calls
- **http** `^1.3.0` - Additional HTTP utilities
- **connectivity_plus** `^6.1.5` - Network connectivity monitoring
- **internet_connection_checker** `^3.0.1` - Internet availability checks

### Local Storage
- **shared_preferences** `^2.2.1` - Key-value storage
- **sqflite** `^2.4.2` - SQLite database for offline support
- **path_provider** `^2.1.5` - File system paths

### Firebase
- **firebase_core** `^3.14.0` - Firebase initialization
- **firebase_messaging** `^15.2.7` - Push notifications (FCM)

### UI & Animations
- **lottie** `^3.1.0` - JSON animations
- **flutter_svg** `^2.2.0` - SVG image support
- **cached_network_image** `^3.4.1` - Image caching
- **loader_overlay** `^5.0.0` - Global loading overlay
- **percent_indicator** `^4.2.5` - Progress indicators
- **marquee** `^2.3.0` - Scrolling text
- **carousel_slider** `^5.1.1` - Image carousels
- **data_table_2** `^2.6.0` - Advanced data tables

### Location & Maps
- **google_maps_flutter** `^2.12.3` - Google Maps integration
- **geolocator** `^14.0.2` - GPS location tracking
- **geocoding** `^4.0.0` - Address ↔ coordinates conversion

### Media & Audio
- **image_picker** `^1.2.0` - Camera/gallery image selection
- **image** `^4.5.4` - Image manipulation
- **flutter_sound** `^9.28.0` - Audio recording
- **just_audio** `^0.10.4` - Audio playback
- **audio_waveforms** `^1.3.0` - Audio visualization

### Authentication & Security
- **local_auth** `^2.3.0` - Biometric authentication
- **permission_handler** `^12.0.1` - Runtime permissions
- **app_tracking_transparency** `^2.0.6` - iOS ATT framework

### Form & Input
- **animated_custom_dropdown** `^3.1.1` - Custom dropdown widgets
- **country_code_picker** `^3.4.0` - Country code selection
- **email_validator** `^3.0.0` - Email validation
- **country_phone_validator** `^1.0.1` - Phone number validation

### Utilities
- **intl** `^0.20.2` - Internationalization
- **package_info_plus** `^8.3.1` - App version info
- **device_info_plus** `^11.5.0` - Device information
- **url_launcher** `^6.3.2` - Open URLs/make calls
- **logger** `^2.6.1` - Enhanced logging
- **path** `^1.9.1` - File path manipulation

### Development Tools
- **flutter_lints** `^5.0.0` - Linting rules
- **build_runner** `^2.4.6` - Code generation
- **flutter_gen_runner** `^5.3.2` - Asset code generation
- **flutter_launcher_icons** `^0.13.1` - App icon generation

For complete dependency list, see [`pubspec.yaml`](./pubspec.yaml)

---

## 📱 App Information

- **Version**: 1.0.18+33
- **Flutter SDK**: >=3.7.2
- **Platforms**: Android, iOS
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **Backend Communication**: RESTful APIs via Dio
- **Notifications**: Firebase Cloud Messaging

---

## 🔧 Development Guidelines

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter_lints` for consistent code style
- Run `flutter analyze` before committing

### Git Workflow
```powershell
# Check status
git status

# Create feature branch
git checkout -b feature/your-feature-name

# Commit changes
git add .
git commit -m "Description of changes"

# Push to remote
git push origin feature/your-feature-name
```

### Pre-Commit Checklist
- [ ] Code passes `flutter analyze`
- [ ] All tests pass (`flutter test`)
- [ ] No debug print statements
- [ ] Comments and documentation updated
- [ ] Environment flags set correctly
- [ ] Version number updated if needed

---

## 🐛 Troubleshooting

### Common Issues

**Build Failures**
```powershell
# Clean build cache
flutter clean
flutter pub get

# Rebuild generated files
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Firebase Issues**
- Verify `google-services.json` and `GoogleService-Info.plist` are in correct locations
- Check package name/bundle ID matches Firebase console
- Ensure Firebase services are enabled in console

**Location Not Working**
- Check permissions are granted in device settings
- Verify location services are enabled
- Test with physical device (emulator GPS may be unreliable)

**Database Errors**
- Delete app and reinstall to reset database
- Check database schema in `lib/services/database_constants.dart`

---

## 📄 License

This project is proprietary software. All rights reserved.

---

## 👥 Contact & Support

For support, bug reports, feature requests, or business inquiries:
- **Project Maintainer**: [Contact Information]
- **Issue Tracker**: [Repository Issues URL]
- **Documentation**: [Documentation URL if available]

---

## 🙏 Acknowledgments

Built with Flutter and powered by:
- Firebase for cloud services
- Google Maps for location features
- Open source community for amazing packages

---

**Last Updated**: November 2025
