#!/bin/bash

# Script to create a GitHub release with local APK
# Usage: ./scripts/create_release.sh v1.0.0 path/to/app.apk

VERSION=$1
APK_PATH=$2

if [ -z "$VERSION" ] || [ -z "$APK_PATH" ]; then
    echo "Usage: $0 <version> <apk-path>"
    echo "Example: $0 v1.0.0 build/app/outputs/flutter-apk/app-release.apk"
    exit 1
fi

if [ ! -f "$APK_PATH" ]; then
    echo "Error: APK file not found at $APK_PATH"
    exit 1
fi

echo "Creating release $VERSION..."

# Create the tag
git tag "$VERSION"
git push origin "$VERSION"

echo ""
echo "✅ Tag $VERSION created and pushed!"
echo ""
echo "Next steps:"
echo "1. Wait for GitHub Actions to build the release (check Actions tab)"
echo "2. Or manually create release on GitHub:"
echo "   https://github.com/HovX01/restaurant-admin-flutter/releases/new?tag=$VERSION"
echo ""
echo "To manually upload your APK:"
echo "1. Go to the URL above"
echo "2. Fill in release notes"
echo "3. Drag and drop your APK file"
echo "4. Click 'Publish release'"
