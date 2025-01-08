import 'package:flutter/material.dart';
import 'package:app_xe_ban_sua/theme/app_theme.dart';
import 'package:app_xe_ban_sua/views/bluetooth_off_view.dart';
import 'package:app_xe_ban_sua/views/scan_view.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late BluetoothAdapterState _bluetoothAdapterState;

  @override
  void initState() {
    _bluetoothAdapterState = BluetoothAdapterState.unknown;

    FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _bluetoothAdapterState = state;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage = _bluetoothAdapterState != BluetoothAdapterState.on
        ? const BleOffPage()
        : const ScanPage();

    return MaterialApp(
      title: 'Trình điều khiển xe bán sữa',
      home: currentPage,
      theme: appTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
