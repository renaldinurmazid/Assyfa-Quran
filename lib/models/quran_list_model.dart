// To parse this JSON data, do
//
//     final quranListModel = quranListModelFromJson(jsonString);

import 'dart:convert';

QuranListModel quranListModelFromJson(String str) =>
    QuranListModel.fromJson(json.decode(str));

String quranListModelToJson(QuranListModel data) => json.encode(data.toJson());

class QuranListModel {
  int code;
  String message;
  List<Datum> data;

  QuranListModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory QuranListModel.fromJson(Map<String, dynamic> json) => QuranListModel(
    code: json["code"],
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int nomor;
  String nama;
  String namaLatin;
  int jumlahAyat;
  String tempatTurun;
  String arti;
  Map<String, String> audioFull;

  Datum({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.audioFull,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    nomor: json["nomor"],
    nama: json["nama"],
    namaLatin: json["namaLatin"],
    jumlahAyat: json["jumlahAyat"],
    tempatTurun: json["tempatTurun"],
    arti: json["arti"],
    audioFull: Map.from(
      json["audioFull"],
    ).map((k, v) => MapEntry<String, String>(k, v)),
  );

  Map<String, dynamic> toJson() => {
    "nomor": nomor,
    "nama": nama,
    "namaLatin": namaLatin,
    "jumlahAyat": jumlahAyat,
    "tempatTurun": tempatTurun,
    "arti": arti,
    "audioFull": Map.from(
      audioFull,
    ).map((k, v) => MapEntry<String, dynamic>(k, v)),
  };
}
