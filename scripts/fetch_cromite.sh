#!/usr/bin/env bash
set -euo pipefail

# This script downloads the latest Cromite System WebView
# APKs for arm and arm64 and places them in the prebuilt directory.

REPO="uazo/cromite"
API_URL="https://api.github.com/repos/${REPO}/releases/latest"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(realpath "$SCRIPT_DIR/..")"

mkdir -p "$ROOT_DIR/prebuilt/arm" "$ROOT_DIR/prebuilt/arm64"

if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required but not installed" >&2
    exit 1
fi

echo "Fetching release information..."
RELEASE_JSON=$(curl -sL "$API_URL")

ARM_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[] | select(.name|test("arm[^6].*SystemWebView.*\\.apk$|webview-arm.*\\.apk$")) | .browser_download_url' | head -n1)
ARM64_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[] | select(.name|test("arm64.*SystemWebView.*\\.apk$|webview-arm64.*\\.apk$")) | .browser_download_url' | head -n1)

if [[ -z "$ARM_URL" || -z "$ARM64_URL" ]]; then
    echo "Could not determine download URLs for arm/arm64 assets" >&2
    exit 1
fi

echo "Downloading arm APK..."
curl -L "$ARM_URL" -o "$ROOT_DIR/prebuilt/arm/SystemWebView.apk"

echo "Downloading arm64 APK..."
curl -L "$ARM64_URL" -o "$ROOT_DIR/prebuilt/arm64/SystemWebView.apk"

echo "APKs have been downloaded to $ROOT_DIR/prebuilt"

