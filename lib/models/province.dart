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
class Province {
  final String name;
  final int population; // 人口
  final double agriculture; // 農業力
  final double commerce; // 商業力
  final double security; // 治安（0.0〜1.0）
  final double publicSupport; // 民心（0.0〜1.0）
  final double military; // 軍事力
  final List<Resource> resources; // 資源リスト
  final double development; // 発展度

  // 勢力補正・技術補正・天候補正・災害補正・市場補正・投資補正・イベント補正などは仮引数
  Province({
    required this.name,
    required this.population,
    required this.agriculture,
    required this.commerce,
    required this.security,
    required this.publicSupport,
    required this.military,
    required this.resources,
    required this.development,
  });

  /// 税収計算
  double taxIncome({
    double taxRate = 0.1,
    double factionBonus = 1.0,
  }) {
    // 税収 = (人口 × 税率 × 民心 × 治安) × 勢力補正
    return population * taxRate * publicSupport * security * factionBonus;
  }

  /// 農業収穫量計算
  double agricultureYield({
    double techBonus = 1.0,
    double weatherBonus = 1.0,
    double disasterBonus = 1.0,
    double publicSupportBonus = 1.0,
  }) {
    // 農業収穫量 = (農業力 × 人口 × 技術補正 × 天候補正 × 災害補正) × 民心補正
    return agriculture * population * techBonus * weatherBonus * disasterBonus * publicSupportBonus;
  }

  /// 商業収益計算
  double commerceIncome({
    double securityBonus = 1.0,
    int tradeRoutes = 1,
    double friendshipBonus = 1.0,
    double marketBonus = 1.0,
  }) {
    // 商業収益 = (商業力 × 人口 × 治安補正 × 交易路数 × 他州友好度) × 市場補正
    return commerce * population * securityBonus * tradeRoutes * friendshipBonus * marketBonus;
  }

  /// 資源産出量計算
  double resourceYield({
    double geoBonus = 1.0,
    double laborBonus = 1.0,
  }) {
    // 資源産出量 = Σ(資源ごとに: baseYield × 地理補正 × 労働力補正 × 需要補正)
    double total = 0.0;
    for (final r in resources) {
      total += r.baseYield * geoBonus * laborBonus * r.demand;
    }
    return total;
  }

  /// 交易収益計算
  double tradeIncome({
    double tradeAmount = 1.0,
    double partnerDemand = 1.0,
    double securityBonus = 1.0,
    double friendshipBonus = 1.0,
    double priceFluctuation = 1.0,
  }) {
    // 交易収益 = (交易量 × 交易相手の需要 × 治安 × 友好度) × 価格変動
    return tradeAmount * partnerDemand * securityBonus * friendshipBonus * priceFluctuation;
  }

  /// 発展度計算
  double calcDevelopment({
    double investBonus = 1.0,
    double eventBonus = 1.0,
  }) {
    // 発展度 = (農業収穫量 + 商業収益 + 資源産出量) × 投資補正 × イベント補正
    return (agricultureYield() + commerceIncome() + resourceYield()) * investBonus * eventBonus;
  }
}
