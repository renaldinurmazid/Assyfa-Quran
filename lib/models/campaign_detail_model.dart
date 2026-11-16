import 'dart:convert';

CampaignDetailModel campaignDetailModelFromJson(String str) =>
    CampaignDetailModel.fromJson(json.decode(str));

String campaignDetailModelToJson(CampaignDetailModel data) =>
    json.encode(data.toJson());

class CampaignDetailModel {
  String status;
  String message;
  CampaignData data;

  CampaignDetailModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CampaignDetailModel.fromJson(Map<String, dynamic> json) =>
      CampaignDetailModel(
        status: json["status"],
        message: json["message"],
        data: CampaignData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class CampaignData {
  int id;
  String title;
  String coverImage;
  String? endDate;
  String targetAmount;
  String description;
  String collectedAmount;
  int percentage;
  int donaturCount;
  int fundraiserCount;
  String formType;
  int? qurbanPrice;
  String? formattedQurbanPrice;
  double currentAmount; // Diubah ke double karena JSON mengirim "10000.00"
  CampaignCategory? category;
  QurbanDetail? qurbanDetail;
  List<CampaignUpdate> updates;
  List<CampaignFundraiser> fundraisers;
  String? shareUrl;
  int? withOption;
  List<CampaignOption>? campaignOptions;

  CampaignData({
    required this.id,
    required this.title,
    required this.coverImage,
    this.endDate,
    required this.targetAmount,
    required this.description,
    required this.collectedAmount,
    required this.percentage,
    required this.donaturCount,
    required this.fundraiserCount,
    required this.formType,
    this.qurbanPrice,
    this.formattedQurbanPrice,
    required this.currentAmount,
    this.category,
    this.qurbanDetail,
    required this.updates,
    required this.fundraisers,
    this.shareUrl,
    this.withOption,
    this.campaignOptions,
  });
  factory CampaignData.fromJson(Map<String, dynamic> json) {
    // Fungsi pembantu untuk parsing angka yang mungkin datang sebagai String
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return CampaignData(
      id: json["id"],
      title: json["title"],
      coverImage: json["cover_image"],
      endDate: json["end_date"],
      targetAmount: json["target_amount"],
      description: json["description"],
      collectedAmount: json["collected_amount"],
      percentage: json["percentage"] ?? 0,
      donaturCount: json["donatur_count"] ?? 0,
      fundraiserCount: json["fundraiser_count"] ?? 0,
      formType: json["form_type"],
      qurbanPrice: json["qurban_price"],
      formattedQurbanPrice: json["formatted_qurban_price"],
      currentAmount: parseDouble(json["current_amount"]), // Gunakan parser aman
      category: json["category"] != null
          ? CampaignCategory.fromJson(json["category"])
          : null,
      qurbanDetail: json["qurban_detail"] != null
          ? QurbanDetail.fromJson(json["qurban_detail"])
          : null,
      updates: json["updates"] != null
          ? List<CampaignUpdate>.from(
              json["updates"].map((x) => CampaignUpdate.fromJson(x)),
            )
          : [],
      fundraisers: json["fundraisers"] != null
          ? List<CampaignFundraiser>.from(
              json["fundraisers"].map((x) => CampaignFundraiser.fromJson(x)),
            )
          : [],
      shareUrl: json["share_url"],
      withOption: json["with_option"],
      campaignOptions: json["campaign_options"] != null
          ? List<CampaignOption>.from(
              json["campaign_options"].map((x) => CampaignOption.fromJson(x)),
            )
          : null,
    );
  }
  // Jangan lupa update toJson juga
  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "cover_image": coverImage,
    "end_date": endDate,
    "target_amount": targetAmount,
    "description": description,
    "collected_amount": collectedAmount,
    "percentage": percentage,
    "donatur_count": donaturCount,
    "fundraiser_count": fundraiserCount,
    "form_type": formType,
    "qurban_price": qurbanPrice,
    "formatted_qurban_price": formattedQurbanPrice,
    "current_amount": currentAmount
        .toString(), // Sesuaikan dengan format API jika perlu
    "category": category?.toJson(),
    "qurban_detail": qurbanDetail?.toJson(),
    "updates": List<dynamic>.from(updates.map((x) => x.toJson())),
    "fundraisers": List<dynamic>.from(fundraisers.map((x) => x.toJson())),
    "share_url": shareUrl,
    "with_option": withOption,
    "campaign_options": campaignOptions != null
        ? List<dynamic>.from(campaignOptions!.map((x) => x.toJson()))
        : null,
  };
}

class CampaignOption {
  int id;
  int campaignId;
  String name;
  String price;
  int slot;

  CampaignOption({
    required this.id,
    required this.campaignId,
    required this.name,
    required this.price,
    required this.slot,
  });

  factory CampaignOption.fromJson(Map<String, dynamic> json) => CampaignOption(
    id: json["id"],
    campaignId: json["campaign_id"],
    name: json["name"],
    price: json["price"],
    slot: json["slot"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "campaign_id": campaignId,
    "name": name,
    "price": price,
    "slot": slot,
  };
}

class CampaignCategory {
  int id;
  String name;
  String slug;

  CampaignCategory({required this.id, required this.name, required this.slug});

  factory CampaignCategory.fromJson(Map<String, dynamic> json) =>
      CampaignCategory(id: json["id"], name: json["name"], slug: json["slug"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "slug": slug};
}

class QurbanDetail {
  int id;
  int campaignId;
  String animalType;
  String variantName;
  String qurbanType;
  String pricePerUnit;
  int totalSlots;
  DateTime? createdAt;
  DateTime? updatedAt;

  QurbanDetail({
    required this.id,
    required this.campaignId,
    required this.animalType,
    required this.variantName,
    required this.qurbanType,
    required this.pricePerUnit,
    required this.totalSlots,
    this.createdAt,
    this.updatedAt,
  });

  factory QurbanDetail.fromJson(Map<String, dynamic> json) => QurbanDetail(
    id: json["id"],
    campaignId: json["campaign_id"],
    animalType: json["animal_type"],
    variantName: json["variant_name"],
    qurbanType: json["qurban_type"],
    pricePerUnit: json["price_per_unit"],
    totalSlots: json["total_slots"],
    createdAt: json["created_at"] != null
        ? DateTime.parse(json["created_at"])
        : null,
    updatedAt: json["updated_at"] != null
        ? DateTime.parse(json["updated_at"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "campaign_id": campaignId,
    "animal_type": animalType,
    "variant_name": variantName,
    "qurban_type": qurbanType,
    "price_per_unit": pricePerUnit,
    "total_slots": totalSlots,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class CampaignUpdate {
  int id;
  int campaignId;
  String title;
  String content;
  DateTime date;
  DateTime createdAt;
  DateTime updatedAt;
  String createdAtFormatted;

  CampaignUpdate({
    required this.id,
    required this.campaignId,
    required this.title,
    required this.content,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.createdAtFormatted,
  });

  factory CampaignUpdate.fromJson(Map<String, dynamic> json) => CampaignUpdate(
    id: json["id"],
    campaignId: json["campaign_id"],
    title: json["title"],
    content: json["content"],
    date: DateTime.parse(json["date"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAtFormatted: json["created_at_formatted"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "campaign_id": campaignId,
    "title": title,
    "content": content,
    "date": date.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "created_at_formatted": createdAtFormatted,
  };
}

class CampaignFundraiser {
  int id;
  String name;
  int totalReferral;
  String totalCollected;

  CampaignFundraiser({
    required this.id,
    required this.name,
    required this.totalReferral,
    required this.totalCollected,
  });

  factory CampaignFundraiser.fromJson(Map<String, dynamic> json) =>
      CampaignFundraiser(
        id: json["id"],
        name: json["name"] ?? 'Anonim',
        totalReferral: json["total_referral"] ?? 0,
        totalCollected: json["total_collected"] ?? 'Rp0',
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "total_referral": totalReferral,
    "total_collected": totalCollected,
  };
}
