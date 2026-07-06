#!/usr/bin/env bash
# 全体 Weekly 冒頭の運用: 対象プロジェクトの Status=Done 項目を全件アーカイブする。
# アーカイブ前に board-close-done.sh を実行し、close の整合を取ってから使うこと。
# アーカイブは削除ではない。Project 設定の Archived items ページから復元できる。
set -euo pipefail
cd "$(dirname "$0")"
source lib/board-common.sh

ids="$(gh project item-list "$BOARD_PROJECT_NUMBER" --owner "$BOARD_OWNER" \
  --format json --limit 1000 --query "status:Done" --jq '.items[].id')"

if [ -z "$ids" ]; then
  echo "Done の項目はありません。"
  exit 0
fi

count=0
while read -r id; do
  [ -n "$id" ] || continue
  gh project item-archive "$BOARD_PROJECT_NUMBER" --owner "$BOARD_OWNER" --id "$id" >/dev/null
  count=$((count + 1))
done <<< "$ids"

echo "archived: ${count} 件"
