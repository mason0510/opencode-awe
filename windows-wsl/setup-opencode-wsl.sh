#!/bin/bash

# windows-wsl/setup-opencode-wsl.sh
#
# 在 Windows WSL 環境下，為「當前 WSL 用戶」自動配置 OpenCode：
#   - 使用倉庫根目錄的 opencode.json-pub
#   - 用環境變量 OPENAI_API_KEY 生成 ~/.config/opencode/opencode.json
#
# 使用示例（在 WSL shell 中）：
#   cd /path/to/opencode-awe
#   export OPENAI_API_KEY="sk-..."   # 必填，只存在於當前 shell
#   windows-wsl/setup-opencode-wsl.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
TEMPLATE_PATH="$SCRIPT_DIR/opencode.json-pub"

CONFIG_DIR="$HOME/.config/opencode"
TARGET_PATH="$CONFIG_DIR/opencode.json"

echo "[setup-opencode-wsl] Template: $TEMPLATE_PATH"

if [ ! -f "$TEMPLATE_PATH" ]; then
  echo "[setup-opencode-wsl][ERROR] Template not found: $TEMPLATE_PATH" >&2
  exit 1
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "[setup-opencode-wsl][ERROR] OPENAI_API_KEY is not set." >&2
  echo "  請在 WSL 內先 export OPENAI_API_KEY=\"你的 key\"（建議從安全存儲加載）。" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "[setup-opencode-wsl][ERROR] jq is required but not installed inside WSL." >&2
  echo "  在 WSL 中安裝示例：sudo apt update && sudo apt install -y jq" >&2
  exit 1
fi

mkdir -p "$CONFIG_DIR"

echo "[setup-opencode-wsl] Generating config at $TARGET_PATH ..."

tmp_file="$TARGET_PATH.tmp.$$"

# WSL 只需要配置 openai 的 apiKey，不修改 gemini.options.apiKey
jq --arg key "$OPENAI_API_KEY" '
  .provider.openai.options.apiKey = $key
' "$TEMPLATE_PATH" > "$tmp_file"

mv "$tmp_file" "$TARGET_PATH"

echo "[setup-opencode-wsl] Local config updated: $TARGET_PATH"

echo "[setup-opencode-wsl] Done. 現在可以在 WSL 中直接運行 'opencode'（如果已安裝）。"
