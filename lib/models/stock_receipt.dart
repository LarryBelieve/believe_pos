class StockReceipt {
  final int? id;
  final int productId;
  final int? supplierId;
  final int quantity;
  final double costPrice;
  final String receiptDate;
  StockReceipt({
    this.id,
    required this.productId,
    this.supplierId,
    required this.quantity,
    required this.costPrice,
    required this.receiptDate,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'supplierId': supplierId,
      'quantity': quantity,
      'costPrice': costPrice,
      'receiptDate': receiptDate,
    };
  }

  factory StockReceipt.fromMap(Map<String, dynamic> map) {
    return StockReceipt(
      id: map['id'],
      productId: map['productId'],
      supplierId: map['supplierId'],
      quantity: map['quantity'],
      costPrice: (map['costPrice'] as num).toDouble(),
      receiptDate: map['receiptDate'],
    );
  }
}
