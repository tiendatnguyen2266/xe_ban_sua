//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_xe_ban_sua/consts/consts.dart';
import 'package:app_xe_ban_sua/theme/app_theme.dart';

class ConnectionInfoWidget extends StatelessWidget {
  final bool isConnected;
  final String infoText;
  final Function(bool) changeStatus;

  const ConnectionInfoWidget({
    super.key,
    required this.isConnected,
    required this.infoText,
    required this.changeStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      child: Container(
        decoration: BoxDecoration(
          color: colorCard,
          borderRadius: BorderRadius.circular(24.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        child: ListTile(
          leading: Icon(
            isConnected ? Icons.check_circle : Icons.error,
            color: isConnected ? Colors.green : Colors.red,
          ),
          title: Text(
            isConnected ? 'Đã Kết Nối' : 'Đã Ngắt Kết Nối',
            style: const TextStyle(
              fontSize: infoTextSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            infoText,
            style: const TextStyle(
              fontSize: infoTextSize,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => changeStatus(!isConnected),
          ),
        ),
      ),
    );
  }
}
