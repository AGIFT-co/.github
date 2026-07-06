#!/usr/bin/env bash
# adServer project (AGIFT-co No.2) の作業対象一覧を取得する。
# 運用ルール（docs/github-operation.md「Issue 一覧の取得」）に従い Status=Done を除外する。
# 使い方: board-list.sh [追加クエリ]
#   例: board-list.sh "assignee:@me"
#   例: board-list.sh "status:Review"
# 出力: gh project item-list の JSON
set -euo pipefail
cd "$(dirname "$0")"
source lib/board-common.sh

EXTRA_QUERY="${1:-}"

gh project item-list "$BOARD_PROJECT_NUMBER" --owner "$BOARD_OWNER" \
  --format json --limit 1000 \
  --query "-status:Done ${EXTRA_QUERY}"
