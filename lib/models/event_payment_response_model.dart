import 'package:quran_app/models/payment_method_model.dart';

class EventPaymentResponseModel {
  String status;
  String message;
  EventPaymentData? data;

  EventPaymentResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory EventPaymentResponseModel.fromJson(Map<String, dynamic> json) =>
      EventPaymentResponseModel(
        status: json["status"] == true ? 'success' : (json["status"] == false ? 'error' : json["status"].toString()),
        message: json["message"],
        data: json["data"] != null ? EventPaymentData.fromJson(json["data"]) : null,
      );
}

class EventPaymentData {
  EventRegistrationData registration;
  EventPayment? payment;

  EventPaymentData({required this.registration, this.payment});

  factory EventPaymentData.fromJson(Map<String, dynamic> json) => EventPaymentData(
    registration: EventRegistrationData.fromJson(json["registration"]),
    payment: json["payment"] != null ? EventPayment.fromJson(json["payment"]) : null,
  );
}

class EventRegistrationData {
  int id;
  int eventId;
  int userId;
  String registrationCode;
  String name;
  String email;
  String? phoneNumber;
  String status;
  String? price;
  DateTime createdAt;

  EventRegistrationData({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.registrationCode,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.status,
    this.price,
    required this.createdAt,
  });

  factory EventRegistrationData.fromJson(Map<String, dynamic> json) => EventRegistrationData(
    id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
    eventId: json["event_id"] is int ? json["event_id"] : int.tryParse(json["event_id"]?.toString() ?? '0') ?? 0,
    userId: json["user_id"] is int ? json["user_id"] : int.tryParse(json["user_id"]?.toString() ?? '0') ?? 0,
    registrationCode: json["registration_code"],
    name: json["name"],
    email: json["email"],
    phoneNumber: json["phone_number"],
    status: json["status"],
    price: json["price"],
    createdAt: DateTime.parse(json["created_at"]),
  );
}

class EventPayment {
  int eventRegistrationId;
  int paymentMethodeId;
  String amount;
  String payCode;
  String? qrString;
  String? qrCodeUrl;
  String? transactionId;
  String instructions;
  String status;
  DateTime expiredAt;
  DateTime updatedAt;
  DateTime createdAt;
  int id;
  PaymentMethod? paymentMethode;

  EventPayment({
    required this.eventRegistrationId,
    required this.paymentMethodeId,
    required this.amount,
    required this.payCode,
    this.qrString,
    this.qrCodeUrl,
    this.transactionId,
    required this.instructions,
    required this.status,
    required this.expiredAt,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    this.paymentMethode,
  });

  factory EventPayment.fromJson(Map<String, dynamic> json) => EventPayment(
    eventRegistrationId: json["event_registration_id"] is int ? json["event_registration_id"] : int.tryParse(json["event_registration_id"]?.toString() ?? '0') ?? 0,
    paymentMethodeId: json["payment_methode_id"] is int ? json["payment_methode_id"] : int.tryParse(json["payment_methode_id"]?.toString() ?? '0') ?? 0,
    amount: json["amount"].toString(),
    payCode: json["pay_code"] ?? '',
    qrString: json["qr_string"],
    qrCodeUrl: json["qr_code_url"],
    transactionId: json["transaction_id"],
    instructions: json["instructions"] is String ? json["instructions"] : (json["instructions"] != null ? json["instructions"].toString() : '[]'),
    status: json["status"],
    expiredAt: DateTime.parse(json["expired_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
    paymentMethode: json["payment_methode"] == null
        ? null
        : PaymentMethod.fromJson(json["payment_methode"]),
  );

  bool get isQris => qrCodeUrl != null && qrCodeUrl!.isNotEmpty;
}
