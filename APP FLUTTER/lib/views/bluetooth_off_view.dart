import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_xe_ban_sua/consts/consts.dart';
import 'package:app_xe_ban_sua/theme/app_theme.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleOffPage extends StatelessWidget {
  const BleOffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0.0),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: CupertinoColors.systemBlue,
            ),
            Text(
              'Bluetooth Đang Tắt',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleSize,
                color: Colors.grey[800],
              ),
            ),
            Platform.isAndroid
                ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: CupertinoColors.systemBlue,
                          width: 1,
                        ),
                        foregroundColor: Colors.grey[800],
                        backgroundColor: colorCard,
                      ),
                      child: const Text('Bật Bluetooth'),
                      onPressed: () async {
                        try {
                          if (Platform.isAndroid) {
                            await FlutterBluePlus.turnOn();
                          }
                        } catch (e) {
                          if (kDebugMode) {
                            print(e.toString());
                          }
                        }
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
