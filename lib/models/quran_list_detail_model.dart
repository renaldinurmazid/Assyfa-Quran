// To parse this JSON data, do
//
//     final quranListDetailModel = quranListDetailModelFromJson(jsonString);

import 'dart:convert';

QuranListDetailModel quranListDetailModelFromJson(String str) =>
    QuranListDetailModel.fromJson(json.decode(str));

String quranListDetailModelToJson(QuranListDetailModel data) =>
    json.encode(data.toJson());

class QuranListDetailModel {
  int code;
  String message;
  Data data;

  QuranListDetailModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory QuranListDetailModel.fromJson(Map<String, dynamic> json) =>
      QuranListDetailModel(
        code: json["code"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  int nomor;
  String nama;
  String namaLatin;
  int jumlahAyat;
  String tempatTurun;
  String arti;
  Map<String, String> audioFull;
  List<Ayat> ayat;

  Data({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.audioFull,
    required this.ayat,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    nomor: json["nomor"],
    nama: json["nama"],
    namaLatin: json["namaLatin"],
    jumlahAyat: json["jumlahAyat"],
    tempatTurun: json["tempatTurun"],
    arti: json["arti"],
    audioFull: Map.from(
      json["audioFull"],
    ).map((k, v) => MapEntry<String, String>(k, v)),
    ayat: List<Ayat>.from(json["ayat"].map((x) => Ayat.fromJson(x))),
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
    "ayat": List<dynamic>.from(ayat.map((x) => x.toJson())),
  };
}

class Ayat {
  int nomorAyat;
  String teksArab;
  String teksLatin;
  String teksIndonesia;
  Map<String, String> audio;

  Ayat({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    required this.audio,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) => Ayat(
    nomorAyat: json["nomorAyat"],
    teksArab: json["teksArab"],
    teksLatin: json["teksLatin"],
    teksIndonesia: json["teksIndonesia"],
    audio: Map.from(
      json["audio"],
    ).map((k, v) => MapEntry<String, String>(k, v)),
  );

  Map<String, dynamic> toJson() => {
    "nomorAyat": nomorAyat,
    "teksArab": teksArab,
    "teksLatin": teksLatin,
    "teksIndonesia": teksIndonesia,
    "audio": Map.from(audio).map((k, v) => MapEntry<String, dynamic>(k, v)),
  };
}
