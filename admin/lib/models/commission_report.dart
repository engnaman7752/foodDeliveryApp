class CommissionReport {
  String? reportId;
  String? orderId;
  String? sellerId;
  String? sellerName;
  String? totalOrderAmount;
  String? sellerAmount; // 90%
  String? companyCommission; // 10%
  String? paymentMethod;
  String? transactionDate;
  String? status; // "pending", "paid", "failed"

  CommissionReport({
    this.reportId,
    this.orderId,
    this.sellerId,
    this.sellerName,
    this.totalOrderAmount,
    this.sellerAmount,
    this.companyCommission,
    this.paymentMethod,
    this.transactionDate,
    this.status,
  });

  CommissionReport.fromJson(Map<String, dynamic> json) {
    reportId = json["reportId"];
    orderId = json["orderId"];
    sellerId = json["sellerId"];
    sellerName = json["sellerName"];
    totalOrderAmount = json["totalOrderAmount"]?.toString();
    sellerAmount = json["sellerAmount"]?.toString();
    companyCommission = json["companyCommission"]?.toString();
    paymentMethod = json["paymentMethod"];
    transactionDate = json["transactionDate"];
    status = json["status"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["reportId"] = reportId;
    data["orderId"] = orderId;
    data["sellerId"] = sellerId;
    data["sellerName"] = sellerName;
    data["totalOrderAmount"] = totalOrderAmount;
    data["sellerAmount"] = sellerAmount;
    data["companyCommission"] = companyCommission;
    data["paymentMethod"] = paymentMethod;
    data["transactionDate"] = transactionDate;
    data["status"] = status;
    return data;
  }

  double getCompanyCommissionDouble() {
    return double.tryParse(companyCommission ?? "0") ?? 0;
  }

  double getSellerAmountDouble() {
    return double.tryParse(sellerAmount ?? "0") ?? 0;
  }

  double getTotalOrderAmountDouble() {
    return double.tryParse(totalOrderAmount ?? "0") ?? 0;
  }
}
