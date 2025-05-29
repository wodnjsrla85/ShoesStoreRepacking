// 전종익 날짜별 매출그래프를 그리기 위해 추가했습니다.

class DailyRevenue {
  final String date;
  final int amount;

  DailyRevenue({required this.date, required this.amount});

  factory DailyRevenue.fromJson(Map<String, dynamic> json) {
    return DailyRevenue(
      date: json['date'] ?? '',
      amount: (json['total'] ?? 0) ~/ 10000,
    );
  }
}