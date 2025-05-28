class Orders {
  final int? oid;
  final String ocid;
  final String opid;
  final String oeid;
  final int ocount;
  final String odate;
  final String ostatus;
  final int ocarbool;
  final int oreturncount;
  final String oreturndate;
  final String oreturnstatus;
  final String odefectivereason;
  final String oreason;

  Orders(
    {
      required this.oid,
      required this.ocid,
      required this.opid,
      required this.oeid,
      required this.ocount,
      required this.odate,
      required this.ostatus,
      required this.ocarbool,
      required this.oreturncount,
      required this.oreturndate,
      required this.oreturnstatus,
      required this.odefectivereason,
      required this.oreason
    }
  );

  factory Orders.fromJson(List<dynamic> json){
    return Orders(
      oid: json[0], 
      ocid: json[1] ?? "", 
      opid: json[3] ?? "", 
      oeid: json[4] ?? "", 
      ocount: json[5] ?? 0, 
      odate: json[6] ?? "", 
      ostatus: json[7] ?? "", 
      ocarbool: json[8] ?? 0, 
      oreturncount: json[9] ?? 0, 
      oreturndate: json[10] ?? "", 
      oreturnstatus: json[11] ?? "", 
      odefectivereason: json[12] ?? "", 
      oreason: json[13] ?? ""
      );
  }

  Map<String, dynamic>toMap(){
    return{
      'oid' : oid,
      'ocid' : ocid,
      'opid' : opid,
      'oeid' : oeid,
      'ocount' : ocount,
      'odate' : odate,
      'ostatus' : ostatus,
      'ocarbool' : ocarbool,
      'oreturncount' : oreturncount,
      'oreturndate' : oreturndate,
      'oreturnstatus' : oreturnstatus,
      'odefectivereason' : odefectivereason,
      'oreason' : oreason
    };
  }
  Orders copyWith({
      int? oid,
      String? ocid,
      String? opid,
      String? oeid,
      int? ocount,
      String? odate,
      String? ostatus,
      int? ocarbool,
      int? oreturncount,
      String? oreturndate,
      String? oreturnstatus,
      String? odefectivereason,
      String? oreason
    }){
    return Orders(
      oid:oid ?? this.oid,
      ocid:ocid ?? this.ocid,
      opid:opid ?? this.opid,
      oeid:oeid ?? this.oeid,
      ocount:ocount ?? this.ocount,
      odate:odate ?? this.odate,
      ostatus:ostatus ?? this.ostatus,
      ocarbool:ocarbool ?? this.ocarbool,
      oreturncount:oreturncount ?? this.oreturncount,
      oreturndate:oreturndate ?? this.oreturndate,
      oreturnstatus:oreturnstatus ?? this.oreturnstatus,
      odefectivereason:odefectivereason ?? this.odefectivereason,
      oreason:oreason ?? this.oreason
    );
  }


}
