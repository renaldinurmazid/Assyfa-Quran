// To parse this JSON data, do
//
//     final quranPage = quranPageFromJson(jsonString);

import 'dart:convert';

QuranPage quranPageFromJson(String str) => QuranPage.fromJson(json.decode(str));

String quranPageToJson(QuranPage data) => json.encode(data.toJson());

class QuranPage {
  String message;
  String mode;
  List<Datum> data;
  Meta meta;
  Type type;

  QuranPage({
    required this.message,
    required this.mode,
    required this.data,
    required this.meta,
    required this.type,
  });

  factory QuranPage.fromJson(Map<String, dynamic> json) => QuranPage(
    message: json["message"] ?? "",
    mode: json["mode"] ?? "",
    data: json["data"] == null
        ? []
        : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    meta: json["meta"] == null
        ? Meta(
            range: Range(startPage: 0, endPage: 0, perPage: 0),
            navigation: Navigation(),
          )
        : Meta.fromJson(json["meta"]),
    type: json["type"] == null
        ? Type(id: 0, name: "", slug: "")
        : Type.fromJson(json["type"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "mode": mode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "meta": meta.toJson(),
    "type": type.toJson(),
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
    juzNumbers: json["juz_numbers"] == null
        ? []
        : List<int>.from(json["juz_numbers"].map((x) => x)),
    isTargetPage: json["is_target_page"] ?? false,
    ayahs: json["ayahs"] == null
        ? []
        : List<AyahElement>.from(
            json["ayahs"].map((x) => AyahElement.fromJson(x)),
          ),
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
  DateTime createdAt;
  DateTime updatedAt;
  AyahAyah ayah;
  List<Block> blocks;

  AyahElement({
    required this.id,
    required this.ayahId,
    required this.quranPageId,
    required this.createdAt,
    required this.updatedAt,
    required this.ayah,
    required this.blocks,
  });

  factory AyahElement.fromJson(Map<String, dynamic> json) => AyahElement(
    id: json["id"] ?? 0,
    ayahId: json["ayah_id"] ?? 0,
    quranPageId: json["quran_page_id"] ?? 0,
    createdAt: json["created_at"] == null
        ? DateTime.now()
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? DateTime.now()
        : DateTime.parse(json["updated_at"]),
    ayah: json["ayah"] == null
        ? AyahAyah(
            id: 0,
            surahId: 0,
            ayahNumber: 0,
            juzNumber: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            surah: Surah(id: 0, name: "", totalAyah: 0),
            audio: [],
          )
        : AyahAyah.fromJson(json["ayah"]),
    blocks: json["blocks"] == null
        ? []
        : List<Block>.from(json["blocks"].map((x) => Block.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ayah_id": ayahId,
    "quran_page_id": quranPageId,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "ayah": ayah.toJson(),
    "blocks": List<dynamic>.from(blocks.map((x) => x.toJson())),
  };
}

class AyahAyah {
  int id;
  int surahId;
  int ayahNumber;
  int juzNumber;
  DateTime createdAt;
  DateTime updatedAt;
  Surah surah;
  List<Audio> audio;

  AyahAyah({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    required this.juzNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.surah,
    required this.audio,
  });

  factory AyahAyah.fromJson(Map<String, dynamic> json) => AyahAyah(
    id: json["id"] ?? 0,
    surahId: json["surah_id"] ?? 0,
    ayahNumber: json["ayah_number"] ?? 0,
    juzNumber: json["juz_number"] ?? 0,
    createdAt: json["created_at"] == null
        ? DateTime.now()
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? DateTime.now()
        : DateTime.parse(json["updated_at"]),
    surah: json["surah"] == null
        ? Surah(id: 0, name: "", totalAyah: 0)
        : Surah.fromJson(json["surah"]),
    audio: json["audio"] == null
        ? []
        : List<Audio>.from(json["audio"].map((x) => Audio.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "surah_id": surahId,
    "ayah_number": ayahNumber,
    "juz_number": juzNumber,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "surah": surah.toJson(),
    "audio": List<dynamic>.from(audio.map((x) => x.toJson())),
  };
}

class Audio {
  int id;
  int ayahId;
  int reciterId;
  String audioPath;
  DateTime createdAt;
  DateTime updatedAt;
  Reciter? reciter;

  Audio({
    required this.id,
    required this.ayahId,
    required this.reciterId,
    required this.audioPath,
    required this.createdAt,
    required this.updatedAt,
    this.reciter,
  });

  factory Audio.fromJson(Map<String, dynamic> json) => Audio(
    id: json["id"] ?? 0,
    ayahId: json["ayah_id"] ?? 0,
    reciterId: json["reciter_id"] ?? 0,
    audioPath: json["audio_path"] ?? "",
    createdAt: json["created_at"] == null
        ? DateTime.now()
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? DateTime.now()
        : DateTime.parse(json["updated_at"]),
    reciter: json["reciter"] == null ? null : Reciter.fromJson(json["reciter"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ayah_id": ayahId,
    "reciter_id": reciterId,
    "audio_path": audioPath,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "reciter": reciter?.toJson(),
  };
}

class Reciter {
  int id;
  ReciterName name;
  String code;

  Reciter({required this.id, required this.name, required this.code});

  factory Reciter.fromJson(Map<String, dynamic> json) => Reciter(
    id: json["id"],
    name: reciterNameValues.map[json["name"]]!,
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": reciterNameValues.reverse[name],
    "code": code,
  };
}

enum ReciterName {
  ABDULLAH_AL_JUHANY,
  ABDUL_MUHSIN_AL_QASIM,
  ABDURRAHMAN_AS_SUDAIS,
  IBRAHIM_AL_DOSSARI,
  MISYARI_RASYID_AL_AFASI,
  YASSER_AL_DOSARI,
}

final reciterNameValues = EnumValues({
  "Abdullah Al-Juhany": ReciterName.ABDULLAH_AL_JUHANY,
  "Abdul Muhsin Al-Qasim": ReciterName.ABDUL_MUHSIN_AL_QASIM,
  "Abdurrahman As-Sudais": ReciterName.ABDURRAHMAN_AS_SUDAIS,
  "Ibrahim Al-Dossari": ReciterName.IBRAHIM_AL_DOSSARI,
  "Misyari Rasyid Al-Afasi": ReciterName.MISYARI_RASYID_AL_AFASI,
  "Yasser Al-Dosari": ReciterName.YASSER_AL_DOSARI,
});

class Surah {
  int id;
  String name;
  int totalAyah;

  Surah({required this.id, required this.name, required this.totalAyah});

  factory Surah.fromJson(Map<String, dynamic> json) =>
      Surah(id: json["id"], name: json["name"], totalAyah: json["total_ayah"]);

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
  DateTime createdAt;
  DateTime updatedAt;

  Block({
    required this.id,
    required this.ayahPageMapId,
    required this.blockNumber,
    required this.top,
    required this.left,
    required this.width,
    required this.height,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Block.fromJson(Map<String, dynamic> json) => Block(
    id: json["id"],
    ayahPageMapId: json["ayah_page_map_id"],
    blockNumber: json["block_number"],
    top: json["top"],
    left: json["left"],
    width: json["width"],
    height: json["height"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ayah_page_map_id": ayahPageMapId,
    "block_number": blockNumber,
    "top": top,
    "left": left,
    "width": width,
    "height": height,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class Meta {
  Range range;
  Navigation navigation;

  Meta({required this.range, required this.navigation});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    range: json["range"] == null
        ? Range(startPage: 0, endPage: 0, perPage: 0)
        : Range.fromJson(json["range"]),
    navigation: json["navigation"] == null
        ? Navigation()
        : Navigation.fromJson(json["navigation"]),
  );

  Map<String, dynamic> toJson() => {
    "range": range.toJson(),
    "navigation": navigation.toJson(),
  };
}

class Navigation {
  dynamic prevPageNumber;
  int? nextPageNumber;

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
    startPage: json["start_page"],
    endPage: json["end_page"],
    perPage: json["per_page"],
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
  int? viewportWidth;
  int? viewportHeight;

  Type({
    required this.id,
    required this.name,
    required this.slug,
    this.viewportWidth,
    this.viewportHeight,
  });

  factory Type.fromJson(Map<String, dynamic> json) => Type(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    slug: json["slug"] ?? "",
    viewportWidth: json["viewport_width"],
    viewportHeight: json["viewport_height"],
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
