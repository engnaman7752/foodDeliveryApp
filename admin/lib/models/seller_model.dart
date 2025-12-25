class SellerModel {
  String? sellerId;
  String? sellerName;
  String? sellerEmail;
  String? sellerAvatar;
  String? restaurantName;
  String? totalEarnings;
  String? totalOrders;
  String? rating;
  bool? isApproved;
  String? joinDate;
  String? phoneNumber;
  String? address;

  SellerModel({
    this.sellerId,
    this.sellerName,
    this.sellerEmail,
    this.sellerAvatar,
    this.restaurantName,
    this.totalEarnings,
    this.totalOrders,
    this.rating,
    this.isApproved,
    this.joinDate,
    this.phoneNumber,
    this.address,
  });

  SellerModel.fromJson(Map<String, dynamic> json) {
    sellerId = json["sellerId"];
    sellerName = json["sellerName"];
    sellerEmail = json["sellerEmail"];
    sellerAvatar = json["sellerAvtar"];
    restaurantName = json["restaurantName"];
    totalEarnings = json["totalEarnings"]?.toString();
    totalOrders = json["totalOrders"]?.toString();
    rating = json["rating"]?.toString();
    isApproved = json["isApproved"] ?? false;
    joinDate = json["joinDate"];
    phoneNumber = json["phoneNumber"];
    address = json["address"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["sellerId"] = sellerId;
    data["sellerName"] = sellerName;
    data["sellerEmail"] = sellerEmail;
    data["sellerAvtar"] = sellerAvatar;
    data["restaurantName"] = restaurantName;
    data["totalEarnings"] = totalEarnings;
    data["totalOrders"] = totalOrders;
    data["rating"] = rating;
    data["isApproved"] = isApproved;
    data["joinDate"] = joinDate;
    data["phoneNumber"] = phoneNumber;
    data["address"] = address;
    return data;
  }

  double getTotalEarningsDouble() {
    return double.tryParse(totalEarnings ?? "0") ?? 0;
  }

  int getTotalOrdersInt() {
    return int.tryParse(totalOrders ?? "0") ?? 0;
  }
}
