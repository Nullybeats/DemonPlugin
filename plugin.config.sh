#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Per-plugin release config — the ONE file to edit when onboarding a new plugin.
#
#  release_macos.sh and the CI workflow source this. Change these values (and the
#  matching CMake PRODUCT_NAME + Installer/Windows/DemonSynth.iss) and the whole
#  build → sign → notarize → package → upload pipeline retargets to the new plugin.
#  See RELEASING.md for the full per-plugin checklist.
# ─────────────────────────────────────────────────────────────────────────────

# Store slug — must match the Product.slug on producertour.com and the R2 folder
# under plugins/<slug>/ and soundbanks/<slug>/.
PLUGIN_SLUG="demon-synth"

# The built bundle name — must match CMake PRODUCT_NAME. Produces
# "<DISPLAY>.vst3" / "<DISPLAY>.component".
PLUGIN_DISPLAY="Demon Synth"

# Marketing version (also embedded by CMake/Info.plist + the Inno installer).
PLUGIN_VERSION="1.0.0"

# Output installer basenames (must match the filenames the website seed expects
# in apps/backend/prisma/seeds/seed-demon-synth.ts and the R2 paths).
DMG_BASENAME="DemonSynth_v${PLUGIN_VERSION}_macOS"
WIN_BASENAME="DemonSynth_v${PLUGIN_VERSION}_Windows"

# Apple Developer ID signing (same legal entity as the website's R2/Stripe).
SIGN_IDENTITY="Developer ID Application: Producer Tour LLC (W28TLN4A8X)"
APPLE_TEAM_ID="W28TLN4A8X"

# R2 destination prefix for installers (public bucket producer-tour-assets).
R2_PLUGINS_PREFIX="plugins/${PLUGIN_SLUG}"

# Optional: for re-packaging an already-notarized build into a DMG without a
# fresh compile (release_macos.sh default path). Leave blank for new plugins —
# they always use --from-build.
LIVE_PLUGINS_ZIP_URL="https://pub-5e192bc6cd8640f1b75ee043036d06d2.r2.dev/plugins/demon-synth/DemonSynth_v1.0.0_macOS.zip"
