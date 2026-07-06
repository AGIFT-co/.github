#!/usr/bin/env bash
# 作業完了時の遷移: Status=Review / Target date=今日。
# Review から Done への移動は全体 Weekly のマネージャー確認による（本スクリプトでは行わない）。
# 使い方: board-finish.sh <issue-url>
set -euo pipefail
cd "$(dirname "$0")"
source lib/board-common.sh

FIELD_TARGET_DATE="Target date"

url="${1:?使い方: board-finish.sh <issue-url>}"
item="$(board_require_item "$url")"
fields="$(board_fields_json)"

target_date_field_id="$(board_field_id "$fields" "$FIELD_TARGET_DATE")"
today="$(date +%F)"

gh project item-edit --id "$item" --project-id "$(board_project_id)" \
  --field-id "$target_date_field_id" --date "$today" >/dev/null
board_set_status "$item" "$fields" "Review"

echo "finish: ${url} (Status=Review, Target date=${today})"
