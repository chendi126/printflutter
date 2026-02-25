
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/tier_config.dart';
import '../models/photo_sku.dart';
import '../providers/config_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<Object, TextEditingController> _controllers = {};

  TextEditingController _ctrl(Object key, String initialText) {
    final cached = _controllers[key];
    if (cached != null) return cached;
    final c = TextEditingController(text: initialText);
    _controllers[key] = c;
    return c;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const GlassNavBar(
        middle: Text('设置'),
      ),
      child: Consumer<ConfigProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: Stack(
              children: [
                const GlassBackground(),
                ListView(
                  children: [
                    _buildOperatorSettings(context, provider),
                    _buildDocumentSettings(context, provider),
                    _buildPhotoSettings(context, provider),
                    _buildFeishuLinkCard(context),
                    _buildResetCard(context),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOperatorSettings(BuildContext context, ConfigProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: CupertinoListSection.insetGrouped(
          backgroundColor: Color(0x00000000),
          header: Text('同步与标注', style: const TextStyle(color: CupertinoColors.label)),
          children: [
            CupertinoListTile(
              title: const Text('操作人员', style: TextStyle(color: CupertinoColors.label)),
              trailing: SizedBox(
                width: 180,
                child: CupertinoTextField(
                  controller: _ctrl('operatorName', provider.config.operatorName),
                  placeholder: '操作人员',
                  textAlign: TextAlign.end,
                  decoration: null,
                  onChanged: (value) {
                    final newConfig = provider.config.copyWith(operatorName: value);
                    provider.updateConfig(newConfig);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentSettings(BuildContext context, ConfigProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: CupertinoListSection.insetGrouped(
          backgroundColor: Color(0x00000000),
          header: Text('文档打印设置', style: const TextStyle(color: CupertinoColors.label)),
          children: [
            CupertinoListTile(
              title: const Text('模式名称', style: TextStyle(color: CupertinoColors.label)),
              trailing: SizedBox(
                width: 150,
                child: CupertinoTextField(
                  controller: _ctrl('documentModeName', provider.config.documentModeName),
                  placeholder: '模式名称',
                  textAlign: TextAlign.end,
                  decoration: null,
                  onChanged: (value) {
                    final newConfig = provider.config.copyWith(documentModeName: value);
                    provider.updateConfig(newConfig);
                  },
                ),
              ),
            ),
            ...provider.config.documentTiers.asMap().entries.map((entry) {
              int index = entry.key;
              TierConfig tier = entry.value;
              return _buildTierRow(context, provider, index, tier);
            }),
            CupertinoListTile(
              title: const Text('添加阶梯'),
              leading: const Icon(CupertinoIcons.add_circled, color: CupertinoColors.activeBlue),
              onTap: () => _addTier(provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierRow(BuildContext context, ConfigProvider provider, int index, TierConfig tier) {
    return Dismissible(
      key: ValueKey(tier),
      direction: DismissDirection.endToStart,
      background: Container(
        color: CupertinoColors.destructiveRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white),
      ),
      onDismissed: (direction) {
        final newTiers = List<TierConfig>.from(provider.config.documentTiers)..removeAt(index);
        final newConfig = provider.config.copyWith(documentTiers: newTiers);
        provider.updateConfig(newConfig);
      },
      child: CupertinoListTile(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Column(
          children: [
            Row(
              children: [
                const Text('页数: ', style: TextStyle(fontSize: 14, color: CupertinoColors.label)),
                Expanded(
                  child: CupertinoTextField(
                    controller: _ctrl('tier-${tier.hashCode}-min', tier.minPages.toString()),
                    keyboardType: TextInputType.number,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                    onChanged: (val) {
                      tier.minPages = int.tryParse(val) ?? 0;
                      provider.updateConfig(provider.config);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text('-', style: TextStyle(color: CupertinoColors.secondaryLabel)),
                ),
                Expanded(
                  child: CupertinoTextField(
                    controller: _ctrl('tier-${tier.hashCode}-max', tier.maxPages.toString()),
                    keyboardType: TextInputType.number,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                    onChanged: (val) {
                      tier.maxPages = int.tryParse(val) ?? 999999;
                      provider.updateConfig(provider.config);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('单面: ', style: TextStyle(fontSize: 14, color: CupertinoColors.label)),
                Expanded(
                  child: CupertinoTextField(
                    controller: _ctrl('tier-${tier.hashCode}-single', tier.singlePrice.toString()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                    suffix: const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Text('元', style: TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel)),
                    ),
                    onChanged: (val) {
                      tier.singlePrice = double.tryParse(val) ?? 0.0;
                      provider.updateConfig(provider.config);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text('双面: ', style: TextStyle(fontSize: 14, color: CupertinoColors.label)),
                Expanded(
                  child: CupertinoTextField(
                    controller: _ctrl('tier-${tier.hashCode}-double', tier.doublePrice.toString()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                    suffix: const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Text('元', style: TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel)),
                    ),
                    onChanged: (val) {
                      tier.doublePrice = double.tryParse(val) ?? 0.0;
                      provider.updateConfig(provider.config);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSettings(BuildContext context, ConfigProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: CupertinoListSection.insetGrouped(
          backgroundColor: Color(0x00000000),
          header: Text('照片打印设置', style: const TextStyle(color: CupertinoColors.label)),
          children: [
            CupertinoListTile(
              title: const Text('模式名称', style: TextStyle(color: CupertinoColors.label)),
              trailing: SizedBox(
                width: 150,
                child: CupertinoTextField(
                  controller: _ctrl('photoModeName', provider.config.photoModeName),
                  placeholder: '模式名称',
                  textAlign: TextAlign.end,
                  decoration: null,
                  onChanged: (value) {
                    final newConfig = provider.config.copyWith(photoModeName: value);
                    provider.updateConfig(newConfig);
                  },
                ),
              ),
            ),
            ...provider.config.photoSkus.asMap().entries.map((entry) {
              int index = entry.key;
              PhotoSku sku = entry.value;
              return _buildSkuRow(context, provider, index, sku);
            }),
            CupertinoListTile(
              title: const Text('添加规格'),
              leading: const Icon(CupertinoIcons.add_circled, color: CupertinoColors.activeBlue),
              onTap: () => _addSku(provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkuRow(BuildContext context, ConfigProvider provider, int index, PhotoSku sku) {
    return Dismissible(
      key: ValueKey(sku),
      direction: DismissDirection.endToStart,
      background: Container(
        color: CupertinoColors.destructiveRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white),
      ),
      onDismissed: (direction) {
        final newSkus = List<PhotoSku>.from(provider.config.photoSkus)..removeAt(index);
        final newConfig = provider.config.copyWith(photoSkus: newSkus);
        provider.updateConfig(newConfig);
      },
      child: CupertinoListTile(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Expanded(
              flex: 2,
              child: CupertinoTextField(
                controller: _ctrl('sku-${sku.hashCode}-name', sku.name),
                placeholder: '规格名称',
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                style: const TextStyle(fontSize: 16),
                onChanged: (val) {
                  sku.name = val;
                  provider.updateConfig(provider.config);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: CupertinoTextField(
                controller: _ctrl('sku-${sku.hashCode}-price', sku.price.toString()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                style: const TextStyle(fontSize: 16),
                suffix: const Padding(
                  padding: EdgeInsets.only(right: 4.0),
                  child: Text('元', style: TextStyle(fontSize: 14, color: CupertinoColors.secondaryLabel)),
                ),
                onChanged: (val) {
                  sku.price = double.tryParse(val) ?? 0.0;
                  provider.updateConfig(provider.config);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeishuLinkCard(BuildContext context) {
    final url = Uri.parse('https://pcn12dls1jyy.feishu.cn/base/WySnb6n0YaWKIDse09Ocoh2rnSd?from=from_copylink');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: CupertinoListSection.insetGrouped(
          backgroundColor: Color(0x00000000),
          header: Text('快捷入口', style: const TextStyle(color: CupertinoColors.label)),
          children: [
            CupertinoListTile(
              title: const Text('打开多维表格', style: TextStyle(color: CupertinoColors.activeBlue)),
              trailing: const Icon(CupertinoIcons.arrow_right),
              onTap: () async {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: CupertinoListSection.insetGrouped(
          backgroundColor: Color(0x00000000),
          header: Text('高级', style: const TextStyle(color: CupertinoColors.label)),
          children: [
            CupertinoListTile(
              title: const Text('恢复默认设置', style: TextStyle(color: CupertinoColors.destructiveRed)),
              trailing: const Icon(CupertinoIcons.refresh),
              onTap: () => _showResetDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _addTier(ConfigProvider provider) {
    final newTiers = List<TierConfig>.from(provider.config.documentTiers)
      ..add(TierConfig(minPages: 0, maxPages: 999, singlePrice: 0.0, doublePrice: 0.0));
    final newConfig = provider.config.copyWith(documentTiers: newTiers);
    provider.updateConfig(newConfig);
  }

  void _addSku(ConfigProvider provider) {
    final newSkus = List<PhotoSku>.from(provider.config.photoSkus)
      ..add(PhotoSku(name: '新规格', price: 0.0));
    final newConfig = provider.config.copyWith(photoSkus: newSkus);
    provider.updateConfig(newConfig);
  }

  void _showResetDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('重置配置'),
        content: const Text('确定要恢复默认配置吗？所有自定义设置将丢失。'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Provider.of<ConfigProvider>(context, listen: false).resetConfig();
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
