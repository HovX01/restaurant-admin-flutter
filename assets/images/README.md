# Restaurant Admin App - Assets

This directory contains logos and images for the Restaurant Admin Flutter app.

## Logos

### `logo.svg`
Main circular logo with full branding (200x200).
- Used in: Login screen, about page, splash screen
- Features: Chef hat, cloche, admin badge, full branding

### `logo_icon.svg`
Simplified icon version for app launcher (120x120).
- Clean design optimized for small sizes
- Blue background with white elements
- Orange admin badge accent

### `logo_horizontal.svg`
Horizontal logo layout with text (320x100).
- Used in: Headers, wide displays, promotional materials
- Includes "RESTAURANT ADMIN SYSTEM" text with Geist Mono font

## App Launcher Icon Setup

To set up the app launcher icon, use the `flutter_launcher_icons` package:

### 1. Add to `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: false  # Set to true if you add iOS support
  image_path: "assets/images/logo_icon.svg"
  adaptive_icon_background: "#1976D2"
  adaptive_icon_foreground: "assets/images/logo_icon.svg"
```

### 2. Generate icons:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate all required Android launcher icon sizes.

## Alternative: Manual Icon Setup

If you prefer to create PNG icons manually, convert `logo_icon.svg` to the following sizes:

**Android (mipmap directories):**
- `mdpi`: 48x48px
- `hdpi`: 72x72px
- `xhdpi`: 96x96px
- `xxhdpi`: 144x144px
- `xxxhdpi`: 192x192px

Place them in: `android/app/src/main/res/mipmap-*/ic_launcher.png`

## Color Scheme

- **Primary Blue**: `#1976D2`
- **Accent Orange**: `#FF6F00`
- **White**: `#FFFFFF`
- **Gray Text**: `#666666`

## Font

All text in logos uses **Geist Mono** font family with various weights:
- Headers: 700 (Bold)
- Body: 500 (Medium)

## Usage in Code

```dart
// SVG Logo
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'assets/images/logo.svg',
  width: 180,
  height: 180,
);

// Or horizontal logo
SvgPicture.asset(
  'assets/images/logo_horizontal.svg',
  width: 320,
  height: 100,
);
```

## Editing

All logos are SVG format and can be edited with:
- [Figma](https://figma.com)
- [Inkscape](https://inkscape.org)
- [Adobe Illustrator](https://adobe.com/illustrator)
- Any text editor (SVG is XML-based)

## License

These logos are part of the Restaurant Admin Flutter app project.
