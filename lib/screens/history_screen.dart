
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // 需要 Material 的 Icons 和 SnackBar (虽然我们用Dialog替代)
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../models/history_record.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_background.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Consumer<HistoryProvider>(
        builder: (context, history, child) {
          return Stack(
            children: [
              const GlassBackground(),
              CustomScrollView(
                slivers: [
                  CupertinoSliverNavigationBar(
                    largeTitle: const Text('历史记录'),
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.trash),
                      onPressed: () {
                        if (history.records.isNotEmpty) {
                          _showClearDialog(context);
                        }
                      },
                    ),
                  ),
                  if (history.records.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          '暂无历史记录',
                          style: TextStyle(color: CupertinoColors.secondaryLabel),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final record = history.records[index];
                          final isLast = index == history.records.length - 1;
                          return Dismissible(
                            key: Key(record.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: CupertinoColors.destructiveRed,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white),
                            ),
                            onDismissed: (direction) {
                              history.removeRecord(record.id);
                            },
                            child: _buildHistoryItem(context, record, isLast),
                          );
                        },
                        childCount: history.records.length,
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, HistoryRecord record, bool isLast) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  record.type.contains('文档') || record.type == 'A4文档打印'
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
                        '${record.type} · ${dateFormat.format(record.timestamp)}',
                        style: const TextStyle(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '¥${record.totalCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: CupertinoTheme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          if (!isLast)
            const Divider(height: 1, indent: 60, color: CupertinoColors.systemGrey5),
        ],
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('清空历史'),
        content: const Text('确定要删除所有历史记录吗？此操作无法撤销。'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Provider.of<HistoryProvider>(context, listen: false).clearAll();
              Navigator.pop(ctx);
            },
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }
}
