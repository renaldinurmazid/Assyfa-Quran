// To parse this JSON data, do
//
//     final quranPage = quranPageFromJson(jsonString);

import 'dart:convert';

QuranPage quranPageFromJson(String str) => QuranPage.fromJson(json.decode(str));

String quranPageToJson(QuranPage data) => json.encode(data.toJson());

class QuranPage {
  String? message;
  String? mode;
  List<Datum> data;
  Meta? meta;
  Type? type;

  QuranPage({
    this.message,
    this.mode,
    required this.data,
    this.meta,
    this.type,
  });

  factory QuranPage.fromJson(Map<String, dynamic> json) => QuranPage(
    message: json["message"],
    mode: json["mode"],
    data: json["data"] != null
        ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x)))
        : [],
    meta: json["meta"] != null ? Meta.fromJson(json["meta"]) : null,
    type: json["type"] != null ? Type.fromJson(json["type"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "mode": mode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "meta": meta?.toJson(),
    "type": type?.toJson(),
  };
}

class Datum {
  int id;
  int pageNumber;
  String imagePath;
  List<int> juzNumbers;
  bool isTargetPage;
  List<AyahElement> ayahs;

  Datum({
    required this.id,
    required this.pageNumber,
    required this.imagePath,
    required this.juzNumbers,
    required this.isTargetPage,
    required this.ayahs,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] ?? 0,
    pageNumber: json["page_number"] ?? 0,
    imagePath: json["image_path"] ?? "",
    juzNumbers: json["juz_numbers"] != null
        ? List<int>.from(json["juz_numbers"].map((x) => x))
        : [],
    isTargetPage: json["is_target_page"] ?? false,
    ayahs: json["ayahs"] != null
        ? List<AyahElement>.from(
            json["ayahs"].map((x) => AyahElement.fromJson(x)),
          )
        : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "page_number": pageNumber,
    "image_path": imagePath,
    "juz_numbers": List<dynamic>.from(juzNumbers.map((x) => x)),
    "is_target_page": isTargetPage,
    "ayahs": List<dynamic>.from(ayahs.map((x) => x.toJson())),
  };
}

class AyahElement {
  int id;
  int ayahId;
  int quranPageId;
  DateTime? createdAt;
  DateTime? updatedAt;
  AyahAyah? ayah;
  List<Block> blocks;

  AyahElement({
    required this.id,
    required this.ayahId,
    required this.quranPageId,
    this.createdAt,
    this.updatedAt,
    this.ayah,
    required this.blocks,
  });

  factory AyahElement.fromJson(Map<String, dynamic> json) => AyahElement(
    id: json["id"] ?? 0,
    ayahId: json["ayah_id"] ?? 0,
    quranPageId: json["quran_page_id"] ?? 0,
    createdAt: json["created_at"] != null
        ? DateTime.parse(json["created_at"])
        : null,
    updatedAt: json["updated_at"] != null
        ? DateTime.parse(json["updated_at"])
        : null,
    ayah: json["ayah"] != null ? AyahAyah.fromJson(json["ayah"]) : null,
    blocks: json["blocks"] != null
        ? List<Block>.from(json["blocks"].map((x) => Block.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ayah_id": ayahId,
    "quran_page_id": quranPageId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "ayah": ayah?.toJson(),
    "blocks": List<dynamic>.from(blocks.map((x) => x.toJson())),
  };
}

class AyahAyah {
  int id;
  int surahId;
  int ayahNumber;
  int juzNumber;
  DateTime? createdAt;
  DateTime? updatedAt;
  Surah? surah;
  List<Audio> audio;

  AyahAyah({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    required this.juzNumber,
    this.createdAt,
    this.updatedAt,
    this.surah,
    required this.audio,
  });

  factory AyahAyah.fromJson(Map<String, dynamic> json) => AyahAyah(
    id: json["id"] ?? 0,
    surahId: json["surah_id"] ?? 0,
    ayahNumber: json["ayah_number"] ?? 0,
    juzNumber: json["juz_number"] ?? 0,
    createdAt: json["created_at"] != null
        ? DateTime.parse(json["created_at"])
        : null,
    updatedAt: json["updated_at"] != null
        ? DateTime.parse(json["updated_at"])
        : null,
    surah: json["surah"] != null ? Surah.fromJson(json["surah"]) : null,
    audio: json["audio"] != null
        ? List<Audio>.from(json["audio"].map((x) => Audio.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "surah_id": surahId,
    "ayah_number": ayahNumber,
    "juz_number": juzNumber,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "surah": surah?.toJson(),
    "audio": List<dynamic>.from(audio.map((x) => x.toJson())),
  };
}

class Audio {
  int id;
  int ayahId;
  int reciterId;
  String audioPath;
  DateTime? createdAt;
  DateTime? updatedAt;
  Reciter? reciter;

  Audio({
    required this.id,
    required this.ayahId,
    required this.reciterId,
    required this.audioPath,
    this.createdAt,
    this.updatedAt,
    this.reciter,
  });

  factory Audio.fromJson(Map<String, dynamic> json) => Audio(
    id: json["id"] ?? 0,
    ayahId: json["ayah_id"] ?? 0,
    reciterId: json["reciter_id"] ?? 0,
    audioPath: json["audio_path"] ?? "",
    createdAt: json["created_at"] != null
        ? DateTime.parse(json["created_at"])
        : null,
    updatedAt: json["updated_at"] != null
        ? DateTime.parse(json["updated_at"])
        : null,
    reciter: json["reciter"] != null ? Reciter.fromJson(json["reciter"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ayah_id": ayahId,
    "reciter_id": reciterId,
    "audio_path": audioPath,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "reciter": reciter?.toJson(),
  };
}

class Reciter {
  int id;
  String name;
  String code;

  Reciter({required this.id, required this.name, required this.code});

  factory Reciter.fromJson(Map<String, dynamic> json) => Reciter(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    code: json["code"] ?? "",
  );

  Map<String, dynamic> toJson() => {"id": id, "name": name, "code": code};
}

class Surah {
  int id;
  String name;
  int totalAyah;

  Surah({required this.id, required this.name, required this.totalAyah});

  factory Surah.fromJson(Map<String, dynamic> json) => Surah(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    totalAyah: json["total_ayah"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "total_ayah": totalAyah,
  };
}

class Block {
  int id;
  int ayahPageMapId;
  int blockNumber;
  int top;
  int left;
  int width;
  int height;
  DateTime? createdAt;
  DateTime? updatedAt;

  Block({
    required this.id,
    required this.ayahPageMapId,
    required this.blockNumber,
    required this.top,
    required this.left,
    required this.width,
    required this.height,
    this.createdAt,
    this.updatedAt,
  });

  factory Block.fromJson(Map<String, dynamic> json) => Block(
    id: json["id"] ?? 0,
    ayahPageMapId: json["ayah_page_map_id"] ?? 0,
    blockNumber: json["block_number"] ?? 0,
    top: json["top"] ?? 0,
    left: json["left"] ?? 0,
    width: json["width"] ?? 0,
    height: json["height"] ?? 0,
    createdAt: json["created_at"] != null
        ? DateTime.parse(json["created_at"])
        : null,
    updatedAt: json["updated_at"] != null
        ? DateTime.parse(json["updated_at"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ayah_page_map_id": ayahPageMapId,
    "block_number": blockNumber,
    "top": top,
    "left": left,
    "width": width,
    "height": height,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Meta {
  Range? range;
  Navigation? navigation;

  Meta({this.range, this.navigation});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    range: json["range"] != null ? Range.fromJson(json["range"]) : null,
    navigation: json["navigation"] != null
        ? Navigation.fromJson(json["navigation"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "range": range?.toJson(),
    "navigation": navigation?.toJson(),
  };
}

class Navigation {
  dynamic prevPageNumber;
  dynamic nextPageNumber;

  Navigation({this.prevPageNumber, this.nextPageNumber});

  factory Navigation.fromJson(Map<String, dynamic> json) => Navigation(
    prevPageNumber: json["prev_page_number"],
    nextPageNumber: json["next_page_number"],
  );

  Map<String, dynamic> toJson() => {
    "prev_page_number": prevPageNumber,
    "next_page_number": nextPageNumber,
  };
}

class Range {
  int startPage;
  int endPage;
  int perPage;

  Range({
    required this.startPage,
    required this.endPage,
    required this.perPage,
  });

  factory Range.fromJson(Map<String, dynamic> json) => Range(
    startPage: json["start_page"] ?? 0,
    endPage: json["end_page"] ?? 0,
    perPage: json["per_page"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "start_page": startPage,
    "end_page": endPage,
    "per_page": perPage,
  };
}

class Type {
  int id;
  String name;
  String slug;
  int viewportWidth;
  int viewportHeight;

  Type({
    required this.id,
    required this.name,
    required this.slug,
    required this.viewportWidth,
    required this.viewportHeight,
  });

  factory Type.fromJson(Map<String, dynamic> json) => Type(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    slug: json["slug"] ?? "",
    viewportWidth: json["viewport_width"] ?? 0,
    viewportHeight: json["viewport_height"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "viewport_width": viewportWidth,
    "viewport_height": viewportHeight,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
