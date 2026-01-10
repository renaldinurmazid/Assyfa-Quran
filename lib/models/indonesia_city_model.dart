// To parse this JSON data, do
//
//     final indonesianCityModel = indonesianCityModelFromJson(jsonString);

import 'dart:convert';

IndonesianCityModel indonesianCityModelFromJson(String str) =>
    IndonesianCityModel.fromJson(json.decode(str));

String indonesianCityModelToJson(IndonesianCityModel data) =>
    json.encode(data.toJson());

class IndonesianCityModel {
  bool status;
  String message;
  List<Datum> data;

  IndonesianCityModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory IndonesianCityModel.fromJson(Map<String, dynamic> json) =>
      IndonesianCityModel(
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
  String id;
  String lokasi;

  Datum({required this.id, required this.lokasi});

  factory Datum.fromJson(Map<String, dynamic> json) =>
      Datum(id: json["id"], lokasi: json["lokasi"]);

  Map<String, dynamic> toJson() => {"id": id, "lokasi": lokasi};
}
