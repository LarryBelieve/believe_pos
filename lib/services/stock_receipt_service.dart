import '../database/database_helper.dart';
import '../models/stock_receipt.dart';

class StockReceiptService {
  static Future<int> receiveStock({
    required StockReceipt receipt,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return await db.transaction((txn) async {
      // 1. Record the stock receipt.
      final receiptId = await txn.insert(
        'stock_receipts',
        receipt.toMap(),
      );
      // 2. Increase the product stock.
      await txn.rawUpdate(
        '''
        UPDATE products
        SET quantity = quantity + ?,
            costPrice = ?
        WHERE id = ?
        ''',
        [
          receipt.quantity,
          receipt.costPrice,
          receipt.productId,
        ],
      );
      // 3. Return the receipt ID.
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
