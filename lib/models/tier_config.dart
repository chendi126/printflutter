
class TierConfig {
  int minPages;
  int maxPages;
  double singlePrice;
  double doublePrice;

  TierConfig({
    required this.minPages,
    required this.maxPages,
    required this.singlePrice,
    required this.doublePrice,
  });

  factory TierConfig.fromJson(Map<String, dynamic> json) {
    return TierConfig(
      minPages: json['minPages'],
      maxPages: json['maxPages'],
      singlePrice: (json['singlePrice'] as num).toDouble(),
      doublePrice: (json['doublePrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minPages': minPages,
      'maxPages': maxPages,
      'singlePrice': singlePrice,
      'doublePrice': doublePrice,
    };
  }
}
