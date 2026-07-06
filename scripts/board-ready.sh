#!/usr/bin/env bash
# 作業一覧として選定した Issue を Backlog から Ready へ移す。
# 使い方: board-ready.sh <issue-url>
set -euo pipefail
cd "$(dirname "$0")"
source lib/board-common.sh

url="${1:?使い方: board-ready.sh <issue-url>}"
item="$(board_require_item "$url")"
fields="$(board_fields_json)"

board_set_status "$item" "$fields" "Ready"

echo "ready: ${url} (Status=Ready)"
