# PayPipes SDK Sample App

This is a complete, runnable Xcode project demonstrating PayPipes SDK integration.

## Quick Start

### Step 1: Open Project

1. Open `ExampleApp.xcodeproj` in Xcode
2. Wait for Xcode to resolve Swift Package Manager dependencies (this may take a minute on first open)
3. If you see "No such module 'PayPipes'" error:
   - Go to **File → Packages → Reset Package Caches**
   - Then **File → Packages → Resolve Package Versions**
   - Clean build folder: **Product → Clean Build Folder** (Shift+Cmd+K)

### Step 2: Update Credentials

⚠️ **Important**: Replace the test credentials in the source files with your actual credentials:
- Open `Sources/ViewController.swift` or `Sources/SwiftUISampleView.swift`
- Find the `createConfiguration()` method
- Update `clientId` and `clientSecret` with your actual values

### Step 3: Configure Signing (Optional)

If you want to run on a physical device:
1. Select the **ExampleApp** project in the navigator
2. Select the **ExampleApp** target
3. Go to **Signing & Capabilities**
4. Select your **Team** (development team is not set by default)
5. Xcode will automatically manage signing

### Step 4: Build and Run

1. Select a simulator or connected device
2. Press **Cmd+R** or click the **Run** button
3. The app should build and run successfully

## Project Structure

- `Sources/`: All source files
  - `ViewController.swift`: UIKit-based example with comprehensive demos
  - `SwiftUISampleView.swift`: SwiftUI-based example
  - `AppDelegate.swift`: App delegate
  - `SceneDelegate.swift`: Scene delegate
  - `IntroViewController.swift`: Intro screen with navigation

## Features Demonstrated

- ✅ UIKit integration
- ✅ SwiftUI integration  
- ✅ Theme customization
- ✅ Billing address handling
- ✅ Error handling
- ✅ Card scanning
- ✅ Multiple payment flows

## Troubleshooting

**Build errors after conversion?**
- Clean build folder: **Product → Clean Build Folder** (Shift+Cmd+K)
- Delete derived data: Close Xcode, delete `~/Library/Developer/Xcode/DerivedData`
- Reopen project and rebuild

**Package not resolving?**
- Check internet connection
- Verify the repository URL is correct
- Try: **File → Packages → Reset Package Caches**

**Framework not found errors?**
- Ensure PayPipes is listed in **Frameworks, Libraries, and Embedded Content**
- Check that the package dependency was added correctly

See the main README.md for detailed integration instructions.
