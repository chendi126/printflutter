
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/tier_config.dart';
import '../models/photo_sku.dart';
import '../providers/config_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('设置'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.refresh),
          onPressed: () => _showResetDialog(context),
        ),
      ),
      child: Consumer<ConfigProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: Stack(
              children: [
                const GlassBackground(),
                ListView(
                  children: [
                    _buildDocumentSettings(context, provider),
                    _buildPhotoSettings(context, provider),
                  ],
                ),
              ],
            ),
          );
        },
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
                  controller: TextEditingController(text: provider.config.documentModeName)
                    ..selection = TextSelection.fromPosition(
                        TextPosition(offset: provider.config.documentModeName.length)),
                  placeholder: '模式名称',
                  textAlign: TextAlign.end,
                  decoration: null,
                  onChanged: (value) {
                    provider.config.documentModeName = value;
                    provider.saveConfig(notify: false);
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
        provider.config.documentTiers.removeAt(index);
        provider.saveConfig();
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
                    controller: TextEditingController(text: tier.minPages.toString()),
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
                      provider.saveConfig(notify: false);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text('-', style: TextStyle(color: CupertinoColors.secondaryLabel)),
                ),
                Expanded(
                  child: CupertinoTextField(
                    controller: TextEditingController(text: tier.maxPages.toString()),
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
                      provider.saveConfig(notify: false);
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
                    controller: TextEditingController(text: tier.singlePrice.toString()),
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
                      provider.saveConfig(notify: false);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text('双面: ', style: TextStyle(fontSize: 14, color: CupertinoColors.label)),
                Expanded(
                  child: CupertinoTextField(
                    controller: TextEditingController(text: tier.doublePrice.toString()),
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
                      provider.saveConfig(notify: false);
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
                  controller: TextEditingController(text: provider.config.photoModeName)
                    ..selection = TextSelection.fromPosition(
                        TextPosition(offset: provider.config.photoModeName.length)),
                  placeholder: '模式名称',
                  textAlign: TextAlign.end,
                  decoration: null,
                  onChanged: (value) {
                    provider.config.photoModeName = value;
                    provider.saveConfig(notify: false);
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
        provider.config.photoSkus.removeAt(index);
        provider.saveConfig();
      },
      child: CupertinoListTile(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Expanded(
              flex: 2,
              child: CupertinoTextField(
                controller: TextEditingController(text: sku.name),
                placeholder: '规格名称',
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                style: const TextStyle(fontSize: 16),
                onChanged: (val) {
                  sku.name = val;
                  provider.saveConfig(notify: false);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: CupertinoTextField(
                controller: TextEditingController(text: sku.price.toString()),
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
                  provider.saveConfig(notify: false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTier(ConfigProvider provider) {
    provider.config.documentTiers.add(TierConfig(
      minPages: 0,
      maxPages: 999,
      singlePrice: 0.0,
      doublePrice: 0.0,
    ));
    provider.saveConfig();
  }

  void _addSku(ConfigProvider provider) {
    provider.config.photoSkus.add(PhotoSku(name: '新规格', price: 0.0));
    provider.saveConfig();
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
