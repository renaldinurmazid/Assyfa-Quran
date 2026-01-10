// To parse this JSON data, do
//
//     final dropdownSurah = dropdownSurahFromJson(jsonString);

import 'dart:convert';

List<DropdownSurah> dropdownSurahFromJson(String str) =>
    List<DropdownSurah>.from(
      json.decode(str).map((x) => DropdownSurah.fromJson(x)),
    );

String dropdownSurahToJson(List<DropdownSurah> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DropdownSurah {
  int id;
  String name;
  String translationName;
  String cityName;
  int totalAyah;

  DropdownSurah({
    required this.id,
    required this.name,
    required this.translationName,
    required this.cityName,
    required this.totalAyah,
  });

  factory DropdownSurah.fromJson(Map<String, dynamic> json) => DropdownSurah(
    id: json["id"],
    name: json["name"],
    translationName: json["translation_name"],
    cityName: json["city_name"],
    totalAyah: json["total_ayah"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "translation_name": translationName,
    "city_name": cityName,
    "total_ayah": totalAyah,
  };
}
