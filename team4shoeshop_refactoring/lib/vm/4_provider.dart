// 도영 : 야호~~~~~~~~~~~~^^

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team4shoeshop_refactoring/model/ordersproduct.dart';
import 'package:http/http.dart' as http;


class OrdersProductNotifier extends StateNotifier<List<OrdersProduct>>{

  OrdersProductNotifier() : super(<OrdersProduct>[]);

  final String baseUrl = "http://127.0.0.1:8000";

  Future<List<OrdersProduct>> fetchOrders(int cid) async {
    final url = Uri.parse("$baseUrl/order_list?cid=$cid");
    final response = await http.get(url);
    final data = json.decode(utf8.decode(response.bodyBytes));

    final List<OrdersProduct> result =
        (data['results'] as List).map((data) =>OrdersProduct.fromJson(data)).toList();
    
    return result;
  }
}


final ordersProductProvider = StateNotifierProvider<OrdersProductNotifier, List<OrdersProduct>>(
  (ref) => OrdersProductNotifier(),
);