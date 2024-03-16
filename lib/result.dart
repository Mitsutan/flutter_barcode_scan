import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

class ScanDataWidget extends StatefulWidget {
  final BarcodeCapture? scandata; // スキャナーのページから渡されたデータ
  const ScanDataWidget({super.key, this.scandata});

  // const ScannerWidget({Key? key});

  @override
  State<StatefulWidget> createState() => _ScanDataWidget();
}

class _ScanDataWidget extends State<ScanDataWidget> {
  // final BarcodeCapture? scandata; // スキャナーのページから渡されたデータ
  // const ScanDataWidget({
  //   super.key,
  //   this.scandata,
  // });

  List<bool> isSwitched = List.empty(growable: true);
  List<Future<Map<String, dynamic>>> dataFuture = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    widget.scandata?.barcodes.forEach((barcode) {
      dataFuture.add(getData(barcode.rawValue!));
    });
  }

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
        itemCount: widget.scandata?.barcodes.length ?? 0,

        // ListView.builder内
        itemBuilder: (context, index) {
          String codeValue =
              widget.scandata?.barcodes[index].rawValue ?? 'null';

          // FutureBuilderを使用して非同期データを処理
          return FutureBuilder(
            future: dataFuture[index],
            builder: (context, snapshot) {
              String cardTitle = '';
              String cardSubtitle = '';
              bool isSwitchDisabled = false;
              isSwitched.add(true);
              if (snapshot.connectionState == ConnectionState.waiting) {
                // return const CircularProgressIndicator();
                cardTitle = '読み込み中';
                cardSubtitle = '';
              } else if (snapshot.hasError) {
                // return Text('エラー: ${snapshot.error}');
                cardTitle = 'エラー';
                // cardSubtitle = '${snapshot.error}';
                cardSubtitle = 'ISBN:$codeValueの情報は取得できませんでした。';
                isSwitchDisabled = true;
              } else {
                cardTitle = snapshot.data?['onix']['DescriptiveDetail']
                    ['TitleDetail']['TitleElement']['TitleText']['content'];
                cardSubtitle =
                    '￥${snapshot.data?['onix']['ProductSupply']['SupplyDetail']['Price'][0]['PriceAmount']}';
              }
              return Card(
                elevation: 5,
                margin: const EdgeInsets.all(9),
                // child: ListTile(
                //   title: Text(
                //     cardTitle,
                //     style: const TextStyle(
                //         fontSize: 23, fontWeight: FontWeight.bold),
                //   ),
                //   subtitle: Text(
                //     cardSubtitle,
                //     style:
                //         const TextStyle(fontSize: 20, color: Color(0xFF553311)),
                //   ),
                //   trailing: IconButton(
                //     icon: const Icon(Icons.more_vert), // ここに任意のアイコンを設定
                //     onPressed: () {
                //       // ボタンが押されたときの処理をここに書く
                //     },
                //   ),
                // ),
                child: SwitchListTile(
                  value: isSwitched[index],
                  onChanged: (isSwitchDisabled)
                      ? null
                      : (bool value) {
                          setState(() {
                            isSwitched[index] = value;
                          });
                          print('「${cardTitle}」is ${isSwitched[index]}');
                        },
                  // onChanged: null,
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
