import 'dart:convert';

NearbyMosqueResponse nearbyMosqueResponseFromJson(String str) =>
    NearbyMosqueResponse.fromJson(json.decode(str));

String nearbyMosqueResponseToJson(NearbyMosqueResponse data) =>
    json.encode(data.toJson());

class NearbyMosqueResponse {
  String status;
  String message;
  String source;
  List<NearbyMosque> data;

  NearbyMosqueResponse({
    required this.status,
    required this.message,
    required this.source,
    required this.data,
  });

  factory NearbyMosqueResponse.fromJson(Map<String, dynamic> json) =>
      NearbyMosqueResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        source: json["source"] ?? "",
        data: json["data"] != null
            ? List<NearbyMosque>.from(
                json["data"].map((x) => NearbyMosque.fromJson(x)),
              )
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "source": source,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class NearbyMosque {
  int id;
  String placeId;
  String name;
  String address;
  double latitude;
  double longitude;
  double? rating;
  int? userRatingsTotal;
  String createdAt;
  String updatedAt;
  double distance;

  NearbyMosque({
    required this.id,
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.userRatingsTotal,
    required this.createdAt,
    required this.updatedAt,
    required this.distance,
  });

  factory NearbyMosque.fromJson(Map<String, dynamic> json) => NearbyMosque(
        id: json["id"] ?? 0,
        placeId: json["place_id"] ?? "",
        name: json["name"] ?? "",
        address: json["address"] ?? "",
        latitude: (json["latitude"] as num?)?.toDouble() ?? 0.0,
        longitude: (json["longitude"] as num?)?.toDouble() ?? 0.0,
        rating: (json["rating"] as num?)?.toDouble(),
        userRatingsTotal: json["user_ratings_total"] as int?,
        createdAt: json["created_at"] ?? "",
        updatedAt: json["updated_at"] ?? "",
        distance: (json["distance"] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "place_id": placeId,
        "name": name,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "rating": rating,
        "user_ratings_total": userRatingsTotal,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "distance": distance,
      };
}
