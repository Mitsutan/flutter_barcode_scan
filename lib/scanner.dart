import 'package:flutter/material.dart';
import 'package:flutter_barcode_scan/result.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerWidget extends StatefulWidget {
  const ScannerWidget({super.key});

  @override
  State<ScannerWidget> createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget>
    with SingleTickerProviderStateMixin {
  // スキャナーの作用を制御するコントローラーのオブジェクト
  MobileScannerController controller = MobileScannerController();
  bool isStarted = true; // カメラがオンしているかどうか
  double zoomFactor = 0.0; // ズームの程度。0から1まで。多いほど近い

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).colorScheme.inversePrimary, // 上の部分の背景色
        title: const Text('スキャンしよう'),
      ),
      backgroundColor: Colors.black,
      body: Builder(
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // カメラの画面の部分
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: MobileScanner(
                  // controller: MobileScannerController(
                    // detectionSpeed: DetectionSpeed.noDuplicates,
                    // autoStart: true,
                    
                  // ),
                  controller: controller,
                  // fit: BoxFit.contain,
                  // QRコードかバーコードが見つかった後すぐ実行する関数
                  onDetect: (scandata) {

                    // QRコードとバーコードタイプがISBNでないものを削除する
                    scandata.barcodes.removeWhere(
                        (barcode) => barcode.format == BarcodeFormat.qrCode || barcode.type != BarcodeType.isbn);

                    // 上記の処理でバーコードがなくなったら何もしない
                    if (scandata.barcodes.isEmpty) {
                      // controller.start();
                      return;
                    }

                    controller.stop(); // まずはカメラを止める

                    setState(() {
                      // 結果を表す画面に切り替える
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            // scandataはスキャンの結果を収める関数であり、これをデータ表示ページに渡す
                            return ScanDataWidget(scandata: scandata);
                          },
                        ),
                      )
                      .then(
                        (value) => controller.start()
                        );
                    });
                  },
                ),
              ),
              // ズームを調整するスライダー
              Slider(
                value: zoomFactor,
                // スライダーの値が変えられた時に実行する関数
                onChanged: (sliderValue) {
                  // sliderValueは変化した後の数字
                  setState(() {
                    zoomFactor = sliderValue;
                    controller.setZoomScale(sliderValue); // 新しい値をカメラに設定する
                  });
                },
              ),
              // 下の方にある3つのボタン
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // フラッシュのオン／オフを操るボタン
                  IconButton(
                      // アイコンの表示はオン／オフによって変わる
                      icon: ValueListenableBuilder<TorchState>(
                        valueListenable: controller.torchState,
                        builder: (context, state, child) {
                          switch (state) {
                            // オフしている場合、オンにする
                            case TorchState.off:
                              return const Icon(
                                Icons.flash_off,
                                color: Colors.grey,
                              );
                            // オンしている場合、オフにする
                            case TorchState.on:
                              return const Icon(
                                Icons.flash_on,
                                color: Color(0xFFFFDDBB),
                              );
                          }
                        },
                      ),
                      iconSize: 50,
                      // ボタンが押されたら切り替えを実行する
                      onPressed: () => controller.toggleTorch()),
                  // カメラのオン／オフのボタン
                  IconButton(
                    color: const Color(0xFFBBDDFF),
                    // オン／オフの状態によって表示するアイコンが変わる
                    icon: isStarted
                        ? const Icon(Icons.videocam_off_outlined) // ストップのアイコン
                        : const Icon(Icons.videocam_outlined), // プレイのアイコン
                    iconSize: 50,
                    // ボタンが押されたらオン／オフを実行する
                    onPressed: () => setState(() {
                      isStarted ? controller.stop() : controller.start();
                      isStarted = !isStarted;
                    }),
                  ),
                  // アイコン前のカメラと裏のカメラを切り替えるボタン
                  IconButton(
                    color: const Color(0xFFBBDDFF),
                    icon: ValueListenableBuilder<CameraFacing>(
                      // アイコンの表示は使っているカメラによって変わる
                      valueListenable: controller.cameraFacingState,
                      builder: (context, state, child) {
                        switch (state) {
                          // 前のカメラの場合
                          case CameraFacing.front:
                            return const Icon(Icons.camera_front);
                          // 後ろのカメラの場合
                          case CameraFacing.back:
                            return const Icon(Icons.camera_rear);
                        }
                      },
                    ),
                    iconSize: 50,
                    onPressed: () {
                      if (isStarted) {
                        controller.switchCamera();
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
