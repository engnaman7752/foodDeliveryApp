class OrderModel {
  String? orderId;
  String? userId;
  String? sellerId;
  String? sellerName;
  String? riderAssigned;
  String? riderName;
  String? totalAmount;
  String? companyCommission; // 10% of total amount
  String? sellerAmount; // 90% of total amount
  String? paymentMethod; // "cash_on_delivery" or "card"
  String?
  status; // "pending", "confirmed", "preparing", "ready", "in_delivery", "ended", "cancelled"
  String? orderTime;
  String? deliveryTime;
  String? addressId;
  bool? isSuccess;
  List<OrderItem>? items;
  bool? cashCollected; // For COD - whether cash has been collected

  OrderModel({
    this.orderId,
    this.userId,
    this.sellerId,
    this.sellerName,
    this.riderAssigned,
    this.riderName,
    this.totalAmount,
    this.companyCommission,
    this.sellerAmount,
    this.paymentMethod,
    this.status,
    this.orderTime,
    this.deliveryTime,
    this.addressId,
    this.isSuccess,
    this.items,
    this.cashCollected,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    orderId = json["orderId"];
    userId = json["userId"];
    sellerId = json["sellerId"];
    sellerName = json["sellerName"];
    riderAssigned = json["riderAssigned"];
    riderName = json["riderName"];
    totalAmount = json["totalAmount"]?.toString();
    companyCommission = json["companyCommission"]?.toString();
    sellerAmount = json["sellerAmount"]?.toString();
    paymentMethod = json["paymentMethod"];
    status = json["status"];
    orderTime = json["orderTime"];
    deliveryTime = json["deliveryTime"];
    addressId = json["addressId"];
    isSuccess = json["isSuccess"] ?? false;
    cashCollected = json["cashCollected"] ?? false;
    if (json["items"] != null) {
      items = <OrderItem>[];
      json["items"].forEach((v) {
        items!.add(OrderItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["orderId"] = orderId;
    data["userId"] = userId;
    data["sellerId"] = sellerId;
    data["sellerName"] = sellerName;
    data["riderAssigned"] = riderAssigned;
    data["riderName"] = riderName;
    data["totalAmount"] = totalAmount;
    data["companyCommission"] = companyCommission;
    data["sellerAmount"] = sellerAmount;
    data["paymentMethod"] = paymentMethod;
    data["status"] = status;
    data["orderTime"] = orderTime;
    data["deliveryTime"] = deliveryTime;
    data["addressId"] = addressId;
    data["isSuccess"] = isSuccess;
    data["cashCollected"] = cashCollected;
    if (items != null) {
      data["items"] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  double getCompanyCommissionDouble() {
    return double.tryParse(companyCommission ?? "0") ?? 0;
  }

  double getSellerAmountDouble() {
    return double.tryParse(sellerAmount ?? "0") ?? 0;
  }

  double getTotalAmountDouble() {
    return double.tryParse(totalAmount ?? "0") ?? 0;
  }
}

class OrderItem {
  String? itemId;
  String? itemName;
  String? quantity;
  String? price;

  OrderItem({this.itemId, this.itemName, this.quantity, this.price});

  OrderItem.fromJson(Map<String, dynamic> json) {
    itemId = json["itemId"];
    itemName = json["itemName"];
    quantity = json["quantity"]?.toString();
    price = json["price"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["itemId"] = itemId;
    data["itemName"] = itemName;
    data["quantity"] = quantity;
    data["price"] = price;
    return data;
  }
}
