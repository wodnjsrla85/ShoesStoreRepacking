import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:team4shoeshop_refactoring/model/customer.dart';
import 'package:team4shoeshop_refactoring/model/orders.dart';


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
// class CartNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
//   late String _cid;

//   @override
//   Future<List<Map<String, dynamic>>> build() async => [];

//   Future<void> fetchCartItems(String cid) async {
//     _cid = cid;
//     state = const AsyncLoading();
//     try {
//       final response = await http.get(Uri.parse("http://127.0.0.1:8000/cart_items?cid=$cid"));
//       final data = json.decode(utf8.decode(response.bodyBytes));
//       if (data["result"] is List) {
//         state = AsyncValue.data(List<Map<String, dynamic>>.from(data["result"]));
//       } else {
//         state = AsyncValue.error("장바구니 데이터를 불러오지 못했습니다");
//       }
//     } catch (e) {
//       state = AsyncValue.error("오류 발생: $e");
//     }
//   }

//   Future<void> deleteCartItem(int oid) async {
//     try {
//       final response = await http.delete(Uri.parse("http://127.0.0.1:8000/delete_cart_item/$oid"));
//       final data = json.decode(utf8.decode(response.bodyBytes));
//       if (data["result"] == "OK") {
//         await fetchCartItems(_cid);
//       } else {
//         state = AsyncValue.error("삭제 실패: ${data['result']}");
//       }
//     } catch (e) {
//       state = AsyncValue.error("삭제 중 오류 발생: $e");
//     }
//   }

//   Future<Customer?> fetchCustomerInfo(String cid) async {
//     try {
//       final res = await http.get(Uri.parse("http://127.0.0.1:8000/customer_info?cid=$cid"));
//       final data = json.decode(utf8.decode(res.bodyBytes));
//       if (data["result"] == "OK") {
//         return Customer(
//           cid: data["cid"],
//           cname: data["cname"],
//           cpassword: "", // 서버에선 전달되지 않음
//           cphone: data["cphone"],
//           cemail: data["cemail"],
//           caddress: data["caddress"],
//           ccardnum: data["ccardnum"],
//           ccardcvc: int.tryParse(data["ccardcvc"].toString()) ?? 0,
//           ccarddate: data["ccarddate"],
//         );
//       } else {
//         return null;
//       }
//     } catch (e) {
//       return null;
//     }
//   }
// }

// final cartProvider = AsyncNotifierProvider<CartNotifier, List<Map<String, dynamic>>>(
//   () => CartNotifier(),
// );

