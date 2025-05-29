import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team4shoeshop_refactoring/admin/widget/admin_drawer.dart';
import 'package:team4shoeshop_refactoring/vm/1_provider.dart';


class AdminReturn extends ConsumerWidget {
  const AdminReturn({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnAsync = ref.watch(adminProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('반품 내역 확인')),
      drawer: AdminDrawer(),
      body: returnAsync.when(
        data: (dataList) {
          if (dataList.isEmpty) {
            return const Center(child: Text('반품 내역이 없습니다.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: Text('· 반품 접수 및 처리 상태',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('반품일 | 반품번호 | 브랜드 | 제품명 | 반품상태 | 수량'),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    final item = dataList[index];
                    

                    return Card(
                      color: Colors.blue[50],
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          '${item.order.oreturndate} : '
                          '반품번호:${item.order.oid} | ${item.pbrand} | ${item.pname} | '
                          '${item.order.oreturnstatus} | ${item.order.ocount}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        error: (err, _) => Center(child: Text('에러 발생: $err')),
        loading: () => const Center(child: CircularProgressIndicator())
      ),
    );
  }
}