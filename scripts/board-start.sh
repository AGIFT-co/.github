#!/usr/bin/env bash
# 作業開始時の遷移: Status=In progress / Iteration=現行 / Start date=今日。
# Priority(優先度)・Size(実作業工数)・Pre-size(作業予測※AI無し) が未設定なら中断する
# （--priority / --size / --presize で同時に設定できる）。
# 使い方: board-start.sh <issue-url> [--priority <名>] [--size <名>] [--presize <名>]
set -euo pipefail
cd "$(dirname "$0")"
source lib/board-common.sh

FIELD_PRIORITY="Priority(優先度)"
FIELD_SIZE="Size(実作業工数)"
FIELD_PRESIZE="Pre-size(作業予測※AI無し)"
FIELD_ITERATION="Iteration"
FIELD_START_DATE="Start date"

url=""
arg_priority=""
arg_size=""
arg_presize=""
while [ $# -gt 0 ]; do
  case "$1" in
    --priority) arg_priority="${2:?--priority に値が必要}"; shift 2 ;;
    --size)     arg_size="${2:?--size に値が必要}"; shift 2 ;;
    --presize)  arg_presize="${2:?--presize に値が必要}"; shift 2 ;;
    -*) board_die "不明なオプション: $1" ;;
    *) url="$1"; shift ;;
  esac
done
[ -n "$url" ] || board_die "使い方: board-start.sh <issue-url> [--priority <名>] [--size <名>] [--presize <名>]"

item="$(board_require_item "$url")"
fields="$(board_fields_json)"

# 先に全て解決・検証してから書き込む（途中失敗で中途半端に更新しない）
declare -a edits=()
missing=""
check_select() { # <フィールド名> <引数値>
  local fname="$1" arg="$2" fid oid current
  fid="$(board_field_id "$fields" "$fname")"
  if [ -n "$arg" ]; then
    oid="$(board_option_id "$fields" "$fname" "$arg")"
    edits+=("--field-id ${fid} --single-select-option-id ${oid}")
  else
    current="$(board_item_select_value "$item" "$fname")"
    [ -n "$current" ] || missing="${missing}${fname} "
  fi
}
check_select "$FIELD_PRIORITY" "$arg_priority"
check_select "$FIELD_SIZE" "$arg_size"
check_select "$FIELD_PRESIZE" "$arg_presize"
[ -z "$missing" ] || board_die "未設定のフィールドがある: ${missing}（--priority/--size/--presize で指定するか Project 側で設定すること）"

iteration_field_id="$(board_field_id "$fields" "$FIELD_ITERATION")"
iteration_id="$(board_current_iteration_id "$FIELD_ITERATION")"
start_date_field_id="$(board_field_id "$fields" "$FIELD_START_DATE")"
project_id="$(board_project_id)"
today="$(date +%F)"

for e in "${edits[@]+"${edits[@]}"}"; do
  # shellcheck disable=SC2086
  gh project item-edit --id "$item" --project-id "$project_id" $e >/dev/null
done
gh project item-edit --id "$item" --project-id "$project_id" \
  --field-id "$iteration_field_id" --iteration-id "$iteration_id" >/dev/null
gh project item-edit --id "$item" --project-id "$project_id" \
  --field-id "$start_date_field_id" --date "$today" >/dev/null
board_set_status "$item" "$fields" "In progress"

echo "start: ${url} (Status=In progress, Iteration=current, Start date=${today})"
