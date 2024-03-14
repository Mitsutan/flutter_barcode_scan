import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanDataWidget extends StatelessWidget {
  final BarcodeCapture? scandata; // スキャナーのページから渡されたデータ
  const ScanDataWidget({
    super.key,
    this.scandata,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('スキャンの結果'),
      ),
      // 検出されたコードの数だけリストを作る
      body: ListView.builder(
        itemCount: scandata?.barcodes.length ?? 0,
        itemBuilder: (context, index) {

          // コードから読み取った文字列
          String codeValue = scandata?.barcodes[index].rawValue ?? 'null';
          // コードのタイプを示すオブジェクト
          BarcodeType? codeType = scandata?.barcodes[index].type;
          // コードのタイプを文字列にする
          String cardTitle = "[${'$codeType'.split('.').last}]";
          // 読み取った内容を表示するウィジェット
          dynamic cardSubtitle = Text(codeValue,
              style: const TextStyle(fontSize: 23, color: Color(0xFF553311)));

          return Card(
            elevation: 5,
            margin: const EdgeInsets.all(9),
            child: ListTile(
              title: Text(
                cardTitle,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              subtitle: cardSubtitle,
            ),
          );
        },
      ),
    );
  }
}
