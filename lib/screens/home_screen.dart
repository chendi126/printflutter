
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // 为了使用 Icons (如果需要) 或其他通用组件
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/history_record.dart';
import '../providers/config_provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_background.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final configProvider = Provider.of<ConfigProvider>(context);
    final calculatorProvider = Provider.of<CalculatorProvider>(context);
    final historyProvider = Provider.of<HistoryProvider>(context);
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('打印费用计算器'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
            color: CupertinoTheme.of(context).primaryColor,
          ),
          onPressed: () {
            _showThemeSheet(context);
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.time),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            const GlassBackground(),
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildModeDropdown(context, configProvider, calculatorProvider),
                  const SizedBox(height: 24),
                  _buildInputCard(context, configProvider, calculatorProvider),
                  const SizedBox(height: 24),
                  _buildResultCard(context, configProvider, calculatorProvider, historyProvider),
                  const SizedBox(height: 32),
                  _buildRecentHistory(context, historyProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('选择主题'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).setOption(ThemeOption.system);
              Navigator.pop(ctx);
            },
            child: const Text('跟随系统'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).setOption(ThemeOption.light);
              Navigator.pop(ctx);
            },
            child: const Text('浅色'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).setOption(ThemeOption.dark);
              Navigator.pop(ctx);
            },
            child: const Text('深色'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          isDefaultAction: true,
          child: const Text('取消'),
        ),
      ),
    );
  }

  Widget _buildModeDropdown(BuildContext context, ConfigProvider config, CalculatorProvider calculator) {
    final currentLabel = calculator.isDocumentMode ? config.config.documentModeName : config.config.photoModeName;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          showCupertinoModalPopup(
            context: context,
            builder: (ctx) {
              return CupertinoActionSheet(
                title: const Text('选择模式'),
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () {
                      calculator.setMode(true);
                      Navigator.pop(ctx);
                    },
                    child: Text(config.config.documentModeName),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () {
                      calculator.setMode(false);
                      Navigator.pop(ctx);
                    },
                    child: Text(config.config.photoModeName),
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(ctx),
                  isDefaultAction: true,
                  child: const Text('取消'),
                ),
              );
            },
          );
        },
        child: Row(
          children: [
            Icon(
              calculator.isDocumentMode ? CupertinoIcons.doc_text : CupertinoIcons.photo,
              color: CupertinoTheme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                currentLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(CupertinoIcons.chevron_down, size: 18, color: CupertinoColors.systemGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(BuildContext context, ConfigProvider config, CalculatorProvider calculator) {
    return GlassCard(
      padding: const EdgeInsets.all(24.0),
      child: calculator.isDocumentMode
          ? _buildDocumentInput(context, calculator)
          : _buildPhotoInput(context, config, calculator),
    );
  }

  Widget _buildDocumentInput(BuildContext context, CalculatorProvider calculator) {
    return Column(
      children: [
        CupertinoTextField(
          controller: TextEditingController(text: calculator.docPages == 0 ? '' : calculator.docPages.toString())
            ..selection = TextSelection.fromPosition(
                TextPosition(offset: (calculator.docPages == 0 ? '' : calculator.docPages.toString()).length)),
          placeholder: '请输入页数',
          prefix: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(CupertinoIcons.doc_text, color: CupertinoColors.systemGrey),
          ),
          keyboardType: TextInputType.number,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          onChanged: (value) {
            calculator.setDocPages(int.tryParse(value) ?? 0);
          },
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(CupertinoIcons.doc_on_doc, color: CupertinoColors.systemGrey),
                const SizedBox(width: 8),
                Text('双面打印', style: CupertinoTheme.of(context).textTheme.textStyle),
              ],
            ),
            CupertinoSwitch(
              value: calculator.isDoubleSided,
              onChanged: (value) {
                calculator.setDoubleSided(value);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoInput(BuildContext context, ConfigProvider config, CalculatorProvider calculator) {
    if (config.config.photoSkus.isEmpty) {
      return const Center(child: Text('请先在设置中添加照片规格'));
    }

    final selectedSku = calculator.selectedPhotoSkuIndex < config.config.photoSkus.length
        ? config.config.photoSkus[calculator.selectedPhotoSkuIndex]
        : null;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _showSkuActionSheet(context, config, calculator);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.photo, color: CupertinoColors.systemGrey),
                const SizedBox(width: 8),
                Text(
                  selectedSku != null ? '${selectedSku.name} (${selectedSku.price}元/张)' : '选择规格',
                  style: CupertinoTheme.of(context).textTheme.textStyle,
                ),
                const Spacer(),
                const Icon(CupertinoIcons.chevron_down, size: 16, color: CupertinoColors.systemGrey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          controller: TextEditingController(text: calculator.photoCount.toString())
            ..selection = TextSelection.fromPosition(
                TextPosition(offset: calculator.photoCount.toString().length)),
          placeholder: '张数',
          prefix: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(CupertinoIcons.number_square, color: CupertinoColors.systemGrey),
          ),
          keyboardType: TextInputType.number,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          onChanged: (value) {
            calculator.setPhotoCount(int.tryParse(value) ?? 0);
          },
        ),
      ],
    );
  }

  void _showSkuActionSheet(BuildContext context, ConfigProvider config, CalculatorProvider calculator) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('选择照片规格'),
        actions: [
          for (int i = 0; i < config.config.photoSkus.length; i++)
            CupertinoActionSheetAction(
              onPressed: () {
                calculator.setSelectedPhotoSkuIndex(i);
                Navigator.pop(ctx);
              },
              isDefaultAction: i == calculator.selectedPhotoSkuIndex,
              child: Text('${config.config.photoSkus[i].name} - ${config.config.photoSkus[i].price}元'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, ConfigProvider config, CalculatorProvider calculator, HistoryProvider history) {
    final totalCost = calculator.calculateTotal(config.config);
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            '总金额',
            style: TextStyle(
              color: isDark ? CupertinoColors.white : CupertinoTheme.of(context).primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(totalCost),
            style: TextStyle(
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: CupertinoTheme.of(context).primaryColor,
              onPressed: totalCost > 0
                  ? () {
                      final record = HistoryRecord(
                        id: const Uuid().v4(),
                        timestamp: DateTime.now(),
                        type: calculator.isDocumentMode ? config.config.documentModeName : config.config.photoModeName,
                        description: calculator.getDescription(config.config),
                        totalCost: totalCost,
                      );
                      history.addRecord(record);
                      // Cupertino 风格通常没有 SnackBar，可以用 Dialog 或其他提示
                      // 这里简单用 Dialog
                      showCupertinoDialog(
                        context: context,
                        builder: (ctx) {
                           Future.delayed(const Duration(milliseconds: 800), () {
                             if(ctx.mounted) Navigator.pop(ctx);
                           });
                           return CupertinoAlertDialog(
                             content: Column(
                               children: const [
                                 Icon(CupertinoIcons.check_mark_circled, size: 40, color: CupertinoColors.activeGreen),
                                 SizedBox(height: 8),
                                 Text('记录已保存'),
                               ],
                             ),
                           );
                        }
                      );
                    }
                  : null,
              child: const Text(
                '记一笔',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white, // 强制高对比白字
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistory(BuildContext context, HistoryProvider history) {
    if (history.records.isEmpty) {
      return const SizedBox.shrink();
    }

    final recentRecords = history.records.take(3).toList();
    final dateFormat = DateFormat('MM-dd HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近记录',
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontSize: 20),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
                child: const Text('查看全部'),
              ),
            ],
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: recentRecords.asMap().entries.map((entry) {
              final index = entry.key;
              final record = entry.value;
              final isLast = index == recentRecords.length - 1;
              
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          record.type == 'A4文档打印' || record.type.contains('文档')
                              ? CupertinoIcons.doc_text
                              : CupertinoIcons.photo,
                          color: CupertinoTheme.of(context).primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.description,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${dateFormat.format(record.timestamp)} · ${record.type}',
                                style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '¥${record.totalCost.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, indent: 60, color: CupertinoColors.systemGrey5),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
