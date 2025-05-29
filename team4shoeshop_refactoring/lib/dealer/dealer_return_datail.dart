import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:team4shoeshop_refactoring/vm/3_provider.dart';

class DealerReturnDetail extends ConsumerWidget {
  final Map<String, dynamic> orderMap;
  const DealerReturnDetail({super.key, required this.orderMap,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnCountController = TextEditingController(
        text: orderMap['oreturncount']?.toString() ?? '');
    final reasonController =
        TextEditingController(text: orderMap['oreason'] ?? '');
    final statusController =
        TextEditingController(text: orderMap['oreturnstatus'] ?? '');
    final defectiveReasonController = TextEditingController(
        text: orderMap['odefectivereason'] ?? '');
    final order = orderMap;

    return Scaffold(
      appBar: AppBar(
        title: const Text('반품 정보 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('상품명: ${order['pname']}'),
          Text('주문일: ${order['odate']}'),
            Text('주문수량: ${order['ocount']}개'),
            Text('원인 규명: ${order['odefectivereason'] ?? ''}'),
            const SizedBox(height: 20),
            TextField(
              controller: returnCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '반품 수량'),
            ),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: '반품 사유'),
            ),
            TextField(
              controller: statusController,
              decoration: const InputDecoration(labelText: '반품 상태'),
            ),
            TextField(
              controller: defectiveReasonController,
              decoration: const InputDecoration(labelText: '원인 규명'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
                Get.back();
              },

            child: Text("취소"),style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,),),
            ElevatedButton(
              onPressed: (){ref.read(dealerReturnProvider.notifier).updateReturnInfo(returnCountController.text, reasonController.text, statusController.text, defectiveReasonController.text, context);},
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
