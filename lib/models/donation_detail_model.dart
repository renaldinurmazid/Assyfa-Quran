import 'package:quran_app/models/payment_method_model.dart';

class DonationDetailModel {
  String status;
  DonationDetailItem data;

  DonationDetailModel({required this.status, required this.data});

  factory DonationDetailModel.fromJson(Map<String, dynamic> json) =>
      DonationDetailModel(
        status: json["status"],
        data: DonationDetailItem.fromJson(json["data"]),
      );
}

class DonationDetailItem {
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
  PaymentDetail payment;

  DonationDetailItem({
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

  factory DonationDetailItem.fromJson(Map<String, dynamic> json) =>
      DonationDetailItem(
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
        payment: PaymentDetail.fromJson(json["payment"]),
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

class PaymentDetail {
  int id;
  int donationId;
  int paymentMethodeId;
  String? externalReference;
  String amount;
  String payCode;
  String? payUrl;
  String? checkoutUrl;
  String? qrString;
  String? qrUrl;
  List<InstructionItem> instructions;
  String status;
  DateTime? expiredAt;
  DateTime createdAt;
  DateTime updatedAt;
  String formattedAmount;
  PaymentMethod? paymentMethode;

  PaymentDetail({
    required this.id,
    required this.donationId,
    required this.paymentMethodeId,
    this.externalReference,
    required this.amount,
    required this.payCode,
    this.payUrl,
    this.checkoutUrl,
    this.qrString,
    this.qrUrl,
    required this.instructions,
    required this.status,
    this.expiredAt,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedAmount,
    this.paymentMethode,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) => PaymentDetail(
    id: json["id"],
    donationId: json["donation_id"],
    paymentMethodeId: json["payment_methode_id"],
    externalReference: json["external_reference"],
    amount: json["amount"],
    payCode: json["pay_code"],
    payUrl: json["pay_url"],
    checkoutUrl: json["checkout_url"],
    qrString: json["qr_string"],
    qrUrl: json["qr_url"],
    instructions: json["instructions"] == null
        ? []
        : List<InstructionItem>.from(
            json["instructions"].map((x) => InstructionItem.fromJson(x)),
          ),
    status: json["status"],
    expiredAt: json["expired_at"] == null
        ? null
        : DateTime.parse(json["expired_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    formattedAmount: json["formatted_amount"],
    paymentMethode: json["payment_methode"] == null
        ? null
        : PaymentMethod.fromJson(json["payment_methode"]),
  );
}

class InstructionItem {
  String title;
  List<String> steps;

  InstructionItem({required this.title, required this.steps});

  factory InstructionItem.fromJson(Map<String, dynamic> json) =>
      InstructionItem(
        title: json["title"],
        steps: List<String>.from(json["steps"].map((x) => x)),
      );
}
