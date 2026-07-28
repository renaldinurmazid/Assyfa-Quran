import 'package:quran_app/models/event_payment_response_model.dart';
import 'package:quran_app/models/event_model.dart';

class EventRegistrationListResponseModel {
  String status;
  String message;
  List<EventRegistrationItem> data;

  EventRegistrationListResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory EventRegistrationListResponseModel.fromJson(Map<String, dynamic> json) =>
      EventRegistrationListResponseModel(
        status: json["status"] == true ? 'success' : (json["status"] == false ? 'error' : json["status"].toString()),
        message: json["message"],
        data: json["data"] != null
            ? List<EventRegistrationItem>.from(json["data"].map((x) => EventRegistrationItem.fromJson(x)))
            : [],
      );
}

class EventRegistrationItem {
  int id;
  int eventId;
  int userId;
  String registrationCode;
  String name;
  String email;
  String? phoneNumber;
  String status;
  DateTime createdAt;
  EventModel? event;
  EventPayment? payment;

  EventRegistrationItem({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.registrationCode,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.status,
    required this.createdAt,
    this.event,
    this.payment,
  });

  factory EventRegistrationItem.fromJson(Map<String, dynamic> json) => EventRegistrationItem(
    id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
    eventId: json["event_id"] is int ? json["event_id"] : int.tryParse(json["event_id"]?.toString() ?? '0') ?? 0,
    userId: json["user_id"] is int ? json["user_id"] : int.tryParse(json["user_id"]?.toString() ?? '0') ?? 0,
    registrationCode: json["registration_code"],
    name: json["name"],
    email: json["email"],
    phoneNumber: json["phone_number"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    event: json["event"] == null ? null : EventModel.fromJson(json["event"]),
    payment: json["payment"] == null ? null : EventPayment.fromJson(json["payment"]),
  );
}
