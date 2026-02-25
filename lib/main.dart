
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/config_provider.dart';
import 'providers/calculator_provider.dart';
import 'providers/history_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConfigProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
      ],
      child: Builder(builder: (context) {
        final theme = Provider.of<ThemeProvider>(context);
        final brightness = theme.resolveBrightness(context);
        return CupertinoApp(
          title: '打印费用计算器',
          theme: CupertinoThemeData(
            brightness: brightness,
            primaryColor: CupertinoColors.activeBlue,
            scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
            barBackgroundColor: CupertinoColors.systemGroupedBackground,
          ),
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: const HomeScreen(),
        );
      }),
    );
  }
}
