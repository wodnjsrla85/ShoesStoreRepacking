class Customer {
  final int? id;
  final String cid;
  final String cname;
  final String cpassword;
  final String cphone;
  final String cemail;
  final String caddress;
  final String ccardnum;
  final int ccardcvc;
  final int ccarddate; // String을 int로 변경하였습니다.
  
  Customer({
    this.id,
    required this.cid,
    required this.cname,
    required this.cpassword,
    required this.cphone,
    required this.cemail,
    required this.caddress,
    required this.ccardnum,
    required this.ccardcvc,
    required this.ccarddate

  });
  //서버에서 받은 제이쓴
  factory Customer.fromJson(List<dynamic> json){
    return Customer(
      id: json[0]??"__", 
      cid: json[1]??"__", 
      cname:json[2]??"__", 
      cpassword: json[3]??"__",
      cphone:json[4]??"__", 
      cemail: json[5]??"__",
      caddress: json[6]??"__",
      ccardnum: json[7]??"__",
      ccardcvc: json[8]??"__",
      ccarddate: json[9] ??"__",
    );
  }
  Map<String,dynamic>toMap(){ 
    return{
      'id' : id,
      'cid' : cid,
      'cname' :cname,
      'cpassword' :cpassword,
      'cphone' :cphone,
      'cemail' :cemail,
      'caddress' :caddress,
      'ccardnum' :ccardnum,
      'ccardcvc' :ccardcvc,
      'ccarddate' :ccarddate,

    };
  }

  Map<String, String> toRegisterMap() { // 전종익 추가, 회원가입시 카드정보를 넣지 않아 필요한 부분만 넣었습니다.
    return {
      'cid': cid,
      'cname': cname,
      'cpassword': cpassword,
      'cphone': cphone,
      'cemail': cemail,
      'caddress': caddress,
    };
  }

  //복사본
  Customer copyWith({
    int? id,
    String? cid,
    String? cname,
    String? cpassword,
    String? cphone,
    String? cemail,
    String? caddress,
    String? ccardnum,
    int? ccardcvc,
    int? ccarddate // String을 int로 변경하였습니다.
  }){
    return Customer(
      id: id ?? this.id, 
      cid: cid ?? this.cid, 
      cname: cname ?? this.cname, 
      cpassword: cpassword ?? this.cpassword, 
      cphone: cphone ?? this.cphone,
      cemail: cemail ?? this.cemail,
      caddress: caddress ?? this.caddress,
      ccardnum: ccardnum ?? this.ccardnum,
      ccardcvc: ccardcvc ?? this.ccardcvc,
      ccarddate: ccarddate ?? this.ccarddate,
    );
  }

}