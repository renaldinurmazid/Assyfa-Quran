class EventModel {
  final int id;
  final String title;
  final String slug;
  final String? thumbnail;
  final String? excerpt;
  final String? content;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minQuota;
  final int? maxQuota;
  final int? price;
  final String? formattedPrice;
  final String? groupLink;
  final bool isPublished;
  final bool isRegistered;

  EventModel({
    required this.id,
    required this.title,
    required this.slug,
    this.thumbnail,
    this.excerpt,
    this.content,
    this.location,
    this.startDate,
    this.endDate,
    this.minQuota,
    this.maxQuota,
    this.price,
    this.formattedPrice,
    this.groupLink,
    required this.isPublished,
    this.isRegistered = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      thumbnail: json['thumbnail'],
      excerpt: json['excerpt'],
      content: json['content'],
      location: json['location'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date']).toLocal()
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date']).toLocal()
          : null,
      minQuota: json['min_quota'] != null ? double.tryParse(json['min_quota'].toString())?.toInt() : null,
      maxQuota: json['max_quota'] != null ? double.tryParse(json['max_quota'].toString())?.toInt() : null,
      price: json['price'] != null ? double.tryParse(json['price'].toString())?.toInt() : null,
      formattedPrice: json['formatted_price'],
      groupLink: json['group_link'],
      isPublished: json['is_published'] == 1 || json['is_published'] == true,
      isRegistered: json['is_registered'] == 1 || json['is_registered'] == true,
    );
  }
}
