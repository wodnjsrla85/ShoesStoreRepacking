class Factory {
  final String fid;
  final String fbrand;
  final String fphone;

  Factory(
    {
      required this.fid,
      required this.fbrand,
      required this.fphone,
    }
  );

  // 서버에서 받은  JSON -> Student 객체
  factory Factory.fromJson(List<dynamic> json){
    return Factory(
      fid: json[0] ?? "",
      fbrand: json[1] ?? "",
      fphone: json[2] ?? "",
    );
  }

  // Student -> Map
  Map<String, dynamic> toMap(){
    return {
      'fid' : fid,
      'fbrand' : fbrand,
      'fphone' : fphone,
    };
  }

  // 퍼포먼스를 위해 사용하는 방법 *원래는 하나만 수정해도 다 날라가서 바뀌는데 하나만 바꾸는 방식으로 개선
  // 복사본 생성시 특정 필드만 변경
  Factory copyWith(
    {
      String? fid,
      String? fbrand,
      String? fphone
    }
  ){
    return Factory(
      fid: fid ?? this.fid, 
      fbrand: fbrand ?? this.fbrand, 
      fphone: fphone ?? this.fphone,
    );
  }
}