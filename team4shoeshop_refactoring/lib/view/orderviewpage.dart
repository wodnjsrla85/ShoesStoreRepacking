// 도영 : 야호 ~~~~~~~~~^^

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team4shoeshop_refactoring/vm/4_provider.dart';

class OrderViewPage extends ConsumerWidget {
  OrderViewPage({super.key});

  final box = GetStorage();
  iniStorage(){
    int cid = box.read("p_userId");
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersProductState = ref.watch(ordersProductProvider);


    return Scaffold(
      appBar: AppBar(title: const Text("주문 내역")),
      body: ordersProductState.isEmpty
          ? const Center(child: Text("결제 완료된 주문이 없습니다."))
          : ListView.builder(
              itemCount: ordersProductState.length,
              itemBuilder: (context, index) {
                final order = ordersProductState[index];
                final total = order.pprice * order.count;

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.network(
                      "${order.image_url}?t=${DateTime.now().millisecondsSinceEpoch}",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                    title: Text(order.pname),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("색상: ${order.pcolor}"),
                        Text("사이즈: ${order.psize}"),
                        Text("수량: ${order.count}"),
                        Text("가격: $total 원"),
                        Text("대리점: ${order.ename ?? "정보 없음"}"),
                        Text("주문일: ${order.odate}"),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}