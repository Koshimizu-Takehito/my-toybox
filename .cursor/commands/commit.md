## Instructions
以下の3つを直列に実行してください。**それ以外の行動は一切禁止**です。

> 💡 このコマンドはデフォルトシェルが **zsh** であることを前提としています（Bash 互換構文）。

1. 現在の Git の staged な変更を `git diff --cached` で確認する
2. Git の staged な変更をもとに、**英語のコミットメッセージを作成する**
   - メッセージは **Conventional Commits** のフォーマットに**必ず**従うこと
   - 単一行の要約に加え、必要に応じて**複数行の詳細説明**を含めてもよい
   - 複数行の詳細説明は、**行頭をハイフン（`-`）で始める箇条書き**とする
   - 詳細説明の**行数は最大３行**とする。コミットは 3. の方法で改行すること。
   - 記述内容の指針：
     - **変更の背景・理由（Why）** と **影響範囲** を中心に。**実装詳細（How）** は必要な範囲で。
     - **1行あたり 72 文字前後**を目安（CLI やメール連携での可読性向上のため）。
     - 必要に応じて **関連 Issue/PR**、**ブレイキングチェンジ**、**移行手順** などを記載。
3. 作成したコミットメッセージを用いて `git commit` を実行する  
   例（zsh）:  
   ```zsh
   git commit \
    -m 'feat: add new animation easing function' \
    -m $'- Introduces a custom elastic ease-in-out curve.\n- Focused on smoother transition and natural rebound effect.'
   ```
