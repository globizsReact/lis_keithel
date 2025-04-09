class CouponResponse {
  final String type;
  final List<Coupon>? coupons;
  final String? errorMessage;

  CouponResponse({
    required this.type,
    this.coupons,
    this.errorMessage,
  });

  // Factory constructor to parse JSON into a CouponResponse object
  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    if (type == 'success') {
      // Success case: Parse the list of coupons
      final coupons = (json['msg'] as List<dynamic>)
          .map((couponJson) => Coupon.fromJson(couponJson))
          .toList();
      return CouponResponse(
        type: type,
        coupons: coupons,
      );
    } else {
      // Failure case: Parse the error message
      final errorMessage = json['msg'] as String;
      return CouponResponse(
        type: type,
        errorMessage: errorMessage,
      );
    }
  }
}

class Coupon {
  final String code; // Coupon code (e.g., "STAYSAFE")
  final int discount; // Discount percentage (e.g., 30)

  Coupon({
    required this.code,
    required this.discount,
  });

  // Factory constructor to parse JSON into a Coupon object
  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      code: json['c'] as String,
      discount: json['t'] as int,
    );
  }
}
