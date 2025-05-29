// 대리점에서 반품 표시를 위해 모델을 추가했습니다. 전종익

import 'package:team4shoeshop_refactoring/model/orders.dart';

class OrdersProduct {
  final Orders order;
  final int pprice;
  final String pbrand;
  final String pname;

  OrdersProduct({
    required this.order,
    required this.pprice,
    required this.pbrand,
    required this.pname,
  });

  factory OrdersProduct.fromJson(Map<String, dynamic> json) {
    return OrdersProduct(
      order: Orders(
        oid: json['oid'],
        ocid: json['ocid'] ?? '',
        opid: json['opid'] ?? '',
        oeid: json['oeid'] ?? '',
        ocount: json['ocount'] ?? 0,
        odate: json['odate'] ?? '',
        ostatus: json['ostatus'] ?? '',
        ocarbool: 0, // 없으면 기본값으로
        oreturncount: json['oreturncount'] ?? 0,
        oreturndate: json['oreturndate'] ?? '',
        oreturnstatus: json['oreturnstatus'] ?? '',
        odefectivereason: json['odefectivereason'] ?? '',
        oreason: json['oreason'] ?? '',
      ),
      pprice: json['pprice'] ?? 0,
      pbrand: json['pbrand'] ?? '',
      pname: json['pname'] ?? '',
    );
  }
}