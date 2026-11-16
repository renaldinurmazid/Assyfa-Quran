import 'package:quran_app/models/payment_method_model.dart';

class MosqueDonationDetailModel {
  String status;
  MosqueDonationDetailItem data;

  MosqueDonationDetailModel({required this.status, required this.data});

  factory MosqueDonationDetailModel.fromJson(Map<String, dynamic> json) =>
      MosqueDonationDetailModel(
        status: json["status"],
        data: MosqueDonationDetailItem.fromJson(json["data"]),
      );
}

class MosqueDonationDetailItem {
  int id;
  int mosqueCharityId;
  int? userId;
  int paymentMethodeId;
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
  MosquePaymentDetail payment;

  MosqueDonationDetailItem({
    required this.id,
    required this.mosqueCharityId,
    this.userId,
    required this.paymentMethodeId,
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

  factory MosqueDonationDetailItem.fromJson(Map<String, dynamic> json) =>
      MosqueDonationDetailItem(
        id: json["id"],
        mosqueCharityId: json["mosque_charity_id"],
        userId: json["user_id"],
        paymentMethodeId: json["payment_methode_id"],
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
        payment: MosquePaymentDetail.fromJson(json["payment"]),
      );
}

class MosqueCharityShort {
  int id;
  String name;
  String coverImage;
  dynamic currentAmount;

  MosqueCharityShort({
    required this.id,
    required this.name,
    required this.coverImage,
    required this.currentAmount,
  });

  factory MosqueCharityShort.fromJson(Map<String, dynamic> json) =>
      MosqueCharityShort(
        id: json["id"],
        name: json["name"],
        coverImage: json["cover_image"],
        currentAmount: json["current_amount"],
      );
}

class MosquePaymentDetail {
  int id;
  int mosqueDonationId;
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

  MosquePaymentDetail({
    required this.id,
    required this.mosqueDonationId,
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

  factory MosquePaymentDetail.fromJson(Map<String, dynamic> json) =>
      MosquePaymentDetail(
        id: json["id"],
        mosqueDonationId: json["mosque_donation_id"],
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
