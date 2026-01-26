class DonationHistoryModel {
  bool status;
  DonationHistoryData data;

  DonationHistoryModel({required this.status, required this.data});

  factory DonationHistoryModel.fromJson(Map<String, dynamic> json) =>
      DonationHistoryModel(
        status: json["status"] == "success" || json["status"] == true,
        data: DonationHistoryData.fromJson(json["data"]),
      );
}

class DonationHistoryData {
  int currentPage;
  List<DonationHistoryItem> data;
  String? nextPageUrl;
  int lastPage;
  int total;

  DonationHistoryData({
    required this.currentPage,
    required this.data,
    this.nextPageUrl,
    required this.lastPage,
    required this.total,
  });

  factory DonationHistoryData.fromJson(Map<String, dynamic> json) =>
      DonationHistoryData(
        currentPage: json["current_page"],
        data: List<DonationHistoryItem>.from(
          json["data"].map((x) => DonationHistoryItem.fromJson(x)),
        ),
        nextPageUrl: json["next_page_url"],
        lastPage: json["last_page"],
        total: json["total"],
      );
}

class DonationHistoryItem {
  int id;
  int userId;
  int paymentMethodeId;
  int campaignId;
  String orderId;
  String guestName;
  String guestPhone;
  String amount;
  String status;
  dynamic paidAt;
  DateTime createdAt;
  DateTime updatedAt;
  String formattedAmount;
  CampaignShort campaign;
  PaymentShort payment;

  DonationHistoryItem({
    required this.id,
    required this.userId,
    required this.paymentMethodeId,
    required this.campaignId,
    required this.orderId,
    required this.guestName,
    required this.guestPhone,
    required this.amount,
    required this.status,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedAmount,
    required this.campaign,
    required this.payment,
  });

  factory DonationHistoryItem.fromJson(Map<String, dynamic> json) =>
      DonationHistoryItem(
        id: json["id"],
        userId: json["user_id"],
        paymentMethodeId: json["payment_methode_id"],
        campaignId: json["campaign_id"],
        orderId: json["order_id"],
        guestName: json["guest_name"],
        guestPhone: json["guest_phone"],
        amount: json["amount"],
        status: json["status"],
        paidAt: json["paid_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        formattedAmount: json["formatted_amount"],
        campaign: CampaignShort.fromJson(json["campaign"]),
        payment: PaymentShort.fromJson(json["payment"]),
      );
}

class CampaignShort {
  int id;
  String title;
  String coverImage;

  CampaignShort({
    required this.id,
    required this.title,
    required this.coverImage,
  });

  factory CampaignShort.fromJson(Map<String, dynamic> json) => CampaignShort(
    id: json["id"],
    title: json["title"],
    coverImage: json["cover_image"],
  );
}

class PaymentShort {
  int id;
  int donationId;
  String status;
  DateTime createdAt;

  PaymentShort({
    required this.id,
    required this.donationId,
    required this.status,
    required this.createdAt,
  });

  factory PaymentShort.fromJson(Map<String, dynamic> json) => PaymentShort(
    id: json["id"],
    donationId: json["donation_id"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
  );
}
