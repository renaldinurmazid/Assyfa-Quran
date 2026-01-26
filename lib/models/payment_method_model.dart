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
  String bankName;
  String accountNumber;
  String accountName;
  String logo;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.logo,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
    id: json["id"],
    name: json["name"],
    bankName: json["bank_name"],
    accountNumber: json["account_number"],
    accountName: json["account_name"],
    logo: json["logo"],
  );
}
