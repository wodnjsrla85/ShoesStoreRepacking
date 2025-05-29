
//대리점 별 매출 

/* 개발자 : 김수아
 * 목적 :  
 *  대히점 마다 매출을 확인할 수 있는 시각적인 자료를 만들고 싶었다.
 * 개발일지 :
 *  20250529
 *  satefullwidget 이였던 파일을 consumerwidget으로 변경하고
 *  riverpod을 이용하여  MVVM 형태의 개발을 만들었다. 
 *  
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:team4shoeshop_refactoring/vm/2_provider.dart';

class AdminDealerRevenue extends ConsumerWidget {
  AdminDealerRevenue({super.key});

  //선택된 년
  final String selectedYear = DateTime.now().year.toString();
  //선택된 월 
  final String selectedMonth = DateTime.now().month.toString().padLeft(2, '0');
  //선택이 가능한 년도 리스트 설정 추가 될 수록 더 넣을 수 있댜.
  final List<String> years = ['2024', '2025'];
  final List<String> months = List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));




  @override
  Widget build(BuildContext context, WidgetRef ref) {
     List<DealerRevenue> chartData =ref.watch(adminDealerRevenueProvider);
     //시작하면 오늘의 날짜로 그래프가 자동적으로 그려지게 만들었다. 
     ref.read(adminDealerRevenueProvider.notifier).fetchChartData();
    return Scaffold(
      appBar: AppBar(
        title: const Text('매장별 매출 현황'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('• 선택한 월의 매장별 매출 (단위: 만원)', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: selectedYear,
                  items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y년'))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      // 먼저 밖에 있는 handler에 선언 되어 있는 변수 년도에 값을 업데이트 
                      ref.read(adminDealerRevenueProvider.notifier).selectedYear =val;
                      //업데이트 된 값을 기반으로 디비를 겁색하여 새로운 값을 받아 온다. 
                      ref.read(adminDealerRevenueProvider.notifier).fetchChartData1();
                    }
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedMonth,
                  items: months.map((m) => DropdownMenuItem(value: m, child: Text('$m월'))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      //먼저 밖에 있는 handeler에 들어 있는 월의 값을 업데이트 
                     ref.read(adminDealerRevenueProvider.notifier).selectedMonth =val;
                     //업데이트 된 값을 기준으로 다시 검색하여 디비에서 값을 넣어 부르기 
                      ref.read(adminDealerRevenueProvider.notifier).fetchChartData1();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: '매장명'),
                  labelStyle: const TextStyle(fontSize: 12),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: '매출 (만원)'),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  ColumnSeries<DealerRevenue, String>(
                    dataSource: chartData,
                    xValueMapper: (DealerRevenue data, _) => data.name,
                    yValueMapper: (DealerRevenue data, _) => data.amount.toDouble(),
                    color: Colors.deepOrange,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DealerRevenue {
  final String name;
  final int amount;

  DealerRevenue({required this.name, required this.amount});
}