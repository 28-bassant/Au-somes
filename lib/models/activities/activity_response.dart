import 'activity_element.dart';
class ActivityResponse {
  ActivityResponse({
    this.phaseId,
    this.name,
    this.audioUrl,
    this.deceptionInstructions,
    this.elements,
  });

  ActivityResponse.fromJson(dynamic json) {
    phaseId = json['phaseId'] ?? '';
    name = json['name'] ?? '';
    audioUrl = json['audioUrl'] ?? '';

    if (json['deceptionInstructions'] != null &&
        json['deceptionInstructions'] is List) {
      deceptionInstructions =
      List<String>.from(json['deceptionInstructions']);
    } else {
      deceptionInstructions = [];
    }

    if (json['elements'] != null && json['elements'] is List) {
      elements = (json['elements'] as List)
          .map((e) => ActivityElement.fromJson(e))
          .toList();
    } else {
      elements = [];
    }
  }

  String? phaseId;
  String? name;
  String? audioUrl;
  List<String>? deceptionInstructions;
  List<ActivityElement>? elements;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['phaseId'] = phaseId;
    map['name'] = name;
    map['audioUrl'] = audioUrl;

    if (deceptionInstructions != null) {
      map['deceptionInstructions'] = deceptionInstructions;
    }

    if (elements != null) {
      map['elements'] = elements?.map((v) => v.toJson()).toList();
    }

    return map;
  }
}

