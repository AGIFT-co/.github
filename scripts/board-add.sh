#!/usr/bin/env bash
# Issue を対象プロジェクト（BOARD_PROJECT_NUMBER/BOARD_OWNER で指定）に追加し、Status=Backlog を設定する。
# gh issue create はボードへ自動追加されないため、起票後は本スクリプトで追加する。
# 使い方: board-add.sh <issue-url>
set -euo pipefail
cd "$(dirname "$0")"
source lib/board-common.sh

url="${1:?使い方: board-add.sh <issue-url>}"

item_id="$(gh project item-add "$BOARD_PROJECT_NUMBER" --owner "$BOARD_OWNER" --url "$url" --format json --jq '.id')"
fields="$(board_fields_json)"
board_set_status "$item_id" "$fields" "Backlog"

echo "added: ${url} (Status=Backlog, item=${item_id})"
