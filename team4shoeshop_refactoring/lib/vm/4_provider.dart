// 도영 : 야호~~~~~~~~~~~~^^

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team4shoeshop_refactoring/model/ordersproduct.dart';
import 'package:http/http.dart' as http;


class OrdersProductNotifier extends AsyncNotifier<List<OrdersProduct>>{

  @override
  Future<List<OrdersProduct>> build() async{
    return await fetchOrders();
  }

  final String baseUrl = "http://127.0.0.1:8000";
  final box =GetStorage();

  Future<List<OrdersProduct>> fetchOrders() async {
    final cid = box.read('p_userId');
    final url = Uri.parse("$baseUrl/order_list?cid=$cid");
    final response = await http.get(url);
    final data = json.decode(utf8.decode(response.bodyBytes));

    final List<OrdersProduct> result =
        (data['result'] as List).map((data) =>OrdersProduct.fromJson(data)).toList();
    
    return result;
  }
}


final ordersProductProvider = AsyncNotifierProvider<OrdersProductNotifier, List<OrdersProduct>>(
  () => OrdersProductNotifier(),
);