## Instructions
以下の4つを直列に実行してください。**それ以外の行動は一切禁止**です。

> 💡 このコマンドはデフォルトシェルが **zsh** であることを前提としています（Bash 互換構文）。

1. 現在のブランチと派生元ブランチを確認する
   - `git branch --show-current` で現在のブランチを確認
   - `git remote -v` でリモートリポジトリを確認
   - `BASE=$(git merge-base --fork-point origin/main HEAD 2>/dev/null || echo origin/main)` で基点を設定
   - `git log --oneline "$BASE"..HEAD --graph --decorate` でコミット履歴を確認
   - `git diff "$BASE"..HEAD` で差分を確認

2. プルリクエストのタイトルと説明を作成する
   - タイトル、説明文は**必ず英文**で作成
   - 説明は `.github/pull_request_template.md` のフォーマットに**必ず**従うこと
   - **Summary**、**Changes**、**Motivation & Context** を中心に記載

3. GitHub CLI を使用してプルリクエストを作成する
   ```zsh
   gh pr create \
     --title "feat: add new feature" \
     --body "## Summary
   Brief description of the changes

   ## Changes
   - Added new feature X
   - Improved performance of Y
   - Updated documentation for Z

   ## Motivation & Context
   - Why this change was necessary
   - What problem it solves
   - How it improves the codebase" \
     --base main
   ```

4. 作成されたプルリクエストのURLを表示する
   - `gh pr list --state open --limit 1 --json url --jq '.[0].url'` でプルリクエストのURLを出力する
