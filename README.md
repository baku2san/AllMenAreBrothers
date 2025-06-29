# 水滸伝戦略ゲーム - All Men Are Brothers

中国古典小説「水滸伝」を題材にしたターン制戦略シミュレーションゲームです。
北宋時代を舞台に、梁山泊を拠点として天下統一を目指すFlutterアプリケーションです。

## 🎮 プレイ

### 🌐 オンラインでプレイ

[![Play Now](https://img.shields.io/badge/🎮_Play_Now-水滸伝戦略ゲーム-2E7D32?style=for-the-badge&logo=flutter)](https://baku2san.github.io/AllMenAreBrothers/)

### 📱 モバイル・デスクトップ対応
- **Web版**: 上記リンクからブラウザで即座にプレイ

### ⚙️ 動作環境
- **推奨ブラウザ**: Chrome, Firefox, Safari, Edge（最新版）
- **必要環境**: モダンWebブラウザ、JavaScript有効
- **画面サイズ**: デスクトップ、タブレット、スマートフォン対応

> 💡 **ヒント**: デスクトップでの操作が最も快適です。モバイルでは横画面表示を推奨します。

## ゲーム概要

### 基本システム
- **ターン制戦略ゲーム**: プレイヤーのターンと敵AIのターンを交互に実行
- **州管理システム**: 各州には人口、農業、商業、治安、軍事、民心の6つのパラメータ
- **勢力システム**: 梁山泊（プレイヤー）、朝廷、豪族、中立、盗賊の5つの勢力
- **歴史的リアリティ**: 水滸伝の世界観と北宋時代の歴史を重視

### 操作方法
- 州をタップして選択・詳細表示
- 右パネルで州の内政や軍事操作
- ターン終了ボタンでターン進行

## 技術仕様

### 開発環境

- **フレームワーク**: Flutter 3.24+
- **言語**: Dart 3.5+
- **対応プラットフォーム**: Web, Android, iOS
- **自動デプロイ**: GitHub Actions → GitHub Pages
- **依存ライブラリ**: provider 6.1.2+, flutter_launcher_icons 0.14.4+

### 最新のアップデート

- ✅ Dart 3.5+対応（null安全化完了）
- ✅ 非推奨API修正（withOpacity → withValues）
- ✅ 依存ライブラリ最新化
- ✅ SVGアイコン生成システム
- ✅ GitHub Actions CI/CD

### プロジェクト構成
```
lib/
├── main.dart                         # メインアプリケーション
├── core/                            # コア設定
│   └── app_config.dart              # アプリ設定・テーマ・定数
├── utils/                           # ユーティリティ
│   └── app_utils.dart               # 共通関数群
├── models/                          # データモデル
│   └── water_margin_strategy_game.dart
├── data/                            # 静的データ
│   ├── water_margin_map.dart        # マップデータ
│   └── water_margin_heroes.dart     # 英雄データ
├── controllers/                     # 状態管理
│   └── water_margin_game_controller.dart # ゲームコントローラー
├── screens/                         # UI画面
│   └── water_margin_game_screen.dart # メインゲーム画面
├── widgets/                         # UIコンポーネント
│   ├── game_map_widget.dart         # マップ表示
│   ├── game_info_panel.dart         # ゲーム情報パネル
│   └── province_detail_panel.dart   # 州詳細パネル
└── services/                        # ゲームロジック（今後実装）
```

### 新機能・改善点（v1.0.0）

- ✅ **GitHub Actions CI/CD**: 自動ビルド・デプロイ
- ✅ **新しいアイコンデザイン**: 中国古典風のSVGアイコン
- ✅ **統一されたテーマ**: `app_config.dart`によるカラーパレット・テーマ管理
- ✅ **コードリファクタリング**: null安全性、型安全性の向上
- ✅ **PWA対応**: プログレッシブWebアプリとして動作
- ✅ **プラットフォーム最適化**: Web/Android/iOS に特化

### 🚀 デプロイメント

このプロジェクトは **GitHub Actions** による自動CI/CDパイプラインを構築しています：

1. **mainブランチへのpush** → 自動ビルド → GitHub Pagesへデプロイ
2. **タグリリース** → 自動リリースノート生成
3. **Web最適化ビルド** → 高速ロード・PWA対応


## 開発・実行方法

### 必要環境
- Flutter SDK 3.6以上
- Dart SDK
- 各プラットフォーム対応の開発環境

### セットアップ
```bash
# 依存関係のインストール
flutter pub get

# 実行
flutter run

# ビルド（例：Android APK）
flutter build apk
```

### 開発指針
- **イミュータブルデザイン**: できる限りfinalやconstを使用
- **関数型プログラミング**: 副作用を避け、純粋関数を優先
- **型安全性**: 明示的な型注釈とnull安全性の活用
- **日本語コメント**: クラス、メソッド、重要なロジックには日本語での説明を記載

## 今後の実装予定

### フェーズ1: 基盤システム（完了）
- ✅ マップ表示とUI基盤
- ✅ 基本的な英雄・勢力データ
- ✅ シンプルな内政システム

### フェーズ2: ゲームプレイ
- 🔄 戦闘システム
- 🔄 英雄育成システム
- 🔄 外交システム
- 🔄 イベントシステム

### フェーズ3: 高度な機能
- ⏳ セーブ/ロード機能
- ⏳ マルチプレイヤー対応
- ⏳ カスタムシナリオ

## 📊 プロジェクト情報

[![Flutter](https://img.shields.io/badge/Flutter-3.6+-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![GitHub Pages](https://img.shields.io/badge/GitHub_Pages-Live-success?style=flat&logo=github)](https://iori.github.io/AllMenAreBrothers/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Auto Deploy](https://img.shields.io/badge/Auto_Deploy-GitHub_Actions-2088FF?style=flat&logo=github-actions)](https://github.com/iori/AllMenAreBrothers/actions)

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 🤝 貢献・フィードバック

- **バグ報告**: [GitHub Issues](https://github.com/iori/AllMenAreBrothers/issues)
- **機能提案**: [GitHub Discussions](https://github.com/iori/AllMenAreBrothers/discussions)
- **プルリクエスト**: コード改善やバグ修正のPRを歓迎します
- **ゲームプレイ**: [実際にプレイ](https://iori.github.io/AllMenAreBrothers/)してフィードバックをお願いします！

---

<div align="center">

**🎮 [今すぐプレイ](https://iori.github.io/AllMenAreBrothers/) | 📖 [開発ドキュメント](docs/) | 🐛 [バグ報告](https://github.com/iori/AllMenAreBrothers/issues)**

**北宋時代の梁山泊で、あなたの天下統一の物語を始めましょう！**

</div>
