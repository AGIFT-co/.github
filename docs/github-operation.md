# GitHub 運用ルール

本書は AGIFT-co の各プロダクトリポジトリに共通する、GitHub Issue と Projects の運用ルールを定める。
対象は組織内の各プロダクトリポジトリとする。
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
- Project 紐づけ: Issue を組織 Projectへ紐づける

## Project 管理

全プロダクトリポジトリの Issue を、組織横断の Projectへ集約する。
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
Pre-size(作業予測※AI無し) は AI 支援を前提としない見積もりとし、Size とは別に運用する。

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

## Issue の close と Project Status の関係

Issue 自体の open/closed は各リポジトリの設定により、dev ブランチへのマージ時に自動で close される。
一方、Project の Status を Review から Done へ移す操作は、全体 Weekly でのマネージャー確認を経た手動操作とする。
この2つの遷移は独立に発生する。
Issue が close 済みでも Status が Done に達していない状態、または Status が Done でも Issue が open のままの状態が一時的に生じる。
両者を同一視せず、別個の状態として扱う。
