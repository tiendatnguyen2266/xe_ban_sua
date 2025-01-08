import 'package:flutter/material.dart';
import 'package:app_xe_ban_sua/consts/consts.dart';
import 'package:app_xe_ban_sua/theme/app_theme.dart';
import 'package:app_xe_ban_sua/widgets/title_widget.dart';
import 'package:gap/gap.dart';

class ScanTitleWidget extends StatelessWidget {
  const ScanTitleWidget({
    super.key,
    required this.isScanning,
  });

  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return isScanning
        ? Column(
            children: [
              LinearProgressIndicator(color: colorCard),
              const Gap(homeSizedHeight * 0.5),
              Row(
                children: [
                  const TitleWidget(
                    title: 'Đang Tìm Kiếm Thiết Bị...',
                    isTitle: false,
                  ),
                  TweenAnimationBuilder(
                    tween: Tween(begin: 15, end: 1.0),
                    duration: const Duration(seconds: 15),
                    builder: (_, dynamic value, child) => Text(
                      "${value.toInt()}sec",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleSize,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : const TitleWidget(title: 'Các Thiết Bị Được Tìm Thấy', isTitle: false);
  }
}
