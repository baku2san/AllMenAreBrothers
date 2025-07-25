# 水滸伝戦略ゲーム 設計書

## 1. アーキテクチャ概要
- Flutter（Dart）によるクリーンアーキテクチャ志向
- データモデル（lib/models/）、静的データ（lib/data/）、UI（lib/screens/・lib/widgets/）、ロジック（lib/services/・lib/controllers/）で分離

## 2. 主要データモデル
### Province（州）
- name, population, agriculture, commerce, security, publicSupport, military, resources, development
- 税収・農業収穫・商業収益・資源産出・交易収益・発展度などの計算メソッドを持つ

### Hero（英雄）
- id, name, nickname, stats（武力・知力・魅力・統率・義理）, skill, faction, isRecruited, currentProvinceId, experience

### ProvinceState
- population, agriculture, commerce, security, military, loyalty, food
- 各種計算メソッド（税収・食料生産・消費・兵糧不足判定など）

### WaterMarginGameState
- provinces（Map<String, Province>）、heroes（List<Hero>）、factions（Map<String, Faction>）、currentTurn、playerGold、gameStatus、diplomacy など

## 3. ゲームロジック
- lib/services/strategy_game_service.dart: ターン進行、AI行動、経済・戦闘・イベント処理
- lib/services/economic_command_service.dart: 経済コマンド処理
- lib/services/diplomacy_service.dart: 外交処理
- lib/services/game_save_service.dart: セーブ/ロード

## 4. UI設計
- lib/screens/ 以下に主要画面（メインマップ、州詳細、英雄管理、外交など）
- lib/widgets/ 以下に再利用UI部品（州パネル、英雄カード、コマンドバー、通知など）
- 州や勢力の状態を色・アイコン・グラフで可視化

## 5. 計算式・パラメータ設計
- 仕様書記載の計算式（税収・農業収穫・商業収益・資源産出・交易収益・発展度）をProvince/ProvinceStateで実装
- 各種補正値（勢力・技術・天候・災害・市場・投資・イベント）を引数で受け取れる設計

## 6. 拡張性・テスト
- データモデルはイミュータブル設計、copyWithで状態遷移
- ユニットテスト・ウィジェットテスト・統合テストを想定

## 7. 改善・リファクタリング方針
- 州モデルの二重定義（lib/models/province.dart, water_margin_strategy_game.dart）を統合し一元管理
- パラメータ名・型の統一（loyalty/publicSupport, int/double など）
- 計算式の重複排除・共通化
- サービス層の責務明確化
- UI部品の再利用性向上

---

（詳細はコード・各サービス/モデルを参照）

# クリーンアーキテクチャ詳細設計

## 1. レイヤ構成

- **Presentation（プレゼンテーション/UI）**
  - 画面（screens/）、ウィジェット（widgets/）
  - ViewModel/Controller（controllers/）
- **Application（アプリケーションサービス）**
  - ゲーム進行・AI・コマンド処理（services/strategy_game_service.dart など）
  - ユースケース単位のサービス
- **Domain（ドメイン/ビジネスロジック）**
  - エンティティ（models/Province, Hero, GameState など）
  - ドメインサービス（戦闘・経済・外交ロジック）
- **Infrastructure（インフラ/永続化・外部連携）**
  - データ永続化（game_save_service.dart）
  - 外部API・ファイルIO

## 2. 主要クラス・インターフェース案

### Presentation層

- `MainGameScreen`（メインマップUI）
- `ProvinceDetailScreen`（州詳細UI）
- `HeroManagementScreen`（英雄管理UI）
- `DiplomacyScreen`（外交UI）
- `各種Widget`（州パネル、英雄カード、コマンドバー等）

### Application層

- `WaterMarginGameController`
  - ターン進行、ユーザー操作受付、状態遷移管理
- `StrategyGameService`
  - AI行動、ターン処理、イベント発火
- `EconomicCommandService`
  - 経済コマンドの実行
- `DiplomacyService`
  - 外交コマンドの実行
- `GameSaveService`
  - セーブ/ロード

### Domain層

- `Province`
- `Hero`
- `WaterMarginGameState`
- `Faction`
- `Resource`
- `DomainService`（戦闘・経済・外交の純粋ロジック）

### Infrastructure層

- `GameSaveRepository`（ファイル/DB保存）
- `ExternalApiClient`（将来的な拡張用）

## 3. 各層の責務

- **Presentation**: UI描画・ユーザー入力受付・ViewModel/Controllerへの委譲
- **Application**: ユースケース実装・状態遷移・ドメイン呼び出し
- **Domain**: ビジネスルール・エンティティ・ドメインサービス
- **Infrastructure**: データ保存・外部連携

## 4. 依存関係ルール

- UI→Controller→Service→Domain→Infrastructureの一方向依存
- Domain層は他層に依存しない
- InfrastructureはDomainのインターフェースを実装

## 5. テスト方針

- Domain層：純粋ロジックのユニットテスト
- Application層：ユースケース単位のテスト
- Presentation層：ウィジェットテスト
- Infrastructure層：モック/スタブでテスト

---

（この設計をもとに、各層の責務分離・依存逆転を意識して実装を進めてください）

## 6. 設計リファクタリングToDo

- [x] 州モデル（Province）の二重定義を統合し、パラメータ・型・計算式を整理する
- [x] 計算式の重複排除・共通化（税収・農業収穫・商業収益など）
- [x] サービス層（lib/services/）の責務を明確化し、ロジックの整理方針を立てる
- [x] データモデルのイミュータブル設計・copyWithパターンの徹底
- [x] UI部品の再利用性向上のための設計改善点を整理
- [x] クリーンアーキテクチャの依存関係ルールを守るようディレクトリ・ファイル構成を見直す
- [x] テスト戦略（ユニット・ウィジェット・統合）を設計し、テスト雛形を用意する

### テスト戦略・雛形方針

- Domain層（models, domain_services）は純粋ロジックのユニットテストを徹底し、計算式・状態遷移の正しさを検証する。
- Application層（services）はユースケース単位でテストし、状態遷移・副作用・エラー処理を網羅する。
- Presentation層（screens, widgets, controllers）はウィジェットテスト・ゴールデンテストでUIの表示・操作・イベントを検証する。
- Infrastructure層（repositories, external_api等）はモック/スタブを活用し、外部依存を排除したテストを行う。
- テスト雛形（test/widget_test.dart等）は各層ごとに標準化し、CI/CDで自動実行できる体制を整備する。
- テストコードは日本語コメントで意図・期待値を明記し、仕様変更時も追従しやすい設計とする。

### ディレクトリ・依存関係見直し方針

- Presentation（screens, widgets, controllers）、Application（services）、Domain（models, domain_services）、Infrastructure（repositories, external_api等）でディレクトリを明確に分離する。
- 依存関係は「UI→Controller→Service→Domain→Infrastructure」の一方向のみ許容し、逆依存・循環参照を禁止する。
- ドメイン層（models, domain_services）は他層に依存せず、純粋なビジネスロジックのみを持つ。
- Application層（services）はユースケース単位でファイル分割し、責務ごとに整理する。
- Infrastructure層はDomainのインターフェースを実装し、外部連携・永続化のみ担当する。
- ディレクトリ構成・importルールを定期的にレビューし、設計意図と乖離があれば即修正する。

### UI部品再利用性向上方針

- lib/widgets/配下のUI部品（州パネル・英雄カード・コマンドバー・通知等）はprops（引数）設計を汎用化し、画面ごとの重複実装を排除する。
- データモデル（Province, Hero等）を直接受け取るWidget設計とし、状態・表示ロジックをWidget内で完結させる。
- 色・フォント・アイコン等のスタイルはapp_theme.dart等で一元管理し、UI部品間で統一する。
- StorybookやWidgetテストを活用し、部品単位での動作確認・ドキュメント化を推進する。
- 今後の拡張（新画面・新機能）時も既存部品の再利用を優先し、DRY原則・保守性向上を徹底する。

### イミュータブル設計・copyWith方針

- すべてのデータモデル（Province, Resource, Hero, ProvinceState, GameState等）はfinal/constを徹底し、外部からの状態変更を禁止する。
- 状態遷移や部分更新はcopyWithメソッドを通じてのみ行い、UI・サービス層からもcopyWith経由で新インスタンスを生成する設計とする。
- copyWithは全フィールドをオプション引数で受け取り、未指定時は元の値を維持する標準パターンを採用。
- イミュータブル設計により、テスト容易性・バグ抑制・パフォーマンス最適化（FlutterのWidgetツリー再構築等）を実現する。

### サービス層責務・整理方針

- 各サービスは「ユースケース単位のアプリケーションロジック」を担当し、ドメイン層（モデル・計算式）への依存は最小限にする。
- `StrategyGameService`：ターン進行、AI行動、イベント発火などゲーム全体の進行管理。
- `EconomicCommandService`：徴税・投資・交易など経済コマンドの実行と結果反映。
- `DiplomacyService`：外交コマンドの実行、友好度・同盟・宣戦などの状態管理。
- `GameSaveService`：ゲーム状態の保存・ロード（インフラ層との橋渡し）。
- `FacilityService`：州施設の建設・効果管理。
- サービス層は「状態遷移・副作用の管理」「UI/Controllerからの操作受付」「ドメイン層の純粋ロジック呼び出し」に責任を限定し、ビジネスルール自体はドメイン層に集約する。
- 今後のリファクタリングでは、サービス層の各メソッドが「1ユースケース＝1メソッド」になるよう整理し、テスト容易性・責務分離を徹底する。

### 計算式共通化・一元管理方針

- 税収・農業収穫・商業収益・資源産出・交易収益・発展度などの計算メソッドは Province クラスに集約し、他モデル・サービスからも呼び出せるようにする。
- 省ごとの状態変化や一時的な補正値（勢力・技術・天候・災害・市場・投資・イベント等）はメソッド引数で受け取る設計とする。
- 既存の ProvinceState などに分散していた計算ロジックは Province 側に統合し、必要に応じてラッパーや変換メソッドを用意する。
- 計算式の仕様は docs/spec.md のパラメータ設計・計算式に準拠し、今後の拡張・バランス調整も Province クラスのメソッドを中心に行う。
