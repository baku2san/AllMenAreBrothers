// ...existing code...

/// 資源の種類
enum ResourceType { rice, salt, iron, cloth }

/// 資源情報
class Resource {
  final ResourceType type;
  final int baseYield; // 基本産出量
  final double demand; // 需要係数
  final double price; // 現在価格

  Resource({
    required this.type,
    required this.baseYield,
    required this.demand,
    required this.price,
  });
}

/// 州モデル

/// 州モデル（水滸伝戦略ゲーム用）
/// 設計書・copilot-instructions.mdの指針に準拠
/// - イミュータブル設計（finalフィールド）
/// - copyWithパターン
/// - 主要パラメータ・計算式を一元管理
class Province {
  /// JSON変換用 toJson
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'population': population,
      'agriculture': agriculture,
      'commerce': commerce,
      'security': security,
      'publicSupport': publicSupport,
      'military': military,
      'resources': resources
          .map((r) => {
                'type': r.type.toString().split('.').last,
                'baseYield': r.baseYield,
                'demand': r.demand,
                'price': r.price,
              })
          .toList(),
      'neighbors': neighbors,
      'development': development,
    };
  }

  /// JSONからの fromJson
  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      name: json['name'] ?? '',
      population: json['population'] ?? 0,
      agriculture: (json['agriculture'] ?? 0).toDouble(),
      commerce: (json['commerce'] ?? 0).toDouble(),
      security: (json['security'] ?? 0).toDouble(),
      publicSupport: (json['publicSupport'] ?? 0).toDouble(),
      military: (json['military'] ?? 0).toDouble(),
      resources: (json['resources'] as List<dynamic>? ?? [])
          .map((r) => Resource(
                type: ResourceType.values.firstWhere(
                  (e) => e.toString().split('.').last == r['type'],
                  orElse: () => ResourceType.rice,
                ),
                baseYield: r['baseYield'] ?? 0,
                demand: (r['demand'] ?? 0).toDouble(),
                price: (r['price'] ?? 0).toDouble(),
              ))
          .toList(),
      neighbors: (json['neighbors'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      development: (json['development'] ?? 0).toDouble(),
    );
  }

  /// 州名
  final String name;

  /// 人口
  final int population;

  /// 隣接州名リスト
  final List<String> neighbors;

  /// 農業力
  final double agriculture;

  /// 商業力
  final double commerce;

  /// 治安（0.0〜1.0）
  final double security;

  /// 民心（0.0〜1.0）
  final double publicSupport;

  /// 軍事力
  final double military;

  /// 資源リスト
  final List<Resource> resources;

  /// 発展度
  final double development;

  /// コンストラクタ
  const Province({
    required this.name,
    required this.population,
    required this.agriculture,
    required this.commerce,
    required this.security,
    required this.publicSupport,
    required this.military,
    required this.resources,
    required this.development,
    this.neighbors = const [],
  });

  /// 税収計算
  /// 税収 = (人口 × 税率 × 民心 × 治安) × 勢力補正
  double taxIncome({
    double taxRate = 0.1,
    double factionBonus = 1.0,
  }) {
    return population * taxRate * publicSupport * security * factionBonus;
  }

  /// 農業収穫量計算
  /// 農業収穫量 = (農業力 × 人口 × 技術補正 × 天候補正 × 災害補正) × 民心補正
  double agricultureYield({
    double techBonus = 1.0,
    double weatherBonus = 1.0,
    double disasterBonus = 1.0,
    double publicSupportBonus = 1.0,
  }) {
    return agriculture * population * techBonus * weatherBonus * disasterBonus * publicSupportBonus;
  }

  /// 商業収益計算
  /// 商業収益 = (商業力 × 人口 × 治安補正 × 交易路数 × 他州友好度) × 市場補正
  double commerceIncome({
    double securityBonus = 1.0,
    int tradeRoutes = 1,
    double friendshipBonus = 1.0,
    double marketBonus = 1.0,
  }) {
    return commerce * population * securityBonus * tradeRoutes * friendshipBonus * marketBonus;
  }

  /// 資源産出量計算
  /// 資源産出量 = Σ(資源ごとに: baseYield × 地理補正 × 労働力補正 × 需要補正)
  double resourceYield({
    double geoBonus = 1.0,
    double laborBonus = 1.0,
  }) {
    double total = 0.0;
    for (final r in resources) {
      total += r.baseYield * geoBonus * laborBonus * r.demand;
    }
    return total;
  }

  /// 交易収益計算
  /// 交易収益 = (交易量 × 交易相手の需要 × 治安 × 友好度) × 価格変動
  double tradeIncome({
    double tradeAmount = 1.0,
    double partnerDemand = 1.0,
    double securityBonus = 1.0,
    double friendshipBonus = 1.0,
    double priceFluctuation = 1.0,
  }) {
    return tradeAmount * partnerDemand * securityBonus * friendshipBonus * priceFluctuation;
  }

  /// 発展度計算
  /// 発展度 = (農業収穫量 + 商業収益 + 資源産出量) × 投資補正 × イベント補正
  double calcDevelopment({
    double investBonus = 1.0,
    double eventBonus = 1.0,
  }) {
    return (agricultureYield() + commerceIncome() + resourceYield()) * investBonus * eventBonus;
  }

  /// イミュータブル更新用 copyWith
  /// 任意のフィールドのみ変更した新インスタンスを返す
  Province copyWith({
    String? name,
    int? population,
    double? agriculture,
    double? commerce,
    double? security,
    double? publicSupport,
    double? military,
    List<Resource>? resources,
    double? development,
    List<String>? neighbors,
  }) {
    return Province(
      name: name ?? this.name,
      population: population ?? this.population,
      agriculture: agriculture ?? this.agriculture,
      commerce: commerce ?? this.commerce,
      security: security ?? this.security,
      publicSupport: publicSupport ?? this.publicSupport,
      military: military ?? this.military,
      resources: resources ?? this.resources,
      development: development ?? this.development,
      neighbors: neighbors ?? this.neighbors,
    );
  }
}
