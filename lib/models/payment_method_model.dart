class PaymentMethodModel {
  bool status;
  List<PaymentMethod> data;

  PaymentMethodModel({required this.status, required this.data});

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      PaymentMethodModel(
        status: json["status"] == "success" || json["status"] == true,
        data: json["data"] == null
            ? []
            : List<PaymentMethod>.from(
                json["data"].map((x) => PaymentMethod.fromJson(x)),
              ),
      );
}

class PaymentMethod {
  int id;
  String name;
  String? code;
  String? paymentType;
  String? provider;
  String? bankName;
  String? accountNumber;
  String? accountName;
  String? logo;

  PaymentMethod({
    required this.id,
    required this.name,
    this.code,
    this.paymentType,
    this.provider,
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.logo,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    paymentType: json["payment_type"],
    provider: json["provider"],
    bankName: json["bank_name"],
    accountNumber: json["account_number"],
    accountName: json["account_name"],
    logo: json["logo"],
  );
}
