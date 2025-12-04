class LoginResponse {
  LoginResponse({
      this.id, 
      this.email, 
      this.childName, 
      this.childAge, 
      this.token, 
      this.expiresIn, 
      this.refreshToken, 
      this.refreshTokenExpiration,});

  LoginResponse.fromJson(dynamic json) {
    id = json['id'];
    email = json['email'];
    childName = json['childName'];
    childAge = json['childAge'];
    token = json['token'];
    expiresIn = json['expiresIn'];
    refreshToken = json['refreshToken'];
    refreshTokenExpiration = json['refreshTokenExpiration'];
  }
  String? id;
  String? email;
  String? childName;
  int? childAge;
  String? token;
  int? expiresIn;
  String? refreshToken;
  String? refreshTokenExpiration;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['email'] = email;
    map['childName'] = childName;
    map['childAge'] = childAge;
    map['token'] = token;
    map['expiresIn'] = expiresIn;
    map['refreshToken'] = refreshToken;
    map['refreshTokenExpiration'] = refreshTokenExpiration;
    return map;
  }

}