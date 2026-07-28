#!/usr/bin/env bash
# 公開リポジトリに社内固有情報が混入していないか検査する（正本）。
# CI（.github/workflows/guard-sensitive-content.yml）から実行するほか、手元でも実行できる。
# 依存: git（PCRE 有効ビルド）
#
# 使い方: scripts/check-sensitive.sh
# 終了コード: 0=検出なし / 1=検出あり
#
# 検査対象は追跡ファイルの内容のみとする。コミットメッセージは対象外。
# docs/git-workflow.md が全コミットへの Issue 番号記載を求めており、
# そこに非公開リポジトリ名が正当に現れるため。
set -uo pipefail
cd "$(dirname "$0")/.."

# 本スクリプトと呼び出し元ワークフローは検査パターン自体を含むため、対象から除く。
EXCLUDES=(
  ':(exclude)scripts/check-sensitive.sh'
  ':(exclude).github/workflows/guard-sensitive-content.yml'
)

# 検査ルール: "説明|PCRE パターン"
RULES=(
  "非公開プロダクトのリポジトリ名（-dist 付きの公開リポは除く）|(?i)adserver(?!-(iOS|android)-SDK-dist)"
  "カレンダー日付（リリース日程・マイルストーンの漏洩）|\b20[0-9]{2}-[0-9]{2}-[0-9]{2}\b"
  "社内メールアドレス|@agift\.co\.jp"
  "Project 番号のハードコード|BOARD_PROJECT_NUMBER=[0-9]"
  "Project タイトルのハードコード|BOARD_PROJECT_TITLE=[\"']?[^<\"'\$[:space:]]"
  "認証情報らしき文字列|(gh[pousr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY|xox[baprs]-)"
)

found=0
for rule in "${RULES[@]}"; do
  desc="${rule%%|*}"
  pattern="${rule#*|}"
  if hits="$(git grep -PIn -e "$pattern" -- . "${EXCLUDES[@]}")"; then
    echo "NG: ${desc}" >&2
    printf '%s\n' "$hits" | sed 's/^/  /' >&2
    echo >&2
    found=1
  fi
done

if [ "$found" -ne 0 ]; then
  cat >&2 <<'MSG'
公開リポジトリに社内固有情報が含まれている可能性がある。
固有名は直書きせず、環境変数またはプレースホルダに置き換えること。
検出が誤りの場合は scripts/check-sensitive.sh の RULES を調整する。
MSG
  exit 1
fi

echo "OK: 社内固有情報の混入は検出されなかった。"
