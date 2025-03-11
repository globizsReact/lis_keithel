class Product {
  final String id;
  final String productTypeId;
  final String productBrandId;
  final String name;
  final String details;
  final String description;
  final double price;
  final String uom;
  final String uomCode;
  final double weightPerPcs;
  final String needConversion;
  final String photo;

  Product({
    required this.id,
    required this.productTypeId,
    required this.productBrandId,
    required this.name,
    required this.details,
    required this.description,
    required this.price,
    required this.uom,
    required this.uomCode,
    required this.weightPerPcs,
    required this.needConversion,
    required this.photo,
  });

  // Factory constructor for deserialization
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      productTypeId: json['product_type_id'].toString(),
      productBrandId: json['product_brand_id'].toString(),
      name: json['name'],
      details: json['details'],
      description: json['description'],
      price: double.parse(json['price']),
      uom: json['uom'].toString(),
      uomCode: json['uom_code'],
      weightPerPcs: double.parse(json['weight_per_pcs']),
      needConversion: json['need_conversion'].toString(),
      photo: json['photo'],
    );
  }
}
