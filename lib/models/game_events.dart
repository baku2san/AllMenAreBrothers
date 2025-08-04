/// 水滸伝ゲームのイベントシステム
/// フェーズ2: イベント基盤、英雄との出会い、歴史的イベント
library;

import '../data/water_margin_map.dart';

import '../models/water_margin_strategy_game.dart' hide Hero;

/// イベントの種類
enum EventType {
  heroEncounter, // 英雄との出会い
  historical, // 歴史的イベント
  random, // ランダムイベント
  battle, // 戦闘イベント
  diplomatic, // 外交イベント
}

/// イベントの選択肢
class EventChoice {
  const EventChoice({
    required this.id,
    required this.text,
    required this.effects,
    this.requirements,
  });

  final String id;
  final String text;
  final List<EventEffect> effects;
  final EventRequirements? requirements;

  /// 選択肢が利用可能かチェック
  bool isAvailable(WaterMarginGameState gameState) {
    if (requirements == null) return true;
    return requirements!.isMet(gameState);
  }
}

/// イベントの効果
class EventEffect {
  const EventEffect({
    required this.type,
    required this.value,
    this.targetId,
  });

  final EventEffectType type;
  final int value;
  final String? targetId; // 対象のID（英雄、州など）

  static const EventEffect gainGold100 = EventEffect(
    type: EventEffectType.goldChange,
    value: 100,
  );

  static const EventEffect loseGold50 = EventEffect(
    type: EventEffectType.goldChange,
    value: -50,
  );

  static const EventEffect gainTroops500 = EventEffect(
    type: EventEffectType.troopsChange,
    value: 500,
  );
}

/// イベント効果の種類
enum EventEffectType {
  goldChange, // 資金変動
  troopsChange, // 兵力変動
  heroRecruitment, // 英雄登用
  provinceControl, // 州の支配権変更
  loyaltyChange, // 民心変動
  relationshipChange, // 関係値変動
}

/// イベントの発生条件
class EventRequirements {
  const EventRequirements({
    this.minTurn,
    this.maxTurn,
    this.requiredProvinces,
    this.requiredHeroes,
    this.minGold,
    this.controlledProvince,
  });

  final int? minTurn;
  final int? maxTurn;
  final List<String>? requiredProvinces;
  final List<String>? requiredHeroes;
  final int? minGold;
  final String? controlledProvince;

  bool isMet(WaterMarginGameState gameState) {
    if (minTurn != null && gameState.currentTurn < minTurn!) return false;
    if (maxTurn != null && gameState.currentTurn > maxTurn!) return false;
    if (minGold != null && gameState.playerGold < minGold!) return false;

    if (requiredProvinces != null) {
      final controlledProvinces = gameState.provinces.values
          .where((p) => WaterMarginMap.initialProvinceFactions[p.name]?.name == Faction.liangshan.name)
          .map((p) => p.name)
          .toSet();
      if (!requiredProvinces!.every((name) => controlledProvinces.contains(name))) {
        return false;
      }
    }

    if (requiredHeroes != null) {
      final recruitedHeroes = gameState.heroes.where((h) => h.isRecruited).map((h) => h.id).toSet();
      if (!requiredHeroes!.every((id) => recruitedHeroes.contains(id))) {
        return false;
      }
    }

    return true;
  }
}

/// ゲームイベント
class GameEvent {
  const GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.choices,
    this.requirements,
    this.isOneTime = false,
  });

  final String id;
  final String title;
  final String description;
  final EventType type;
  final List<EventChoice> choices;
  final EventRequirements? requirements;
  final bool isOneTime; // 一度だけ発生するか

  /// イベントが発生可能かチェック
  bool canTrigger(WaterMarginGameState gameState, Set<String> triggeredEvents) {
    if (isOneTime && triggeredEvents.contains(id)) return false;
    if (requirements != null && !requirements!.isMet(gameState)) return false;
    return true;
  }

  /// 利用可能な選択肢を取得
  List<EventChoice> getAvailableChoices(WaterMarginGameState gameState) {
    return choices.where((choice) => choice.isAvailable(gameState)).toList();
  }
}

/// イベント管理システム
class GameEventSystem {
  /// 全イベント一覧
  static const List<GameEvent> allEvents = [
    // 英雄との出会いイベント
    GameEvent(
      id: 'meet_wu_song',
      title: '武松との出会い',
      description: '景陽岡で虎退治をした豪傑・武松と出会った。梁山泊に誘ってみよう。',
      type: EventType.heroEncounter,
      choices: [
        EventChoice(
          id: 'recruit_wu_song',
          text: '梁山泊に誘う',
          effects: [
            EventEffect(
              type: EventEffectType.heroRecruitment,
              value: 1,
              targetId: 'wu_song',
            ),
          ],
          requirements: EventRequirements(minGold: 200),
        ),
        EventChoice(
          id: 'ignore_wu_song',
          text: '見送る',
          effects: [],
        ),
      ],
      requirements: EventRequirements(minTurn: 5),
      isOneTime: true,
    ),

    GameEvent(
      id: 'meet_li_kui',
      title: '李逵との出会い',
      description: '江州で暴れん坊の李逵と出会った。粗暴だが義理堅い男のようだ。',
      type: EventType.heroEncounter,
      choices: [
        EventChoice(
          id: 'recruit_li_kui',
          text: '仲間に加える',
          effects: [
            EventEffect(
              type: EventEffectType.heroRecruitment,
              value: 1,
              targetId: 'li_kui',
            ),
          ],
        ),
        EventChoice(
          id: 'refuse_li_kui',
          text: '断る',
          effects: [],
        ),
      ],
      requirements: EventRequirements(minTurn: 8),
      isOneTime: true,
    ),

    // 歴史的イベント
    GameEvent(
      id: 'imperial_amnesty',
      title: '朝廷の招安',
      description: '朝廷から招安（恩赦）の使者が来た。梁山泊の今後を決める重要な選択だ。',
      type: EventType.historical,
      choices: [
        EventChoice(
          id: 'accept_amnesty',
          text: '招安を受け入れる',
          effects: [
            EventEffect(type: EventEffectType.goldChange, value: 1000),
            EventEffect(type: EventEffectType.loyaltyChange, value: 20),
          ],
        ),
        EventChoice(
          id: 'reject_amnesty',
          text: '招安を拒否する',
          effects: [
            EventEffect(type: EventEffectType.troopsChange, value: 1000),
            EventEffect(type: EventEffectType.loyaltyChange, value: -10),
          ],
        ),
      ],
      requirements: EventRequirements(
        minTurn: 20,
        requiredHeroes: ['song_jiang'],
      ),
      isOneTime: true,
    ),

    // ランダムイベント
    GameEvent(
      id: 'merchant_caravan',
      title: '商人キャラバン',
      description: '裕福な商人のキャラバンが領内を通過しようとしています。',
      type: EventType.random,
      choices: [
        EventChoice(
          id: 'tax_collection',
          text: '通行税を徴収する',
          effects: [EventEffect.gainGold100],
        ),
        EventChoice(
          id: 'escort_service',
          text: '護衛サービスを提供する',
          effects: [
            EventEffect(type: EventEffectType.goldChange, value: 200),
            EventEffect(
              type: EventEffectType.loyaltyChange,
              value: 10,
            ),
          ],
          requirements: EventRequirements(minGold: 50),
        ),
        EventChoice(
          id: 'rob_caravan',
          text: 'キャラバンを襲う',
          effects: [
            EventEffect(type: EventEffectType.goldChange, value: 500),
            EventEffect(
              type: EventEffectType.loyaltyChange,
              value: -20,
            ),
          ],
        ),
      ],
    ),

    GameEvent(
      id: 'natural_disaster',
      title: '自然災害',
      description: '大雨による洪水が発生し、農作物に被害が出ています。',
      type: EventType.random,
      choices: [
        EventChoice(
          id: 'provide_relief',
          text: '災害救援を行う',
          effects: [
            EventEffect(type: EventEffectType.goldChange, value: -300),
            EventEffect(type: EventEffectType.loyaltyChange, value: 25),
          ],
          requirements: EventRequirements(minGold: 300),
        ),
        EventChoice(
          id: 'ignore_disaster',
          text: '見て見ぬふりをする',
          effects: [
            EventEffect(type: EventEffectType.loyaltyChange, value: -15),
          ],
        ),
      ],
    ),

    GameEvent(
      id: 'bandit_raid',
      title: '盗賊の襲撃',
      description: '近隣の盗賊団が村を襲撃している。どう対処するか？',
      type: EventType.battle,
      choices: [
        EventChoice(
          id: 'fight_bandits',
          text: '盗賊と戦う',
          effects: [
            EventEffect(type: EventEffectType.troopsChange, value: -100),
            EventEffect(type: EventEffectType.loyaltyChange, value: 15),
          ],
        ),
        EventChoice(
          id: 'negotiate_bandits',
          text: '盗賊と交渉する',
          effects: [
            EventEffect(type: EventEffectType.goldChange, value: -200),
          ],
          requirements: EventRequirements(minGold: 200),
        ),
        EventChoice(
          id: 'ignore_bandits',
          text: '関わらない',
          effects: [
            EventEffect(type: EventEffectType.loyaltyChange, value: -10),
          ],
        ),
      ],
    ),

    GameEvent(
      id: 'traveling_scholar',
      title: '旅の学者',
      description: '博識な学者が梁山泊を訪れ、貴重な知識を教えてくれるという。',
      type: EventType.random,
      choices: [
        EventChoice(
          id: 'learn_from_scholar',
          text: '教えを請う',
          effects: [
            EventEffect(type: EventEffectType.goldChange, value: -100),
            EventEffect(type: EventEffectType.loyaltyChange, value: 5),
          ],
          requirements: EventRequirements(minGold: 100),
        ),
        EventChoice(
          id: 'decline_scholar',
          text: '丁重に断る',
          effects: [],
        ),
      ],
    ),

    GameEvent(
      id: 'festival_celebration',
      title: '祭りの開催',
      description: '収穫祭の季節になりました。祭りを開催して民心を上げますか？',
      type: EventType.random,
      choices: [
        EventChoice(
          id: 'hold_festival',
          text: '盛大な祭りを開く',
          effects: [
            EventEffect(type: EventEffectType.goldChange, value: -150),
            EventEffect(type: EventEffectType.loyaltyChange, value: 20),
          ],
          requirements: EventRequirements(minGold: 150),
        ),
        EventChoice(
          id: 'simple_festival',
          text: '質素な祭りにする',
          effects: [
            EventEffect(type: EventEffectType.goldChange, value: -50),
            EventEffect(type: EventEffectType.loyaltyChange, value: 8),
          ],
          requirements: EventRequirements(minGold: 50),
        ),
        EventChoice(
          id: 'no_festival',
          text: '祭りは行わない',
          effects: [
            EventEffect(type: EventEffectType.loyaltyChange, value: -5),
          ],
        ),
      ],
    ),

    GameEvent(
      id: 'spy_infiltration',
      title: '間者の潜入',
      description: '朝廷の間者が梁山泊に潜入しているという情報を得ました。',
      type: EventType.random,
      choices: [
        EventChoice(
          id: 'hunt_spy',
          text: '間者を探し出す',
          effects: [
            EventEffect(type: EventEffectType.goldChange, value: -100),
            EventEffect(type: EventEffectType.loyaltyChange, value: 10),
          ],
          requirements: EventRequirements(minGold: 100),
        ),
        EventChoice(
          id: 'ignore_spy',
          text: '放置する',
          effects: [
            EventEffect(type: EventEffectType.loyaltyChange, value: -8),
          ],
        ),
      ],
    ),

    // 外交イベント
    GameEvent(
      id: 'alliance_proposal',
      title: '同盟の提案',
      description: '近隣の豪族から同盟の提案がありました。',
      type: EventType.diplomatic,
      choices: [
        EventChoice(
          id: 'accept_alliance',
          text: '同盟を結ぶ',
          effects: [
            EventEffect(type: EventEffectType.goldChange, value: -200),
            EventEffect(type: EventEffectType.troopsChange, value: 300),
          ],
          requirements: EventRequirements(minGold: 200),
        ),
        EventChoice(
          id: 'reject_alliance',
          text: '同盟を断る',
          effects: [],
        ),
      ],
    ),
  ];

  /// 発生可能なイベントを取得
  static List<GameEvent> getAvailableEvents(
    WaterMarginGameState gameState,
    Set<String> triggeredEvents,
  ) {
    return allEvents.where((event) => event.canTrigger(gameState, triggeredEvents)).toList();
  }

  /// ランダムイベントを1つ選択
  static GameEvent? getRandomEvent(
    WaterMarginGameState gameState,
    Set<String> triggeredEvents,
  ) {
    final availableEvents = getAvailableEvents(gameState, triggeredEvents);
    if (availableEvents.isEmpty) return null;

    final randomIndex = DateTime.now().millisecondsSinceEpoch % availableEvents.length;
    return availableEvents[randomIndex];
  }

  /// イベント効果を適用
  static WaterMarginGameState applyEventEffects(
    WaterMarginGameState gameState,
    List<EventEffect> effects,
  ) {
    var newGameState = gameState;

    for (final effect in effects) {
      switch (effect.type) {
        case EventEffectType.goldChange:
          newGameState = newGameState.copyWith(
            playerGold: (newGameState.playerGold + effect.value).clamp(0, 999999),
          );
          break;

        case EventEffectType.troopsChange:
          // TODO: 特定の州の兵力を変更する実装
          break;

        case EventEffectType.heroRecruitment:
          if (effect.targetId != null) {
            final updatedHeroes = newGameState.heroes.map((hero) {
              if (hero.id == effect.targetId) {
                return hero.copyWith(isRecruited: true);
              }
              return hero;
            }).toList();
            newGameState = newGameState.copyWith(heroes: updatedHeroes);
          }
          break;

        case EventEffectType.loyaltyChange:
          // TODO: 民心変動の実装
          break;

        case EventEffectType.provinceControl:
          // TODO: 州の支配権変更の実装
          break;

        case EventEffectType.relationshipChange:
          // TODO: 関係値変動の実装
          break;
      }
    }

    return newGameState;
  }
}
