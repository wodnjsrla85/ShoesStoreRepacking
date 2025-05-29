//로그인 페이지 

/* 개발자 : 김수아
 * 목적 :  
 *  회원 이용이 가능하도록 하는 페이지이다. 
 *  
 * 개발일지 :
 *  20250528
 *  satefullwidget 이였던 파일을 consumerwidget으로 변경하고
 *  riverpod을 이용하여  MVVM 형태의 개발을 만들었다. 
 *  회원이 로그인 버튼을 누르게 되면 외부에 있는 handler로 디비 작동을 연결해 주었다. 
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:team4shoeshop_refactoring/view/adminlogin.dart';
import 'package:team4shoeshop_refactoring/view/joincustomer.dart';
import 'package:team4shoeshop_refactoring/vm/2_provider.dart';

class LoginPage extends ConsumerWidget{
  LoginPage({super.key});
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'images/bcdmart.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: userIdController,
                  decoration: InputDecoration(
                    labelText: '사용자 ID를 입력하세요',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '패스워드를 입력하세요',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (){
                      //로그인에 넣은 값을 보내준다.
                      ref.read(loginProvider.notifier).login(userIdController.text.trim(),passwordController.text.trim()) ;
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('로그인', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Get.to(() => const Joincustomer()),
                      icon: const Icon(Icons.person_add),
                      label: const Text('회원가입'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Get.off(() => const Adminlogin()),
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('관리자 페이지'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}