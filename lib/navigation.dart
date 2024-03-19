import 'package:flutter/material.dart';
import 'package:flutter_barcode_scan/setting.dart';

import 'home.dart';
import 'scanner.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'コードスキャナー',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NavigationWidget(),
    );
  }
}

class NavigationWidget extends StatefulWidget {
  const NavigationWidget({super.key});

  @override
  State<NavigationWidget> createState() => _NavigationWidget();
}

class _NavigationWidget extends State<NavigationWidget> {
  int selectedIndex = 0;

  static const pages = [
    MyHomePage(title: 'ホーム'),
    ScannerWidget(),
    SettingWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_sharp), label: 'スキャン'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
          ]),
    );
  }
}
