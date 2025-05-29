import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team4shoeshop_refactoring/dealer/dealer_widget/dealer_widget.dart';
import 'package:team4shoeshop_refactoring/vm/3_provider.dart';

class DealerMain extends ConsumerWidget {
  const DealerMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealerlistProvider = ref.watch(delaerMainProvider);
    final String dal =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";
    final box = GetStorage();
    final dadminname = box.read('ename') ?? '_';

    return Scaffold(
      appBar: AppBar(title: Text("[$dadminname] $dal 매출 현황")),
      drawer: DealerDrawer(),
      body: dealerlistProvider.when(
        data: (item) {
          int totalsales = 0;
          for (var item in item) {
            final price = item.pprice;
            final count = item.ocount;
            totalsales += price * count;
          }

          Map<String, List<Map<String, dynamic>>> tempMap = {};

          for (var item in item) {
            String date = (item.odate).toString().substring(0, 10);
            String name = item.pname;
            int count = item.ocount;
            int price = item.pprice;
            int total = price * count;

            tempMap.putIfAbsent(date, () => []);
            tempMap[date]!.add({'name': name, 'count': count, 'total': total});
          }

          List<Map<String, dynamic>> groupedData =
              tempMap.entries
                  .map((e) => {'date': e.key, 'products': e.value})
                  .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "이번 달 총 매출: ${totalsales ~/ 10000} 만원",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    item.isEmpty
                        ? const Center(child: Text('이번 달 매출이 없습니다.'))
                        : ListView.builder(
                          itemCount: groupedData.length,
                          itemBuilder: (context, index) {
                            final day = groupedData[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today),
                                        const SizedBox(width: 8),
                                        Text(
                                          day['date']?.toString() ?? '',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ...List<Widget>.from(
                                      day['products'].map((product) {
                                        final name = product['name'] ?? '';
                                        final count = product['count'] ?? 0;
                                        final total = product['total'] ?? 0;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("$name ($count개)"),
                                              Text(
                                                "${(total / 10000).toStringAsFixed(1)} 만원",
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          );
        },
        error: (error, _) => Center(child: Text('에러 : $error')),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
