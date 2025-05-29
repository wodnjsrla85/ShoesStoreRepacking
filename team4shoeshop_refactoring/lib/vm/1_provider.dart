import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:team4shoeshop_refactoring/model/customer.dart';
import 'package:team4shoeshop_refactoring/model/ordersproduct.dart';
import '../model/daily_revenue.dart';



// shoeslistpage.dart 로그인하고 메인화면
class ShoesNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return await fetchShoes();
  }

  Future<List<Map<String, dynamic>>> fetchShoes() async {
    final response = await http.get(Uri.parse("http://127.0.0.1:8000/product_list"));
    final data = json.decode(utf8.decode(response.bodyBytes));
    return List<Map<String, dynamic>>.from(data['result']);
  }

  Future<void> refreshShoes() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async => await fetchShoes());
  }
}
final searchProvider = StateProvider<String>((ref) => "");  // 검색창을 위해 추가
final shoesProvider =
    AsyncNotifierProvider<ShoesNotifier, List<Map<String, dynamic>>>(
  () => ShoesNotifier(),
);


// joincustomer.dart 회원가입 화면
class CustomerNotifier extends AsyncNotifier<List<Customer>> {
  @override
  Future<List<Customer>> build() async {
    return []; // 회원 목록을 유지하지 않음
  }

  
  Future<String> insertCustomer(Customer customer) async {
    try {
      final uri = Uri.parse("http://127.0.0.1:8000/insert_customer");
      final request = http.MultipartRequest("POST", uri);
      request.fields.addAll(customer.toRegisterMap());

      final response = await request.send();
      final resultString = await response.stream.bytesToString();
      final jsonResult = json.decode(resultString);
      return jsonResult['result'] ?? "Error";
    } catch (e) {
      return "Error";
    }
  }

  
  Future<bool> checkCustomerIdDuplicate(String cid) async {
    try {
      final url = Uri.parse("http://127.0.0.1:8000/check_customer_id?cid=$cid");
      final response = await http.get(url);
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data["result"] == "exists";
    } catch (e) {
      return true; // 오류 발생 시 중복된 것으로 간주
    }
  }
}

final customerProvider = AsyncNotifierProvider<CustomerNotifier, List<Customer>>(
  () => CustomerNotifier(),
);



// cart.dart 장바구니 화면
class CartNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  late String _cid;

  @override
  Future<List<Map<String, dynamic>>> build() async => [];

  Future<void> fetchCartItems(String cid) async {
    _cid = cid;
    state = AsyncLoading();
    try {
      final response = await http.get(Uri.parse("http://127.0.0.1:8000/cart_items?cid=$cid"));
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data["result"] is List) {
        state = AsyncValue.data(List<Map<String, dynamic>>.from(data["result"]));
      } else {
        state = AsyncValue.error("장바구니 데이터를 불러오지 못했습니다", StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error("오류 발생: $e", StackTrace.current);
    }
  }

  Future<void> deleteCartItem(int oid) async {
    try {
      final response = await http.delete(Uri.parse("http://127.0.0.1:8000/delete_cart_item/$oid"));
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data["result"] == "OK") {
        await fetchCartItems(_cid);
      } else {
        state = AsyncValue.error("삭제 실패: ${data['result']}", StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error("삭제 중 오류 발생: $e", StackTrace.current);
    }
  }

  Future<Customer?> fetchCustomerInfo(String cid) async {
    try {
      final res = await http.get(Uri.parse("http://127.0.0.1:8000/customer_info?cid=$cid"));
      // print("응답 결과: ${res.body}"); 디버깅용 찍어보기
      final data = json.decode(utf8.decode(res.bodyBytes));
      if (data["result"] == "OK") {
        return Customer(
          cid: data["cid"],
          cname: data["cname"],
          cpassword: "", // 서버에선 전달되지 않음
          cphone: data["cphone"],
          cemail: data["cemail"],
          caddress: data["caddress"],
          ccardnum: data["ccardnum"],
          ccardcvc: int.tryParse(data["ccardcvc"].toString()) ?? 0,
          ccarddate: data["ccarddate"],
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, List<Map<String, dynamic>>>(
  () => CartNotifier(),
);







// admin_daily_revenue.dart 날짜별 매출 그래프 출력
class DailyRevenueNotifier extends AsyncNotifier<List<DailyRevenue>> {
  @override
  Future<List<DailyRevenue>> build() async {
    // 기본값 로딩 시 여기서 자동 호출됨
    return await fetchRevenue();
  }

  Future<List<DailyRevenue>> fetchRevenue() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/daily_revenue'));
    final data = json.decode(utf8.decode(response.bodyBytes));

    if (data["result"] != null && data["result"] is List) {
      final revenues = (data["result"] as List)
          .map((item) => DailyRevenue.fromJson(item))
          .toList();
      return revenues;
    } else {
      throw Exception("서버 응답 형식 오류");
    }
  }
}

final dailyRevenueProvider =
    AsyncNotifierProvider<DailyRevenueNotifier, List<DailyRevenue>>(
  () => DailyRevenueNotifier(),
);





// dealer_return.dart 대리점 반품 출력
class DealerNotifier extends AsyncNotifier<List<OrdersProduct>> {
  @override
  Future<List<OrdersProduct>> build() async {
    final box = GetStorage();
    final eid = box.read('adminId') ?? '';

    final response = await http.get(Uri.parse('http://127.0.0.1:8000/list'));
    if (response.statusCode == 200) {
      final List data = json.decode(utf8.decode(response.bodyBytes))['results'];
      return data
          .map((e) => OrdersProduct.fromJson(e))
          .where((item) => item.order.oeid == eid)
          .toList();
    } else {
      throw Exception('주문 데이터를 불러오지 못했습니다');
    }
  }
}

final dealerProvider =
    AsyncNotifierProvider<DealerNotifier, List<OrdersProduct>>(
  () => DealerNotifier(),
);


// admin_return.dart 본사 반품 출력

class AdminNotifier extends AsyncNotifier<List<OrdersProduct>> {
  @override
  Future<List<OrdersProduct>> build() async {
    final response = await http.get(Uri.parse("http://127.0.0.1:8000/return_orders"));
    final data = json.decode(utf8.decode(response.bodyBytes));

    if (data['result'] != null && data['result'] is List) {
      return (data['result'] as List)
          .map((json) => OrdersProduct.fromJson(json))
          .toList();
    } else {
      throw Exception("서버 응답 형식 오류");
    }
  }
}

final adminProvider = AsyncNotifierProvider<AdminNotifier, List<OrdersProduct>>(
  () => AdminNotifier(),
);

