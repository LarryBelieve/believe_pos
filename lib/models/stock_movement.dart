class StockMovement {
  final int? id;
  final int productId;
  final int quantity;
  final String movementType;
  final int? referenceId;
  final String? note;
  final String movementDate;
  final int stockBefore;
  final int stockAfter;

  StockMovement({
    this.id,
    required this.productId,
    required this.quantity,
    required this.movementType,
    this.referenceId,
    this.note,
    required this.movementDate,
    required this.stockBefore,
    required this.stockAfter,
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
      'stockBefore': stockBefore,
      'stockAfter': stockAfter,
    };
  }

  factory StockMovement.fromMap(Map<String, dynamic> map) {
    return StockMovement(
      id: map['id'],
      productId: map['productId'],
      quantity: map['quantity'],
      movementType: map['movementType'],
      referenceId: map['referenceId'],
      note: map['note'],
      movementDate: map['movementDate'],
      stockBefore: map['stockBefore'] ?? 0,
      stockAfter: map['stockAfter'] ?? 0,
    );
  }
}
