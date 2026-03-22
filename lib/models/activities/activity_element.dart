class ActivityElement {
  ActivityElement({
    this.id,
    this.imageUrl,
    this.x,
    this.y,
    this.role,
    this.isCorrect,
    this.targetedZoneId,
  });

  ActivityElement.fromJson(dynamic json) {
    id = json['id'];
    imageUrl = json['imageUrl'];
    x = json['x'];
    y = json['y'];
    role = json['role'];
    isCorrect = json['isCorrect'];
    targetedZoneId = json['targetedZoneId'];
  }

  String? id;
  String? imageUrl;
  int? x;
  int? y;
  String? role;
  bool? isCorrect;
  dynamic targetedZoneId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['imageUrl'] = imageUrl;
    map['x'] = x;
    map['y'] = y;
    map['role'] = role;
    map['isCorrect'] = isCorrect;
    map['targetedZoneId'] = targetedZoneId;
    return map;
  }
}
