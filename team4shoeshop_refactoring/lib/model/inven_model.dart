class Invenmodel {
  final String pbrand;
  final String pname;
  final int psize;
  final String pcolor;
  final int pstock;

  Invenmodel(
    {
      required this.pbrand,
      required this.pname,
      required this.psize,
      required this.pcolor,
      required this.pstock,
    }
  );

  factory Invenmodel.fromJson(Map<String, dynamic> json){
    return Invenmodel(
      pbrand: json['pbrand'] ?? '_', 
      pname: json['pname'] ?? '_',  
      psize: json['psize'] ?? '', 
      pcolor: json['pcolor'] ?? '', 
      pstock: json['pstock'] ??''
    );
  }
}