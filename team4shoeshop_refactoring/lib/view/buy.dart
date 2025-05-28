import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:team4shoeshop_refactoring/view/shoeslistpage.dart';
import 'package:team4shoeshop_refactoring/vm/3_provider.dart';

class BuyPage extends ConsumerWidget {
  BuyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController passwordController = TextEditingController();
    final isProcessing = ref.watch(buyProvider);
    final buyNotifier = ref.read(buyProvider.notifier);
    final arguments = Get.arguments ?? {};
    final isSingleBuy = arguments["product"] != null;
    final items = arguments["items"] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("결제하기")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isSingleBuy)
              _buildSingleBuySummary(arguments)
            else
              _buildMultipleBuySummary(items),
            const SizedBox(height: 16),
            passwordField(passwordController),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: ()async{
                isProcessing 
                ? null 
                : await buyNotifier.submitPurchase(passwordController.text,arguments);
                isProcessing == false
                ? Get.to(()=>Shoeslistpage()) 
                : null;
              }, 
              child: const Text("결제하기"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleBuySummary(Map args) {
    final product = args["product"];
    final quantity = args["quantity"];
    final price = product["pprice"] * quantity;
    final selectedSize = args["selectedSize"];
    final ename = args["storeName"] ?? "알 수 없음";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("상품 정보", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text("- 상품명: ${product["pname"]}"),
        Text("- 색상: ${product["pcolor"]}"),
        Text("- 사이즈: $selectedSize"),
        Text("- 수량: $quantity"),
        Text("- 대리점: $ename"),
        Text("- 가격: $price원"),
      ],
    );
  }

  Widget _buildMultipleBuySummary(List items) {
    num total = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("선택한 상품 목록", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...items.map((item) {
          final price = item["pprice"] * item["count"];
          total += price;
          return Text(
            "- ${item["pname"]} (${item["count"]}개) / 대리점: ${item["ename"]} / ${price}원",
          );
        }).toList(),
        const SizedBox(height: 10),
        Text("총 결제 금액: ${total}원",
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget passwordField(TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      maxLength: 2,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "카드 비밀번호 앞 2자리",
      ),
    );
  }
}