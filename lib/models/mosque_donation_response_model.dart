import 'dart:convert';
import 'package:quran_app/models/payment_method_model.dart';

class MosqueDonationResponseModel {
  String status;
  String message;
  MosqueDonationData data;

  MosqueDonationResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MosqueDonationResponseModel.fromJson(Map<String, dynamic> json) =>
      MosqueDonationResponseModel(
        status: json["status"]?.toString() ?? '',
        message: json["message"]?.toString() ?? '',
        data: MosqueDonationData.fromJson(json["data"] ?? {}),
      );
}

class MosqueDonationData {
  MosqueDonation donation;
  MosquePayment payment;

  MosqueDonationData({required this.donation, required this.payment});

  factory MosqueDonationData.fromJson(Map<String, dynamic> json) =>
      MosqueDonationData(
        donation: MosqueDonation.fromJson(json["donation"] ?? {}),
        payment: MosquePayment.fromJson(json["payment"] ?? {}),
      );
}

class MosqueDonation {
  int? userId;
  int mosqueCharityId;
  int paymentMethodeId;
  String orderId;
  String? guestName;
  String? guestPhone;
  String amount;
  String status;
  DateTime updatedAt;
  DateTime createdAt;
  int id;
  String formattedAmount;

  MosqueDonation({
    this.userId,
    required this.mosqueCharityId,
    required this.paymentMethodeId,
    required this.orderId,
    this.guestName,
    this.guestPhone,
    required this.amount,
    required this.status,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    required this.formattedAmount,
  });

  factory MosqueDonation.fromJson(Map<String, dynamic> json) => MosqueDonation(
    userId: json["user_id"],
    mosqueCharityId: json["mosque_charity_id"] ?? 0,
    paymentMethodeId: json["payment_methode_id"] ?? 0,
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
    formattedAmount: json["formatted_amount"]?.toString() ?? '',
  );
}

class MosquePayment {
  int mosqueDonationId;
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
  String formattedAmount;
  PaymentMethod? paymentMethode;

  MosquePayment({
    required this.mosqueDonationId,
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
    required this.formattedAmount,
    this.paymentMethode,
  });

  factory MosquePayment.fromJson(Map<String, dynamic> json) => MosquePayment(
    mosqueDonationId: json["mosque_donation_id"] ?? 0,
    paymentMethodeId: json["payment_methode_id"] ?? 0,
    amount: json["amount"]?.toString() ?? '',
    payCode: json["pay_code"]?.toString() ?? '',
    qrString: json["qr_string"]?.toString(),
    qrCodeUrl: json["qr_url"]?.toString() ?? json["qr_code_url"]?.toString(),
    instructions: json["instructions"] is String
        ? json["instructions"]
        : (json["instructions"] != null
            ? jsonEncode(json["instructions"])
            : '[]'),
    status: json["status"]?.toString() ?? '',
    expiredAt: json["expired_at"] != null
        ? (DateTime.tryParse(json["expired_at"].toString()) ??
            DateTime.now().add(const Duration(days: 1)))
        : DateTime.now().add(const Duration(days: 1)),
    updatedAt: json["updated_at"] != null
        ? (DateTime.tryParse(json["updated_at"].toString()) ?? DateTime.now())
        : DateTime.now(),
    createdAt: json["created_at"] != null
        ? (DateTime.tryParse(json["created_at"].toString()) ?? DateTime.now())
        : DateTime.now(),
    id: json["id"] ?? 0,
    formattedAmount: json["formatted_amount"]?.toString() ?? '',
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
    title: json["title"]?.toString() ?? '',
    steps: json["steps"] != null
        ? List<String>.from(json["steps"].map((x) => x?.toString() ?? ''))
        : [],
  );
}
