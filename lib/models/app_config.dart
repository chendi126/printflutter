
import 'tier_config.dart';
import 'photo_sku.dart';

class AppConfig {
  String documentModeName;
  List<TierConfig> documentTiers;
  String photoModeName;
  List<PhotoSku> photoSkus;

  AppConfig({
    this.documentModeName = 'A4文档打印',
    required this.documentTiers,
    this.photoModeName = '照片打印',
    required this.photoSkus,
  });

  factory AppConfig.defaultConfig() {
    return AppConfig(
      documentTiers: [
        TierConfig(minPages: 1, maxPages: 9, singlePrice: 0.25, doublePrice: 0.30),
        TierConfig(minPages: 10, maxPages: 99, singlePrice: 0.20, doublePrice: 0.25),
        TierConfig(minPages: 100, maxPages: 199, singlePrice: 0.15, doublePrice: 0.17),
        TierConfig(minPages: 200, maxPages: 999999, singlePrice: 0.13, doublePrice: 0.15),
      ],
      photoSkus: [
        PhotoSku(name: '6寸', price: 3.00),
        PhotoSku(name: '3寸', price: 3.50),
      ],
    );
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      documentModeName: json['documentModeName'] ?? 'A4文档打印',
      documentTiers: (json['documentTiers'] as List)
          .map((e) => TierConfig.fromJson(e))
          .toList(),
      photoModeName: json['photoModeName'] ?? '照片打印',
      photoSkus: (json['photoSkus'] as List)
          .map((e) => PhotoSku.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentModeName': documentModeName,
      'documentTiers': documentTiers.map((e) => e.toJson()).toList(),
      'photoModeName': photoModeName,
      'photoSkus': photoSkus.map((e) => e.toJson()).toList(),
    };
  }
}
