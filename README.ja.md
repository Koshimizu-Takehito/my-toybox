# my-toybox

![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)
![Swift](https://img.shields.io/badge/swift-6.1-orange.svg)
![MIT](https://img.shields.io/badge/license-MIT-black)

**my-toybox** は、SwiftUI と Metal を活用したさまざまなアニメーションや描画のサンプルを集めた iOS アプリプロジェクトです。  
複数の画面（Screen）が用意されており、各画面では個性的な UI エフェクトやアニメーションを試すことができます。

## 概要

- **言語 / フレームワーク**: Swift, SwiftUI, Metal  
- **プロジェクト形式**: Xcode プロジェクト（`MyToybox.xcodeproj`）  
- **動作環境**: iOS (iPhone/iPad)、Xcode 16.3 以降を推奨  

本プロジェクトは、SwiftUI でのアニメーションや Metal シェーダーを使ったグラフィックス表現を学習・実験するための「おもちゃ箱 (Toybox)」として設計されています。  
アプリを起動すると、サイドバー（またはコンパクト端末では一覧画面）にサンプルの一覧が表示され、選択すると対応するアニメーション／描画サンプルをすぐに実行・確認できます。

## 特徴

1. **豊富なサンプル画面 (Screen)**  
   - `Sources/Screens` 以下に多数の画面が定義されており、それぞれが独自のアニメーションや描画ロジックを持ちます。  
   - `Screen.swift` / `ScreenID.swift` で画面の識別子を一元管理し、`Screens.json` から読み込む仕組みになっています。

2. **Metal シェーダーによる表現**  
   - `MosaicShader.metal` や `WaveParticleShader.metal` など、Metal シェーダーファイルを用いたビジュアルエフェクトを多数実装しています。  
   - SwiftUI のシェーダーサポートを使い、カスタムの描画を簡潔に呼び出せるよう工夫しています。

3. **Swift Concurrency / async-await**  
   - `RootScreenViewModel` 内で `async/await` を使って JSON データを読み込み、メインスレッドに画面一覧をバインドしています。  
   - `@Observable` (Swift 5.9 以降) を使ったシンプルな状態管理を試すことができます。

4. **画面遷移**  
   - SwiftUI の `NavigationSplitView` を使い、iPad や横向き時はサイドバー＋詳細表示、iPhone 縦向き時はプッシュ遷移のような動作になります。  
   - 選択したサンプル画面が右ペイン（または新たな画面）に即時表示されます。

## ディレクトリ構成

```
my-toybox/
  ├─ MyToybox.xcodeproj/         # Xcode プロジェクトファイル
  ├─ MyToybox/
  │   ├─ Resources/
  │   │   └─ Assets.xcassets/    # 画像アセットやアプリアイコン
  │   ├─ Sources/
  │   │   ├─ App/
  │   │   │   └─ App.swift       # @main アプリエントリーポイント
  │   │   ├─ Screens/
  │   │   │   ├─ Root/          # アプリ起点画面 (RootScreen + ViewModel)
  │   │   │   ├─ Screens/       # サンプル画面
  │   │   └─ ...                # アプリ固有の他のソースコード
  │   └─ ...
  └─ ...
```

- `App.swift`: アプリのエントリーポイント。`RootScreen` が初期画面として指定されています。
- `RootScreen.swift`: アプリ起動時に表示される「画面一覧＋詳細表示」のメインビュー。
- `RootScreenViewModel.swift`: 画面一覧データの取得など、ビジネスロジックを担当。
- `Screens.json`: アプリ内で利用する画面情報（`ScreenID`、画面タイトル、説明文など）を JSON フォーマットで保持。

## インストール & ビルド手順

1. **リポジトリをクローン**  
   ```bash
   git clone https://github.com/Koshimizu-Takehito/my-toybox.git
   ```
2. **Xcode でプロジェクトを開く**  
   - `my-toybox/MyToybox.xcodeproj` を Xcode で開きます。
3. **ビルド & 実行**  
   - ターゲットを `MyToybox` に設定し、実機 or シミュレーターを選んで実行してください。

## 使い方

1. アプリを起動すると、一覧（サイドバー）に多数のサンプルが並びます。  
2. 任意のサンプル名をタップ（選択）すると、そのアニメーションや描画サンプルが画面に表示されます。  
3. iPad や横向き時はサイドバーと詳細画面が同時表示され、ワイドなレイアウトで実行結果を確認できます。  

## ライセンス

This project is licensed under the MIT License - see the [LICENSE](https://github.com/Koshimizu-Takehito/my-toybox/blob/main/LICENSE) file for details.

## 作者

- **Author**: *[Koshimizu-Takehito](https://github.com/Koshimizu-Takehito)*
