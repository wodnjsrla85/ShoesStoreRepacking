import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:team4shoeshop_refactoring/dealer/dealer_return_datail.dart';
import 'package:team4shoeshop_refactoring/dealer/dealer_widget/dealer_widget.dart';
import 'package:team4shoeshop_refactoring/vm/1_provider.dart';

class DealerReturn extends ConsumerWidget {
  const DealerReturn({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnAsync = ref.watch(dealerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("반품 요청 관리")),
      drawer: DealerDrawer(),
      body: returnAsync.when(
        data:
            (orders) =>
                orders.isEmpty
                    ? const Center(child: Text("주문 내역이 없습니다."))
                    : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final item = orders[index];
                        final price = item.pprice;
                        final count = item.order.ocount;
                        final total = price * count;

                        return Card(
                          margin: const EdgeInsets.all(10),
                          color:
                              item.order.oreturndate.isNotEmpty
                                  ? Colors.red[300]
                                  : null,
                          child: ListTile(
                            title: Text(
                              "상품: ${item.pname} / ${item.order.ocount}개",
                            ),
                            subtitle: Text("주문일: ${item.order.odate}"),
                            trailing: Text("₩$total"),
                            onTap: () async {
                              final result = await Get.to(
                                () => DealerReturnDetail(
                                  orderMap: {
                                    ...item.order.toMap(),
                                    'pprice': item.pprice,
                                    'pname': item.pname,
                                    'pbrand': item.pbrand,
                                  },
                                ),
                              );
                              if (result == true) {
                                ref.invalidate(dealerProvider); // 상태 갱신
                              }
                            },
                          ),
                        );
                      },
                    ),
        error: (err, _) => Center(child: Text("에러 발생: $err")),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
