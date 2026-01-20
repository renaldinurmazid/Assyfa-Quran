// To parse this JSON data, do
//
//     final charity = charityFromJson(jsonString);

import 'dart:convert';

Charity charityFromJson(String str) => Charity.fromJson(json.decode(str));

String charityToJson(Charity data) => json.encode(data.toJson());

class Charity {
  String status;
  String message;
  List<Datum> data;

  Charity({required this.status, required this.message, required this.data});

  factory Charity.fromJson(Map<String, dynamic> json) => Charity(
    status: json["status"],
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  String title;
  String coverImage;
  String collectedAmount;
  String? endDate;
  int percentage;

  Datum({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.collectedAmount,
    required this.endDate,
    required this.percentage,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    title: json["title"],
    coverImage: json["cover_image"],
    collectedAmount: json["collected_amount"],
    endDate: json["end_date"],
    percentage: json["percentage"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "cover_image": coverImage,
    "collected_amount": collectedAmount,
    "end_date": endDate,
    "percentage": percentage,
  };
}
