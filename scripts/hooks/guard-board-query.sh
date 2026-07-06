#!/usr/bin/env bash
# Claude Code PreToolUse フック(Bash): 生の `gh project item-*` を止め、正本スクリプトへ誘導する。
# 正本: AGIFT-co/.github の scripts/board-*.sh（Done 除外・ステータス遷移などの運用ルールを内蔵）。
# 登録: 各環境の settings.json の PreToolUse (matcher: Bash) に本ファイルの絶対パスを指定する。
# 意図的な例外は `BOARD_RAW=1 gh project item-edit ...` のように明示して実行する。
set -uo pipefail

payload="$(cat)"
cmd="$(printf '%s' "$payload" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' \
  2>/dev/null || true)"

case "$cmd" in
  *scripts/board-*) exit 0 ;; # 正本スクリプト経由は許可
  *BOARD_RAW=1*) exit 0 ;;    # 明示的な例外（理由をユーザーに説明した上で使う）
  *"gh project item-"*)
    {
      echo "[guard-board-query] 生の gh project item-* は使わない。"
      echo "正本スクリプト（~/github/.github/scripts/）を使うこと:"
      echo "  一覧取得(Done除外):     board-list.sh [追加クエリ]"
      echo "  起票後のボード追加:     board-add.sh <issue-url>"
      echo "  選定 Backlog→Ready:     board-ready.sh <issue-url>"
      echo "  作業開始 →In progress:  board-start.sh <issue-url> [--priority/--size/--presize]"
      echo "  作業完了 →Review:       board-finish.sh <issue-url>"
      echo "  Done→close 整合:        board-close-done.sh"
      echo "  Done アーカイブ:        board-archive-done.sh"
      echo "根拠: AGIFT-co/.github docs/github-operation.md「ボード操作スクリプト（正本）」"
      echo "どうしても生コマンドが必要な場合のみ BOARD_RAW=1 を付けて実行する。"
    } >&2
    exit 2
    ;;
esac

exit 0
