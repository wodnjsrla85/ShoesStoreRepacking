import 'dart:typed_data';

class Product {
  final int? id;
  final String pid;
  final String pbrand;
  final String pname;
  final int psize;
  final String pcolor;
  final int pstock;
  final int pprice;
  final Uint8List pimage;
  
  Product(
    {
      this.id,
      required this.pid,
      required this.pbrand,
      required this.pname,
      required this.psize,
      required this.pcolor,
      required this.pstock,
      required this.pprice,
      required this.pimage,
    }
    );
  //서버에서 받은 제이쓴
  factory Product.fromJson(List<dynamic> json){
    return Product(
      id: json[0],
      pid: json[1] ?? "__",
      pbrand: json[2] ?? "__",
      pname: json[3] ?? "__",
      psize: json[4] ?? 0,
      pcolor: json[5] ?? "__",
      pstock: json[6] ?? 0,
      pprice: json[7] ?? 0,
      pimage: json[8] ?? '',
    );
  }
  Map<String,dynamic>toMap(){
    return{
      'id': id,
      'pid': pid,
      'pbrand': pbrand,
      'pname': pname,
      'psize': psize,
      'pcolor': pcolor,
      'pstock': pstock,
      'pprice' : pprice,
      'pimage' :pimage,
    };
  }
  //복사본
  Product copyWith({
    int? id,
    String? pid,
    String? pbrand,
    String? pname,
    int? psize,
    String? pcolor,
    int? pstock,
    int? pprice,
    Uint8List? pimage
  }){
    return Product(
      id: id ?? this.id, 
      pid: pid ?? this.pid, 
      pbrand: pbrand ?? this.pbrand, 
      pname: pname ?? this.pname, 
      psize: psize ?? this.psize,
      pcolor: pcolor ?? this.pcolor,
      pstock: pstock ?? this.pstock,
      pprice: pprice ?? this.pprice,
      pimage: pimage ?? this.pimage
    );
  }

}