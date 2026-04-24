#!/usr/bin/env python3
"""
Generate semantic-key based Localizable.xcstrings (English source language),
rewrite @Metadata to type-safe symbol references, and emit symbol helpers.
Run from repo root: python3 Scripts/sync_screen_localization.py
"""
from __future__ import annotations

import ast
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCREENS_ROOT = ROOT / "Packages/Sources/MyToyboxScreens"
SCREEN_DIR = SCREENS_ROOT / "Screens"
CATALOG_PATH = SCREENS_ROOT / "Resources" / "Localizable.xcstrings"

METADATA_BLOCK = re.compile(
    r"@Metadata\(\s*title:\s*(?P<t>[^,]+?)\s*,\s*description:\s*(?P<d>[^,]+?)\s*,\s*tags:\s*(?P<tags>\[[^\]]*\])\s*\)",
    re.MULTILINE | re.DOTALL,
)
STRUCT_DECL = re.compile(r"\bstruct\s+([A-Za-z_][A-Za-z0-9_]*)")
STRING_LITERAL = re.compile(r'^"(?:\\.|[^"])*"$')

# Struct-based semantic IDs (domain-oriented, typo-free).
SCREEN_ID_OVERRIDES: dict[str, str] = {
    "DateformatStyleScreen": "dateFormatStyle",
    "VisualeffectScreen": "visualEffect",
    "RinganimationScreen": "ringAnimation",
    "ViewcontrollerRepresentableScreen": "viewControllerRepresentable",
    "RealTimeMosicScreen": "realTimeMosaic",
    "SqureflowScreen": "squareFlow",
    "Meshgradient2Screen": "meshGradientControlPoints",
    "SolarSystem1Screen": "solarSystemHeliocentric",
    "SolarSystem2Screen": "solarSystemBlend",
    "LissajousCurveDemoScreen1": "lissajousCurveInteractive",
    "LissajousCurveDemoScreen2": "lissajousCurveVariant",
    "DotsSpinnerDemoScreen": "loadingDotsSpinner",
    "OrbitingDotsLoaderDemoScreen": "loadingOrbitingDots",
    "AutoScrolledTextFieldDemoScreen": "autoScrollTailFollow",
    "AutoScrolledTextFieldDemoScreen2": "autoScrollKeyboardAvoidance",
    "UnevenRoundedRectangle1Screen": "unevenRoundedRectanglePerSide",
    "UnevenRoundedRectangle2Screen": "unevenRoundedRectanglePresets",
    "VoronoiDiagramDemoScreen1": "voronoiEuclidean",
    "VoronoiDiagramDemoScreen2": "voronoiCustomMetric",
    "Motions4Screen": "fourMotions",
}

EN_TEXT_REPLACEMENTS: dict[str, str] = {
    "Dateformat Style": "Date Format Style",
    "Enumpicker": "Enum Picker",
    "GradientAnimation": "Gradient Animation",
    "ProgressiveBlur": "Progressive Blur",
    "RadialLayout": "Radial Layout",
    "Ringanimation": "Ring Animation",
    "Scaledmetric Dynamictype": "ScaledMetric and Dynamic Type",
    "Squreflowview": "Square Flow",
    "Uiviewcontrollerrepresentable": "UIViewControllerRepresentable",
    "Visualeffect": "Visual Effect",
    "WaveParticle": "Wave Particle",
}

KEY_TEXT_OVERRIDES: dict[str, tuple[str, str]] = {
    "screen.voronoiEuclidean.title": ("Voronoi (Euclidean)", "ボロノイ図（標準距離）"),
    "screen.voronoiEuclidean.description": ("Voronoi look with familiar distance feel", "いつもの距離感覚でのボロノイ模様"),
    "screen.voronoiCustomMetric.title": ("Voronoi (custom metric)", "ボロノイ図（計量可変）"),
    "screen.voronoiCustomMetric.description": ("Voronoi look when distance rules change", "距離の取り方を変えたときのボロノイ模様"),
}


@dataclass(frozen=True)
class MetadataOccurrence:
    start: int
    end: int
    tags: str
    title_expr: str
    description_expr: str
    screen_id: str


@dataclass(frozen=True)
class Entry:
    key: str
    symbol: str
    en: str
    ja: str


def unescape_swift_string(lit: str) -> str:
    s = lit.strip()
    assert s.startswith('"') and s.endswith('"')
    return ast.literal_eval(s)


def to_camel(parts: list[str]) -> str:
    out: list[str] = []
    for p in parts:
        tokens = [t for t in re.split(r"[^A-Za-z0-9]+", p) if t]
        for token in tokens:
            if not out:
                out.append(token[0].lower() + token[1:])
            else:
                out.append(token[0].upper() + token[1:])
    return ''.join(out) or 'key'


def symbol_name_for_key(key: str) -> str:
    return to_camel(key.split('.'))


def normalize_folder_id(path: Path) -> str:
    rel = path.relative_to(SCREEN_DIR)
    folder = rel.parts[0]
    folder = folder.replace('-', '_')
    folder = re.sub(r'[^A-Za-z0-9_]+', '_', folder)
    return folder[0].lower() + folder[1:]


def struct_name_to_id(struct_name: str) -> str:
    if struct_name in SCREEN_ID_OVERRIDES:
        return SCREEN_ID_OVERRIDES[struct_name]
    trimmed = re.sub(r"(Screen|View)$", "", struct_name)
    return trimmed[0].lower() + trimmed[1:] if trimmed else struct_name


def collect_metadata_occurrences(path: Path, text: str) -> list[MetadataOccurrence]:
    out: list[MetadataOccurrence] = []
    for m in METADATA_BLOCK.finditer(text):
        struct_match = STRUCT_DECL.search(text, m.end())
        if struct_match is None:
            continue
        sid = struct_name_to_id(struct_match.group(1))
        out.append(MetadataOccurrence(
            start=m.start(),
            end=m.end(),
            tags=m.group('tags'),
            title_expr=m.group('t').strip(),
            description_expr=m.group('d').strip(),
            screen_id=sid,
        ))
    return out


def parse_existing_catalog() -> tuple[dict[str, str], dict[str, tuple[str, str]]]:
    ja_to_en: dict[str, str] = {}
    semantic: dict[str, tuple[str, str]] = {}
    if not CATALOG_PATH.exists():
        return ja_to_en, semantic
    raw = CATALOG_PATH.read_text(encoding='utf-8')
    if raw.endswith('\\n'):
        raw = raw[:-2] + '\n'
    data = json.loads(raw)
    source = data.get('sourceLanguage')
    for key, payload in data.get('strings', {}).items():
        loc = payload.get('localizations', {})
        en = loc.get('en', {}).get('stringUnit', {}).get('value')
        ja = loc.get('ja', {}).get('stringUnit', {}).get('value')
        if source == 'ja':
            if isinstance(en, str):
                ja_to_en[key] = en
        else:
            if isinstance(en, str) and isinstance(ja, str):
                semantic[key] = (en, ja)
    return ja_to_en, semantic


def normalized_en(en: str) -> str:
    return EN_TEXT_REPLACEMENTS.get(en, en)


def resolve_from_existing(
    path: Path,
    kind: str,
    screen_id: str,
    semantic_existing: dict[str, tuple[str, str]],
) -> tuple[str, str] | None:
    key = f'screen.{screen_id}.{kind}'
    if key in semantic_existing:
        en, ja = semantic_existing[key]
        return normalized_en(en), ja

    # Backward compatibility: previous generator used folder-based screen IDs.
    old_id = normalize_folder_id(path)
    old_key = f'screen.{old_id}.{kind}'
    if old_key in semantic_existing:
        en, ja = semantic_existing[old_key]
        return normalized_en(en), ja

    return None


def metadata_entries(ja_to_en: dict[str, str], semantic_existing: dict[str, tuple[str, str]]) -> tuple[list[Entry], list[str]]:
    entries: dict[str, Entry] = {}
    errors: list[str] = []

    for path in sorted(SCREEN_DIR.rglob('*.swift')):
        if 'Root' in str(path) or 'TagPicker' in str(path):
            continue
        text = path.read_text(encoding='utf-8')
        occs = collect_metadata_occurrences(path, text)

        for occ in occs:
            for kind, expr in (("title", occ.title_expr), ("description", occ.description_expr)):
                key = f'screen.{occ.screen_id}.{kind}'
                symbol = symbol_name_for_key(key)

                if STRING_LITERAL.fullmatch(expr):
                    ja = unescape_swift_string(expr)
                    en = ja_to_en.get(ja)
                    if en is None:
                        if re.fullmatch(r'[A-Za-z0-9 .,:;!?()/-]+', ja):
                            en = ja
                        else:
                            errors.append(f'{path.relative_to(ROOT)}: missing English translation for {ja!r}')
                            continue
                    en = normalized_en(en)
                else:
                    existing = resolve_from_existing(path=path, kind=kind, screen_id=occ.screen_id, semantic_existing=semantic_existing)
                    if existing is None:
                        errors.append(f"{path.relative_to(ROOT)}: semantic key {key!r} has no existing en/ja")
                        continue
                    en, ja = existing

                if key in KEY_TEXT_OVERRIDES:
                    en, ja = KEY_TEXT_OVERRIDES[key]

                entries[key] = Entry(key=key, symbol=symbol, en=en, ja=ja)

    fixed = {
        'app.title': ('MyToybox', 'MyToybox'),
        'app.selectScreen': ('Please select a screen', '画面を選択してください'),
        'tag.picker.clearAll': ('Deselect All', 'すべて解除'),
        'tag.picker.selectAll': ('Select All', 'すべて選択'),
        'tag.layout': ('Layout', 'レイアウト'),
        'tag.animation': ('Animation', 'アニメーション'),
        'tag.metal': ('Metal', 'Metal'),
    }
    for key, (en, ja) in fixed.items():
        entries[key] = Entry(key=key, symbol=symbol_name_for_key(key), en=en, ja=ja)

    return sorted(entries.values(), key=lambda e: e.key), errors


def write_catalog(entries: list[Entry]) -> None:
    strings: dict[str, dict] = {}
    for e in entries:
        strings[e.key] = {
            'extractionState': 'manual',
            'localizations': {
                'en': {'stringUnit': {'state': 'translated', 'value': e.en}},
                'ja': {'stringUnit': {'state': 'translated', 'value': e.ja}},
            }
        }
    payload = {
        'sourceLanguage': 'en',
        'strings': strings,
        'version': '1.0',
    }
    CATALOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    CATALOG_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def validate_symbol_collisions(entries: list[Entry]) -> None:
    symbol_to_key: dict[str, str] = {}
    duplicates: list[tuple[str, str, str]] = []

    for e in entries:
        prev = symbol_to_key.get(e.symbol)
        if prev and prev != e.key:
            duplicates.append((e.symbol, prev, e.key))
        symbol_to_key[e.symbol] = e.key

    if duplicates:
        print('Symbol collision errors:', file=sys.stderr)
        for symbol, a, b in duplicates:
            print(f'  {symbol}: {a} <-> {b}', file=sys.stderr)
        raise SystemExit(1)


def rewrite_metadata_files(entries: list[Entry]) -> None:
    symbol_by_key = {e.key: e.symbol for e in entries}

    for path in sorted(SCREEN_DIR.rglob('*.swift')):
        if 'Root' in str(path) or 'TagPicker' in str(path):
            continue

        text = path.read_text(encoding='utf-8')
        occs = collect_metadata_occurrences(path, text)
        if not occs:
            continue

        parts: list[str] = []
        cursor = 0
        for occ in occs:
            parts.append(text[cursor:occ.start])
            t_key = f'screen.{occ.screen_id}.title'
            d_key = f'screen.{occ.screen_id}.description'
            replacement = (
                f'@Metadata(title: .{symbol_by_key[t_key]}, '
                f'description: .{symbol_by_key[d_key]}, '
                f'tags: {occ.tags})'
            )
            parts.append(replacement)
            cursor = occ.end
        parts.append(text[cursor:])

        new_text = ''.join(parts)
        if new_text != text:
            path.write_text(new_text, encoding='utf-8')


def main() -> int:
    ja_to_en, semantic_existing = parse_existing_catalog()
    entries, errors = metadata_entries(ja_to_en=ja_to_en, semantic_existing=semantic_existing)
    if errors:
        print('Localization errors:', file=sys.stderr)
        for e in errors:
            print(e, file=sys.stderr)
        return 1

    rewrite_metadata_files(entries)
    write_catalog(entries)
    validate_symbol_collisions(entries)
    print(f'Wrote {CATALOG_PATH} with {len(entries)} keys')
    print('Using Xcode-generated type-safe symbols from Localizable.xcstrings')
    return 0


if __name__ == '__main__':
    sys.exit(main())
