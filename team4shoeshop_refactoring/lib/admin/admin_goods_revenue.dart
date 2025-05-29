// 물건별 판매량 


/* 개발자 : 김수아
 * 목적 :  
 *  제품 마다 매출을 확인할 수 있는 시각적인 자료를 만들고 싶었다.
 *  이러한 시각자료는 즉각적으로 확인 할 수 있는 만큼 잘나가는 제품 위주로 어떻게 마케팅을 할 수 있을 지에 대하여 더 빠르게 다가갈 수 있다. 
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


class AdminGoodsRevenue extends ConsumerWidget {
  AdminGoodsRevenue({super.key});
  
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    //만약 변경되는 값이 있다면 실시간으로 반영하기 위해 값에 watch를 주었다. 
    final List<GoodsRevenue> chartData = ref.watch(adminGoodsRevenueProvider);
    // 한번 실핼 할 때 디비에 연결하여 조건에 맞는 값을 검색하고 그 값을 받아 도표에 넣어 준다. 
    //read는 계속 진행이 되기 때문에 내부에서 한 번만 진행 하도록 만들었다.
    ref.read(adminGoodsRevenueProvider.notifier).fetchChartData();
    return Scaffold(
      appBar: AppBar(
        title: const Text('상품별 매출 현황'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('• 모든 상품별 매출 현황', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: -20,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: '단위: 만원'),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  LineSeries<GoodsRevenue, String>(
                    dataSource: chartData,
                    xValueMapper: (GoodsRevenue data, _) => data.name,
                    yValueMapper: (GoodsRevenue data, _) => data.amount,
                    markerSettings: const MarkerSettings(isVisible: true),
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    color: Colors.purple,
                    name: '매출',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoodsRevenue {
  final String name;
  final int amount;

  GoodsRevenue({required this.name, required this.amount});
}