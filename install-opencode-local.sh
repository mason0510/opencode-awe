#!/bin/bash

# install-opencode-local.sh
#
# 一鍵在「本機」安裝並配置 OpenCode：
#   - 如本地沒有 opencode-awe 倉庫，先自動 git clone
#   - 用環境變量 OPENAI_API_KEY 生成 ~/.config/opencode/opencode.json
#   - 可選：如本機尚未安裝 opencode，使用 OPENCODE_INSTALL_CMD 自動安裝
#
# 使用示例（在新機器上）：
#   export OPENAI_API_KEY="sk-..."                       # 必填，只存在於當前 shell
#   export OPENCODE_INSTALL_CMD="curl -fsSL https://opencode.ai/install.sh | bash"  # 可選
#   curl -fsSL https://raw.githubusercontent.com/mason0510/opencode-awe/main/install-opencode-local.sh | bash

set -euo pipefail

REPO_DIR="${OPENCODE_AWE_DIR:-$HOME/opencode-awe}"
REPO_URL="${OPENCODE_AWE_REPO_URL:-https://github.com/mason0510/opencode-awe.git}"

echo "[install-opencode-local] Target repo dir: $REPO_DIR"

if ! command -v git >/dev/null 2>&1; then
  echo "[install-opencode-local][ERROR] git is required but not installed." >&2
  exit 1
fi

if [ ! -d "$REPO_DIR/.git" ]; then
  echo "[install-opencode-local] Cloning opencode-awe from $REPO_URL ..."
  git clone "$REPO_URL" "$REPO_DIR"
else
  echo "[install-opencode-local] Using existing repo at $REPO_DIR"
fi

TEMPLATE_PATH="$REPO_DIR/opencode.json-pub"

if [ ! -f "$TEMPLATE_PATH" ]; then
  echo "[install-opencode-local][ERROR] Template not found: $TEMPLATE_PATH" >&2
  exit 1
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "[install-opencode-local][ERROR] OPENAI_API_KEY is not set." >&2
  echo "  請在本機 export OPENAI_API_KEY=\"你的 key\"（建議從 keychain-cli 加載）。" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "[install-opencode-local][ERROR] jq is required but not installed." >&2
  echo "  macOS 可用：brew install jq" >&2
  echo "  Linux 可用：apt/yum 安裝 jq" >&2
  exit 1
fi

CONFIG_DIR="$HOME/.config/opencode"
TARGET_PATH="$CONFIG_DIR/opencode.json"

mkdir -p "$CONFIG_DIR"

echo "[install-opencode-local] Generating local config at $TARGET_PATH ..."

tmp_file="$TARGET_PATH.tmp.$$"

jq --arg key "$OPENAI_API_KEY" '
  .provider.openai.options.apiKey = $key |
  .provider.gemini.options.apiKey = $key
' "$TEMPLATE_PATH" > "$tmp_file"

mv "$tmp_file" "$TARGET_PATH"

echo "[install-opencode-local] Local config updated: $TARGET_PATH"

echo "[install-opencode-local] Checking opencode binary on this machine..."

echo "[install-opencode-local] Local config updated: $TARGET_PATH"

echo "[install-opencode-local] Checking opencode binary on this machine..."

if command -v opencode >/dev/null 2>&1; then
  if [ "${OPENCODE_FORCE_REINSTALL:-0}" = "1" ]; then
    echo "[install-opencode-local] opencode detected, FORCE_REINSTALL=1 → cleaning old install..."
    # 嘗試清理默認安裝位置（若存在）
    if [ -d "$HOME/.opencode" ]; then
      echo "  - Removing $HOME/.opencode"
      rm -rf "$HOME/.opencode"
    fi
    if [ -L "/usr/local/bin/opencode" ] || [ -f "/usr/local/bin/opencode" ]; then
      echo "  - Removing /usr/local/bin/opencode"
      sudo rm -f /usr/local/bin/opencode || true
    fi
    # 清理後重新檢查
    hash -r || true
    if command -v opencode >/dev/null 2>&1; then
      echo "  [WARN] opencode 仍在 PATH 中（可能是其他安裝方式），請手動檢查。" >&2
    else
      echo "  [OK] 本地默認安裝已清理。"
    fi
  else
    echo "[install-opencode-local] opencode already installed: $(command -v opencode)"
  fi
fi

if ! command -v opencode >/dev/null 2>&1; then
  echo "[install-opencode-local] opencode not found on this machine after cleanup/检查。"
  if [ -n "${OPENCODE_INSTALL_CMD:-}" ]; then
    echo "[install-opencode-local] Installing opencode via OPENCODE_INSTALL_CMD..."
    # 由用戶提供的命令，這裡不做硬編碼，避免洩漏個人環境
    bash -lc "$OPENCODE_INSTALL_CMD"
  else
    echo "[install-opencode-local][WARN] 未設置 OPENCODE_INSTALL_CMD，跳過自動安裝。" >&2
    echo "  請按官方文檔手動安裝 opencode，或設置 OPENCODE_INSTALL_CMD 後重跑本腳本。" >&2
  fi
fi

echo "[install-opencode-local] Done. 現在可以在本機直接運行 'opencode'（如已安裝）。"
