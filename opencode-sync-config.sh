#!/bin/bash

# opencode-sync-config.sh
#
# 用戶只需要：
#   1) 在本機設置 OPENAI_API_KEY
#   2) 設置 REMOTE_HOST (你的服務器 IP 或域名)
#   3) 可選 REMOTE_USER (默認 admin)
#
# 腳本會：
#   - 讀取當前目錄的 opencode.json-pub
#   - 生成本地 ~/.config/opencode/opencode.json（填入 apiKey）
#   - 將同一份配置上傳到遠程：
#       /home/$REMOTE_USER/.config/opencode/opencode.json
#
# 示例：
#   export OPENAI_API_KEY="sk-xxx"
#   export REMOTE_HOST="82.29.54.80"
#   ./opencode-sync-config.sh

set -euo pipefail

TEMPLATE_PATH="./opencode.json-pub"

CONFIG_DIR="$HOME/.config/opencode"
TARGET_PATH="$CONFIG_DIR/opencode.json"

REMOTE_USER="${REMOTE_USER:-admin}"
REMOTE_HOST="${REMOTE_HOST:-}"
REMOTE_CONFIG_DIR="/home/$REMOTE_USER/.config/opencode"

echo "[opencode-sync] Template: $TEMPLATE_PATH"

# 1. 基本檢查
if [ ! -f "$TEMPLATE_PATH" ]; then
  echo "[ERROR] Template not found: $TEMPLATE_PATH" >&2
  exit 1
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "[ERROR] OPENAI_API_KEY is not set." >&2
  echo "  請先在本機 export OPENAI_API_KEY=\"你的 key\"（建議從 keychain-cli 加載）。" >&2
  exit 1
fi

if [ -z "$REMOTE_HOST" ]; then
  echo "[ERROR] REMOTE_HOST is not set." >&2
  echo "  示例：export REMOTE_HOST=\"82.29.54.80\"" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "[ERROR] jq is required but not installed." >&2
  echo "  macOS 可用：brew install jq" >&2
  exit 1
fi

# 2. 生成本地配置
mkdir -p "$CONFIG_DIR"

echo "[opencode-sync] Generating local opencode.json at $TARGET_PATH ..."

tmp_file="$TARGET_PATH.tmp.$$"

jq --arg key "$OPENAI_API_KEY" '
  .provider.openai.options.apiKey = $key |
  .provider.gemini.options.apiKey = $key
' "$TEMPLATE_PATH" > "$tmp_file"

mv "$tmp_file" "$TARGET_PATH"

echo "[opencode-sync] Local config updated: $TARGET_PATH"

# 3. 同步到遠程伺服器
echo "[opencode-sync] Ensuring remote dir: $REMOTE_USER@$REMOTE_HOST:$REMOTE_CONFIG_DIR"
ssh "$REMOTE_USER@$REMOTE_HOST" "mkdir -p '$REMOTE_CONFIG_DIR'"

echo "[opencode-sync] Uploading config to remote..."
scp "$TARGET_PATH" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_CONFIG_DIR/opencode.json"

echo "[opencode-sync] Remote config updated: $REMOTE_USER@$REMOTE_HOST:$REMOTE_CONFIG_DIR/opencode.json"
echo "[opencode-sync] Done."
