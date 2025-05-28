import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:team4shoeshop_refactoring/model/returnsModel.dart';
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
}

final buyProvider = StateNotifierProvider<BuyNotifier,bool>((ref) => BuyNotifier(),);