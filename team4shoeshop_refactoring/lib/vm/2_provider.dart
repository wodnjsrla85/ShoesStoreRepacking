
/** 목적 :
 * riverpod을 공부하기 위해 개발을 시작하였다
 * 이름  : 김수아 
 * 개발 일지 : 
 * view/loin.dart
 * 로그인 파일을 stf - >stl로 변경하여 필요한 핸드러를 구성하하였다
 * 핸드러는 login
 */
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import 'package:team4shoeshop_refactoring/model/customer.dart';
import 'package:team4shoeshop_refactoring/view/shoeslistpage.dart';


//로그인을 도와줌 
class LoginNotifier extends StateNotifier<List<Customer>>{
  LoginNotifier():super([]);

  

  Future<void> login(String id ,String pw) async {
    final box = GetStorage();
    box.write('p_userId', "");
    box.write('p_password', "");

    if (id.isEmpty || pw.isEmpty) {
      return;
    }

    final url = Uri.parse("http://127.0.0.1:8000/login");
    final request = http.MultipartRequest('POST', url);
    request.fields['cid'] = id;
    request.fields['cpassword'] = pw;
    void _showDialog(String name) {
      Get.defaultDialog(
        title: '환영합니다',
        middleText: '$name 님, 환영합니다.',
        backgroundColor: Colors.white,
        barrierDismissible: false,
        actions: [
          TextButton(
            onPressed: () {
              box.write('p_userId',id);
              Get.back();
              Get.to(() => const Shoeslistpage());
            },
            child: const Text('Exit'),
          ),
        ],
      );
    }
  
    try {
      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);

      if (data["result"] == "success") {
        box.write('p_userId', id);
        _showDialog(data["cname"]);
      } else {
        Get.snackbar(
          '로그인 실패',
          'ID 또는 비밀번호가 잘못되었습니다.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("오류", "서버 오류: $e");
    }
  }
    

  void errorSnackBar() {
    Get.snackbar(
      '경고',
      '사용자 ID와 암호를 입력하세요',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      colorText:Colors.white,
      backgroundColor: Colors.red,
    );
  }

}
final loginProvider  = StateNotifierProvider<LoginNotifier, List<Customer>>(
  (ref) => LoginNotifier(),
);