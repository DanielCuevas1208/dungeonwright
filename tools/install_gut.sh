#!/usr/bin/env bash
# Installs the pinned GUT version into addons/gut.
# Downloads and extracts in the system temp folder so the project never
# contains duplicate GUT files.
set -euo pipefail

TOOLS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$TOOLS")"
MANIFEST="$TOOLS/gut.version.json"

VERSION="$(jq -r '.version' "$MANIFEST")"
URL="$(jq -r '.archive_url' "$MANIFEST")"
SHA="$(jq -r '.sha256' "$MANIFEST")"
ADDON_PATH="$(jq -r '.addon_path_in_archive' "$MANIFEST")"
TARGET="$ROOT/addons/gut"
WORK="$(mktemp -d)"
ARCHIVE="$WORK/Gut-$VERSION.zip"
EXTRACT="$WORK/gut_extract_$VERSION"

trap 'rm -rf "$WORK"' EXIT

if [ -d "$TARGET" ] && [ "${1:-}" != "--force" ]; then
  echo "GUT is already installed at $TARGET. Use --force to reinstall."
  exit 0
fi

if [ ! -f "$ARCHIVE" ]; then
  echo "Downloading GUT $VERSION..."
  curl -fsSL -o "$ARCHIVE" "$URL"
fi

echo "$SHA  $ARCHIVE" | sha256sum -c - > /dev/null

rm -rf "$EXTRACT"
unzip -q "$ARCHIVE" -d "$EXTRACT"
rm -rf "$TARGET"
mkdir -p "$ROOT/addons"
cp -R "$EXTRACT/$ADDON_PATH" "$TARGET"
echo "Installed GUT $VERSION to $TARGET"
