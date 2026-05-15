# AGIFT-co — Organization Defaults

AGIFT-co 組織共通のデフォルト設定を管理するリポジトリです。
ここに置いたファイルは、独自の設定を持たない組織内の全リポジトリに自動的に適用されます。

## 含まれるもの

### Issue テンプレート

`.github/ISSUE_TEMPLATE/` 配下に、Issue 種別ごとのテンプレートを定義しています。
Issue 作成時にテンプレートを選択することで、記載内容を統一できます。

| テンプレート | 用途 |
|---|---|
| [bug](/.github/ISSUE_TEMPLATE/bug.md) | 不具合の報告 |
| [enhancement](/.github/ISSUE_TEMPLATE/enhancement.md) | 機能改善 |
| [feature](/.github/ISSUE_TEMPLATE/feature.md) | 新機能開発 |
| [chore](/.github/ISSUE_TEMPLATE/chore.md) | リファクタリング・依存更新・環境整備など |
| [documentation](/.github/ISSUE_TEMPLATE/documentation.md) | ドキュメントの改善・追加 |
| [question](/.github/ISSUE_TEMPLATE/question.md) | チーム内の相談・要件整理 |
| [test](/.github/ISSUE_TEMPLATE/test.md) | 動作確認・テスト |

> [!NOTE]
> 空白の Issue 作成は無効化しています（`blank_issues_enabled: false`）。
> 必ずいずれかのテンプレートを選択してください。

## 関連リポジトリ

| リポジトリ | 説明 |
|---|---|
| [AGIFT-co/dotfiles](https://github.com/AGIFT-co/dotfiles) | 全社共通の開発ツール設定（Claude Code スキルなど） |
