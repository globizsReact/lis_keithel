class ProductL {
  final int productId;
  final String productName;

  ProductL({
    required this.productId,
    required this.productName,
  });

  factory ProductL.fromJson(Map<String, dynamic> json) {
    return ProductL(
      productId: json['product_id'],
      productName: json['product_name'],
    );
  }
}

class ProductLedgerEntry {
  final String productName;
  final String uom;
  final double credit;
  final double debit;
  final DateTime transactionDate;
  final String remark;

  ProductLedgerEntry({
    required this.productName,
    required this.uom,
    required this.credit,
    required this.debit,
    required this.transactionDate,
    required this.remark,
  });

  factory ProductLedgerEntry.fromJson(Map<String, dynamic> json) {
    return ProductLedgerEntry(
      productName: json['product_name'],
      uom: json['uom'],
      credit: (json['credit'] ?? 0).toDouble(),
      debit: (json['debit'] ?? 0).toDouble(),
      transactionDate: DateTime.parse(json['transaction_date']),
      remark: json['remark'] ?? '',
    );
  }
}
