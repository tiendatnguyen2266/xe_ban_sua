import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_xe_ban_sua/views/scan_view.dart';
import 'package:app_xe_ban_sua/consts/consts.dart';
import 'package:app_xe_ban_sua/model/data_model.dart';
import 'package:app_xe_ban_sua/widgets/connection_info_widget.dart';
import 'package:app_xe_ban_sua/widgets/title_widget.dart';
import 'package:app_xe_ban_sua/widgets/sensor_data_widget.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.esp32Characteristic,
  });

  final BluetoothCharacteristic esp32Characteristic;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ReceivedDataModel _dataModel;
  late BluetoothCharacteristic _esp32Characteristic;

  @override
  void initState() {
    super.initState();
    _esp32Characteristic = widget.esp32Characteristic;
    _dataModel = ReceivedDataModel(
      nhietbonnong: 0,
      nhietbonlanh: 0,
      nguongbonnong: 70.0,
      nguongbonlanh: 3.0,
      dungtich: 300.0,
      soluongchai: 0,
    );
    _listenBleData();
  }

  @override
  void dispose() {
    if (_esp32Characteristic.device.isConnected) {
      _esp32Characteristic.device.disconnect();
    }
    super.dispose();
  }

  Future _sendBleData(SendDataModel dataModel) async {
    if (_esp32Characteristic.device.isConnected) {
      try {
        final jsonData = jsonEncode(dataModel.toJson());
        await _esp32Characteristic.write(utf8.encode(jsonData));
        if (kDebugMode) print('Data sent successfully: $jsonData');
      } catch (e) {
        if (kDebugMode) print('Error sending data: $e');
      }
    }
  }

  void _listenBleData() async {
    await _esp32Characteristic.setNotifyValue(true);
    _esp32Characteristic.lastValueStream.listen(
          (value) {
        if (mounted) {
          setState(() {
            try {
              var decode = utf8.decode(value);
              if (kDebugMode) print('Received data: $decode');
              _dataModel = ReceivedDataModel.fromJson(jsonDecode(decode)); // Parse JSON
              if (kDebugMode) print('Parsed data: $_dataModel');
            } catch (e) {
              if (kDebugMode) print('Error decoding data: $e');
            }
          });
        }
      },
    ).onError((err) {
      if (kDebugMode) print('Error listening to BLE data: $err');
    });
  }

  void _showThresholdInputDialog(BuildContext context, String title, String currentValue, Function(double) onSave) {
    final TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Nhập giá trị'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                final value = double.tryParse(controller.text);
                if (value != null) {
                  setState(() {
                    if (title.contains('nóng')) {
                      _dataModel = ReceivedDataModel(
                        nhietbonnong: _dataModel.nhietbonnong,
                        nhietbonlanh: _dataModel.nhietbonlanh,
                        nguongbonnong: value,
                        nguongbonlanh: _dataModel.nguongbonlanh,
                        dungtich: _dataModel.dungtich,
                        soluongchai: _dataModel.soluongchai,
                      );
                    } else if (title.contains('lạnh')) {
                      _dataModel = ReceivedDataModel(
                        nhietbonnong: _dataModel.nhietbonnong,
                        nhietbonlanh: _dataModel.nhietbonlanh,
                        nguongbonnong: _dataModel.nguongbonnong,
                        nguongbonlanh: value,
                        dungtich: _dataModel.dungtich,
                        soluongchai: _dataModel.soluongchai,
                      );
                    } else if (title.contains('dung tích')) {
                      _dataModel = ReceivedDataModel(
                        nhietbonnong: _dataModel.nhietbonnong,
                        nhietbonlanh: _dataModel.nhietbonlanh,
                        nguongbonnong: _dataModel.nguongbonnong,
                        nguongbonlanh: _dataModel.nguongbonlanh,
                        dungtich: value,
                        soluongchai: _dataModel.soluongchai,
                      );
                    }
                  });
                  onSave(value);
                  Navigator.pop(context);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: [
          const Gap(homeSizedHeight),
          const TitleWidget(title: 'Trình Điều Khiển Xe Bán Sữa', isTitle: true),
          const Gap(homeSizedHeight),
          const TitleWidget(title: 'Trạng Thái Kết Nối', isTitle: false),
          ConnectionInfoWidget(
            isConnected: _esp32Characteristic.device.isConnected,
            infoText: _esp32Characteristic.device.isConnected
                ? 'Đã Kết Nối Với: ${_esp32Characteristic.device.platformName}'
                : 'Đã Ngắt Kết Nối',
            changeStatus: (p0) async {
              await _esp32Characteristic.device.disconnect();
              setState(() {});
              Fluttertoast.showToast(
                msg: '${_esp32Characteristic.device.platformName} disconnected',
              );
              Future.delayed(const Duration(milliseconds: 1500)).then(
                    (value) => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanPage()),
                ),
              );
            },
          ),
          const Gap(vPadding),
          const TitleWidget(title: 'Nhiệt Độ Trong Bồn', isTitle: false),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SensorDataWidget(
                  title: 'Bồn Nóng',
                  info: '${_dataModel.nhietbonnong.toStringAsFixed(1)}°',
                  iconData: Icons.thermostat_outlined,
                  color: Colors.red,
                ),
              ),
              Expanded(
                child: SensorDataWidget(
                  title: 'Bồn Lạnh',
                  info: '${_dataModel.nhietbonlanh.toStringAsFixed(1)}°',
                  iconData: Icons.thermostat_outlined,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const Gap(vPadding),
          const TitleWidget(title: 'Ngưỡng Nhiệt Độ', isTitle: false),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: _ThresholdInputWidget(
                  title: 'Ngưỡng Bồn Nóng',
                  value: _dataModel.nguongbonnong.toStringAsFixed(1),
                  onPressed: () {
                    _showThresholdInputDialog(
                      context,
                      'Cập nhật ngưỡng bồn nóng',
                      _dataModel.nguongbonnong.toStringAsFixed(1),
                          (value) async {
                        await _sendBleData(SendDataModel(
                          nguongbonnong: value,
                          nguongbonlanh: _dataModel.nguongbonlanh,
                          dungtich: _dataModel.dungtich,
                        ));
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: _ThresholdInputWidget(
                  title: 'Ngưỡng Bồn Lạnh',
                  value: _dataModel.nguongbonlanh.toStringAsFixed(1),
                  onPressed: () {
                    _showThresholdInputDialog(
                      context,
                      'Cập nhật ngưỡng bồn lạnh',
                      _dataModel.nguongbonlanh.toStringAsFixed(1),
                          (value) async {
                        await _sendBleData(SendDataModel(
                          nguongbonnong: _dataModel.nguongbonnong,
                          nguongbonlanh: value,
                          dungtich: _dataModel.dungtich,
                        ));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          const Gap(vPadding),
          const TitleWidget(title: 'Dung Tích Mỗi Chai', isTitle: false),
          _ThresholdInputWidget(
            title: 'Dung Tích',
            value: _dataModel.dungtich.toStringAsFixed(1),
            onPressed: () {
              _showThresholdInputDialog(
                context,
                'Cập nhật dung tích',
                _dataModel.dungtich.toStringAsFixed(1),
                    (value) async {
                  await _sendBleData(SendDataModel(
                    nguongbonnong: _dataModel.nguongbonnong,
                    nguongbonlanh: _dataModel.nguongbonlanh,
                    dungtich: value,
                  ));
                },
              );
            },
          ),
          const Gap(vPadding),
          const TitleWidget(title: 'Số Lượng Chai Đã Bán', isTitle: false),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(24.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              child: ListTile(
                title: const Text(
                  'Số Lượng Chai',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  _dataModel.soluongchai.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThresholdInputWidget extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onPressed;

  const _ThresholdInputWidget({
    required this.title,
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}