class Purchase {
  final int? id;
  final int supplierId;
  final double total;
  final String purchaseDate;

  Purchase({
    this.id,
    required this.supplierId,
    required this.total,
    required this.purchaseDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierId': supplierId,
      'total': total,
      'purchaseDate': purchaseDate,
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'],
      supplierId: map['supplierId'],
      total: (map['total'] as num).toDouble(),
      purchaseDate: map['purchaseDate'],
    );
  }
}
