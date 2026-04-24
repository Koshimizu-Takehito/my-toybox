# Localization Workflow (Xcode 26 + Semantic Keys)

This project uses Xcode String Catalogs with generated type-safe Swift symbols, plus a sync script that keeps semantic keys and metadata aligned.

## Required Xcode setting

Generated symbol usage in this repository assumes:

- Build Setting: **Generate String Catalog Symbols** = `YES`
- Build setting key: `STRING_CATALOG_GENERATE_SYMBOLS`

You can verify this in the target's Build Settings under Localization.

## Source of truth

- `Packages/Sources/MyToyboxScreens/Resources/Localizable.xcstrings`
  - Canonical localization data
  - `sourceLanguage` is English
  - Keys are semantic (for example: `screen.badgeDemo.title`)

`Localizable.xcstrings` is the canonical data source.  
`Scripts/sync_screen_localization.py` is a normalizer/enforcer that validates and reshapes files to follow repository policy.

## Why `Scripts/sync_screen_localization.py` exists

`Scripts/sync_screen_localization.py` is an operational consistency tool.

It is responsible for:

- Validating semantic key/symbol naming collisions before build-time surprises
- Rewriting `@Metadata(...)` references in screen files to the expected key-derived symbols
- Regenerating `Localizable.xcstrings` in a normalized format
- Marking catalog entries as manual extraction state for Xcode-generated symbols

It is **not** a replacement for Xcode localization features. It complements them to keep this repository's key policy consistent.

## Enforced workflow

### 1) New screen creation path

Use `make new-screen` (or its `NAME=` variants).

The underlying script `Scripts/new_screen.sh` now runs:

```bash
python3 Scripts/sync_screen_localization.py
```

and fails if synchronization fails.

### 2) CI enforcement

CI runs:

```bash
python3 Scripts/sync_screen_localization.py
git diff --exit-code
```

If running the sync script changes tracked files, CI fails.
This prevents unsynced localization changes from being merged.

## Developer expectations

- Prefer semantic keys and generated symbols over ad-hoc string literals.
- If you edit localization-relevant metadata manually, run:

```bash
python3 Scripts/sync_screen_localization.py
```

before committing.
- Do not hand-format `Localizable.xcstrings`; let the script/Xcode manage it.

## Troubleshooting

- **Sync fails with missing localization mapping**
  - Add or correct metadata/localization entries so each required key resolves.
- **CI fails on `git diff --exit-code` after sync**
  - Run sync locally, review generated changes, and commit them.
- **Build fails with missing generated symbols**
  - Ensure the catalog is in sync and build settings keep string catalog symbol generation enabled.

