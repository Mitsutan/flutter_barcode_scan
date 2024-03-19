import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sqflite/sqflite.dart';

class SettingWidget extends StatefulWidget {
  const SettingWidget({super.key});

  @override
  State<SettingWidget> createState() => _SettingWidget();
}

class _SettingWidget extends State<SettingWidget> {
  String _appVersion = '-.-.-';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> settings = [
      {
        'title': '全データ削除',
        'sub': 'スキャンした本の全データを削除します。',
        'icon': Icons.delete,
        'enable': true,
        'showDialog': AlertDialogWidget(
            title: '全データ削除',
            content: 'すべてのデータが削除されます。この変更は復元できません。よろしいですか？',
            onPressed: () {
              deleteDatabase('scanned_books.db');
            }),
      },
      {
        'title': 'バージョン情報',
        'sub': _appVersion,
        'icon': Icons.info,
        'enable': false
      },
    ];
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('設定'),
        ),
        body: Container(
          padding: const EdgeInsets.all(8),
          child: ListView.separated(
            itemCount: settings.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                enabled: settings[index]['enable'],
                leading: Icon(settings[index]['icon']),
                title: Text(settings[index]['title']),
                subtitle: Text(settings[index]['sub']),
                onTap: () {
                  log('Tapped: ${settings[index]['title']}');
                  if (settings[index]['pushTo'] != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => settings[index]['pushTo'],
                      ),
                    );
                  }
                  if (settings[index]['showDialog'] != null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return settings[index]['showDialog'];
                      },
                    );
                  }
                },
              );
            },
          ),
        ));
  }
}

class AlertDialogWidget extends StatelessWidget {
  final String title;
  final String content;
  final Function onPressed;
  const AlertDialogWidget(
      {super.key,
      required this.title,
      required this.content,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: const Text('いいえ'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('はい'),
          onPressed: () {
            onPressed();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
