#!/usr/bin/env bash
# 不変条件「Status=Done の Issue は closed である」を回復する（冪等）。
# 対象プロジェクトで Status=Done かつ open の Issue を全件 close する。
# Done への移動と close は運用中のデーモンが行うため、本スクリプトは取りこぼし時の手動回復用。
set -euo pipefail
cd "$(dirname "$0")"
source lib/board-common.sh

targets="$(gh project item-list "$BOARD_PROJECT_NUMBER" --owner "$BOARD_OWNER" \
  --format json --limit 1000 --query "status:Done is:open" \
  --jq '.items[] | select(.content.number != null) | "\(.content.repository) \(.content.number)"')"

if [ -z "$targets" ]; then
  echo "Status=Done かつ open の Issue はありません。"
  exit 0
fi

count=0
while read -r repo number; do
  [ -n "$number" ] || continue
  echo "close: ${repo}#${number}"
  gh issue close "$number" --repo "$repo" --reason completed \
    --comment "Status=Done のため close します（board-close-done による自動整合）。"
  count=$((count + 1))
done <<< "$targets"

echo "closed: ${count} 件"
