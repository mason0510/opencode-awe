#!/bin/bash

# linux/install-opencode-remote.sh
#
# 一鍵在遠程 Linux 服務器上安裝並配置 OpenCode。
#
# 注意：
#   - 腳本默認不會自動卸載已有的 opencode，只是檢測是否存在：
#       * 已安裝 → 跳過安裝步驟，只更新配置
#       * 未安裝 → 執行 OPENCODE_INSTALL_CMD 安裝
#   - 如果你之前用其他方式安裝過，且想「乾淨重裝」，請先手動卸載
#     （例如移除 ~/.opencode、/usr/local/bin/opencode 或按官方文檔執行卸載）。
#
# 前置：
#   1) 本機已安裝 ssh/scp、jq
#   2) 本庫根目錄有 opencode.json-pub 和 opencode-sync-config.sh
#
# 使用方式：
#   cd opencode-awe
#   export OPENAI_API_KEY="sk-xxx"          # 必填，僅在本機環境變量，不會寫入 Git
#   export REMOTE_HOST="1.2.3.4"           # 必填，遠程服務器 IP 或域名
#   export REMOTE_USER="admin"             # 可選，默認 admin；需要有 ssh 權限
#   # 可選：如果遠程未安裝 opencode，需要提供官方安裝命令
#   export OPENCODE_INSTALL_CMD="curl -fsSL https://opencode.ai/install.sh | bash"  # 示例，占位
#   linux/install-opencode-remote.sh

set -euo pipefail

REMOTE_USER="${REMOTE_USER:-admin}"
REMOTE_HOST="${REMOTE_HOST:-}"

if [ -z "$REMOTE_HOST" ]; then
  echo "[install-opencode][ERROR] REMOTE_HOST is not set." >&2
  echo "  示例：export REMOTE_HOST=\"82.29.54.80\"" >&2
  exit 1
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "[install-opencode][ERROR] OPENAI_API_KEY is not set." >&2
  echo "  請先在本機 export OPENAI_API_KEY=\"你的 key\"（建議從 keychain-cli 加載）。" >&2
  exit 1
fi

if ! command -v ssh >/dev/null 2>&1 || ! command -v scp >/dev/null 2>&1; then
  echo "[install-opencode][ERROR] ssh/scp not found on local machine." >&2
  exit 1
fi

echo "[install-opencode] Target: $REMOTE_USER@$REMOTE_HOST"

echo "[install-opencode] Checking opencode on remote..."
if ssh "$REMOTE_USER@$REMOTE_HOST" "command -v opencode >/dev/null 2>&1"; then
  if [ "${OPENCODE_FORCE_REINSTALL:-0}" = "1" ]; then
    echo "[install-opencode] opencode detected on remote, FORCE_REINSTALL=1 → cleaning old install..."
    ssh "$REMOTE_USER@$REMOTE_HOST" '
      set -e
      if [ -d "$HOME/.opencode" ]; then
        echo "  - Removing $HOME/.opencode"
        rm -rf "$HOME/.opencode"
      fi
      if [ -L "/usr/local/bin/opencode" ] || [ -f "/usr/local/bin/opencode" ]; then
        echo "  - Removing /usr/local/bin/opencode"
        sudo rm -f /usr/local/bin/opencode || true
      fi
      hash -r || true
      if command -v opencode >/dev/null 2>&1; then
        echo "  [WARN] opencode 仍在 PATH 中（可能使用其他安裝方式），請人工檢查。" >&2
      else
        echo "  [OK] 默認安裝路徑已清理。"
      fi
    '
  else
    echo "[install-opencode] opencode already installed on remote."
  fi
fi

if ! ssh "$REMOTE_USER@$REMOTE_HOST" "command -v opencode >/dev/null 2>&1"; then
  echo "[install-opencode] opencode not found on remote after cleanup/檢查。"
  if [ -z "${OPENCODE_INSTALL_CMD:-}" ]; then
    echo "[install-opencode][ERROR] OPENCODE_INSTALL_CMD not set, cannot auto-install." >&2
    echo "  請查看官方文檔，設置安裝命令，例如：" >&2
    echo "    export OPENCODE_INSTALL_CMD=\"curl -fsSL https://opencode.ai/install.sh | bash\"" >&2
    exit 1
  fi

  echo "[install-opencode] Installing opencode on remote via OPENCODE_INSTALL_CMD..."
  ssh "$REMOTE_USER@$REMOTE_HOST" "$OPENCODE_INSTALL_CMD"

  echo "[install-opencode] Verifying opencode after install..."
  if ! ssh "$REMOTE_USER@$REMOTE_HOST" "command -v opencode >/dev/null 2>&1"; then
    echo "[install-opencode][ERROR] opencode still not found after running install command." >&2
    exit 1
  fi
fi

echo "[install-opencode] Ensuring global opencode in /usr/local/bin (if possible)..."
ssh "$REMOTE_USER@$REMOTE_HOST" '
  set -e
  if command -v opencode >/dev/null 2>&1; then
    BIN_PATH=$(command -v opencode)
    if [ ! -x "$BIN_PATH" ]; then chmod +x "$BIN_PATH"; fi
    if [ ! -e /usr/local/bin/opencode ]; then
      ln -s "$BIN_PATH" /usr/local/bin/opencode 2>/dev/null || true
    fi
  fi
'

echo "[install-opencode] Installing and syncing config via opencode-sync-config.sh..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

REMOTE_USER="$REMOTE_USER" \
REMOTE_HOST="$REMOTE_HOST" \
OPENAI_API_KEY="$OPENAI_API_KEY" \
"$SCRIPT_DIR/opencode-sync-config.sh"

echo "[install-opencode] Running a simple opencode self-test on remote (opencode --help)..."
ssh "$REMOTE_USER@$REMOTE_HOST" '
  if command -v opencode >/dev/null 2>&1; then
    if opencode --help >/dev/null 2>&1; then
      echo "[install-opencode][remote] Test OK: 'opencode --help' succeeded."
    else
      echo "[install-opencode][remote][WARN] 'opencode --help' 返回非 0，請手動檢查。" >&2
    fi
  else
    echo "[install-opencode][remote][WARN] 無法執行測試：opencode 不在 PATH 中。" >&2
  fi
'

echo "[install-opencode] Done."
