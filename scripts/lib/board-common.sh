#!/usr/bin/env bash
# board-*.sh の共通ヘルパー。単体では実行せず、各スクリプトから source する。
# 依存: gh / python3
#
# 対象プロジェクトは環境変数で指定できる。
#   BOARD_PROJECT_NUMBER=5 BOARD_OWNER=AGIFT-co board-list.sh
# 前提: 対象プロジェクトが Status フィールド（Backlog/Ready/In progress/Review/Done）を持つこと。

BOARD_PROJECT_NUMBER="${BOARD_PROJECT_NUMBER:-2}"
BOARD_OWNER="${BOARD_OWNER:-AGIFT-co}"

board_die() {
  echo "error: $*" >&2
  exit 1
}

# プロジェクトの node id（PVT_...）を返す。初回のみ API を呼び、以降は再利用する。
board_project_id() {
  if [ -z "${_BOARD_PROJECT_ID:-}" ]; then
    _BOARD_PROJECT_ID="$(gh project view "$BOARD_PROJECT_NUMBER" --owner "$BOARD_OWNER" --format json --jq '.id')"
    [ -n "$_BOARD_PROJECT_ID" ] || board_die "プロジェクトが見つからない: ${BOARD_OWNER}/${BOARD_PROJECT_NUMBER}"
  fi
  printf '%s' "$_BOARD_PROJECT_ID"
}

# issue URL から対象プロジェクト上の item id を返す。未登録なら空文字。
# 使い方: board_item_id <issue-url>
board_item_id() {
  local url="$1" path owner repo number project_id
  case "$url" in
    https://github.com/*/*/issues/*) ;;
    *) board_die "issue URL の形式が不正: $url" ;;
  esac
  path="${url#https://github.com/}"
  owner="${path%%/*}"
  path="${path#*/}"
  repo="${path%%/*}"
  number="${path##*/}"
  project_id="$(board_project_id)"
  gh api graphql \
    -f query='query($owner:String!,$repo:String!,$num:Int!){repository(owner:$owner,name:$repo){issue(number:$num){projectItems(first:20){nodes{id project{id}}}}}}' \
    -f owner="$owner" -f repo="$repo" -F num="$number" \
    --jq ".data.repository.issue.projectItems.nodes[] | select(.project.id==\"$project_id\") | .id"
}

# item id を返し、未登録なら board-add.sh へ誘導して終了する。
board_require_item() {
  local url="$1" item
  item="$(board_item_id "$url")"
  [ -n "$item" ] || board_die "ボード未登録: $url （先に scripts/board-add.sh で追加すること）"
  printf '%s' "$item"
}

# フィールド定義 JSON（field-list の生 JSON）を返す。
board_fields_json() {
  gh project field-list "$BOARD_PROJECT_NUMBER" --owner "$BOARD_OWNER" --format json --limit 30
}

# 使い方: board_field_id <fields-json> <フィールド名>
board_field_id() {
  printf '%s' "$1" | python3 -c '
import sys, json
name = sys.argv[1]
for f in json.load(sys.stdin)["fields"]:
    if f["name"] == name:
        print(f["id"]); sys.exit(0)
sys.exit(f"field not found: {name}")' "$2"
}

# 単一選択フィールドの選択肢 id を名前で解決する（完全一致、なければ一意な部分一致）。
# 使い方: board_option_id <fields-json> <フィールド名> <選択肢名>
board_option_id() {
  printf '%s' "$1" | python3 -c '
import sys, json
fname, oname = sys.argv[1], sys.argv[2]
for f in json.load(sys.stdin)["fields"]:
    if f["name"] != fname:
        continue
    opts = f.get("options", [])
    exact = [o for o in opts if o["name"] == oname]
    partial = [o for o in opts if oname in o["name"]]
    hit = exact or (partial if len(partial) == 1 else [])
    if hit:
        print(hit[0]["id"]); sys.exit(0)
    names = " / ".join(o["name"] for o in opts)
    sys.exit(f"option not found: {fname}={oname} (choices: {names})")
sys.exit(f"field not found: {fname}")' "$2" "$3"
}

# Status を設定する。
# 使い方: board_set_status <item-id> <fields-json> <Status名>
board_set_status() {
  local item="$1" fields="$2" status_name="$3" field_id option_id
  field_id="$(board_field_id "$fields" "Status")"
  option_id="$(board_option_id "$fields" "Status" "$status_name")"
  gh project item-edit --id "$item" --project-id "$(board_project_id)" \
    --field-id "$field_id" --single-select-option-id "$option_id" >/dev/null
}

# 今日を含む Iteration の id を返す。該当がなければエラー終了。
# field-list の JSON には iteration 期間が含まれないため、GraphQL で直接取得する。
# 使い方: board_current_iteration_id <フィールド名>
board_current_iteration_id() {
  gh api graphql \
    -f query='query($project:ID!,$field:String!){node(id:$project){... on ProjectV2{field(name:$field){... on ProjectV2IterationField{configuration{iterations{id startDate duration}}}}}}}' \
    -f project="$(board_project_id)" -f field="$1" \
  | python3 -c '
import sys, json
from datetime import date, timedelta
its = json.load(sys.stdin)["data"]["node"]["field"]["configuration"]["iterations"]
today = date.today()
for it in its:
    start = date.fromisoformat(it["startDate"])
    if start <= today < start + timedelta(days=it["duration"]):
        print(it["id"]); sys.exit(0)
sys.exit("current iteration not found（今日を含む Iteration を Project 側で作成すること）")'
}

# item の単一選択フィールドの現在値（名前）を返す。未設定なら空文字。
# 使い方: board_item_select_value <item-id> <フィールド名>
board_item_select_value() {
  gh api graphql \
    -f query='query($id:ID!,$field:String!){node(id:$id){... on ProjectV2Item{fieldValueByName(name:$field){... on ProjectV2ItemFieldSingleSelectValue{name}}}}}' \
    -f id="$1" -f field="$2" \
    --jq '.data.node.fieldValueByName.name // ""'
}
