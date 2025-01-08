class ReceivedDataModel {
  final num nhietbonnong;
  final num nhietbonlanh;
  final num nguongbonnong;
  final num nguongbonlanh;
  final num dungtich;
  final num soluongchai;

  ReceivedDataModel({
    required this.nhietbonnong,
    required this.nhietbonlanh,
    required this.nguongbonnong,
    required this.nguongbonlanh,
    required this.dungtich,
    required this.soluongchai,
  });

  factory ReceivedDataModel.fromJson(Map<String, dynamic> json) {
    return ReceivedDataModel(
      nhietbonnong: json['nhietbonnong'],
      nhietbonlanh: json['nhietbonlanh'],
      nguongbonnong: json['nguongbonnong'],
      nguongbonlanh: json['nguongbonlanh'],
      dungtich: json['dungtich'],
      soluongchai: json['soluongchai'],
    );
  }
}

class SendDataModel {
  final num nguongbonnong;
  final num nguongbonlanh;
  final num dungtich;

  SendDataModel({
    required this.nguongbonnong,
    required this.nguongbonlanh,
    required this.dungtich,
  });

  Map<String, dynamic> toJson() {
    return {
      'nguongbonnong': nguongbonnong,
      'nguongbonlanh': nguongbonlanh,
      'dungtich': dungtich,
    };
  }
}