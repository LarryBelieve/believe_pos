import '../database/database_helper.dart';
import '../models/cart_item.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/stock_movement.dart';

class SalesService {
  static Future<int> saveSale({
    required Sale sale,
    required List<CartItem> cartItems,
  }) async {
    final db = await DatabaseHelper.instance.database;

    return await db.transaction((txn) async {
      // 1. Save the sale.
      final int saleId = await txn.insert(
        'sales',
        sale.toMap(),
      );

      // 2. Process every item.
      for (final item in cartItems) {
        if (item.product.id == null) {
          throw Exception(
            'Product "${item.product.name}" has no ID.',
          );
        }

        final productId = item.product.id!;

        // Get current stock.
        final stockResult = await txn.query(
          'products',
          columns: ['quantity'],
          where: 'id = ?',
          whereArgs: [productId],
          limit: 1,
        );

        if (stockResult.isEmpty) {
          throw Exception(
            'Product "${item.product.name}" was not found.',
          );
        }

        // Stock before sale.
        final int stockBefore = (stockResult.first['quantity'] as num).toInt();

        // Check available stock.
        if (item.quantity > stockBefore) {
          throw Exception(
            'Not enough ${item.product.name} in stock. '
            'Available: $stockBefore',
          );
        }

        // Stock after sale.
        final int stockAfter = stockBefore - item.quantity;

        // 3. Save sale item.
        await txn.insert(
          'sale_items',
          SaleItem(
            saleId: saleId,
            productId: productId,
            productName: item.product.name,
            quantity: item.quantity,
            price: item.product.price,
          ).toMap(),
        );

        // 4. Update product stock.
        await txn.rawUpdate(
          '''
          UPDATE products
          SET quantity = ?
          WHERE id = ?
          ''',
          [
            stockAfter,
            productId,
          ],
        );

        // 5. Record stock movement.
        await txn.insert(
          'stock_movements',
          StockMovement(
            productId: productId,
            quantity: -item.quantity,
            movementType: 'SALE',
            referenceId: saleId,
            note: 'Stock sold',
            movementDate: sale.saleDate,
            stockBefore: stockBefore,
            stockAfter: stockAfter,
          ).toMap(),
        );
      }

      // 6. Return sale ID.
      return saleId;
    });
  }
}
