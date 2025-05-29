import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:team4shoeshop_refactoring/model/daily_revenue.dart';
import 'package:team4shoeshop_refactoring/vm/1_provider.dart';

class AdminDailyRevenue extends ConsumerWidget {
  const AdminDailyRevenue({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueAsync = ref.watch(dailyRevenueProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('일자별 매출 현황')),
      body: revenueAsync.when(
        data: (data) => Column(
          children: [
            const Text('• 모든 일자별 매출 현황', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(title: AxisTitle(text: '단위: 만원')),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  ColumnSeries<DailyRevenue, String>(
                    dataSource: data,
                    xValueMapper: (DailyRevenue item, _) => item.date,
                    yValueMapper: (DailyRevenue item, _) => item.amount,
                    color: Colors.orange,
                    name: '매출',
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('에러 발생: $err')),
      ),
    );
  }
}