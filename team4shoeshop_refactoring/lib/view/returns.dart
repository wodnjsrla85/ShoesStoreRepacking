import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team4shoeshop_refactoring/vm/3_provider.dart';


class Returns extends ConsumerWidget {
  const Returns({super.key});

  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnNotifier = ref.watch(retunrProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text("반품 내역")),
      body: returnNotifier.when(
        data: (returns) {
          return ListView.builder(
              itemCount: returns.length,
              itemBuilder: (context, index) {
                final item = returns[index];
                final total = item.pprice * item.count;
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("${item.pname} (${item.count}개)"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("색상: ${item.pcolor} / 사이즈: ${item.psize}"),
                        Text("반품상태: ${item.returnStatus}"),
                        Text("주문일: ${item.date}"),
                        Text("환불금액: $total원"),
                      ],
                    ),
                  ),
                );
              },
            );
        }, 
        error: (error,_) => Center(child: Text('Error : $error'),), 
        loading: () => Center(child: CircularProgressIndicator(),),
      ),
      
      
      
          
    );
  }
}