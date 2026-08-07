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
      // 1. Save the sale
      final int saleId = await txn.insert(
        'sales',
        sale.toMap(),
      );

      // 2. Process every item in the sale
      for (final item in cartItems) {
        // Make sure the product has an ID
        if (item.product.id == null) {
          throw Exception(
            'Product "${item.product.name}" has no ID.',
          );
        }

        // Make sure there is enough stock
        final stockResult = await txn.query(
          'products',
          columns: ['quantity'],
          where: 'id = ?',
          whereArgs: [item.product.id],
          limit: 1,
        );

        if (stockResult.isEmpty) {
          throw Exception(
            'Product "${item.product.name}" was not found.',
          );
        }

        final int currentStock = stockResult.first['quantity'] as int;

        if (item.quantity > currentStock) {
          throw Exception(
            'Not enough ${item.product.name} in stock. '
            'Available: $currentStock',
          );
        }

        // 3. Save the sale item
        await txn.insert(
          'sale_items',
          SaleItem(
            saleId: saleId,
            productId: item.product.id!,
            productName: item.product.name,
            quantity: item.quantity,
            price: item.product.price,
          ).toMap(),
        );

        // 4. Reduce product stock
        await txn.rawUpdate(
          '''
          UPDATE products
          SET quantity = quantity - ?
          WHERE id = ?
          ''',
          [
            item.quantity,
            item.product.id,
          ],
        );

        // 5. Record stock movement
        await txn.insert(
          'stock_movements',
          StockMovement(
            productId: item.product.id!,
            quantity: -item.quantity,
            movementType: 'SALE',
            referenceId: saleId,
            note: 'Stock sold',
            movementDate: sale.saleDate,
          ).toMap(),
        );
      }

      // 6. Return the sale ID
      return saleId;
    });
  }
}
