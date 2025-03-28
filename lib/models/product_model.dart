class Product {
  final String id;
  final String productTypeId;
  final String productBrandId;
  final String name;
  final String details;
  final String description;
  final double price;
  final String uom;
  final String? uomCode; // Nullable field
  final double weightPerPcs;
  final String needConversion;
  final String? photo; // Nullable field

  Product({
    required this.id,
    required this.productTypeId,
    required this.productBrandId,
    required this.name,
    required this.details,
    required this.description,
    required this.price,
    required this.uom,
    this.uomCode, // Nullable
    required this.weightPerPcs,
    required this.needConversion,
    this.photo, // Nullable
  });

  // Factory constructor for deserialization
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '', // Default to empty string if null
      productTypeId: json['product_type_id']?.toString() ?? '',
      productBrandId: json['product_brand_id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Product', // Default name if null
      details: json['details'] ?? '', // Default to empty string if null
      description: json['description'] ?? '', // Default to empty string if null
      price: double.tryParse(json['price']?.toString() ?? '0.0') ??
          0.0, // Default to 0.0 if null
      uom: json['uom']?.toString() ?? '', // Default to empty string if null
      uomCode: json['uom_code']?.toString(), // Nullable
      weightPerPcs:
          double.tryParse(json['weight_per_pcs']?.toString() ?? '0.0') ??
              0.0, // Default to 0.0 if null
      needConversion:
          json['need_conversion']?.toString() ?? '0', // Default to '0' if null
      photo: json['photo']?.toString(), // Nullable
    );
  }
}
