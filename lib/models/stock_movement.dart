class StockMovement {
  final int? id;
  final int productId;
  final int quantity;
  final String movementType;
  final int? referenceId;
  final String? note;
  final String movementDate;

  StockMovement({
    this.id,
    required this.productId,
    required this.quantity,
    required this.movementType,
    this.referenceId,
    this.note,
    required this.movementDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
      'movementType': movementType,
      'referenceId': referenceId,
      'note': note,
      'movementDate': movementDate,
    };
  }

  factory StockMovement.fromMap(
    Map<String, dynamic> map,
  ) {
    return StockMovement(
      id: map['id'],
      productId: map['productId'],
      quantity: map['quantity'],
      movementType: map['movementType'],
      referenceId: map['referenceId'],
      note: map['note'],
      movementDate: map['movementDate'],
    );
  }
}
