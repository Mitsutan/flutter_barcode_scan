import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

class ScanDataWidget extends StatelessWidget {
  final BarcodeCapture? scandata; // スキャナーのページから渡されたデータ
  const ScanDataWidget({
    super.key,
    this.scandata,
  });

  Future<Map<String, dynamic>> getData(String isbn) async {
    var response =
        await http.get(Uri.https('api.openbd.jp', '/v1/get', {'isbn': isbn}));
    var jsonResponse = jsonDecode(response.body);
    return jsonResponse[0];
  }

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

        // ListView.builder内
        itemBuilder: (context, index) {
          String codeValue = scandata?.barcodes[index].rawValue ?? 'null';

          // FutureBuilderを使用して非同期データを処理
          return FutureBuilder(
            future: getData(codeValue),
            builder: (context, snapshot) {
              String cardTitle = '';
              String cardSubtitle = '';
              if (snapshot.connectionState == ConnectionState.waiting) {
                // return const CircularProgressIndicator();
                cardTitle = '読み込み中';
                cardSubtitle = '';
              } else if (snapshot.hasError) {
                // return Text('エラー: ${snapshot.error}');
                cardTitle = 'エラー';
                // cardSubtitle = '${snapshot.error}';
                cardSubtitle = 'ISBN:$codeValueは登録されていないようです。';
              } else {
                cardTitle = snapshot.data?['onix']['DescriptiveDetail']
                    ['TitleDetail']['TitleElement']['TitleText']['content'];
                cardSubtitle =
                    '￥${snapshot.data?['onix']['ProductSupply']['SupplyDetail']['Price'][0]['PriceAmount']}';
              }
              return Card(
                elevation: 5,
                margin: const EdgeInsets.all(9),
                child: ListTile(
                  title: Text(
                    cardTitle,
                    style: const TextStyle(
                        fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    cardSubtitle,
                    style:
                        const TextStyle(fontSize: 20, color: Color(0xFF553311)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
