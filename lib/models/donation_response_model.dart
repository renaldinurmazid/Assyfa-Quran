import 'dart:convert';
import 'package:quran_app/models/payment_method_model.dart';

class DonationResponseModel {
  String status;
  String message;
  DonationData data;

  DonationResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DonationResponseModel.fromJson(Map<String, dynamic> json) =>
      DonationResponseModel(
        status: json["status"],
        message: json["message"],
        data: DonationData.fromJson(json["data"]),
      );
}

class DonationData {
  Donation donation;
  Payment payment;

  DonationData({required this.donation, required this.payment});

  factory DonationData.fromJson(Map<String, dynamic> json) => DonationData(
    donation: Donation.fromJson(json["donation"]),
    payment: Payment.fromJson(json["payment"]),
  );
}

class Donation {
  int? userId;
  int campaignId;
  int paymentMethodeId;
  String orderId;
  String? guestName;
  String? guestPhone;
  String amount;
  String status;
  DateTime updatedAt;
  DateTime createdAt;
  int id;

  Donation({
    this.userId,
    required this.campaignId,
    required this.paymentMethodeId,
    required this.orderId,
    this.guestName,
    this.guestPhone,
    required this.amount,
    required this.status,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory Donation.fromJson(Map<String, dynamic> json) => Donation(
    userId: json["user_id"],
    campaignId: json["campaign_id"],
    paymentMethodeId: json["payment_methode_id"],
    orderId: json["order_id"]?.toString() ?? '',
    guestName: json["guest_name"]?.toString(),
    guestPhone: json["guest_phone"]?.toString(),
    amount: json["amount"]?.toString() ?? '',
    status: json["status"]?.toString() ?? '',
    updatedAt: json["updated_at"] != null
        ? (DateTime.tryParse(json["updated_at"].toString()) ?? DateTime.now())
        : DateTime.now(),
    createdAt: json["created_at"] != null
        ? (DateTime.tryParse(json["created_at"].toString()) ?? DateTime.now())
        : DateTime.now(),
    id: json["id"] ?? 0,
  );
}

class Payment {
  int donationId;
  int paymentMethodeId;
  String amount;
  String payCode;
  String? qrString;
  String? qrCodeUrl;
  String instructions;
  String status;
  DateTime expiredAt;
  DateTime updatedAt;
  DateTime createdAt;
  int id;
  PaymentMethod? paymentMethode;

  Payment({
    required this.donationId,
    required this.paymentMethodeId,
    required this.amount,
    required this.payCode,
    this.qrString,
    this.qrCodeUrl,
    required this.instructions,
    required this.status,
    required this.expiredAt,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    this.paymentMethode,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    donationId: json["donation_id"] ?? 0,
    paymentMethodeId: json["payment_methode_id"] ?? 0,
    amount: json["amount"]?.toString() ?? '',
    payCode: json["pay_code"]?.toString() ?? '',
    qrString: json["qr_string"],
    qrCodeUrl: json["qr_url"] ?? json["qr_code_url"],
    instructions: json["instructions"] is String
        ? json["instructions"]
        : (json["instructions"] != null ? jsonEncode(json["instructions"]) : '[]'),
    status: json["status"],
    expiredAt: DateTime.parse(json["expired_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    id: json["id"],
    paymentMethode: json["payment_methode"] == null
        ? null
        : PaymentMethod.fromJson(json["payment_methode"]),
  );

  bool get isQris => qrCodeUrl != null && qrCodeUrl!.isNotEmpty;
}

class Instruction {
  String title;
  List<String> steps;

  Instruction({required this.title, required this.steps});

  factory Instruction.fromJson(Map<String, dynamic> json) => Instruction(
    title: json["title"],
    steps: List<String>.from(json["steps"].map((x) => x)),
  );
}
