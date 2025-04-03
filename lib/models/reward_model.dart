class RewardModel {
  final String reply;
  final List<RewardItem> active;
  final List<RewardItem> used;
  final List<RewardItem> transferred;
  final List<RewardItem> expired;

  RewardModel({
    required this.reply,
    required this.active,
    required this.used,
    required this.transferred,
    required this.expired,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      reply: json['reply'],
      active: (json['active'] as List<dynamic>)
          .map((item) => RewardItem.fromJson(item))
          .toList(),
      used: (json['used'] as List<dynamic>)
          .map((item) => RewardItem.fromJson(item))
          .toList(),
      transferred: (json['transferred'] as List<dynamic>)
          .map((item) => RewardItem.fromJson(item))
          .toList(),
      expired: (json['expired'] as List<dynamic>)
          .map((item) => RewardItem.fromJson(item))
          .toList(),
    );
  }
}

class RewardItem {
  final String id;
  final String salesOrderId;
  final double point;
  final String expireDate;

  RewardItem({
    required this.id,
    required this.salesOrderId,
    required this.point,
    required this.expireDate,
  });

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(
      id: json['id'],
      salesOrderId: json['sales_order_id'],
      point: double.parse(json['point']),
      expireDate: json['expire_date'],
    );
  }
}
