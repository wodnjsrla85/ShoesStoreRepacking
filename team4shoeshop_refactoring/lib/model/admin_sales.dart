class AdminSales {
  final String ename;
  final int yesterday;
  final int today;

  AdminSales(
    {
      required this.ename,
      required this.yesterday,
      required this.today
    }
  );

  factory AdminSales.fromJson(Map<String, dynamic> json){
    return AdminSales(
      ename: json['ename'] ?? '', 
      yesterday: json['yesterday'] ?? '', 
      today: json['today'] ?? ''
    );
  }
}