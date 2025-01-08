import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_xe_ban_sua/consts/consts.dart';
import 'package:app_xe_ban_sua/theme/app_theme.dart';
import 'package:app_xe_ban_sua/views/home_view.dart';
import 'package:app_xe_ban_sua/widgets/scan_title_widget.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late bool _isScanning;
  late bool _isConnecting;
  late List<ScanResult> _scanResults;
  late BluetoothCharacteristic _selectedCharacteristic;

  @override
  void initState() {
    super.initState();
    _isScanning = false;
    _isConnecting = false;
    _scanResults = [];

    _scanDevice();
  }

  @override
  void dispose() {
    _scanResults.clear();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _scanDevice() async {
    _scanResults.clear();

    FlutterBluePlus.scanResults.listen(
          (results) {
        if (mounted) setState(() => _scanResults = results);
      },
      onError: (e) {
        if (kDebugMode) {
          print('Xảy ra lỗi khi quét: $e');
        }
      },
    );

    FlutterBluePlus.isScanning.listen((state) {
      if (mounted) setState(() => _isScanning = state);
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Xảy ra lỗi khi quét: $e');
      }
    }
  }

  Future<void> _refreshScan() async {
    if (_isScanning) {
      await FlutterBluePlus.stopScan();
    }
    await _scanDevice();
  }

  Future<void> _getCharacteristic({required int selectedDeviceIndex}) async {
    List<BluetoothService> services =
    await _scanResults[selectedDeviceIndex].device.discoverServices();

    bool characteristicFound = false;

    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() == esp32CharacteristicUuid) {
          // Check if the characteristic supports notify and write
          if (characteristic.properties.notify && characteristic.properties.write) {
            _selectedCharacteristic = characteristic;
            characteristicFound = true;
            break;
          }
        }
      }
      if (characteristicFound) break;
    }

    setState(() => _isConnecting = false);

    if (!characteristicFound) {
      Fluttertoast.showToast(
        msg: 'Không tìm thấy đặc tính phù hợp',
        backgroundColor: Colors.red,
      );
      await _scanResults[selectedDeviceIndex].device.disconnect();
      return;
    }

    Fluttertoast.showToast(
      msg: '${_scanResults[selectedDeviceIndex].device.platformName} connected',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshScan,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: hPadding,
                vertical: vPadding,
              ),
              child: ListView(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const Gap(homeSizedHeight),
                  ScanTitleWidget(isScanning: _isScanning),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      String platformName =
                          _scanResults[index].device.platformName;
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: platformName.isEmpty
                              ? Colors.grey[200]!.withOpacity(0.5)
                              : Colors.grey[200],
                          borderRadius:
                          const BorderRadius.all(Radius.circular(22)),
                        ),
                        child: ListTile(
                          leading: Icon(
                            platformName.isEmpty
                                ? Icons.do_not_disturb_alt
                                : Icons.devices_outlined,
                          ),
                          title: Text(
                            platformName.isEmpty ? 'Thiết bị không xác định' : platformName,
                          ),
                          subtitle: Text('${_scanResults[index].rssi} dBm'),
                          subtitleTextStyle:
                          _computeTextStyle(_scanResults[index].rssi),
                          trailing: TextButton(
                            onPressed: () async {
                              setState(() => _isConnecting = true);

                              await _scanResults[index].device.connect();
                              await _getCharacteristic(selectedDeviceIndex: index);

                              if (mounted) {
                                Future.microtask(
                                      () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(
                                          esp32Characteristic: _selectedCharacteristic,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            child: Text(
                              platformName.isEmpty
                                  ? 'Không thể kết nối'
                                  : 'Kết nối',
                              style: TextStyle(
                                color: platformName.isEmpty
                                    ? CupertinoColors.systemGrey
                                    : CupertinoColors.systemGreen,
                                fontSize: platformName.isEmpty ? 12 : 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Gap(homeSizedHeight),
                ],
              ),
            ),
          ),
          _isConnecting
              ? Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.black.withOpacity(0.5),
            ),
            child: Center(
              child: CircularProgressIndicator(color: colorCard),
            ),
          )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  static TextStyle _computeTextStyle(int rssi) {
    if (rssi >= -35) {
      return TextStyle(color: Colors.greenAccent[700]!.withOpacity(0.5));
    } else if (rssi >= -45) {
      return TextStyle(
          color: Color.lerp(Colors.greenAccent[700]!.withOpacity(0.5),
              Colors.lightGreen.withOpacity(0.5), -(rssi + 35) / 10));
    } else if (rssi >= -55) {
      return TextStyle(
          color: Color.lerp(Colors.lightGreen.withOpacity(0.5),
              Colors.lime[600]!.withOpacity(0.5), -(rssi + 45) / 10));
    } else if (rssi >= -65) {
      return TextStyle(
          color: Color.lerp(Colors.lime[600]!.withOpacity(0.5),
              Colors.amber.withOpacity(0.5), -(rssi + 55) / 10));
    } else if (rssi >= -75) {
      return TextStyle(
          color: Color.lerp(Colors.amber.withOpacity(0.5),
              Colors.deepOrangeAccent.withOpacity(0.5), -(rssi + 65) / 10));
    } else if (rssi >= -85) {
      return TextStyle(
          color: Color.lerp(Colors.deepOrangeAccent.withOpacity(0.5),
              Colors.redAccent.withOpacity(0.5), -(rssi + 75) / 10));
    } else {
      return TextStyle(color: Colors.redAccent.withOpacity(0.5));
    }
  }
}