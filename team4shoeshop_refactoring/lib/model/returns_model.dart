class ReturnsModel{
  final String pid;
  final int count;
  final String returnStatus;
  final String date;
  final String pname;
  final int pprice;
  final String pcolor;
  final int psize;

  ReturnsModel(
    {
      required this.pid,
      required this.count,
      required this.returnStatus,
      required this.date,
      required this.pname,
      required this.pprice,
      required this.pcolor,
      required this.psize,
    }
  );

  factory ReturnsModel.fromJson(Map<String, dynamic> json){
    return ReturnsModel(
      pid: json['pid'] ?? "", 
      count: json['count'] ?? "", 
      returnStatus: json['returnStatus'] ?? "", 
      date: json['date'] ?? "", 
      pname: json['pname'] ?? "", 
      pprice: json['pprice'], 
      pcolor: json['pcolor'] ?? "", 
      psize: json['psize'],
    );
  }

  Map<String,dynamic> toMap(){
    return{
      'pid': pid, 
      'count': count, 
      'return_status': returnStatus, 
      'date': date, 
      'pname': pname, 
      'pprice': pprice, 
      'pcolor': pcolor, 
      'psize': psize,
    };
  }
}