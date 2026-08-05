class Sale {
  final int? id;
  final double total;
  final String paymentMethod;
  final String saleDate;

  Sale({
    this.id,
    required this.total,
    required this.paymentMethod,
    required this.saleDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total': total,
      'paymentMethod': paymentMethod,
      'saleDate': saleDate,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      total: map['total'],
      paymentMethod: map['paymentMethod'],
      saleDate: map['saleDate'],
    );
  }
}
