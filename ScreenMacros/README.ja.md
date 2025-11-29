## ScreenMacros

**ScreenMacros** は、画面を表す `enum` から型安全な SwiftUI `View` を自動生成する
Swift マクロパッケージです。

`enum` に `@ScreenRegistry` を付け、必要に応じて各 case に `@Screen` を付けることで、
その `enum` 自体を SwiftUI の `View` として扱えるようになります。

```swift
import SwiftUI
import ScreenMacrosClient

@ScreenRegistry
enum ScreenID {
    case homeScreen
    case detailScreen(id: Int?)
    case loadResult(result: Result<Int, Error>)
}
```

マクロ展開後は次のようなコードが生成されます（View 名は case 名から推論されます）:

```swift
extension ScreenID: View {
    @MainActor @ViewBuilder
    var body: some View {
        switch self {
        case .homeScreen:
            HomeScreen()
        case .detailScreen(id: let id):
            DetailScreen(id: id)
        case .loadResult(result: let result):
            LoadResult(result: result)
        }
    }
}
```

これにより、`ScreenID` をそのまま SwiftUI の `View` として利用できます。

---

## インストール

`Package.swift` に **ScreenMacros** を追加します。

```swift
dependencies: [
    .package(url: "https://github.com/your-account/ScreenMacros.git", from: "0.1.0")
]
```

利用するターゲットでクライアントモジュールを指定します。

```swift
.target(
    name: "YourFeature",
    dependencies: [
        .product(name: "ScreenMacrosClient", package: "ScreenMacros")
    ]
)
```

---

## マクロ一覧

### `@ScreenRegistry`

- **付与先**: `enum`  
- **生成内容**:
  - `extension <Enum>: View`
  - `var body: some View`

`@Screen` が付いていない場合でも、case 名を UpperCamelCase に変換して
View 型を推論します。

```swift
@ScreenRegistry
enum ScreenID {
    case gameOfLifeScreen  // → GameOfLifeScreen()
    case mosaicScreen      // → MosaicScreen()
}
```

### `@Screen`

- **付与先**: `enum case`  
- **用途**: 推論される View 型を上書きしたり、引数ラベルをマッピングしたりする

```swift
@ScreenRegistry
enum ScreenID {
    @Screen(CustomView.self)
    case customScreen

    @Screen(DetailView.self, ["id": "detailId"])
    case detail(id: Int)

    @Screen(["foo": "image"])
    case multiColorImage(foo: Image, colors: [Color])
}
```

---

## アクセスレベルの自動調整

**`@ScreenRegistry` は、元の `enum` のアクセスレベルを自動的に引き継ぎます。**

- **アクセスレベルの対応**
  - `public enum` → `public extension` / `public var body`
  - `internal enum`（修飾子なしを含む）→ 修飾子なしの `extension` / `var body`
  - `fileprivate` / `private` も同様に、元の修飾子をそのまま反映

例:

```swift
@ScreenRegistry
public enum ScreenID {
    case homeScreen
}
```

展開後:

```swift
public enum ScreenID {
    case homeScreen
}

public extension ScreenID: View {
    @MainActor @ViewBuilder
    public var body: some View {
        switch self {
        case .homeScreen:
            HomeScreen()
        }
    }
}
```

これにより、

- `internal enum` に `public var body` が生成されてしまう
- `public enum` なのに extension 側が internal のまま

といったアクセスレベルの不整合を防ぎ、ライブラリとして `public` API を
安全に公開できます。

---

## Optional / Result を含む associated value のサポート

`@ScreenRegistry` は、associated value の**具体的な型には依存せず**、

- case の引数ラベルを `let` で束縛し
- その束縛値を View イニシャライザにそのまま渡す

という単純なルールで動作します。

そのため、`Optional` や `Result` を含むケースもそのまま扱えます。

```swift
@ScreenRegistry
enum ScreenID {
    case optionalDetail(id: Int?)
    case loadResult(result: Result<Int, Error>)
}
```

展開結果:

```swift
extension ScreenID: View {
    @MainActor @ViewBuilder
    var body: some View {
        switch self {
        case .optionalDetail(id: let id):
            OptionalDetail(id: id)
        case .loadResult(result: let result):
            LoadResult(result: result)
        }
    }
}
```

`Optional` / `Result` 以外の複雑なジェネリック型（`[String]` や `Result<[User], Error>` など）でも、
同じルールでそのまま引き回されるため、画面用の `enum` で自由に利用できます。

---

## パラメータマッピング

case の引数ラベルと View のイニシャライザの引数名が異なる場合は、
`@Screen` の第 2 引数としてマッピングを渡します。

```swift
@ScreenRegistry
enum ScreenID {
    @Screen(ProfileView.self, ["userId": "id", "showEdit": "editable"])
    case profile(userId: Int, showEdit: Bool)
}
```

展開結果:

```swift
extension ScreenID: View {
    @MainActor @ViewBuilder
    var body: some View {
        switch self {
        case .profile(userId: let userId, showEdit: let showEdit):
            ProfileView(id: userId, editable: showEdit)
        }
    }
}
```

- マッピングのキーは **case の引数ラベル** と一致している必要があります。
- マッピングに含まれない引数は、そのままのラベル名で View に渡されます。


