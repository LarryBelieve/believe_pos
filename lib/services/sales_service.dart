import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/cart_item.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';

class SalesService {
  static Future<int> saveSale({
    required Sale sale,
    required List<CartItem> cartItems,
  }) async {
    final db = await DatabaseHelper.instance.database;

    return await db.transaction((txn) async {
      // Save sale
      final int saleId = await txn.insert(
        'sales',
        sale.toMap(),
      );

      // Save every sold item
      for (final item in cartItems) {
        await txn.insert(
          'sale_items',
          SaleItem(
            saleId: saleId,
            productId: item.product.id!,
            quantity: item.quantity,
            price: item.product.price,
          ).toMap(),
        );

        // Reduce stock
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
      }

      return saleId;
    });
  }
}
