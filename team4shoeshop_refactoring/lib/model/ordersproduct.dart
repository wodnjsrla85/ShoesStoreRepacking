class OrdersProduct{
  final int oid;
  final String pid;
  final int count;
  final String odate;
  final String ostatus;
  final String pname;
  final int pprice;
  final String pcolor;
  final int psize;
  final String ename;
  final String image_url;

  OrdersProduct(
    {
      required this.oid,
      required this.pid,
      required this.count,
      required this.odate,
      required this.ostatus,
      required this.pname,
      required this.pprice,
      required this.pcolor,
      required this.psize,
      required this.ename,
      required this.image_url
    }
  );

  factory OrdersProduct.fromJson(List<dynamic> json){
    return OrdersProduct(
      oid: json[0] ?? 0, 
      pid: json[1] ?? "__", 
      count: json[2] ?? 0, 
      odate: json[3] ?? "__", 
      ostatus: json[4] ?? "__", 
      pname: json[5] ?? "__", 
      pprice: json[6] ?? 0, 
      pcolor: json[7] ?? "__", 
      psize: json[8] ?? 0, 
      ename: json[9] ?? "__", 
      image_url: json[10] ?? "__"
      );
  }
  
  OrdersProduct copyWith(
    {
     int? oid,
     String? pid,
     int? count,
     String? odate,
     String? ostatus,
     String? pname,
     int? pprice,
     String? pcolor,
     int? psize,
     String? ename,
     String? image_url
    }
  ){
    return OrdersProduct(
      oid: oid ?? this.oid, 
      pid: pid ?? this.pid, 
      count: count ?? this.count, 
      odate: odate ?? this.odate, 
      ostatus: ostatus ?? this.ostatus, 
      pname: pname ?? this.pname, 
      pprice: pprice ?? this.pprice, 
      pcolor: pcolor ?? this.pcolor, 
      psize: psize ??  this.psize, 
      ename: ename ?? this.ename, 
      image_url: image_url ?? this.image_url
      );
  }

}