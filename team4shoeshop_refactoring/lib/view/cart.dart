import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team4shoeshop_refactoring/view/edit_profile_page.dart';
import 'package:team4shoeshop_refactoring/vm/1_provider.dart';
import 'buy.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final box = GetStorage();
  Set<int> selectedOids = {};

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final cid = box.read('p_userId');
    ref.read(cartProvider.notifier).fetchCartItems(cid);
  });
}

  void toggleSelection(int oid) {
    setState(() {
      if (selectedOids.contains(oid)) {
        selectedOids.remove(oid);
      } else {
        selectedOids.add(oid);
      }
    });
  }

  Future<void> deleteItem(int oid) async {
    await ref.read(cartProvider.notifier).deleteCartItem(oid);
  }

  Future<void> goToBuy() async {
    if (selectedOids.isEmpty) {
      Get.snackbar("선택 없음", "구매할 항목을 선택해주세요.");
      return;
    }

    final cid = box.read("p_userId");
    final customer = await ref.read(cartProvider.notifier).fetchCustomerInfo(cid);

    if (customer == null ||
        customer.ccardnum.isEmpty ||
        customer.ccardcvc == 0 ||
        customer.ccarddate == 0) {
      Get.snackbar("카드 정보 없음", "회원정보 수정이 필요합니다.");
      await Future.delayed(const Duration(seconds: 1));
      Get.to(() => const EditProfilePage());
      return;
    }

    final items = ref.read(cartProvider).value ?? [];
    final selectedItems = items.where((item) => selectedOids.contains(item["oid"])).toList();

    Get.to(() => const BuyPage(), arguments: {
      "items": selectedItems,
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartItemsAsync = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("장바구니")),
      body: cartItemsAsync.when(
        data: (items) => Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text("장바구니가 비어있습니다."))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = selectedOids.contains(item["oid"]);

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (_) => toggleSelection(item["oid"]),
                            ),
                            title: Text(item["pname"]),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("색상: ${item["pcolor"]}"),
                                Text("사이즈: ${item["psize"]}"),
                                Text("수량: ${item["count"]}"),
                                Text("가격: ${item["pprice"] * item["count"]}원"),
                                Text("대리점: ${item["ename"]}"),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteItem(item["oid"]),
                            ),
                            isThreeLine: true,
                            contentPadding: const EdgeInsets.all(8),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: goToBuy,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("선택한 상품 결제하기"),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("오류 발생: \$err")),
      ),
    );
  }
}