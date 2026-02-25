
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/config_provider.dart';
import 'providers/calculator_provider.dart';
import 'providers/history_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
// ignore: unused_import
import 'services/feishu_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: 如需启用飞书直连（无后端），请取消注释并填入你的自建应用信息
  // 注意：AppSecret 仅限本地个人使用，切勿提交到公共仓库或分发给他人
  
  FeishuSyncService.enableDirect(
    appId: 'cli_a9140b4c7b38dcc7',
    appSecret: 'JW0gabbo1OSl8KvRrpaTWcnwY47GAXOz',
    appToken: 'WySnb6n0YaWKIDse09Ocoh2rnSd',
    tableId: 'tblBul7YG0prNXtw',
  );
  FeishuSyncService.endpoint = ''; // 启用直连需置空 endpoint
  /*
  // 若本机需要代理才能连通飞书 API：
  // FeishuSyncService.setProxy('127.0.0.1:7890');
  */

  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConfigProvider(prefs)),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return CupertinoApp(
          title: '哒哒哒计算器',
          theme: CupertinoThemeData(
            brightness: themeProvider.resolveBrightness(context),
            primaryColor: CupertinoColors.activeBlue,
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
