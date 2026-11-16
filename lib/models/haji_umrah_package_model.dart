import 'package:quran_app/api/url.dart';

class HajiUmrahPackageModel {
  int? id;
  String? title;
  String? slug;
  String? description;
  String? coverImage;
  List<dynamic>? images;
  String? price;
  String? departureCityId;
  String? departureCity;
  DateTime? departureDate;
  DateTime? returnDate;
  int? durationDays;
  String? flightDetail;
  int? quota;
  int? quotaLeft;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? priceFormatted;
  String? targetAmount;
  String? targetAmountFormatted;
  UmrahDetail? umrahDetail;

  HajiUmrahPackageModel({
    this.id,
    this.title,
    this.slug,
    this.description,
    this.coverImage,
    this.images,
    this.price,
    this.departureCityId,
    this.departureCity,
    this.departureDate,
    this.returnDate,
    this.durationDays,
    this.flightDetail,
    this.quota,
    this.quotaLeft,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.priceFormatted,
    this.targetAmount,
    this.targetAmountFormatted,
    this.umrahDetail,
  });

  // Computed property to get a clean cover/banner image URL
  String get bannerImageUrl {
    String url = coverImage ?? '';
    if (url.isNotEmpty &&
        !url.startsWith('http://') &&
        !url.startsWith('https://')) {
      if (url.startsWith('/')) {
        return '${Url.baseUrl}$url';
      } else {
        return '${Url.baseUrl}/$url';
      }
    }
    return url;
  }

  factory HajiUmrahPackageModel.fromJson(Map<String, dynamic> json) {
    final umrahDetailRaw = json['umrah_detail'];
    final umrahDetailObj = umrahDetailRaw is Map<String, dynamic> ? umrahDetailRaw : null;
    
    // Clean up city prefixes like KABUPATEN or KOTA for cleaner display
    String? cleanDepartureCity = json['departure_city']?.toString() ?? umrahDetailObj?['departure_city']?.toString();
    if (cleanDepartureCity != null) {
      cleanDepartureCity = cleanDepartureCity.replaceAll('KABUPATEN ', '').replaceAll('KOTA ', '');
    }

    return HajiUmrahPackageModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      coverImage: json['cover_image'] as String?,
      images: json['images'] as List<dynamic>?,
      price: json['price']?.toString(),
      departureCityId: json['departure_city_id']?.toString(),
      departureCity: cleanDepartureCity,
      departureDate: json['departure_date'] != null ? DateTime.tryParse(json['departure_date'].toString()) : null,
      returnDate: json['return_date'] != null ? DateTime.tryParse(json['return_date'].toString()) : null,
      durationDays: json['duration_days'] as int?,
      flightDetail: json['flight_detail'] as String?,
      quota: json['quota'] as int?,
      quotaLeft: json['quota_left'] as int?,
      status: json['status'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      priceFormatted: json['price_formatted'] as String?,
      targetAmount: json['target_amount']?.toString(),
      targetAmountFormatted: json['target_amount_formatted'] as String?,
      umrahDetail: umrahDetailObj != null ? UmrahDetail.fromJson(umrahDetailObj) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'cover_image': coverImage,
      'images': images,
      'price': price,
      'departure_city_id': departureCityId,
      'departure_city': departureCity,
      'departure_date': departureDate?.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'duration_days': durationDays,
      'flight_detail': flightDetail,
      'quota': quota,
      'quota_left': quotaLeft,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'price_formatted': priceFormatted,
      'target_amount': targetAmount,
      'target_amount_formatted': targetAmountFormatted,
      'umrah_detail': umrahDetail?.toJson(),
    };
  }
}

class UmrahDetail {
  String? departureCity;
  DateTime? departureDate;
  DateTime? returnDate;
  int? durationDays;
  String? flightDetail;
  String? departureDateFormatted;
  String? returnDateFormatted;

  UmrahDetail({
    this.departureCity,
    this.departureDate,
    this.returnDate,
    this.durationDays,
    this.flightDetail,
    this.departureDateFormatted,
    this.returnDateFormatted,
  });

  factory UmrahDetail.fromJson(Map<String, dynamic> json) {
    return UmrahDetail(
      departureCity: json['departure_city'] as String?,
      departureDate: json['departure_date'] != null ? DateTime.tryParse(json['departure_date'].toString()) : null,
      returnDate: json['return_date'] != null ? DateTime.tryParse(json['return_date'].toString()) : null,
      durationDays: json['duration_days'] as int?,
      flightDetail: json['flight_detail'] as String?,
      departureDateFormatted: json['departure_date_formatted'] as String?,
      returnDateFormatted: json['return_date_formatted'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departure_city': departureCity,
      'departure_date': departureDate?.toIso8601String().split('T')[0],
      'return_date': returnDate?.toIso8601String().split('T')[0],
      'duration_days': durationDays,
      'flight_detail': flightDetail,
      'departure_date_formatted': departureDateFormatted,
      'return_date_formatted': returnDateFormatted,
    };
  }
}
