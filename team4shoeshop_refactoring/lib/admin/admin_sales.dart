import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:team4shoeshop_refactoring/admin/widget/admin_drawer.dart';
import 'package:team4shoeshop_refactoring/vm/3_provider.dart';

class AdminSales extends ConsumerWidget {
  const AdminSales({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminSalesNotifier = ref.read(adminSalesProvider);

    return Scaffold(
      drawer: AdminDrawer(),
      appBar: AppBar(centerTitle: true),
      body: adminSalesNotifier.when(
        data: (salesData) {
          return ListView.builder(
            itemCount: salesData.length,
            itemBuilder: (context, index) {
              final item = salesData[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    item.ename,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text('어제 매출: ${item.yesterday}원'),
                      Text('오늘 매출: ${item.today}원'),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (error, _) => Center(child: Text('에러 발생 : $error')),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
