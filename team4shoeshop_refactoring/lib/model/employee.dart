class Employee{
  final String eid;
  final String ename;
  final String epassword;
  final int epermission;
  final Double elatdata;
  final Double elongdata;

  
  Employee({
    required this.eid,
    required this.ename,
    required this.epassword,
    required this.epermission,
    required this.elatdata,
    required this.elongdata

  });
  //서버에서 받은 제이쓴
  factory Employee.fromJson(List<dynamic> json){
    return Employee(
      eid: json[0]??"__", 
      ename: json[1]??"__", 
      epassword:json[2]??"__", 
      epermission:json[3]??"__", 
      elatdata: json[4]??"__");
      elongdata: json[5]??"__");
  }
  Map<String,dynamic>toMap(){
    return{
      'eid' : eid,
      'ename' : ename,
      'epassword' : epassword,
      'epermission' : epermission,
      'elatdata' : elatedata
      'elongdata' : elongdata
    };
  }
  //복사본
  Employee copyWith({
    String? eid,
    String? ename,
    String? epassword,
    int? epermission,
    Double? elatdata,
    Double? elongdata,
  }){
    return Employee(
      eid: eid ?? this.eid, 
      ename: ename ?? this.ename, 
      epassword:epassword ?? this.epassword, 
      epermission:epermission ?? this.epermission, 
      elatdata: elatdata ?? this.elatdata, 
      elongdata:elongdata ?? this.elongdata
    );
  }

}