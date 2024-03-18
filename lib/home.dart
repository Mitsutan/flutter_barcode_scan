import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scan/scanner.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<int>? totalPriceFuture;

  @override
  void initState() {
    super.initState();

    openDatabase(
      'scanned_books.db',
      version: 1,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE scanned_books (id INTEGER PRIMARY KEY AUTOINCREMENT, isbn TEXT, title TEXT, price INTEGER, date TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        Map<int, String> tableUpgradeSql = {
          2: 'ALTER TABLE scanned_books ADD COLUMN cover TEXT',
        };
        for (int i = oldVersion + 1; i <= newVersion; i++) {
          db.execute(tableUpgradeSql[i]!);
        }
      },
    );

    updateTotalPrice();
  }

  void updateTotalPrice() {
    setState(() {
      totalPriceFuture = getTotalPrice();
    });
  }

  // データベースからpriceの合計を取得する
  Future<int> getTotalPrice() async {
    Database db = await openDatabase('scanned_books.db');
    List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT SUM(price) FROM scanned_books');
    // db.close();
    if (result[0]['SUM(price)'] != null) {
      return result[0]['SUM(price)'];
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              elevation: 5,
              margin: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  const SizedBox(
                    width: double.infinity,
                  ),
                  const Text(
                    '累計金額',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  FutureBuilder(
                    future: totalPriceFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      return Text(
                        NumberFormat.simpleCurrency(
                                locale: 'ja_JP', name: 'JPY')
                            .format(snapshot.data),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
            ElevatedButton(
              // 押したらスキャンの画面に入るボタン
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const ScannerWidget(),
                      ),
                    )
                    .then((value) => updateTotalPrice());
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner_sharp, // QRスキャンのアイコン
                  ),
                  Text(
                    'スキャンを始める',
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
