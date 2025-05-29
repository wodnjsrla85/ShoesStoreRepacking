// 도영 : 야호~~~~~~~~~~~~^^

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team4shoeshop_refactoring/model/ordersproduct.dart';
import 'package:http/http.dart' as http;
import 'package:team4shoeshop_refactoring/model/sales.dart';

import '../model/product.dart';


class OrdersProductNotifier extends AsyncNotifier<List<OrdersProduct>>{

  @override
  Future<List<OrdersProduct>> build() async{
    return await fetchOrders();
  }

  final String baseUrl = "http://127.0.0.1:8000";
  final box = GetStorage();
  

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

// -------------------

class LowStockNotifier extends AsyncNotifier<int>{

  @override
  Future<int> build() async{
    return await fetchLowStock();
  }
  
  final String baseUrl = "http://127.0.0.1:8000";

  
  Future<int> fetchLowStock() async{
    final url = Uri.parse("$baseUrl/a_low_stock");
    final response = await http.get(url);
    final int lowStock = (json.decode(utf8.decode(response.bodyBytes))['result']??0);
    return lowStock;
  }
}

final lowStockProvider = AsyncNotifierProvider<LowStockNotifier, int>(
  () => LowStockNotifier(),
  );

// ------------------

class SalesNotifier extends AsyncNotifier<Sales>{

@override
  Future<Sales> build() async{
    final today = await fetchTodaySales();
    final yesterday = await fetchYesterdaySales();
    return Sales(todaySales: today, yesterdaySales: yesterday);
  }

  final String baseUrl = "http://127.0.0.1:8000";

  Future<int> fetchTodaySales() async{
    final url = Uri.parse("$baseUrl/a_today_sales");
    final response = await http.get(url);
    final int todaySales = (json.decode(utf8.decode(response.bodyBytes))['result']??0);

    return todaySales;
  }

   Future<int> fetchYesterdaySales() async{
    final url = Uri.parse("$baseUrl/a_yesterday_sales");
    final response = await http.get(url);
    final int yesterdaySales = (json.decode(utf8.decode(response.bodyBytes))['result']??0);

    return yesterdaySales;
  }
}

final salesProvider = AsyncNotifierProvider<SalesNotifier, Sales>(
  () => SalesNotifier(),
);

// ----------------------


class ApprovalNotifier extends AsyncNotifier<int>{

@override
  Future<int> build() async{
    return await approvalCouont();
  }

  final String baseUrl = "http://127.0.0.1:8000";
  final box = GetStorage();

  Future<int> approvalCouont() async{
    final permission = box.read('adminPermission');
    final url = Uri.parse("$baseUrl/a_approval_count/$permission");
    final response = await http.get(url);
    final int approvalCount = (json.decode(utf8.decode(response.bodyBytes))['result']??0);

    return approvalCount;
  }
}

final approvalProvider = AsyncNotifierProvider<ApprovalNotifier, int>(
  () => ApprovalNotifier(),
);

// ----------------------

class ReturnCountNotifier extends AsyncNotifier<int>{

@override
  Future<int> build() async{
    return await returnCount();
  }

  final String baseUrl = "http://127.0.0.1:8000";
  
  Future<int> returnCount() async{
   
    final url = Uri.parse("$baseUrl/a_return_count");
    final response = await http.get(url);
    final int approvalCount = (json.decode(utf8.decode(response.bodyBytes))['result']??0);

    return approvalCount;
  }
}

final returnCountProvider = AsyncNotifierProvider<ReturnCountNotifier, int>(
  () => ReturnCountNotifier(),
);