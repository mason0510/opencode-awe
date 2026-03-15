#!/bin/bash

# windows-wsl/reset-opencode-wsl.sh
#
# 在 Windows WSL 環境中：
#   1) 盡量「徹底卸載」現有的 OpenCode 安裝
#   2) （可選）使用 OPENCODE_INSTALL_CMD 重新安裝 OpenCode
#   3) 調用 setup-opencode-wsl.sh 重新寫入配置並做一次自測
#
# 使用示例（在 WSL shell 中）：
#   cd /path/to/opencode-awe
#   export OPENAI_API_KEY="sk-..."   # 必填，用於重新配置
#   export OPENCODE_INSTALL_CMD="curl -fsSL https://opencode.ai/install.sh | bash"  # 可選，安裝命令
#   windows-wsl/reset-opencode-wsl.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "[reset-opencode-wsl] WSL user : $(whoami)"
echo "[reset-opencode-wsl] HOME     : $HOME"

echo "[reset-opencode-wsl] Step 1: removing existing OpenCode install (if any)..."

if [ -d "$HOME/.opencode" ]; then
  echo "  - Removing $HOME/.opencode"
  rm -rf "$HOME/.opencode"
else
  echo "  - $HOME/.opencode not found (skip)"
fi

if [ -L "/usr/local/bin/opencode" ] || [ -f "/usr/local/bin/opencode" ]; then
  echo "  - Removing /usr/local/bin/opencode (may require sudo)"
  sudo rm -f /usr/local/bin/opencode || true
else
  echo "  - /usr/local/bin/opencode not found (skip)"
fi

if [ -d "$HOME/.config/opencode" ]; then
  echo "  - Removing $HOME/.config/opencode"
  rm -rf "$HOME/.config/opencode"
else
  echo "  - $HOME/.config/opencode not found (skip)"
fi

hash -r || true

echo "[reset-opencode-wsl] Step 2: reinstalling OpenCode (optional)..."

if command -v opencode >/dev/null 2>&1; then
  echo "  [WARN] opencode 仍在 PATH 中，說明有其他安裝來源（請人工檢查）。" >&2
else
  # 默認自動安裝：如未顯式設置 OPENCODE_INSTALL_CMD，使用官方安裝命令
  if [ -z "${OPENCODE_INSTALL_CMD:-}" ]; then
    OPENCODE_INSTALL_CMD="curl -fsSL https://opencode.ai/install.sh | bash"
    echo "  [INFO] 未設置 OPENCODE_INSTALL_CMD，使用默認安裝命令：$OPENCODE_INSTALL_CMD"
  fi

  echo "  - Installing opencode via OPENCODE_INSTALL_CMD..."
  bash -lc "$OPENCODE_INSTALL_CMD"
fi

echo "[reset-opencode-wsl] Step 3: reconfigure OpenCode via windows-wsl/setup-opencode-wsl.sh"

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "  [ERROR] OPENAI_API_KEY 未設置，無法重新寫入配置。" >&2
  echo "         請在 WSL 內 export OPENAI_API_KEY=\"你的 key\" 後重跑本腳本。" >&2
  exit 1
fi

"$ROOT_DIR/windows-wsl/setup-opencode-wsl.sh"

echo "[reset-opencode-wsl] Done."
