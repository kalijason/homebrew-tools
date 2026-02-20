#!/bin/bash
# Helper script for updating formula versions
#
# Usage:
#   ./scripts/update-formula.sh <formula-name> <version>
#
# Example:
#   ./scripts/update-formula.sh mac-tts 1.0.3
#   ./scripts/update-formula.sh qwen-tts 1.0.1

set -e

FORMULA_NAME="$1"
VERSION="$2"

if [ -z "$FORMULA_NAME" ] || [ -z "$VERSION" ]; then
    echo "Usage: $0 <formula-name> <version>"
    echo "Example: $0 mac-tts 1.0.3"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
FORMULA_FILE="$REPO_ROOT/Formula/${FORMULA_NAME}.rb"

if [ ! -f "$FORMULA_FILE" ]; then
    echo "Error: Formula not found: $FORMULA_FILE"
    exit 1
fi

# Extract homepage to determine GitHub repo
HOMEPAGE=$(grep 'homepage' "$FORMULA_FILE" | sed 's/.*homepage "\(.*\)"/\1/')
if [ -z "$HOMEPAGE" ]; then
    echo "Error: Could not extract homepage from formula"
    exit 1
fi

# Construct tarball URL
TARBALL_URL="${HOMEPAGE}/archive/refs/tags/v${VERSION}.tar.gz"

echo "Formula: $FORMULA_NAME"
echo "Version: $VERSION"
echo "URL: $TARBALL_URL"
echo ""

# Download and compute SHA256
echo "Downloading tarball to compute SHA256..."
SHA256=$(curl -sL "$TARBALL_URL" | shasum -a 256 | awk '{print $1}')

if [ -z "$SHA256" ] || [ "$SHA256" = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ]; then
    echo "Error: Failed to download tarball or received empty file"
    echo "Make sure the release tag v${VERSION} exists"
    exit 1
fi

echo "SHA256: $SHA256"
echo ""

# Create backup
cp "$FORMULA_FILE" "$FORMULA_FILE.bak"

# Update version in URL
sed -i '' "s|/archive/refs/tags/v[0-9.]*\.tar\.gz|/archive/refs/tags/v${VERSION}.tar.gz|" "$FORMULA_FILE"

# Update SHA256
sed -i '' "s/sha256 \"[a-f0-9]*\"/sha256 \"${SHA256}\"/" "$FORMULA_FILE"

echo "Updated $FORMULA_FILE"
echo ""
echo "Changes:"
diff "$FORMULA_FILE.bak" "$FORMULA_FILE" || true
echo ""

# Clean up backup
rm "$FORMULA_FILE.bak"

echo "Done! Don't forget to:"
echo "  1. Review the changes"
echo "  2. Test with: brew reinstall $FORMULA_NAME"
echo "  3. Commit and push to homebrew-tools"
