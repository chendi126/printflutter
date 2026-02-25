# 打印费用计算器方案设计 (Print Cost Calculator Design) v3.0

## 1. 项目概述
本项目旨在开发一个基于 Flutter 的移动端应用，用于快速计算打印费用。
支持 **A4文档打印** (阶梯计费) 和 **照片打印** (按张计费) 两种模式。
**核心特性**：
*   **高度自定义**：支持用户在设置中自定义所有价格、阶梯范围以及界面显示的文字名称。
*   **历史记录管理**：自动保存计算记录，支持查看和删除。
*   **现代化 UI**：采用 Material Design 3 风格，卡片式布局，简洁美观，操作流畅。

## 2. 核心功能

### 2.1 计费模式 (Billing Modes)

#### A. A4 文档打印 (Document Printing)
*   **计费逻辑**: 基于页数的阶梯定价，区分单/双面。
*   **默认价格表**:

| 页数范围 (Pages) | 黑白单面 (元/张) | 黑白双面 (元/张) |
| :--- | :--- | :--- |
| **1 - 9** | 0.25 | 0.30 |
| **10 - 99** | 0.20 | 0.25 |
| **100 - 199** | 0.15 | **0.17** |
| **200 及以上** | 0.13 | **0.15** |

*   **计算规则**:
    *   单面：`纸张数 = 页数`
    *   双面：`纸张数 = ceil(页数 / 2)`
    *   总价 = `纸张数 * 对应阶梯单价`

#### B. 照片打印 (Photo Printing)
*   **计费逻辑**: 按尺寸/类型单价计费。
*   **默认价格表**:

| 规格名称 | 单价 (元/张) |
| :--- | :--- |
| **6寸** | 3.00 |
| **3寸** | 3.50 |

### 2.2 历史记录 (History)
*   **自动保存**: 每次计算完成后（或点击“记录”按钮），自动将结果保存到本地。
*   **列表展示**: 按时间倒序展示历史计算记录。每条记录包含：
    *   时间戳 (如 "今天 14:30")
    *   类型 (A4 / 照片)
    *   关键详情 (如 "50页 双面" 或 "6寸 x 5张")
    *   总金额
*   **删除功能**:
    *   **单条删除**: 左滑或长按删除单条记录。
    *   **全部清空**: 提供一键清空所有历史记录的选项。

### 2.3 用户界面 (UI) 设计规范

*   **设计风格**: 现代化、极简主义。
    *   使用 **Card (卡片)** 区分不同功能区块（输入区、结果区、历史区）。
    *   **大字体** 展示总金额，突出重点。
    *   **圆角** 和 **柔和阴影** 提升视觉舒适度。
    *   配色建议：主色调使用清爽的蓝色或青色，金额使用醒目的橙色或红色。

*   **首页 (Home)**:
    *   **顶部**: 模式切换 (SegmentedControl 或 TabBar)。
    *   **中部 (输入卡片)**:
        *   大号数字键盘或输入框。
        *   清晰的开关/选择器。
    *   **下部 (结果卡片)**:
        *   实时显示计算结果。
        *   “保存/记一笔”按钮 (如果非自动保存)。
    *   **底部 (最近历史)**: (可选) 仅显示最近 3 条记录，点击“查看全部”进入历史页。

*   **历史记录页 (History)**:
    *   列表视图，支持侧滑删除。
    *   右上角“清空”按钮。

*   **设置页 (Settings)**:
    *   分组列表 (A4设置 / 照片设置 / 通用)。
    *   支持内联编辑或弹窗编辑价格。

## 3. 技术架构

*   **开发框架**: Flutter (Dart)
*   **状态管理**: `Provider`。
    *   `ConfigProvider`: 价格与文字配置。
    *   `CalculatorProvider`: 计算逻辑。
    *   `HistoryProvider`: 历史记录的增删查。
*   **数据存储**: `shared_preferences`。
    *   配置信息存为 JSON 字符串。
    *   历史记录存为 JSON 列表字符串。

## 4. 数据模型设计 (Data Models)

```dart
// 1. A4 阶梯配置
class TierConfig {
  int minPages;
  int maxPages;
  double singlePrice;
  double doublePrice;
}

// 2. 照片规格配置
class PhotoSku {
  String name;
  double price;
}

// 3. 历史记录
class HistoryRecord {
  String id;
  DateTime timestamp;
  String type; // "document" or "photo"
  String description; // "50页 双面"
  double totalCost;
}

// 4. 全局配置
class AppConfig {
  String documentModeName;
  List<TierConfig> documentTiers;
  String photoModeName;
  List<PhotoSku> photoSkus;
}
```

## 5. 开发计划

1.  **项目初始化**: Flutter create, 依赖安装 (provider, shared_preferences, intl, uuid)。
2.  **数据层**: 实现 Config 和 History 的模型与持久化。
3.  **UI - 设置页**: 优先完成配置功能，因为计算依赖配置。
4.  **UI - 首页**: 实现计算器逻辑与交互。
5.  **UI - 历史页**: 实现记录列表与删除功能。
6.  **美化**: 调整 UI 细节，字体、间距、颜色。
