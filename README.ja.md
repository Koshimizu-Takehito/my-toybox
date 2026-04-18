# my-toybox

![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS-blue.svg)
![Swift](https://img.shields.io/badge/swift-6.3-orange.svg)
![MIT](https://img.shields.io/badge/license-MIT-black)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Koshimizu-Takehito/my-toybox)

**my-toybox** は、SwiftUI と Metal を活用したさまざまなアニメーションや描画のサンプルを集めた iOS/macOS アプリプロジェクトです。  
複数の画面（Screen）が用意されており、各画面では個性的な UI エフェクトやアニメーションを試すことができます。

## 概要

- **言語 / フレームワーク**: Swift 6.3, SwiftUI, Metal  
- **プロジェクト形式**: Xcode ワークスペース（`MyToybox.xcworkspace`）  
- **動作環境**: iOS 18+（iPhone/iPad）、macOS 15+  
- **推奨環境**: Xcode 26.4.1 以降  

本プロジェクトは、SwiftUI でのアニメーションや Metal シェーダーを使ったグラフィックス表現を学習・実験するための「おもちゃ箱 (Toybox)」として設計されています。  
アプリを起動すると、サイドバー（またはコンパクト端末では一覧画面）にサンプルの一覧が表示され、選択すると対応するアニメーション／描画サンプルをすぐに実行・確認できます。

## 特徴

### 🔹 豊富なサンプル画面 (Screen)
`Packages/Sources/MyToyboxScreens/Screens/` 以下に多数の画面が定義されており、それぞれが独自のアニメーションや描画ロジックを持ちます。  
`Screen.swift` で画面の識別子を一元管理しています。  
`enum Screen` の case 名は**Swift の識別子として有効な lowerCamelCase（例: `gameOfLifeScreen`）** で記述する必要があります。

### 🔹 SPM ビルドツールプラグイン
このプロジェクトでは SPM プラグインを使用してビルド時に自動でリソースをコンパイルします：

| プラグイン | 入力 | 出力 |
|-----------|------|------|
| `BuildMetalShaders` | `.metal` ファイル | `default.metallib`（コンパイル済みシェーダー） |

`@Screens` マクロ ([ScreenMacros](https://github.com/Koshimizu-Takehito/ScreenMacros)) により、各 `Screen` case が対応する `View` 型に変換されます。

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
  │   │   │   └─ ThumbnailView.swift   # サムネイル表示ラッパー
  │   │   └─ MyToyboxScreens/      # 全画面の実装
  │   │       ├─ Screen.swift      # Screen enum 定義
  │   │       ├─ Exports.swift     # パブリック API エクスポート
  │   │       ├─ Screens/          # 各種アニメーション画面
  │   │       │   └─ Root/         # ルート画面とビューモデル
  │   │       ├─ Shaders/          # Metal シェーダーファイル
  │   │       ├─ TagPicker/        # タグフィルター UI コンポーネント
  │   │       ├─ Utils/            # ユーティリティと Metal シェーダーヘッダ
  │   │       └─ Resources/        # バンドルリソース（アセット、xib）
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
- `RootScreen.swift`: アプリ起動時に表示される「画面一覧＋詳細表示」のメインビュー。
- `RootViewModel.swift`: 画面一覧データの取得など、ビジネスロジックを担当。
- `Screen.swift`: すべての画面を定義する enum とメタデータを含むファイル。

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

### 新規画面の作成

```bash
# 対話モード
make new-screen

# 直接作成
make new-screen NAME=MyNewAnimation

# Metal シェーダー付き
make new-screen NAME=MyShaderEffect SHADER=yes
```

## 使い方

1. アプリを起動すると、一覧（サイドバー）に多数のサンプルが並びます。
2. 任意のサンプル名をタップ（選択）すると、そのアニメーションや描画サンプルが画面に表示されます。
3. iPad や横向き時はサイドバーと詳細画面が同時表示され、ワイドなレイアウトで実行結果を確認できます。

## ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。詳細は [LICENSE](https://github.com/Koshimizu-Takehito/my-toybox/blob/main/LICENSE) をご覧ください。

## 作者

- **Author**: *[Koshimizu-Takehito](https://github.com/Koshimizu-Takehito)*
