
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team4shoeshop_refactoring/admin/widget/admin_drawer.dart';
import 'package:team4shoeshop_refactoring/vm/3_provider.dart';

class AdminInvenPage extends ConsumerWidget {
  const AdminInvenPage({super.key});

  // void _fetchInventory() async {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminInvenModel = ref.watch(adminInvenProvider);

    return Scaffold(
      drawer: AdminDrawer(),
      appBar: AppBar(
        title: Text('관리자 재고 현황'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Get.to(AdminApproval());
            }, 
            icon: Icon(Icons.approval)
            )
        ],
      ),
      body: adminInvenModel.when(
        data: (items) {
          return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isLow = item.pstock < 30;
                return Card(
                  color: isLow ? Colors.redAccent.shade100 : Colors.grey,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      '${item.pbrand} ${item.pname}',
                      style: TextStyle(
                          color: isLow ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '사이즈: ${item.psize}, 색상: ${item.pcolor}\n재고: ${item.pstock}',
                      style: TextStyle(
                          color: isLow ? Colors.white70 : Colors.black87),
                    ),
                  ),
                );
              },
            );
        }, 
        error: (error, _) => Center(child: Text('에러 발생 : $error'),), 
        loading: () => Center(child: CircularProgressIndicator(),),
      ),
    );
  }
}