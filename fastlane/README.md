# fastlane (App Store metadata only)

このプロジェクトでは fastlane を **App Store Connect のメタデータ・スクリーンショット・リリースノート** の同期にのみ使う。
ビルドとアップロードは XcodeCloud が担当しており、`build_app` / `upload_to_testflight` などのビルド系 lane は意図的に持たない。

## ローカルでの初回セットアップ

1. App Store Connect → **Users and Access → Integrations → Keys** から API Key を取得し、`AuthKey_<KEYID>.p8` をこのディレクトリ直下に配置する（`.gitignore` で除外済）。
2. リポジトリ直下の `.env.template` を `.env` にコピーし、Key ID / Issuer ID を埋める。`.env` は gitignore 済み。
   ```sh
   cp .env.template .env
   $EDITOR .env   # ASC_KEY_ID, ASC_ISSUER_ID を記入
   ```
   （`make` がこの `.env` を自動 include するため、`export` は不要。）
3. リポジトリ直下で `make fastlane-setup` を実行する。bundler 経由で fastlane が入り、ASC 側の現状メタデータが `fastlane/metadata/` と `fastlane/screenshots/` にダウンロードされる。

## 日常運用

| 操作 | コマンド |
|---|---|
| ASC 側の最新を取り込む | `make metadata-pull` |
| ローカル変更を検証する | `make metadata-precheck` |
| ローカル変更を ASC に反映する | `make metadata-push` |

## Lanes

- `bundle exec fastlane pull` — メタデータとスクリーンショットを ASC からダウンロードする。
- `bundle exec fastlane push` — メタデータ・スクリーンショット・リリースノートを ASC へアップロードする（バイナリは触らない）。
- `bundle exec fastlane precheck_metadata` — ローカルファイルを ASC ガイドライン違反などについて検証する（アップロードしない）。

## CI

`.github/workflows/app-store-metadata.yml` から `workflow_dispatch` で同じ make ターゲットが叩ける。
詳細はリポジトリ直下の `README.md` の「App Store メタデータ管理」セクションを参照。
