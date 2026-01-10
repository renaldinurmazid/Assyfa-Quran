// To parse this JSON data, do
//
//     final dropdownJuz = dropdownJuzFromJson(jsonString);

import 'dart:convert';

List<DropdownJuz> dropdownJuzFromJson(String str) => List<DropdownJuz>.from(
  json.decode(str).map((x) => DropdownJuz.fromJson(x)),
);

String dropdownJuzToJson(List<DropdownJuz> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DropdownJuz {
  int juzNomor;
  List<Surah> surah;

  DropdownJuz({required this.juzNomor, required this.surah});

  factory DropdownJuz.fromJson(Map<String, dynamic> json) => DropdownJuz(
    juzNomor: json["juz_nomor"],
    surah: List<Surah>.from(json["surah"].map((x) => Surah.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "juz_nomor": juzNomor,
    "surah": List<dynamic>.from(surah.map((x) => x.toJson())),
  };
}

class Surah {
  int id;
  String name;
  String translationName;
  String cityName;
  int totalAyah;

  Surah({
    required this.id,
    required this.name,
    required this.translationName,
    required this.cityName,
    required this.totalAyah,
  });

  factory Surah.fromJson(Map<String, dynamic> json) => Surah(
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
