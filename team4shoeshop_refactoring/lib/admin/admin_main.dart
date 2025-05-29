/*
2025.05.05 이학현 / admin 폴더, admin 로그인 후 넘어오는 메인 화면 생성
*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:team4shoeshop_refactoring/admin/widget/admin_drawer.dart';
import 'package:team4shoeshop_refactoring/vm/4_provider.dart';

class AdminMain extends ConsumerWidget {
  const AdminMain({super.key});

  // final box = GetStorage();
 
  // int todaySales = 0;
  // int yesterdaySales = 0;
  // int approval = 0;
  // int returnCount = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   final permission = box.read('adminPermission');
  //   // handler = DatabaseHandler();
  //   getJSONData();
  //   getApprovalCount(permission);
  // }

  // getJSONData()async{
  // var response = await http.get(Uri.parse("http://127.0.0.1:8000/a_low_stock"));
  // var response1 = await http.get(Uri.parse("http://127.0.0.1:8000/a_today_sales"));
  // var response2 = await http.get(Uri.parse("http://127.0.0.1:8000/a_yesterday_sales"));
  // var response4 = await http.get(Uri.parse("http://127.0.0.1:8000/a_return_count"));
  // lowStock = (json.decode(utf8.decode(response.bodyBytes))['result'])??0;
  // todaySales = (json.decode(utf8.decode(response1.bodyBytes))['result'])??0;
  // yesterdaySales = (json.decode(utf8.decode(response2.bodyBytes))['result'])??0;
  // returnCount = (json.decode(utf8.decode(response4.bodyBytes))['result'])??0;
  // setState(() {});
  // print(aData); // 데이터 잘 들어오는지 확인용
  // }

  //   getApprovalCount(int permission)async{
  //   var response3 = await http.get(Uri.parse("http://127.0.0.1:8000/a_approval_count/$permission"));
  //   approval = (json.decode(utf8.decode(response3.bodyBytes))['result'])??0;
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockState = ref.watch(lowStockProvider);
    final salesState = ref.watch(salesProvider);
    final approvalState = ref.watch(approvalProvider);
    final returnCountState = ref.watch(returnCountProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AdminDrawer(),
      appBar: AppBar(
        title: Text(
          '매장 통합 관리 시스템',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          lowStockState.when(
            data: (data) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 중앙 콘텐츠
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 60),
                          child: SizedBox(
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.blue[100],
                                ),
                                height: 80,
                                width: 300,
                                child: Center(
                                  child: Text(
                                    "재고가 30개 미만인 상품이 ${data}개 있습니다.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ],
              );
            },
            error: (error, _) => Center(child: Text('에러 : $error')),
            loading: () => Center(child: CircularProgressIndicator()),
          ),
          salesState.when(
            data: (data) {
              return SizedBox(
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.blue[100],
                              ),
                              height: 80,
                              width: 300,
                              child: Center(
                                child: Text(
                                  "전일 매출은 ${data.yesterdaySales}원 입니다.\n금일 매출은 ${data.todaySales}원 입니다.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        );
            }, 
            error: (error, _) => Center(child: Text("에러 : $error")), 
            loading: () => Center(child: CircularProgressIndicator()),
          ),
          approvalState.when(
            data: (data) {
              return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 60, 0, 60),
                          child: SizedBox(
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.blue[100],
                                ),
                                height: 80,
                                width: 300,
                                child: Center(
                                  child: Text(
                                    "결재할 문서가 $data건 있습니다.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
            }, 
            error: (error, _) => Center(child: Text('에러 : $error')), 
            loading: () => Center(child: CircularProgressIndicator()),
          ),
          returnCountState.when(
            data: (data) {
              return SizedBox(
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.blue[100],
                              ),
                              height: 80,
                              width: 300,
                              child: Center(
                                child: Text(
                                  "반품 접수가 $data건 있습니다.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        );
            }, 
            error: (error, _) => Center(child: Text('에러 : $error')), 
            loading: () => Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  } // build
} // class
