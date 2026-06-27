#!/bin/bash
#
# Demon Synth — one-command macOS release builder.
#
# Produces a SIGNED + NOTARIZED + STAPLED DMG whose "Install Demon Synth" app
# downloads the 8.5 GB of sound banks from R2 during install — the artifact the
# website should serve for macOS.
#
# By default it reuses the already-notarized plugins from the live R2 zip
# (known-good) instead of rebuilding from a possibly-dirty working tree. To
# package a fresh local build instead, pass  --from-build.
#
# Usage:
#   # build + sign + notarize + staple (full release):
#   APPLE_ID="producertour@gmail.com" APPLE_APP_PASSWORD="abcd-efgh-ijkl-mnop" \
#     ./release_macos.sh
#
#   # build + sign only, skip notarization (no password yet):
#   ./release_macos.sh --no-notarize
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/Installer/Output"
STAGE="$(mktemp -d)/DemonSynth"
DMG_NAME="DemonSynth_v1.0.0_macOS"
VOLUME_NAME="Demon Synth"

IDENTITY="${SIGN_IDENTITY:-Developer ID Application: Producer Tour LLC (W28TLN4A8X)}"
TEAM_ID="${APPLE_TEAM_ID:-W28TLN4A8X}"
LIVE_PLUGINS_ZIP="https://pub-5e192bc6cd8640f1b75ee043036d06d2.r2.dev/plugins/demon-synth/DemonSynth_v1.0.0_macOS.zip"

NOTARIZE=1
FROM_BUILD=0
for arg in "$@"; do
  case "$arg" in
    --no-notarize) NOTARIZE=0 ;;
    --from-build)  FROM_BUILD=1 ;;
  esac
done

echo "▶ Demon Synth macOS release  (identity: $IDENTITY)"
mkdir -p "$OUTPUT_DIR" "$STAGE"

# ── 1. Stage the plugins ──────────────────────────────────────────────────────
if [ "$FROM_BUILD" = "1" ]; then
  BUILD_VST3="$PROJECT_ROOT/build/NulyBeatsPlugin_artefacts/Release/VST3/Demon Synth.vst3"
  BUILD_AU="$PROJECT_ROOT/build/NulyBeatsPlugin_artefacts/Release/AU/Demon Synth.component"
  [ -d "$BUILD_VST3" ] || { echo "✗ No local build. Run cmake build first or drop --from-build."; exit 1; }
  cp -R "$BUILD_VST3" "$STAGE/"
  cp -R "$BUILD_AU" "$STAGE/"
  echo "  ✓ staged plugins from local build"
else
  echo "  ↓ downloading live notarized plugins…"
  curl -fsSL -o "$STAGE/live.zip" "$LIVE_PLUGINS_ZIP"
  ( cd "$STAGE" && unzip -q live.zip && rm live.zip )
  # Flatten VST3/ and AU/ subfolders from the zip into the stage root.
  [ -d "$STAGE/VST3/Demon Synth.vst3" ] && mv "$STAGE/VST3/Demon Synth.vst3" "$STAGE/" && rmdir "$STAGE/VST3" 2>/dev/null || true
  [ -d "$STAGE/AU/Demon Synth.component" ] && mv "$STAGE/AU/Demon Synth.component" "$STAGE/" && rmdir "$STAGE/AU" 2>/dev/null || true
  echo "  ✓ staged already-notarized plugins"
fi

# ── 2. Compile + sign the installer / uninstaller apps ────────────────────────
echo "▶ Building installer apps…"
"$SCRIPT_DIR/create_installer_app.sh" >/dev/null
for app in "Install Demon Synth.app" "Uninstall Demon Synth.app"; do
  cp -R "$SCRIPT_DIR/$app" "$STAGE/"
  codesign --force --timestamp --options runtime \
    --sign "$IDENTITY" "$STAGE/$app"
  echo "  ✓ signed: $app"
done

# Re-verify the plugins still carry a valid Developer ID signature (they came
# notarized; codesign --verify is a cheap safety net).
for p in "Demon Synth.vst3" "Demon Synth.component"; do
  [ -e "$STAGE/$p" ] && codesign --verify --deep --strict "$STAGE/$p" && echo "  ✓ verified: $p"
done

# ── 3. License + README ───────────────────────────────────────────────────────
[ -f "$PROJECT_ROOT/Installer/LICENSE.txt" ] && cp "$PROJECT_ROOT/Installer/LICENSE.txt" "$STAGE/"
cat > "$STAGE/README.txt" <<'README'
DEMON SYNTH — by Nully Beats

To install, double-click "Install Demon Synth".
It installs the VST3 + AU and downloads all sound banks (~8.5 GB) automatically,
then asks you to sign in with your Producer Tour account to activate.

© Nolan Griffis p/k/a Nully Beats — Producer Tour Publishing LLC
README

# ── 4. Build + sign the DMG ───────────────────────────────────────────────────
echo "▶ Creating DMG…"
rm -f "$OUTPUT_DIR/$DMG_NAME.dmg"
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$STAGE" \
  -ov -format UDZO -imagekey zlib-level=9 "$OUTPUT_DIR/$DMG_NAME.dmg" >/dev/null
codesign --force --timestamp --sign "$IDENTITY" "$OUTPUT_DIR/$DMG_NAME.dmg"
echo "  ✓ DMG signed: $OUTPUT_DIR/$DMG_NAME.dmg"

# ── 5. Notarize + staple ──────────────────────────────────────────────────────
if [ "$NOTARIZE" = "1" ]; then
  : "${APPLE_ID:?Set APPLE_ID (e.g. producertour@gmail.com)}"
  : "${APPLE_APP_PASSWORD:?Set APPLE_APP_PASSWORD (app-specific password from appleid.apple.com)}"
  echo "▶ Notarizing (this can take a few minutes)…"
  xcrun notarytool submit "$OUTPUT_DIR/$DMG_NAME.dmg" \
    --apple-id "$APPLE_ID" --password "$APPLE_APP_PASSWORD" --team-id "$TEAM_ID" --wait
  xcrun stapler staple "$OUTPUT_DIR/$DMG_NAME.dmg"
  echo "  ✓ notarized + stapled"
  spctl -a -vvv -t open --context context:primary-signature "$OUTPUT_DIR/$DMG_NAME.dmg" || true
else
  echo "▶ Skipping notarization (--no-notarize). DMG is signed but NOT yet notarized."
fi

rm -rf "$(dirname "$STAGE")"
echo "✅ Done → $OUTPUT_DIR/$DMG_NAME.dmg"
