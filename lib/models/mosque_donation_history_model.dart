class MosqueDonationHistoryModel {
  bool status;
  MosqueDonationHistoryData data;

  MosqueDonationHistoryModel({required this.status, required this.data});

  factory MosqueDonationHistoryModel.fromJson(Map<String, dynamic> json) =>
      MosqueDonationHistoryModel(
        status: json["status"] == "success" || json["status"] == true,
        data: MosqueDonationHistoryData.fromJson(json["data"]),
      );
}

class MosqueDonationHistoryData {
  int currentPage;
  List<MosqueDonationHistoryItem> data;
  String? nextPageUrl;
  int lastPage;
  int total;

  MosqueDonationHistoryData({
    required this.currentPage,
    required this.data,
    this.nextPageUrl,
    required this.lastPage,
    required this.total,
  });

  factory MosqueDonationHistoryData.fromJson(Map<String, dynamic> json) =>
      MosqueDonationHistoryData(
        currentPage: json["current_page"],
        data: List<MosqueDonationHistoryItem>.from(
          json["data"].map((x) => MosqueDonationHistoryItem.fromJson(x)),
        ),
        nextPageUrl: json["next_page_url"],
        lastPage: json["last_page"],
        total: json["total"],
      );
}

class MosqueDonationHistoryItem {
  int id;
  int? userId;
  int paymentMethodeId;
  int mosqueCharityId;
  String orderId;
  String? guestName;
  String? guestPhone;
  String amount;
  String status;
  dynamic paidAt;
  DateTime createdAt;
  DateTime updatedAt;
  String formattedAmount;
  MosqueCharityShort mosqueCharity;
  MosquePaymentShort payment;

  MosqueDonationHistoryItem({
    required this.id,
    this.userId,
    required this.paymentMethodeId,
    required this.mosqueCharityId,
    required this.orderId,
    this.guestName,
    this.guestPhone,
    required this.amount,
    required this.status,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedAmount,
    required this.mosqueCharity,
    required this.payment,
  });

  factory MosqueDonationHistoryItem.fromJson(Map<String, dynamic> json) =>
      MosqueDonationHistoryItem(
        id: json["id"],
        userId: json["user_id"],
        paymentMethodeId: json["payment_methode_id"],
        mosqueCharityId: json["mosque_charity_id"],
        orderId: json["order_id"],
        guestName: json["guest_name"],
        guestPhone: json["guest_phone"],
        amount: json["amount"],
        status: json["status"],
        paidAt: json["paid_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        formattedAmount: json["formatted_amount"],
        mosqueCharity: MosqueCharityShort.fromJson(json["mosque_charity"]),
        payment: MosquePaymentShort.fromJson(json["payment"]),
      );
}

class MosqueCharityShort {
  int id;
  String name;
  String coverImage;

  MosqueCharityShort({
    required this.id,
    required this.name,
    required this.coverImage,
  });

  factory MosqueCharityShort.fromJson(Map<String, dynamic> json) =>
      MosqueCharityShort(
        id: json["id"],
        name: json["name"],
        coverImage: json["cover_image"],
      );
}

class MosquePaymentShort {
  int id;
  int mosqueDonationId;
  String status;
  DateTime createdAt;

  MosquePaymentShort({
    required this.id,
    required this.mosqueDonationId,
    required this.status,
    required this.createdAt,
  });

  factory MosquePaymentShort.fromJson(Map<String, dynamic> json) =>
      MosquePaymentShort(
        id: json["id"],
        mosqueDonationId: json["mosque_donation_id"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
      );
}
