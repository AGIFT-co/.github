# Git ブランチ運用

## ブランチ戦略

| ブランチ | 用途 | PRマージ先 |
|---------|------|-----------|
| `main` | 本番リリース（商用展開時のみ） | — |
| `dev` | スプリント統合 | `main`（本番リリース時のみ） |
| `feature/*` | 作業ブランチ | `dev` |

## ルール

- `main` への直接 commit・push・PR は本番リリース時のみ。`origin/HEAD` が `main` でも trunk と見なさない
- 作業ブランチからの PR は常に `dev` に向ける
- PR の作成タイミングはユーザーが判断する。AI 側から提案・実行しない
- Issue のクローズは dev マージ時に自動で行われる（設定済み）

## コミット規約

- Conventional Commits（`type: 要約`、`type` = feat / fix / refactor / docs / test / chore / perf / ci）。scope は付けない
- 要約・本文は日本語（コード・識別子は英語のまま）
- **全コミットに関連 Issue 番号を含める**（例: `fix: 越境リンクを修正 (#191)`）。無ければ先に Issue を作成する
- 1 コミット 1 論点
