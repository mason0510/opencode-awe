#!/bin/bash

# diagnose-opencode-config.sh
#
# 用於排查「Unauthorized: API key is required ...」這類錯誤的快速診斷腳本。
# 支持 mac / Linux / WSL，只檢查本機環境，不會打印出你的真實 API Key。
#
# 功能：
#   1) 檢查 opencode 配置文件是否存在 (~/.config/opencode/opencode.json)
#   2) 檢查 openai / gemini 的 apiKey 是否為空（只顯示長度，不顯示內容）
#   3) 檢查 PATH 中是否能找到 opencode 二進制
#   4) 檢查是否有可能覆蓋配置的環境變量（OPENAI_API_KEY 等）
#
# 使用方式：
#   cd opencode-awe
#   chmod +x diagnose-opencode-config.sh   # 第一次
#   ./diagnose-opencode-config.sh

set -euo pipefail

CONFIG_PATH="${OPENCODE_CONFIG_PATH:-$HOME/.config/opencode/opencode.json}"

echo "=== OpenCode configuration diagnostics ==="
echo "User : $(whoami)"
echo "Host : $(hostname)"
echo "OS   : $(uname -a 2>/dev/null || uname)"
echo "HOME : $HOME"
echo

echo "[1] Checking config file location"
echo "    Expected: $CONFIG_PATH"

if [ ! -f "$CONFIG_PATH" ]; then
  echo "    [ERROR] Config file not found at $CONFIG_PATH" >&2
  echo "    建議：先運行對應的配置腳本（如 opencode-sync-config.sh 或 windows-wsl/setup-opencode-wsl.sh）。" >&2
  exit 1
else
  echo "    [OK] Found config file."
fi

if ! command -v jq >/dev/null 2>&1; then
  echo
  echo "[WARN] jq 未安裝，無法解析 JSON，只能確認文件存在。" >&2
  echo "      macOS: brew install jq" >&2
  echo "      Debian/Ubuntu/WSL: sudo apt update && sudo apt install -y jq" >&2
  exit 1
fi

echo
echo "[2] Inspecting API key presence (不顯示具體內容，只顯示長度)"

openai_baseurl=$(jq -r '.provider.openai.options.baseURL // ""' "$CONFIG_PATH")
openai_key=$(jq -r '.provider.openai.options.apiKey // ""' "$CONFIG_PATH")
gemini_baseurl=$(jq -r '.provider.gemini.options.baseURL // ""' "$CONFIG_PATH")
gemini_key=$(jq -r '.provider.gemini.options.apiKey // ""' "$CONFIG_PATH")

len_openai=${#openai_key}
len_gemini=${#gemini_key}

echo "    OpenAI baseURL : ${openai_baseurl:-<empty>}"
echo "    OpenAI apiKey  : length=$len_openai"
if [ "$len_openai" -eq 0 ]; then
  echo "      [PROBLEM] OpenAI apiKey 為空，請用配置腳本填入。" >&2
fi

echo "    Gemini baseURL : ${gemini_baseurl:-<empty>}"
echo "    Gemini apiKey  : length=$len_gemini"
if [ "$len_gemini" -eq 0 ]; then
  echo "      [PROBLEM] Gemini apiKey 為空，請用配置腳本填入。" >&2
fi

echo
echo "[3] Checking opencode binary in PATH"
if command -v opencode >/dev/null 2>&1; then
  bin_path=$(command -v opencode)
  echo "    [OK] opencode found at: $bin_path"
else
  echo "    [WARN] opencode not found in PATH。" >&2
  echo "          這不會直接導致 API key 錯誤，但說明當前 shell 找不到 opencode。" >&2
fi

echo
echo "[4] Checking possible overriding environment variables (只顯示是否設置以及長度)"

check_env_var() {
  local name="$1"
  local val
  val="${!name-}"
  if [ -n "$val" ]; then
    echo "    $name : set (length=${#val})"
  else
    echo "    $name : not set"
  fi
}

check_env_var OPENAI_API_KEY
check_env_var OPENCODE_API_KEY

echo
echo "[5] Summary"

if [ "$len_openai" -eq 0 ] && [ "$len_gemini" -eq 0 ]; then
  echo "    [SUMMARY] 兩個 apiKey 都為空，這是最常見的 'Unauthorized: API key is required' 原因。" >&2
  echo "    建議：" >&2
  echo "      - 設置 OPENAI_API_KEY 後，重新運行對應的配置腳本，例如：" >&2
  echo "          export OPENAI_API_KEY=\"sk-...\"" >&2
  echo "          ./opencode-sync-config.sh        # 遠程配置" >&2
  echo "          或 windows-wsl/setup-opencode-wsl.sh  # WSL 配置" >&2
elif [ "$len_openai" -eq 0 ] || [ "$len_gemini" -eq 0 ]; then
  echo "    [SUMMARY] 有部分 provider 的 apiKey 為空。某些模型調用時會依賴對應的 key。" >&2
else
  echo "    [SUMMARY] 配置文件中兩個 apiKey 都已設置。" >&2
  echo "             如果仍然報 'API key is required'，請檢查：" >&2
  echo "               1) 當前使用的模型是否走了不同的 provider/baseURL" >&2
  echo "               2) 是否在別的環境（例如 WSL / 遠程機）而不是本機運行 opencode" >&2
fi

echo
echo "[diagnose-opencode-config] Done."
