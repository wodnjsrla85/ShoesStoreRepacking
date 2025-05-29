import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:team4shoeshop_refactoring/model/admin_sales.dart';
import 'package:team4shoeshop_refactoring/model/dealerlistModel.dart';
import 'package:team4shoeshop_refactoring/model/inven_model.dart';
import 'package:team4shoeshop_refactoring/model/returns_model.dart';
import 'package:team4shoeshop_refactoring/view/shoeslistpage.dart';

class EmployeeLoginNotifier extends StateNotifier<String> {
  EmployeeLoginNotifier() : super('');

  final String baseUrl = "http://127.0.0.1:8000";
  final box = GetStorage();

  Future<void> loginAdmin(String id, String pw) async {
    try {
      final url = Uri.parse("$baseUrl/employee_login");
      final request = http.MultipartRequest("POST", url);
      request.fields['eid'] = id;
      request.fields['epassword'] = pw;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);
      
      if (data['result'] == 'success') {
        await box.write('adminId', data['eid']);
        await box.write('adminName', data['ename']);
        await box.write('adminPermission', data['epermission']);
      } else {
        Get.snackbar(
          '로그인 실패',
          '아이디 또는 비밀번호가 올바르지 않습니다.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          colorText: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Get.snackbar("서버 오류", "로그인 요청 중 문제가 발생했습니다.");
    }
  }
}
final employeeLoginProvider = StateNotifierProvider(
  (ref) => EmployeeLoginNotifier(),
);

// Retunrs
class ReturnsNotifire extends AsyncNotifier<List<ReturnsModel>>{
  final box = GetStorage();

  @override
  Future<List<ReturnsModel>> build() async{
    return await fetchReturns();
  }

  Future<List<ReturnsModel>> fetchReturns() async{
    final cid = await box.read('p_userId');
    final url = Uri.parse('http://127.0.0.1:8000/returns?cid=$cid');
    final response = await http.get(url);
    final data = json.decode(utf8.decode(response.bodyBytes));
    final List<ReturnsModel> result = (data['result'] as List).map((data)=> ReturnsModel.fromJson(data)).toList();
    return result;
  }
}
final retunrProvider = AsyncNotifierProvider<ReturnsNotifire,List<ReturnsModel>>(
  () => ReturnsNotifire(),
);

class BuyNotifier extends StateNotifier<bool>{
  BuyNotifier() : super(false);
  final box = GetStorage();
  
  Future<void> submitPurchase(String pw, Map arguments) async {
    if (pw.length != 2) {
      Get.snackbar("비밀번호", "카드 비밀번호 앞 2자리를 입력해주세요");
      return;
    }

    final cid = box.read("p_userId");
    if (cid == null) return;

    final isSingleBuy = arguments["product"] != null;

    state = true;

    if (isSingleBuy) {
      final product = arguments["product"];
      final quantity = arguments["quantity"];
      final oeid = arguments["storeId"];

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("http://127.0.0.1:8000/buy_direct"),
      );
      request.fields["cid"] = cid;
      request.fields["pid"] = product["pid"];
      request.fields["count"] = quantity.toString();
      request.fields["oeid"] = oeid;

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);
    
      if (data["result"] == "OK") {
        Get.snackbar("구매 완료", "상품을 구매하였습니다");
        await Future.delayed(const Duration(seconds: 1));
        Get.offAll(() => const Shoeslistpage());
      } else {
        Get.snackbar("실패", data["message"] ?? "구매 실패");
      }
    } else {
      final selectedItems = arguments["items"] as List;
      final encodedItems = json.encode(selectedItems);

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("http://127.0.0.1:8000/buy_selected"),
      );
      request.fields["cid"] = cid;
      request.fields["items"] = encodedItems;

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);

      if (data["result"] == "OK") {
        Get.snackbar("구매 완료", "선택한 상품을 모두 구매하였습니다");
        await Future.delayed(const Duration(seconds: 1));
        Get.offAll(() => const Shoeslistpage());
      } else {
        Get.snackbar("실패", data["message"] ?? "구매 실패");
      }
    }

    state = false;
  }
}final buyProvider = StateNotifierProvider<BuyNotifier,bool>((ref) => BuyNotifier(),);



class DealerMainNotifier extends AsyncNotifier<List<Dealerlistmodel>>{
  final box = GetStorage();
  @override
  Future<List<Dealerlistmodel>> build() async{
    await fetchDistrictName();
    return await fetchOrderData();
  }

  Future<void> fetchDistrictName() async{
    final eid = box.read('adminId');
    String dadminname = '';
    await http.get(Uri.parse('http://127.0.0.1:8000/district?eid=$eid')).then((response) {
    final result = json.decode(utf8.decode(response.bodyBytes));
    dadminname = result['ename'] ?? '';
    box.write('ename', dadminname);
    });
  }


Future<List<Dealerlistmodel>> fetchOrderData() async{
    final String dal = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";
    final eid = await box.read('adminId');
    final url = Uri.parse('http://127.0.0.1:8000/list');
    final response = await http.get(url);
    final data = json.decode(utf8.decode(response.bodyBytes))['results'];
   

    final result = data.where((item) {
      return item['oeid'].toString() == eid &&
          item['oreturndate'] == null &&
          (item['odate'] ?? '').toString().startsWith(dal);
    }).toList();

    final List<Dealerlistmodel> result1 = (result as List).map((data)=> Dealerlistmodel.fromJson(data)).toList();
    return result1;
  }

    
}

final delaerMainProvider = AsyncNotifierProvider<DealerMainNotifier, List<Dealerlistmodel>>(
  () => DealerMainNotifier(),
);

class AdminInvenNotifier extends AsyncNotifier<List<Invenmodel>>{
  final box = GetStorage();
  @override
  Future<List<Invenmodel>> build() async{
    return await _fetchInventory();
  }

  Future<List<Invenmodel>> _fetchInventory() async {
      final adminLevel = box.read('adminLevel') ?? 'guest';
      final uri = Uri.parse('http://127.0.0.1:8000/a_inventory');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Admin-Level': adminLevel,
        },
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<Invenmodel>result = (data['result'] as List).map((e) => Invenmodel.fromJson(e)).toList();
      return result;
  }
}

final adminInvenProvider = AsyncNotifierProvider<AdminInvenNotifier, List<Invenmodel>>(
  () => AdminInvenNotifier(),
);

class AdminSalesNotifier extends AsyncNotifier<List<AdminSales>>{
  @override
  Future<List<AdminSales>> build() async{
    return await fetchSalesData();
  }

  Future<List<AdminSales>> fetchSalesData()async{
    var response = await http.get(Uri.parse('http://127.0.0.1:8000/a_dealer_sales'));
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<AdminSales> result = (data['result'] as List).map((e) => AdminSales.fromJson(e)).toList();
      return result;
  }
}

final adminSalesProvider = AsyncNotifierProvider<AdminSalesNotifier, List<AdminSales>>(
  () => AdminSalesNotifier(),
);

class DealreReturnNotifier extends StateNotifier{
  DealreReturnNotifier() : super ('');

  Future<void> updateReturnInfo(String oreturncount, String oreason, String oreturnstatus, String odefectivereason, BuildContext context) async {
    final now = DateTime.now();
    final formattedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final orderMap = Get.arguments ?? '_';

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/update_return'),
      body: {
        'oid': orderMap['oid'].toString(),
        'oreturncount': oreturncount,
        'oreason': oreason,
        'oreturnstatus': oreturnstatus,
        'odefectivereason': odefectivereason,
        'oreturndate': formattedDate,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('반품 정보가 저장되었습니다')),
      );
      Navigator.pop(context, true);
    } else {
      Get.snackbar("오류", "서버 응답 실패: ${response.statusCode}");
    }
  }
}

final dealerReturnProvider = StateNotifierProvider((ref) => DealreReturnNotifier(),);
