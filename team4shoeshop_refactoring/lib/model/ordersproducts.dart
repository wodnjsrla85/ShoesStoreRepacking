class OrdersProducts{
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

  OrdersProducts(
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

  factory OrdersProducts.fromJson(Map<String, dynamic> json){
    return OrdersProducts(
      oid: json['oid'] ?? 0, 
      pid: json['pid'] ?? "__", 
      count: json['count'] ?? 0, 
      odate: json['odate'] ?? "__", 
      ostatus: json['ostatus'] ?? "__", 
      pname: json['pname'] ?? "__", 
      pprice: json['pprice'] ?? 0, 
      pcolor: json['pcolor'] ?? "__", 
      psize: json['psize'] ?? 0, 
      ename: json['ename'] ?? "__", 
      image_url: json['image_url'] ?? "__"
      );
  }
  
  OrdersProducts copyWith(
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
    return OrdersProducts(
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