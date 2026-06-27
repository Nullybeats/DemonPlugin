# Releasing a plugin (and onboarding new ones)

The build → sign → notarize → package → upload pipeline is driven by a single
config file: [`plugin.config.sh`](./plugin.config.sh). `Installer/macOS/release_macos.sh`
and `.github/workflows/build.yml` both read it.

## Cut a release of THIS plugin

**Automated (recommended):** push a version tag.
```bash
git tag v1.0.1 && git push origin v1.0.1
```
CI builds macOS + Windows, signs everything (if the signing secrets are set),
notarizes + staples the macOS DMG, uploads both installers to R2, and creates a
GitHub Release. Required secrets are documented at the top of `build.yml`.

**Manual macOS DMG:**
```bash
APPLE_ID="producertour@gmail.com" APPLE_APP_PASSWORD="xxxx-xxxx-xxxx-xxxx" \
  ./Installer/macOS/release_macos.sh --from-build
```

After uploading, bump the version + filenames in the website seed
(`apps/backend/prisma/seeds/seed-demon-synth.ts`) and run it.

## Onboard a NEW plugin (plugin #2, #3, …)

Each plugin is its own repo (copy this one as the template). Then:

1. **`plugin.config.sh`** — set `PLUGIN_SLUG`, `PLUGIN_DISPLAY`, `PLUGIN_VERSION`,
   `DMG_BASENAME`, `WIN_BASENAME`. (Signing identity/team stay the same.) This
   retargets `release_macos.sh` + the macOS CI automatically.
2. **CMake** — set `PRODUCT_NAME` to match `PLUGIN_DISPLAY` (so the built bundle
   is `<DISPLAY>.vst3` / `.component`).
3. **Per-plugin installer content** (these carry the plugin's own bank list, so
   they're edited per plugin, not parameterized):
   - `Installer/Windows/DemonSynth.iss` — `#define` block, the `R2BaseUrl`
     (`soundbanks/<slug>/`), and the 17-ish `DownloadPage.Add(...)` / `Slugs.Add(...)`
     bank entries.
   - `Installer/macOS/DemonSynthInstaller.applescript` — the `soundBanks` list +
     `r2Base`. `create_installer_app.sh` compiles it into "Install <Display>.app".
4. **Sound banks** — upload the bank ZIPs to R2 under `soundbanks/<slug>/`.
5. **Release** — tag `vX.Y.Z` (or run `release_macos.sh`). Installers land in R2
   under `plugins/<slug>/`.
6. **Website wiring** (the platform already supports it — no code changes):
   - Seed a `Product` + `ProductFile`s for the new slug (copy
     `seed-demon-synth.ts`).
   - Add the slug to `PLUGIN_SLUGS` in `seed-cloud-catalog.ts` and run it → the
     plugin appears in `/cloud`, licensing (`/verify`, downloads) and all-access
     entitlement pick it up automatically.

That's it — the catalog, per-account licensing, all-access subscription, install
guide, and update endpoint are all generic over the slug.
