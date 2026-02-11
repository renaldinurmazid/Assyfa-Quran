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
        status: json["status"],
        message: json["message"],
        data: MosqueDonationData.fromJson(json["data"]),
      );
}

class MosqueDonationData {
  MosqueDonation donation;
  MosquePayment payment;

  MosqueDonationData({required this.donation, required this.payment});

  factory MosqueDonationData.fromJson(Map<String, dynamic> json) =>
      MosqueDonationData(
        donation: MosqueDonation.fromJson(json["donation"]),
        payment: MosquePayment.fromJson(json["payment"]),
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
    mosqueCharityId: json["mosque_charity_id"],
    paymentMethodeId: json["payment_methode_id"],
    orderId: json["order_id"],
    guestName: json["guest_name"],
    guestPhone: json["guest_phone"],
    amount: json["amount"],
    status: json["status"],
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    id: json["id"],
    formattedAmount: json["formatted_amount"],
  );
}

class MosquePayment {
  int mosqueDonationId;
  int paymentMethodeId;
  String amount;
  String payCode;
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
    mosqueDonationId: json["mosque_donation_id"],
    paymentMethodeId: json["payment_methode_id"],
    amount: json["amount"],
    payCode: json["pay_code"],
    instructions: json["instructions"],
    status: json["status"],
    expiredAt: DateTime.parse(json["expired_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    id: json["id"],
    formattedAmount: json["formatted_amount"],
    paymentMethode: json["payment_methode"] == null
        ? null
        : PaymentMethod.fromJson(json["payment_methode"]),
  );
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
