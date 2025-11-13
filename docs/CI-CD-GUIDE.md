# CI/CD Guide - GitHub Actions Workflows

This document explains how to use the GitHub Actions workflows for building Android APKs and App Bundles.

## 📦 Available Workflows

### 1. Build Android APK (`build-apk.yml`)

**Purpose**: Automatically builds APK on every push and pull request

**Triggers**:
- Push to `main`, `develop`, or any `claude/**` branch
- Pull requests to `main` or `develop`
- Manual trigger via GitHub Actions UI

**What it does**:
1. ✅ Sets up Flutter and Java environment
2. ✅ Installs dependencies
3. ✅ Generates code with `build_runner`
4. ✅ Runs code analysis (non-blocking)
5. ✅ Runs tests (non-blocking)
6. ✅ Builds APK (Debug for PRs, Release for main)
7. ✅ Uploads APK as artifact
8. ✅ Comments on PR with download instructions

**Build Types**:
- **Debug APK**: Built for pull requests and non-main branches
- **Release APK**: Built for pushes to `main` branch

### 2. Build Release APK and AAB (`build-release.yml`)

**Purpose**: Creates production-ready APK and AAB files for releases

**Triggers**:
- Git tags matching `v*.*.*` (e.g., `v1.0.0`)
- Manual trigger with version input

**What it does**:
1. ✅ Sets up Flutter and Java environment
2. ✅ Installs dependencies and generates code
3. ✅ Runs tests (blocking - must pass)
4. ✅ Runs code analysis (blocking - must pass)
5. ✅ Builds split APKs for different architectures:
   - `arm64-v8a` - Most modern Android devices
   - `armeabi-v7a` - Older Android devices
   - `x86_64` - Emulators and Intel-based devices
6. ✅ Builds App Bundle (AAB) for Google Play Store
7. ✅ Creates GitHub Release with all artifacts
8. ✅ Uploads artifacts for 90 days

## 🚀 Usage

### Building APK for Development

**Automatic Build**:
```bash
# Simply push to your branch
git push origin your-branch-name

# For PRs, the workflow will automatically run
```

**Manual Trigger**:
1. Go to **Actions** tab in GitHub
2. Select **Build Android APK** workflow
3. Click **Run workflow**
4. Select branch and click **Run workflow**

**Download the APK**:
1. Go to the workflow run
2. Scroll down to **Artifacts** section
3. Download the APK file
4. Extract the zip file
5. Install on your device

### Creating a Release

**Method 1: Using Git Tags** (Recommended)
```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0

# The workflow will automatically:
# - Build all APK variants
# - Build App Bundle
# - Create GitHub Release
# - Upload all files
```

**Method 2: Manual Trigger**
1. Go to **Actions** tab
2. Select **Build Release APK and AAB** workflow
3. Click **Run workflow**
4. Enter version (e.g., `v1.0.0`)
5. Click **Run workflow**

### Downloading Release Builds

**From GitHub Release**:
1. Go to **Releases** section
2. Find your version
3. Download the appropriate APK or AAB

**From Artifacts**:
1. Go to the workflow run
2. Download from **Artifacts** section
3. Files are kept for 90 days

## 📱 APK Installation

### On Android Device

**Method 1: Direct Download**
1. Download APK to your phone
2. Open the APK file
3. Enable "Install from Unknown Sources" if prompted
4. Follow installation prompts

**Method 2: Using ADB**
```bash
# Connect device via USB
adb devices

# Install APK
adb install restaurant-admin-v1.0.0-arm64-v8a.apk

# Or install and replace existing
adb install -r restaurant-admin-v1.0.0-arm64-v8a.apk
```

### On Emulator

```bash
# Start emulator
emulator -avd YOUR_AVD_NAME

# Install APK
adb -e install restaurant-admin-v1.0.0-arm64-v8a.apk
```

## 🏗️ Build Artifacts Explained

### APK Files

| File | Architecture | Use Case |
|------|-------------|----------|
| `app-arm64-v8a-release.apk` | ARM 64-bit | Most modern Android phones (2015+) |
| `app-armeabi-v7a-release.apk` | ARM 32-bit | Older Android devices (pre-2015) |
| `app-x86_64-release.apk` | x86 64-bit | Android emulators, Intel devices |

**Which APK should I use?**
- **Modern phones** (2015+): Use `arm64-v8a`
- **Older phones**: Use `armeabi-v7a`
- **Emulators**: Use `x86_64`
- **Not sure?**: Use `arm64-v8a` (works on 95% of devices)

### App Bundle (AAB)

- `app-release.aab` - For uploading to Google Play Store
- Contains all architectures
- Google Play automatically delivers optimized APK to each device

## ⚙️ Workflow Configuration

### Environment Variables

No environment variables or secrets are required for basic builds.

**For signed releases** (optional):
```yaml
# Add these secrets in GitHub Settings > Secrets
KEYSTORE_FILE: base64 encoded keystore
KEYSTORE_PASSWORD: keystore password
KEY_ALIAS: key alias
KEY_PASSWORD: key password
```

### Customizing Workflows

**Change Flutter Version**:
```yaml
# In both workflow files
- name: Set up Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.16.0'  # Change this
```

**Change Build Type**:
```yaml
# For always building release APK
- name: Build APK (Release)
  run: flutter build apk --release
```

**Add Code Signing**:
```yaml
# Add before build step
- name: Decode keystore
  run: |
    echo "${{ secrets.KEYSTORE_FILE }}" | base64 -d > android/app/keystore.jks
```

## 🔍 Troubleshooting

### Build Fails

**Problem**: "Flutter not found"
- **Solution**: Workflow automatically installs Flutter, check logs

**Problem**: "Gradle build failed"
- **Solution**: Check Java version is set to 17
- Verify `android/build.gradle` and `android/app/build.gradle`

**Problem**: "Code generation failed"
- **Solution**: Run locally first:
  ```bash
  flutter pub get
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

### APK Won't Install

**Problem**: "App not installed"
- **Solution**:
  - Enable "Install from Unknown Sources"
  - Uninstall old version first
  - Check if APK architecture matches device

**Problem**: "Parse error"
- **Solution**:
  - Re-download APK (may be corrupted)
  - Use correct architecture APK

### Workflow Not Triggering

**Problem**: Workflow doesn't run on push
- **Solution**:
  - Check branch name matches trigger pattern
  - Verify workflow file is in `.github/workflows/`
  - Check GitHub Actions is enabled for repo

## 📊 Build Status

You can add build status badges to your README:

```markdown
![Build APK](https://github.com/YOUR_USERNAME/restaurant-admin-flutter/actions/workflows/build-apk.yml/badge.svg)
![Build Release](https://github.com/YOUR_USERNAME/restaurant-admin-flutter/actions/workflows/build-release.yml/badge.svg)
```

## 🔐 Security Notes

### For Development Builds
- Uses debug signing (automatically generated)
- Not suitable for production distribution
- Safe for testing and internal use

### For Release Builds
- Currently uses debug signing
- **TODO**: Add proper release signing:
  1. Generate release keystore
  2. Add keystore to GitHub Secrets
  3. Update workflow to use release signing
  4. Never commit keystore to repository

### Best Practices
- ✅ Never commit keystore files
- ✅ Use GitHub Secrets for sensitive data
- ✅ Enable branch protection for `main`
- ✅ Require PR reviews before merge
- ✅ Keep dependencies updated

## 📈 Build Optimization

### Reduce Build Time
- Enable Gradle caching (already configured)
- Use appropriate Java heap size
- Cache Flutter SDK (already configured)

### Reduce APK Size
- Enable ProGuard (already configured for release)
- Enable R8 shrinking (already configured)
- Remove unused resources
- Optimize images

## 🎯 Next Steps

1. **Set up Release Signing**
   - Generate production keystore
   - Add to GitHub Secrets
   - Update workflow configuration

2. **Add Automated Testing**
   - Write widget tests
   - Add integration tests
   - Configure test coverage reporting

3. **Set up Google Play Publishing**
   - Configure service account
   - Add automated Play Store upload
   - Implement staged rollouts

4. **Add Notifications**
   - Slack/Discord notifications on build
   - Email on build failure
   - Status updates to PR

## 📚 Resources

- [Flutter CI/CD Guide](https://docs.flutter.dev/deployment/cd)
- [GitHub Actions for Flutter](https://github.com/marketplace/actions/flutter-action)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Google Play Publishing](https://support.google.com/googleplay/android-developer/answer/9859152)

---

**Last Updated**: 2025-11-13
**Maintained by**: Restaurant Admin System Team
