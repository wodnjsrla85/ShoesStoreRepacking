class Dealerlistmodel {
    // "oid": 10,
    //   "ocid": "yubee",
    //   "opid": "airmax260white",
    //   "oeid": "d010",
    //   "ocount": 1,
    //   "odate": "2025-05-19",
    //   "ostatus": "결제완료",
    //   "oreturncount": null,
    //   "oreturndate": null,
    //   "oreturnstatus": null,
    //   "oreason": null,
    //   "pprice": 129000,
    //   "pbrand": "나이키",
    //   "pname": "에어맥스",
    //   "odefectivereason": null
    final int oid;
    final String ocid;
    final String opid;
    final String oeid;
    final int ocount;
    final String odate;
    final String ostatus;
    final String oreturncount;
    final String oreturndate;
    final String oreturnstatus;
    final String oreason;
    final int pprice;
    final String pbrand;
    final String pname;
    final String odefectiverason;

    Dealerlistmodel(
      {
        required this.oid,
        required this.ocid,
        required this.opid,
        required this.oeid,
        required this.ocount,
        required this.odate,
        required this.ostatus,
        required this.oreturncount,
        required this.oreturndate,
        required this.oreturnstatus,
        required this.oreason,
        required this.pprice,
        required this.pbrand,
        required this.pname,
        required this.odefectiverason,
      }
    );

    factory Dealerlistmodel.fromJson(Map<String, dynamic> json){
    return Dealerlistmodel(
      oid: json['oid'] ?? '', 
      ocid: json['ocid'] ?? '', 
      opid: json['opid'] ?? '', 
      oeid: json['oeid'] ?? '', 
      ocount: json['ocount'] ?? '', 
      odate: json['odate'] ?? '', 
      ostatus: json['ostatus'] ?? '', 
      oreturncount: json['oreturncount'] ?? '', 
      oreturndate: json['oreturndate'] ?? '', 
      oreturnstatus: json['oreturnstatus'] ?? '', 
      oreason: json['oreason'] ?? '',  
      pprice: json['pprice'] ?? '', 
      pbrand: json['pbrand'] ?? '', 
      pname: json['pname'] ?? '', 
      odefectiverason: json['odefectiverason'] ?? ''
    );
  }
}