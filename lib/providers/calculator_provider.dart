
import 'package:flutter/foundation.dart';
import '../models/app_config.dart';
import '../models/tier_config.dart';

class CalculatorProvider with ChangeNotifier {
  // 模式: true = 文档, false = 照片
  bool _isDocumentMode = true;
  
  // 文档模式状态
  int _docPages = 0;
  bool _isDoubleSided = false;

  // 照片模式状态
  int _selectedPhotoSkuIndex = 0;
  int _photoCount = 1;

  // Getters
  bool get isDocumentMode => _isDocumentMode;
  int get docPages => _docPages;
  bool get isDoubleSided => _isDoubleSided;
  int get selectedPhotoSkuIndex => _selectedPhotoSkuIndex;
  int get photoCount => _photoCount;

  // Setters
  void setMode(bool isDocument) {
    _isDocumentMode = isDocument;
    notifyListeners();
  }

  void setDocPages(int pages) {
    _docPages = pages;
    notifyListeners();
  }

  void setDoubleSided(bool value) {
    _isDoubleSided = value;
    notifyListeners();
  }

  void setSelectedPhotoSkuIndex(int index) {
    _selectedPhotoSkuIndex = index;
    notifyListeners();
  }

  void setPhotoCount(int count) {
    _photoCount = count;
    notifyListeners();
  }

  // 计算逻辑
  double calculateTotal(AppConfig config) {
    if (_isDocumentMode) {
      return _calculateDocumentCost(config);
    } else {
      return _calculatePhotoCost(config);
    }
  }

  double _calculateDocumentCost(AppConfig config) {
    if (_docPages <= 0) return 0.0;

    int paperCount;
    if (_isDoubleSided) {
      paperCount = (_docPages / 2).ceil();
    } else {
      paperCount = _docPages;
    }

    // 查找匹配的阶梯
    // 注意：设计文档说 "基于页数的阶梯定价"，但计算规则说 "总价 = 纸张数 * 对应阶梯单价"
    // 通常阶梯是按"页数"还是"纸张数"来定单价？
    // 设计文档表格列名是 "页数范围 (Pages)"。
    // 所以单价是根据 "页数" 决定的，还是 "纸张数"？
    // 表格里列名是 "页数范围"。
    // 假设：单价由 *页数* 所在的阶梯决定。
    // 但是计算公式是 `总价 = 纸张数 * 对应阶梯单价`。
    // 让我们再仔细看设计文档。
    // "单面：纸张数 = 页数", "双面：纸张数 = ceil(页数 / 2)"
    // "总价 = 纸张数 * 对应阶梯单价"
    // 表格头： "页数范围 (Pages)" | "黑白单面 (元/张)" | "黑白双面 (元/张)"
    // 这里的 (元/张) 应该是 (元/纸张)。
    // 阶梯判定通常是基于打印的 *总量*。
    // 这里的 "页数范围" 应该是指用户输入的 "页数"。
    
    TierConfig? matchTier;
    for (var tier in config.documentTiers) {
      if (_docPages >= tier.minPages && _docPages <= tier.maxPages) {
        matchTier = tier;
        break;
      }
    }

    // 如果没有匹配到（比如超过最大范围），使用最后一个阶梯
    matchTier ??= config.documentTiers.last;

    double unitPrice = _isDoubleSided ? matchTier.doublePrice : matchTier.singlePrice;
    return paperCount * unitPrice;
  }

  double _calculatePhotoCost(AppConfig config) {
    if (_photoCount <= 0) return 0.0;
    if (config.photoSkus.isEmpty) return 0.0;
    
    if (_selectedPhotoSkuIndex < 0 || _selectedPhotoSkuIndex >= config.photoSkus.length) {
      return 0.0;
    }

    double price = config.photoSkus[_selectedPhotoSkuIndex].price;
    return _photoCount * price;
  }
  
  String getDescription(AppConfig config) {
    if (_isDocumentMode) {
      return '$_docPages页 ${_isDoubleSided ? "双面" : "单面"}';
    } else {
      if (config.photoSkus.isEmpty || _selectedPhotoSkuIndex < 0 || _selectedPhotoSkuIndex >= config.photoSkus.length) {
        return '$_photoCount张';
      }
      return '${config.photoSkus[_selectedPhotoSkuIndex].name} x $_photoCount张';
    }
  }
}
