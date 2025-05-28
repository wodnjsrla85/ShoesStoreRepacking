import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team4shoeshop_refactoring/admin/admin_main.dart';
import 'package:team4shoeshop_refactoring/view/login.dart';
import 'package:team4shoeshop_refactoring/vm/3_provider.dart';


class Adminlogin extends ConsumerWidget {
  const Adminlogin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminIdController = TextEditingController();
    final adminpasswordController = TextEditingController();
    final employeeNotifier = ref.read(employeeLoginProvider.notifier);
    final box = GetStorage();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          '관리자 로그인',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('images/login.png'),
                    radius: 60,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: adminIdController,
                    decoration: const InputDecoration(
                      labelText: '관리자 ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: adminpasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '패스워드',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:() async{
                        final id = adminIdController.text.trim();
                        final pw = adminpasswordController.text.trim();
                        await employeeNotifier.loginAdmin(id,pw);
                        if(box.read('adminId') != null){
                          Get.to(()=> AdminMain());
                        }else{
                          return;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Get.off(() =>LoginPage()),
                    child: const Text(
                      '고객 로그인으로 돌아가기',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}