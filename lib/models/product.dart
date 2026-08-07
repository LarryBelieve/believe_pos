class Product {
  final int? id;
  final String name;
  final double price;
  final double costPrice;
  final int quantity;
  final String category;
  final String barcode;
  final int? supplierId;
  Product({
    this.id,
    required this.name,
    required this.price,
    this.costPrice = 0,
    required this.quantity,
    required this.category,
    required this.barcode,
    this.supplierId,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'costPrice': costPrice,
      'quantity': quantity,
      'category': category,
      'barcode': barcode,
      'supplierId': supplierId,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0,
      quantity: map['quantity'],
      category: map['category'],
      barcode: map['barcode'],
      supplierId: map['supplierId'],
    );
  }
}
