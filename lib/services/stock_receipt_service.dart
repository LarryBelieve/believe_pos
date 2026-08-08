import '../database/database_helper.dart';
import '../models/stock_receipt.dart';
import '../models/stock_movement.dart';

class StockReceiptService {
  static Future<int> receiveStock({
    required StockReceipt receipt,
  }) async {
    final db = await DatabaseHelper.instance.database;

    return await db.transaction((txn) async {
      // Make sure the product exists.
      final productResult = await txn.query(
        'products',
        columns: ['quantity'],
        where: 'id = ?',
        whereArgs: [receipt.productId],
        limit: 1,
      );

      if (productResult.isEmpty) {
        throw Exception(
          'Product with ID ${receipt.productId} was not found.',
        );
      }

      // Stock before receiving.
      final int stockBefore = (productResult.first['quantity'] as num).toInt();

      // Stock after receiving.
      final int stockAfter = stockBefore + receipt.quantity;

      // Record the stock receipt.
      final receiptId = await txn.insert(
        'stock_receipts',
        receipt.toMap(),
      );

      // Update product stock.
      await txn.rawUpdate(
        '''
        UPDATE products
        SET quantity = ?,
            costPrice = ?
        WHERE id = ?
        ''',
        [
          stockAfter,
          receipt.costPrice,
          receipt.productId,
        ],
      );

      // Record stock movement with before/after values.
      await txn.insert(
        'stock_movements',
        StockMovement(
          productId: receipt.productId,
          quantity: receipt.quantity,
          movementType: 'RECEIVED',
          referenceId: receiptId,
          note: 'Stock received',
          movementDate: receipt.receiptDate,
          stockBefore: stockBefore,
          stockAfter: stockAfter,
        ).toMap(),
      );

      return receiptId;
    });
  }

  static Future<List<StockReceipt>> getStockReceipts() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'stock_receipts',
      orderBy: 'receiptDate DESC',
    );

    return result.map((e) => StockReceipt.fromMap(e)).toList();
  }

  static Future<List<StockReceipt>> getReceiptsForProduct(
    int productId,
  ) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'stock_receipts',
      where: 'productId = ?',
      whereArgs: [productId],
      orderBy: 'receiptDate DESC',
    );

    return result.map((e) => StockReceipt.fromMap(e)).toList();
  }
}
