# GitHub 運用ルール

本書は AGIFT-co の各プロダクトリポジトリに共通する、GitHub Issue と Projects の運用ルールを定める。
対象は adserver・adserver-api・adserver-iOS-SDK・adserver-android-SDK の4リポジトリとする。
ブランチ戦略・コミット規約はリポジトリ固有の規約（各リポジトリの `.claude/rules/git-workflow.md` 等）に従う。

## Issue テンプレート

`.github/ISSUE_TEMPLATE/` は AGIFT-co/.github が提供し、独自設定を持たない全リポジトリに自動適用される。
プロダクトリポジトリ側に個別のテンプレート定義は不要とする。
テンプレート種別は bug / enhancement / feature / chore / refactor / documentation / question / test の8種。
テンプレート選択時に、対応する種別ラベルが自動付与される。
空白 Issue の作成は無効化されている（`blank_issues_enabled: false`）。

## ラベル

ラベルは13種。うち8種はテンプレートが自動付与する種別ラベル、残り5種は手動で付与する補助ラベルとする。

### 種別ラベル（テンプレート自動付与）

| ラベル | 説明 |
|---|---|
| bug | 予期しない動作・不具合の報告 |
| enhancement | 既存機能の改善 |
| feature | 新機能の開発 |
| chore | 依存更新・ビルド設定・CI/CD など保守作業 |
| refactor | 外部の振る舞いを変えないコードの内部整理 |
| documentation | ドキュメントの改善・追加 |
| question | 確認・相談・ディスカッション |
| test | 動作確認・テストの追加 |

### 補助ラベル（手動付与）

| ラベル | 説明 |
|---|---|
| performance | パフォーマンス改善・最適化 |
| security | セキュリティに関わる問題・改善 |
| breaking-change | 後方互換性を壊す変更 |
| duplicate | 既存 Issue と重複 |
| wontfix | 対応しないと判断したもの |

補助ラベルは種別ラベルを置き換えず、種別ラベルに追加して付与する。

## Issue 作成時の必須設定

Issue 作成時は次の4項目を設定する。

- Assignee: 担当者を割り当てる
- Label: テンプレート由来の種別ラベルに加え、該当する補助ラベルを付与する
- Priority: Project の Priority(優先度) フィールドを設定する
- Project 紐づけ: Issue を組織 Project「adServer project」（No.2）へ紐づける

CLI で起票した Issue はボードへ自動追加されない。
起票後に `scripts/board-add.sh <issue-url>` で追加する（Status=Backlog が設定される）。

## Project 管理（adServer project）

全プロダクトリポジトリの Issue を、組織横断の Project「adServer project」（No.2）へ集約する。
Project への自動追加は使わず、Issue ごとに手動で紐づける。

### フィールド

| フィールド | 選択肢・仕様 |
|---|---|
| Status | Backlog / Ready / In progress / Review / Done |
| Priority(優先度) | 緊急 / 優先度：高 / 優先度：中 / 優先度：低 / 要相談 |
| Size(実作業工数) | 半日(4hour) / 1日(8hour) / 数日(24hour) / 1週間(40hour) / 1週間以上(40hour ↑ ) |
| Pre-size(作業予測※AI無し) | Without AI：半日(4hour) から Without AI：一月以上(120hour ↑ ) までの8段階 |
| Iteration | 1週間単位、月曜開始 |

Size(実作業工数) は AI 支援を前提とした実作業工数の見積もりとする。
Pre-size(作業予測※AI無し) は AI 支援なしの見積もりであり、Size とは別に運用する。

### Status 遷移の手順

Issue の調査・実装作業は次の遷移で運用する。
各遷移は正本スクリプト（後述「ボード操作スクリプト（正本）」）で行う。

| 遷移 | タイミング | 操作 | 設定されるフィールド |
|---|---|---|---|
| Backlog → Ready | 作業一覧として選定したとき | `scripts/board-ready.sh <issue-url>` | Status |
| Ready → In progress | 作業開始 | `scripts/board-start.sh <issue-url>` | Status / Iteration=現行 / Start date=作業開始日 |
| In progress → Review | 作業完了 | `scripts/board-finish.sh <issue-url>` | Status / Target date=作業完了日 |
| Review → Done | 全体 Weekly のマネージャー確認後 | 手動 | Status |

`board-start.sh` は Priority(優先度)・Size(実作業工数)・Pre-size(作業予測※AI無し) の未設定を検出すると中断する。
未設定の場合は `--priority` / `--size` / `--presize` オプションで同時に設定する。

### Issue 一覧の取得

作業対象の Issue 一覧を取得するとき（AI エージェントによる取得を含む）、Status が Done の項目を対象に含めない。
Done は完了済みであり、追加作業の対象外とする。
Review は当該イテレーションの作業スタックであり、追加作業の対象に含めてよい。

CLI では正本スクリプト `scripts/board-list.sh` で取得する。
Done を除外するクエリはスクリプトに内蔵されている。

```bash
scripts/board-list.sh "assignee:@me"  # 追加フィルタは引数で渡す（省略可）
```

## ボード操作スクリプト（正本）

ボードと Issue の定型操作は、本リポジトリの `scripts/` を正本とする（SSOT）。
運用ルール（Done 除外・close 整合・アーカイブ手順）はスクリプトに内蔵し、`gh project` コマンドを直接使わない。

| スクリプト | 用途 |
|---|---|
| `scripts/board-list.sh` | 作業対象一覧の取得（Status=Done を除外） |
| `scripts/board-add.sh` | CLI で起票した Issue のボード追加と Status=Backlog 設定 |
| `scripts/board-ready.sh` | 作業一覧への選定（Backlog → Ready） |
| `scripts/board-start.sh` | 作業開始（→ In progress、Iteration=現行・Start date=当日） |
| `scripts/board-finish.sh` | 作業完了（→ Review、Target date=当日） |
| `scripts/board-close-done.sh` | Status=Done かつ open の Issue を close（冪等） |
| `scripts/board-archive-done.sh` | Status=Done 項目の一括アーカイブ（全体 Weekly 冒頭） |

スクリプトの対象は、省略時は adServer project（AGIFT-co No.2）とする。
別プロジェクトを対象にする場合は環境変数 `BOARD_PROJECT_NUMBER` と `BOARD_OWNER` で指定する。
前提として、対象プロジェクトは Status フィールド（Backlog / Ready / In progress / Review / Done）を持つこと。
フィールド ID・選択肢 ID はスクリプトが実行時に名前から解決するため、ID の管理は不要とする。

AI エージェント（Claude Code）環境では、PreToolUse フック `scripts/hooks/guard-board-query.sh` を settings.json に登録する。
このフックは生の `gh project item-*` を拒否し、正本スクリプトへ誘導する。
どうしても生コマンドが必要な例外は、`BOARD_RAW=1` を付けて明示的に実行する。

## マイルストーン

マイルストーンは期日（due date）を設定して運用する。

| マイルストーン | 内容 | 期日 |
|---|---|---|
| M1 | 要件の再整理 | 2026-05-31 |
| M2 | システム安定化完了 | 2026-06-30 |
| M3 | プレリリース準備完了 | 2026-07-31 |
| M4 | プレリリース運用 | 2026-09-30 |
| M5 | 本リリース | 2026-10-31 |

## 週次レトロスペクティブ

毎週金曜午前に実施する。次を行う。

- 完了 Issue の確認
- KPT（Keep / Problem / Try）
- Backlog から Ready への選定
- Issue の粒度確認
- Iteration の設定

## 全体 Weekly と Status 更新

全体 Weekly でマネージャーが Review 状態の Issue を確認する。
確認後、Status を Review から Done へ手動で移動する。

### Done アイテムのアーカイブ

全体 Weekly の冒頭で、Status が Done の項目を全件アーカイブする。
その後に Review から Done へ移動する。
この順序により、ボードの Done 列には直近1週間分だけが残る。
アーカイブした項目は削除されず、Project 設定の Archived items ページから復元できる。

CLI では正本スクリプト `scripts/board-archive-done.sh` で一括アーカイブする。
実行前に `scripts/board-close-done.sh` を実行し、close の整合を取る。

Projects 組み込みの Auto-archive ワークフローは使用しない。
Auto-archive のフィルタは `is` / `reason` / `updated` のみ対応で、`status` を指定できない。
本運用では Issue の close と Status の Done 移動が独立して発生する。
そのため `is:closed` を条件とする自動アーカイブは、マネージャー確認前の Review 項目まで隠してしまう。

## Issue の close と Project Status の関係

Issue 自体の open/closed は各リポジトリの設定により、dev ブランチへのマージ時に自動で close される。
一方、Project の Status を Review から Done へ移す操作は、全体 Weekly でのマネージャー確認を経た手動操作とする。
この2つの遷移は独立に発生する。
Issue が close 済みでも Status が Done に達していない状態、または Status が Done でも Issue が open のままの状態が一時的に生じる。
両者を同一視せず、別個の状態として扱う。

ただし「Status が Done かつ Issue が open」の状態は不整合であり、放置しない。
不変条件は「Status=Done の Issue は closed」とする。
Done へ移動した Issue は、運用中のデーモンが自動で close する。
デーモンの取りこぼしは `scripts/board-close-done.sh` で回復する（冪等・手動実行）。
