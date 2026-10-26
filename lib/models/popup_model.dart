import 'dart:convert';

PopupResponse popupResponseFromJson(String str) =>
    PopupResponse.fromJson(json.decode(str));

String popupResponseToJson(PopupResponse data) => json.encode(data.toJson());

class PopupResponse {
  String status;
  String message;
  List<PopupData> data;

  PopupResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PopupResponse.fromJson(Map<String, dynamic> json) => PopupResponse(
    status: json["status"] ?? '',
    message: json["message"] ?? '',
    data: json["data"] != null
        ? List<PopupData>.from(json["data"].map((x) => PopupData.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class PopupData {
  int id;
  String title;
  String? description;
  String? image;
  String? actionUrl;
  String? actionText;
  String type;
  bool isDismissible;
  bool showOnce;

  /// once | daily | every_launch. The server already applies it; the app only displays what it is sent.
  String frequency;
  int priority;
  String? startDate;
  String? endDate;

  PopupData({
    required this.id,
    required this.title,
    this.description,
    this.image,
    this.actionUrl,
    this.actionText,
    required this.type,
    required this.isDismissible,
    required this.showOnce,
    required this.frequency,
    required this.priority,
    this.startDate,
    this.endDate,
  });

  factory PopupData.fromJson(Map<String, dynamic> json) => PopupData(
    id: json["id"],
    title: json["title"] ?? '',
    description: json["description"],
    image: json["image"],
    actionUrl: json["action_url"],
    actionText: json["action_text"],
    type: json["type"] ?? 'info',
    isDismissible: json["is_dismissible"] ?? true,
    showOnce: json["show_once"] ?? false,
    // Servers from before `frequency` only sent show_once.
    frequency:
        json["frequency"] ?? ((json["show_once"] ?? false) ? 'once' : 'daily'),
    priority: json["priority"] ?? 0,
    startDate: json["start_date"],
    endDate: json["end_date"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "image": image,
    "action_url": actionUrl,
    "action_text": actionText,
    "type": type,
    "is_dismissible": isDismissible,
    "show_once": showOnce,
    "frequency": frequency,
    "priority": priority,
    "start_date": startDate,
    "end_date": endDate,
  };
}
