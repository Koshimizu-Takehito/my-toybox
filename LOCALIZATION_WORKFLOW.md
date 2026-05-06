# Localization Workflow

Each screen module owns its own `Localizable.xcstrings`; there is no central
catalog. Xcode generates type-safe Swift symbols (e.g. `.screenBadgeDemoTitle`)
from each catalog, scoped to the module's bundle.

## Required Xcode setting

Generated symbol usage assumes:

- Build Setting: **Generate String Catalog Symbols** = `YES`
- Build setting key: `STRING_CATALOG_GENERATE_SYMBOLS`

Verify under each target's Build Settings → Localization.

## Layout

```
Packages/Sources/
├── MyToyboxCore/Resources/Localizable.xcstrings       # app.*
├── MyToyboxUI/Resources/Localizable.xcstrings         # app.title
├── Screens/TagPicker/Resources/Localizable.xcstrings  # tag.*
└── Screens/<Name>/Resources/Localizable.xcstrings    # screen.<id>.title / .description
```

Each module's catalog is the source of truth for that module. Symbols resolve
through the module's own bundle, so there is no cross-module collision risk.

## Adding a new screen

`make new-screen NAME=...` (or `Scripts/new_screen.sh ...`) generates the new
module's `Localizable.xcstrings` with `screen.<id>.title` and
`screen.<id>.description` keys, both pre-translated to en/ja with placeholder
text. Edit the catalog in Xcode to refine the copy.

## Editing existing localization

Edit each module's `Localizable.xcstrings` directly in Xcode. The
`@Metadata(title: .screenXxxTitle, description: .screenXxxDescription, ...)`
references resolve to the module-local symbols automatically; renaming a key
in Xcode regenerates the symbol and surfaces compile errors at the call site.

## Key naming convention

- `app.*` — app-wide UI strings (`MyToyboxCore` / `MyToyboxUI`)
- `tag.*` — tag labels and tag picker UI (`TagPicker`)
- `screen.<id>.title` / `screen.<id>.description` — per-screen metadata

`<id>` is the lowerCamelCase form of the `Screen` enum case name (without the
`Screen` suffix). For example, `case badgeDemoScreen` → `screen.badgeDemo.*`.
