# my-toybox

![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS-blue.svg)
![Swift](https://img.shields.io/badge/swift-6.3-orange.svg)
![MIT](https://img.shields.io/badge/license-MIT-black)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Koshimizu-Takehito/my-toybox)
[![App Clip](https://img.shields.io/badge/App%20Clip-Instant-000000?logo=apple&logoColor=white)](https://appclip.apple.com/id?p=com.takehito.koshimizu.MyToybox.MyToyboxClip)

**my-toybox** は、SwiftUI と Metal を活用したさまざまなアニメーションや描画のサンプルを集めた iOS/macOS アプリプロジェクトです。  
複数の画面（Screen）が用意されており、各画面では個性的な UI エフェクトやアニメーションを試すことができます。

<a href="https://apps.apple.com/app/id6743644224" style="display: inline-block; overflow: hidden; border-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&h=b17e195bc020808628890cbe7fcde25f" alt="Download on the App Store" style="border-radius: 13px; width: 250px; height: 83px;"></a>

> 📎 [App Clip でインストール不要で試す（iOS のみ）](https://appclip.apple.com/id?p=com.takehito.koshimizu.MyToybox.MyToyboxClip)

## 概要

- **言語 / フレームワーク**: Swift 6.3, SwiftUI, Metal  
- **プロジェクト形式**: Xcode ワークスペース（`MyToybox.xcworkspace`）  
- **動作環境**: iOS 18+（iPhone/iPad）、macOS 15+  
- **推奨環境**: Xcode 26.4.1 以降  

本プロジェクトは、SwiftUI でのアニメーションや Metal シェーダーを使ったグラフィックス表現を学習・実験するための「おもちゃ箱 (Toybox)」として設計されています。  
アプリを起動すると、サイドバー（またはコンパクト端末では一覧画面）にサンプルの一覧が表示され、選択すると対応するアニメーション／描画サンプルをすぐに実行・確認できます。

## 特徴

### 🔹 豊富なサンプル画面 (Screen)
`Packages/Sources/Screens/` 以下の各フォルダに画面モジュールがあり、それぞれが独自のアニメーションや描画ロジックを持ちます。  
`Packages/Sources/AppScreens/AppScreen.swift` で画面の識別子を一元管理しています。  
`enum AppScreen` の case 名は**Swift の識別子として有効な lowerCamelCase（例: `gameOfLifeScreen`）** で記述する必要があります。

### 🔹 SPM ビルドツールプラグイン
このプロジェクトでは SPM プラグインを使用してビルド時に自動でリソースをコンパイルします：

| プラグイン | 入力 | 出力 |
|-----------|------|------|
| `BuildMetalShaders` | `.metal` ファイル | `default.metallib`（コンパイル済みシェーダー） |

`@Screens` マクロ ([ScreenMacros](https://github.com/Koshimizu-Takehito/ScreenMacros)) により、各 `AppScreen` case が対応する `View` 型に変換されます。

### 🔹 Metal シェーダーによる表現
`MosaicShader.metal` や `WaveParticleShader.metal` など、Metal シェーダーファイルを用いたビジュアルエフェクトを多数実装しています。  
SwiftUI のシェーダーサポートを使い、カスタムの描画を簡潔に呼び出せるよう工夫しています。

### 🔹 Swift Concurrency / async-await
- `async/await` を使って画面データを非同期で読み込みます。
- `@Observable` を使ったシンプルな状態管理を採用しています。
- `NavigationSplitView` などの SwiftUI イディオムを活用しています。

### 🔹 アダプティブナビゲーション
- iPad や横向き時はサイドバー＋詳細表示の `NavigationSplitView` レイアウト。
- iPhone 縦向き時はプッシュ遷移のような動作になります。
- Regular width デバイスでは最初の画面が自動選択されます。

## ディレクトリ構成

```
my-toybox/
  ├─ MyToybox.xcworkspace/         # Xcode ワークスペース（xed . で開く）
  ├─ Makefile                      # ビルドコマンド（後述）
  ├─ App/
  │   ├─ MyToybox.xcodeproj/       # Xcode プロジェクト
  │   └─ MyToybox/
  │       ├─ App.swift             # @main アプリエントリーポイント
  │       └─ Resources/
  │           └─ Assets.xcassets/  # 画像アセットやアプリアイコン
  ├─ Packages/                     # Swift Package
  │   ├─ Package.swift             # Swift Package 定義
  │   ├─ Plugins/
  │   │   └─ BuildMetalShaders/    # Metal コンパイル用 SPM プラグイン
  │   ├─ Sources/
  │   │   ├─ MyToyboxCore/         # コアプロトコルと共有ユーティリティ
  │   │   │   ├─ ScreenMetadata.swift  # 画面メタデータ＆サムネイルのプロトコル定義
  │   │   │   ├─ Tag.swift             # 画面カテゴリ用 Tag enum
  │   │   │   ├─ ThumbnailView.swift   # サムネイル表示ラッパー
  │   │   │   └─ DeepLinkSheet.swift   # URL ベースのディープリンク処理
  │   │   ├─ AppScreens/           # AppScreen.swift と全画面モジュールの配線
  │   │   ├─ ClipScreens/          # App Clip 向け画面カタログ（サブセット）
  │   │   ├─ MockScreens/          # プレビュー・テスト用モック画面カタログ
  │   │   ├─ PlatformSupport/      # プラットフォーム抽象化（PlatformViewRepresentable）
  │   │   ├─ MyToyboxMedia/        # シェーダー画面向け共有メディア
  │   │   └─ Screens/              # 画面ごとの SPM モジュール（SwiftUI ＋任意で Metal）
  │   │       ├─ RootScreen/       # ルートナビゲーション（サイドバー、分割、コンパクトレイアウト）
  │   │       ├─ DetailScreen/     # 個別画面の詳細ビュー
  │   │       ├─ TagPicker/        # タグフィルター UI（SPM モジュール TagPicker）
  │   │       └─ …                 # その他の画面モジュール（Badge、GameOfLife など）
  │   └─ Tests/
  │       └─ MyToyboxCoreTests/    # コアモジュールのユニットテスト
  ├─ MetadatasMacros/              # @Metadatas / @Metadata マクロパッケージ
  ├─ ScreenMacros/                 # @Screens / @Screen マクロパッケージ
  └─ Scripts/
      ├─ build_metallib.sh         # Metal シェーダービルドスクリプト（プラグイン使用）
      ├─ new_screen.sh             # 新規画面作成スクリプト
      └─ check_screen_sync.sh      # 画面の整合性検証スクリプト
```

**主要ファイル:**
- `App.swift`: アプリのエントリーポイント。`RootScreen` が初期画面として指定されています。
- `Packages/Sources/Screens/RootScreen/RootScreen.swift`: アプリ起動時に表示される「画面一覧＋詳細表示」のメインビュー。
- `Packages/Sources/Screens/RootScreen/RootScreenModel.swift`: カタログ一覧の取得・タグによるフィルタリングなどを担当。
- `Packages/Sources/AppScreens/AppScreen.swift`: すべての画面を定義する enum とメタデータを含むファイル。

## インストール & ビルド手順

### 1. リポジトリをクローン
```bash
git clone https://github.com/Koshimizu-Takehito/my-toybox.git
cd my-toybox
```

### 2. Xcode でプロジェクトを開く
```bash
make open
# または
xed .
```
- `MyToybox.xcworkspace` が開き、アプリと SPM パッケージの両方にアクセスできます。
- SPM のみの開発には `Packages/Package.swift` を開いてください。

> **Note**: Metal シェーダーは SPM プラグインによってビルド時に自動コンパイルされます。

### 3. ビルド & 実行
- ターゲットを `MyToybox` に設定し、実機またはシミュレーターを選んで実行してください。

## Makefile コマンド

このプロジェクトには一般的な開発タスク用の `Makefile` が含まれています：

| コマンド | 説明 |
|---------|------|
| `make help` | 利用可能なコマンドを表示 |
| `make open` | プロジェクトを Xcode で開く |
| `make setup` | Mint（必要に応じて）と依存関係をインストール |
| `make sync` | 最新の変更を取得し、依存関係を更新 |
| `make new-screen` | 新規画面を作成（対話モード） |
| `make new-screen NAME=Foo` | `Foo` という名前の新規画面を作成 |
| `make new-screen NAME=Foo SHADER=yes` | Metal シェーダー付きの新規画面を作成 |
| `make lint` | SwiftLint を実行 |
| `make lint-fix` | SwiftLint を自動修正モードで実行 |
| `make lint-strict` | SwiftLint を厳密モードで実行（警告をエラーとして扱う、CI用） |
| `make format` | SwiftFormat でコードをフォーマット |
| `make format-check` | コードフォーマットをチェック（変更なし） |
| `make fix` | コードをフォーマットし、自動修正を適用 |
| `make clean` | ビルドアーティファクトを削除 |
| `make fastlane-setup` | fastlane を導入し、ASC のメタデータを取得 |
| `make metadata-pull` | App Store Connect から最新メタデータ・スクリーンショットを取得 |
| `make metadata-precheck` | アップロードせずにメタデータを検証 |
| `make metadata-push` | メタデータ・スクリーンショット・リリースノートを ASC へ反映 |

### 新規画面の作成

```bash
# 対話モード
make new-screen

# 直接作成
make new-screen NAME=MyNewAnimation

# Metal シェーダー付き
make new-screen NAME=MyShaderEffect SHADER=yes
```

`make new-screen` は新規画面モジュールに `Resources/Localizable.xcstrings` を生成し、`screen.<id>.title` / `screen.<id>.description` キーを定義します。各画面モジュールは自身の localization カタログを所有し、モジュール固有の bundle 経由でシンボルを解決します。

### ローカライゼーション運用

semantic key ルール、CI での強制、運用方針の詳細は以下を参照してください：

- `LOCALIZATION_WORKFLOW.md`（英語）

## App Store メタデータ管理

ビルドのアップロードは **Xcode Cloud** が担当します。
App Store Connect 側のメタデータ（説明文・キーワード・スクリーンショット・
リリースノート等）は **fastlane `deliver` のメタデータ専用モード** で管理し、
バイナリのアップロードは行いません。

### ローカル運用

1. App Store Connect API キー（`.p8`）を `fastlane/AuthKey_<KEYID>.p8` に配置（gitignore 済）。
2. `cp .env.template .env` を作成し、`ASC_KEY_ID` / `ASC_ISSUER_ID` を記入（`.env` は gitignore 済み・`make` が自動 include）。
3. `make fastlane-setup` で fastlane 導入＋ ASC 側現状を `fastlane/metadata/` `fastlane/screenshots/` に取得。
4. 編集後、`make metadata-precheck` で検証 → `make metadata-push` で反映。

詳細は `fastlane/README.md` を参照。

### CI 運用（GitHub Actions）

`.github/workflows/app-store-metadata.yml` から `workflow_dispatch` で同じ
`make metadata-*` を手動実行できます。認証情報は `app-store-connect`
Environment の secret に Required reviewers 付きで保管します。

- `ASC_KEY_ID` — API Key ID
- `ASC_ISSUER_ID` — Issuer ID
- `ASC_KEY_BASE64` — `.p8` を `base64 -i AuthKey_XXX.p8` でエンコードしたもの

`pull` モードを実行すると、ASC からの取り込み結果が `chore/metadata-pull` ブランチで develop に向けて自動 PR されます。

## 使い方

1. アプリを起動すると、一覧（サイドバー）に多数のサンプルが並びます。
2. 任意のサンプル名をタップ（選択）すると、そのアニメーションや描画サンプルが画面に表示されます。
3. iPad や横向き時はサイドバーと詳細画面が同時表示され、ワイドなレイアウトで実行結果を確認できます。

## ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。詳細は [LICENSE](https://github.com/Koshimizu-Takehito/my-toybox/blob/main/LICENSE) をご覧ください。

## 作者

- **Author**: *[Koshimizu-Takehito](https://github.com/Koshimizu-Takehito)*
