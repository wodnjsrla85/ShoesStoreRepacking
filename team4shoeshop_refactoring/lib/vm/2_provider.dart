/** 목적 :
 * riverpod을 공부하기 위해 개발을 시작하였다
 * 이름  : 김수아 
 * 개발 일지 : 
 * view/loin.dart
 * 로그인 파일을 stf - >stl로 변경하여 필요한 핸드러를 구성하하였다
 * 핸드러는 login
 */

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:riverpod/riverpod.dart';
import 'package:team4shoeshop_refactoring/admin/admin_dealer_revenue.dart';
import 'package:team4shoeshop_refactoring/admin/admin_goods_revenue.dart';
import 'package:team4shoeshop_refactoring/model/customer.dart';
import 'package:team4shoeshop_refactoring/model/product.dart';
import 'package:team4shoeshop_refactoring/view/shoeslistpage.dart';
import 'package:remedi_kopo/remedi_kopo.dart';


//로그인을 도와줌 
class LoginNotifier extends StateNotifier<List<Customer>> {
  LoginNotifier() : super([]);

  Future<void> login(String id, String pw) async {
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

    void showDialog(String name) {
      Get.defaultDialog(
        title: '환영합니다',
        middleText: '$name 님, 환영합니다.',
        backgroundColor: Colors.white,
        barrierDismissible: false,
        actions: [
          TextButton(
            onPressed: () {
              box.write('p_userId', id);
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
        showDialog(data["cname"]);
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
      colorText: Colors.white,
      backgroundColor: Colors.red,
    );
  }
}

// 고객정보가 중간 중간 변하는 값을 만들기 위해서 고객 State를 만들어야 할 것 같아서 만듦
class CustomerState {
  final String cid;
  final String cname;
  final String cpassword;
  final String cphone;
  final String cemail;
  final String caddress;
  final String ccardnum;
  final int ccardcvc;
  final int ccarddate;

  CustomerState({
    this.cid = "",
    this.cname = "",
    this.cpassword = "",
    this.cphone = "",
    this.cemail = "",
    this.caddress = "",
    this.ccardnum = "",
    this.ccardcvc = 0,
    this.ccarddate = 0,
  });

  CustomerState copyWith({
    String? cid,
    String? cname,
    String? cpassword,
    String? cphone,
    String? cemail,
    String? caddress,
    String? ccardnum,
    int? ccardcvc,
    int? ccarddate,
  }) {
    return CustomerState(
      cid: cid ?? this.cid,
      cname: cname ?? this.cname,
      cpassword: cpassword ?? this.cpassword,
      cphone: cphone ?? this.cphone,
      cemail: cemail ?? this.cemail,
      caddress: caddress ?? this.caddress,
      ccardnum: ccardnum ?? this.ccardnum,
      ccardcvc: ccardcvc ?? this.ccardcvc,
      ccarddate: ccarddate ?? this.ccarddate,
    );
  }
}

class Updateuser extends StateNotifier<CustomerState> {
  Updateuser() : super(CustomerState());
    bool _hasLoaded = false;

  //횐원 정보를 가지고 옴 
  Future<void> loadProfile() async {
    if(_hasLoaded){
      return;
    }
    final box = GetStorage();
    String userId = box.read('p_userId') ?? '';

    if (userId.isEmpty) {
      return;
    }

    final url = Uri.parse('http://127.0.0.1:8000/customer_info1?cid=$userId');
    final response = await http.get(url);
    final data = json.decode(utf8.decode(response.bodyBytes));

    if (data['result'] == 'OK') {
      state = state.copyWith(
        cid: userId,
        cname: data['cname'] ?? '',
        cpassword: data['cpassword'] ?? '',
        cphone: data['cphone'] ?? '',
        cemail: data['cemail'] ?? '',
        caddress: data['caddress'] ?? '',
        ccardnum: data['ccardnum'] ?? '',
        ccardcvc: data['ccardcvc'] ?? 0,
        ccarddate: data['ccarddate'] ?? 0,

      );
      _hasLoaded = true;
    }
  }

  // 업데이트 함수
  Future<void> updateProfile(Customer c) async {
    final url = Uri.parse('http://127.0.0.1:8000/update_customer');
    final request = http.MultipartRequest('POST', url);

    final cardDateText = c.ccarddate.toString();
    if (cardDateText.length != 4 ||
        int.tryParse(cardDateText.substring(2)) == null ||
        int.parse(cardDateText.substring(2)) < 1 ||
        int.parse(cardDateText.substring(2)) > 12) {
      Get.snackbar("입력 오류", "유효기간은 YYMM 형식의 4자리 숫자여야 하며, MM은 01~12입니다.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    request.fields['cid'] = c.cid;
    request.fields['cname'] = c.cname;
    request.fields['cpassword'] = c.cpassword;
    request.fields['cphone'] = c.cphone;
    request.fields['cemail'] = c.cemail;
    request.fields['caddress'] = c.caddress;
    request.fields['ccardnum'] = c.ccardnum;
    request.fields['ccardcvc'] = c.ccardcvc.toString();
    request.fields['ccarddate'] = cardDateText;

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = json.decode(body);

      if (data['result'] == 'OK') {
        Get.snackbar("수정 완료", "회원정보가 저장되었습니다.",
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2));
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAll(() => const Shoeslistpage());
        });
      } else {
        Get.snackbar("오류", "수정 실패", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("에러", "서버 오류: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  //주소를 불러옴 
  Future<void> searchAddress(BuildContext context) async {
    String basicAddress = "";
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => RemediKopo()));
    if (result is KopoModel && result.address != null) {
      basicAddress = result.address!;
    }
    state = state.copyWith(caddress: basicAddress);
  }
}

//물건 그래프를 그릴 정보 들고 오는거  
class AdminGoodsRevenueNotifier extends StateNotifier<List<GoodsRevenue>>{

  AdminGoodsRevenueNotifier ():super([]);

  bool loding = false; 
  
  Future<void> fetchChartData() async {
    try {
      if(loding){
        return;
      }
      loding = true;
      final response = await http.get(Uri.parse("http://127.0.0.1:8000/goods_revenue"));
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data['result'] != null && data['result'] is List) {
          
           state = data['result'].map<GoodsRevenue>((item) {
            return GoodsRevenue(
              name: item['name'],
              amount: (item['total'] ?? 0) ~/ 10000, // 만원 단위
            );
          }).toList();
      }
    } catch (e) {
      print('❗ 서버 통신 오류: $e');
    }
  } 
}

//데일리 그래프 그릴 정보 들고 오기 
class AdminDealerRevenueNotifier extends StateNotifier<List<DealerRevenue>>{
  AdminDealerRevenueNotifier ():super([]);
  
  String selectedYear = DateTime.now().year.toString(); //처음 시작 년 
  String selectedMonth = DateTime.now().month.toString().padLeft(2, '0'); // 처음 시작 월 
  
  //처음에 시작하자 마자 한 번 도표를 그릴 함수 
  Future<void> fetchChartData() async {
    try {
      final url = Uri.parse(
        'http://127.0.0.1:8000/dealer_revenue?year=$selectedYear&month=$selectedMonth',
      );
      final response = await http.get(url);
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data['result'] != null && data['result'] is List) {
    
          state = data['result'].map<DealerRevenue>((item) {
            return DealerRevenue(
              name: item['ename'],
              amount: (item['total'] ?? 0) ~/ 10000, // 만원 단위
            );
          }).toList();
      } else {
        state =[];
      }
    } catch (e) {
      print('❗ 에러: $e');
    }
  }



  //데이터가 변경 되었을 때 그 값을 넣어줄 함수 

   Future<void> fetchChartData1() async {
    try {
      final url = Uri.parse(
        'http://127.0.0.1:8000/dealer_revenue?year=$selectedYear&month=$selectedMonth',
      );
      final response = await http.get(url);
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data['result'] != null && data['result'] is List) {
    
          state = data['result'].map<DealerRevenue>((item) {
            return DealerRevenue(
              name: item['ename'],
              amount: (item['total'] ?? 0) ~/ 10000, // 만원 단위
            );
          }).toList();
      } else {
        state =[];
      }
    } catch (e) {
      print('❗ 에러: $e');
    }
  }
}


//상품 등록 불러오기 
class ProductState {
   int? id;
   String pid;
   String pbrand;
   String pname;
   int psize;
   String pcolor;
   int pstock;
   int pprice;
   XFile? pimage;
  ProductState({
    this.id = 0,
    this.pid = "",
    this.pbrand = "",
    this.pname = "",
    this.psize = 0,
    this.pcolor = "",
    this.pstock = 0,
    this.pprice = 0,
    this.pimage
  });

  ProductState copyWith({
    int? id,
    String? pid,
    String? pbrand,
    String? pname,
    int? psize,
    String? pcolor,
    int? pstock,
    int? pprice,
    XFile? pimage
  }) {
    return ProductState(
      id: id ?? this.id,
      pid: pid ?? this.pid,
      pbrand: pbrand ?? this.pbrand,
      pname: pname ?? this.pname,
      psize: psize ?? this.psize,
      pcolor: pcolor ?? this.pcolor,
      pstock: pstock ?? this.pstock,
      pprice: pprice ?? this.pprice,
      pimage: pimage ?? this.pimage,
    );
  }
}

//상품 등록에 사용됨 !!!!
class ProductInsert extends StateNotifier<ProductState>{
  ProductInsert(): super(ProductState());

  Future<void> submitProduct() async {
    final uri = Uri.parse('http://127.0.0.1:8000/a_product_insert');
    final request = http.MultipartRequest('POST', uri);

    request.fields['pid'] = state.pid;
    request.fields['pbrand'] = state.pbrand;
    request.fields['pname'] = state.pname;
    request.fields['psize'] = state.psize.toString();
    request.fields['pcolor'] = state.pcolor;
    request.fields['pstock'] = state.pstock.toString();
    request.fields['pprice'] = state.pprice.toString();
    request.files.add(await http.MultipartFile.fromPath('pimage', state.pimage!.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      Get.snackbar('성공', '상품이 등록되었습니다.');
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
    } else {
      final respStr = await response.stream.bytesToString();
      Get.snackbar('실패', '에러 발생: $respStr');
    }
  }
}
//이미지 

class ImageState {
  XFile? imageFile;
  ImageState({
    this.imageFile=null
  }); 
}
  class ImageHandler  extends StateNotifier<ImageState> {
    ImageHandler(): super(ImageState());
   final ImagePicker picker = ImagePicker();
  Future<void> getImageFromGallery(ImageSource soure) async{
    final pickedFile = await picker.pickImage(source: soure);
    if(PickedFile != null){
      state  = ImageState(imageFile: pickedFile);
    }
  }

  void clearImage(){
   state = ImageState();
  }

}


//상품 등록 
final productInsertProvider = StateNotifierProvider<ProductInsert,ProductState>(
  (ref)=>ProductInsert()
);
//사진 고르기 
final ImageHandlerProvider = StateNotifierProvider<ImageHandler,ImageState>(
  (ref)=>ImageHandler()
);
//데일리 도표
final adminDealerRevenueProvider = StateNotifierProvider<AdminDealerRevenueNotifier,List<DealerRevenue>>(
   (ref)=>AdminDealerRevenueNotifier()
);
//물건 도표
final adminGoodsRevenueProvider = StateNotifierProvider<AdminGoodsRevenueNotifier,List<GoodsRevenue>>(
  (ref)=>AdminGoodsRevenueNotifier());
//로그인
final loginProvider = StateNotifierProvider<LoginNotifier, List<Customer>>(
  (ref) => LoginNotifier(),
);
//업데이트 
final updateuserProvider = StateNotifierProvider<Updateuser, CustomerState>(
  (ref) => Updateuser(),
);
