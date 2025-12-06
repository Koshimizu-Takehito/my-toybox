.PHONY: clean help

# デフォルトターゲット
help:
	@echo "使用可能なコマンド:"
	@echo "  make clean - ビルド成果物を削除"
	@echo ""
	@echo "注: Metal シェーダーと ScreenID.swift はビルド時に"
	@echo "    SPM プラグインが自動生成します"

# クリーン
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf ~/Library/Developer/Xcode/DerivedData/MyToybox-*
	@rm -rf Packages/.build
	@echo "✅ Clean complete"

