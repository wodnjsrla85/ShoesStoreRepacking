// 도영 : 야호 ~~~~~~~~~^^

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team4shoeshop_refactoring/vm/4_provider.dart';

class OrderViewPage extends ConsumerWidget {
  const OrderViewPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersProductState = ref.watch(ordersProductProvider);


    return Scaffold(
      appBar: AppBar(title: const Text("주문 내역")),
      body: ordersProductState.when(
        data: (data) {
          return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final order = data[index];
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
                        Text("대리점: ${order.ename}"),
                        Text("주문일: ${order.odate}"),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
        }, 
        error: (error, _) => Center(child: Text('에러 : $error'),), 
        loading: () => Center(child: CircularProgressIndicator(),),
      )
      
      
      
  
          
    );
  }
}