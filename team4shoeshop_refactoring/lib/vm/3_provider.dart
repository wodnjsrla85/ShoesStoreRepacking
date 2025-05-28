import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:team4shoeshop_refactoring/model/returnsModel.dart';

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
      
      print("서버 응답: $data"); // ✅ 디버깅용

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
      print("오류 발생: $e");
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
    print(result);
    return result;
  }
}
final retunrProvider = AsyncNotifierProvider<ReturnsNotifire,List<ReturnsModel>>(
  () => ReturnsNotifire(),
);