#!/bin/bash
#
# One-command macOS release builder — config-driven (reads ../../plugin.config.sh).
#
# Produces a SIGNED + NOTARIZED + STAPLED DMG whose "Install <Plugin>" app
# downloads the sound banks from R2 during install — the artifact the website
# serves for macOS.
#
# By default it reuses already-notarized plugins from LIVE_PLUGINS_ZIP_URL
# (known-good, for re-packaging the same build). For a fresh local build (the
# normal path for a new plugin/version), pass  --from-build.
#
# Usage:
#   APPLE_ID="producertour@gmail.com" APPLE_APP_PASSWORD="xxxx-xxxx-xxxx-xxxx" \
#     ./release_macos.sh --from-build
#   ./release_macos.sh --no-notarize          # build + sign only
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ── Load per-plugin config ────────────────────────────────────────────────────
# shellcheck source=/dev/null
source "$PROJECT_ROOT/plugin.config.sh"

OUTPUT_DIR="$PROJECT_ROOT/Installer/Output"
STAGE="$(mktemp -d)/$DMG_BASENAME"
VOLUME_NAME="$PLUGIN_DISPLAY"
VST3="$PLUGIN_DISPLAY.vst3"
AU="$PLUGIN_DISPLAY.component"

IDENTITY="${SIGN_IDENTITY}"
TEAM_ID="${APPLE_TEAM_ID}"

NOTARIZE=1
FROM_BUILD=0
for arg in "$@"; do
  case "$arg" in
    --no-notarize) NOTARIZE=0 ;;
    --from-build)  FROM_BUILD=1 ;;
  esac
done

echo "▶ $PLUGIN_DISPLAY v$PLUGIN_VERSION macOS release  (identity: $IDENTITY)"
mkdir -p "$OUTPUT_DIR" "$STAGE"

# ── 1. Stage the plugins ──────────────────────────────────────────────────────
if [ "$FROM_BUILD" = "1" ]; then
  BUILD_VST3="$PROJECT_ROOT/build/NulyBeatsPlugin_artefacts/Release/VST3/$VST3"
  BUILD_AU="$PROJECT_ROOT/build/NulyBeatsPlugin_artefacts/Release/AU/$AU"
  [ -d "$BUILD_VST3" ] || { echo "✗ No local build at $BUILD_VST3. Run the cmake build first, or drop --from-build."; exit 1; }
  cp -R "$BUILD_VST3" "$STAGE/"
  cp -R "$BUILD_AU" "$STAGE/"
  echo "  ✓ staged plugins from local build"
else
  [ -n "${LIVE_PLUGINS_ZIP_URL:-}" ] || { echo "✗ LIVE_PLUGINS_ZIP_URL not set in plugin.config.sh — use --from-build."; exit 1; }
  echo "  ↓ downloading live notarized plugins…"
  curl -fsSL -o "$STAGE/live.zip" "$LIVE_PLUGINS_ZIP_URL"
  ( cd "$STAGE" && unzip -q live.zip && rm live.zip )
  [ -d "$STAGE/VST3/$VST3" ] && mv "$STAGE/VST3/$VST3" "$STAGE/" && rmdir "$STAGE/VST3" 2>/dev/null || true
  [ -d "$STAGE/AU/$AU" ] && mv "$STAGE/AU/$AU" "$STAGE/" && rmdir "$STAGE/AU" 2>/dev/null || true
  echo "  ✓ staged already-notarized plugins"
fi

# ── 2. Compile + sign the installer / uninstaller apps ────────────────────────
echo "▶ Building installer apps…"
"$SCRIPT_DIR/create_installer_app.sh" >/dev/null
for app in "Install $PLUGIN_DISPLAY.app" "Uninstall $PLUGIN_DISPLAY.app"; do
  if [ -d "$SCRIPT_DIR/$app" ]; then
    cp -R "$SCRIPT_DIR/$app" "$STAGE/"
    codesign --force --timestamp --options runtime --sign "$IDENTITY" "$STAGE/$app"
    echo "  ✓ signed: $app"
  fi
done

# Re-verify the plugins carry a valid Developer ID signature.
for p in "$VST3" "$AU"; do
  [ -e "$STAGE/$p" ] && codesign --verify --deep --strict "$STAGE/$p" && echo "  ✓ verified: $p"
done

# ── 3. License + README ───────────────────────────────────────────────────────
[ -f "$PROJECT_ROOT/Installer/LICENSE.txt" ] && cp "$PROJECT_ROOT/Installer/LICENSE.txt" "$STAGE/"
cat > "$STAGE/README.txt" <<README
$PLUGIN_DISPLAY — by Nully Beats

To install, double-click "Install $PLUGIN_DISPLAY".
It installs the VST3 + AU and downloads the sound banks automatically, then asks
you to sign in with your Producer Tour account to activate.

© Nolan Griffis p/k/a Nully Beats — Producer Tour Publishing LLC
README

# ── 4. Build + sign the DMG ───────────────────────────────────────────────────
echo "▶ Creating DMG…"
rm -f "$OUTPUT_DIR/$DMG_BASENAME.dmg"
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$STAGE" \
  -ov -format UDZO -imagekey zlib-level=9 "$OUTPUT_DIR/$DMG_BASENAME.dmg" >/dev/null
codesign --force --timestamp --sign "$IDENTITY" "$OUTPUT_DIR/$DMG_BASENAME.dmg"
echo "  ✓ DMG signed: $OUTPUT_DIR/$DMG_BASENAME.dmg"

# ── 5. Notarize + staple ──────────────────────────────────────────────────────
if [ "$NOTARIZE" = "1" ]; then
  : "${APPLE_ID:?Set APPLE_ID (e.g. producertour@gmail.com)}"
  : "${APPLE_APP_PASSWORD:?Set APPLE_APP_PASSWORD (app-specific password from appleid.apple.com)}"
  echo "▶ Notarizing (this can take a few minutes)…"
  xcrun notarytool submit "$OUTPUT_DIR/$DMG_BASENAME.dmg" \
    --apple-id "$APPLE_ID" --password "$APPLE_APP_PASSWORD" --team-id "$TEAM_ID" --wait
  xcrun stapler staple "$OUTPUT_DIR/$DMG_BASENAME.dmg"
  echo "  ✓ notarized + stapled"
  spctl -a -vvv -t open --context context:primary-signature "$OUTPUT_DIR/$DMG_BASENAME.dmg" || true
else
  echo "▶ Skipping notarization (--no-notarize). DMG is signed but NOT yet notarized."
fi

rm -rf "$(dirname "$STAGE")"
echo "✅ Done → $OUTPUT_DIR/$DMG_BASENAME.dmg"
