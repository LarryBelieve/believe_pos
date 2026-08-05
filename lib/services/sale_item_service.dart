import '../database/database_helper.dart';
import '../models/sale_item.dart';

class SaleItemService {
  static Future<int> addSaleItem(SaleItem item) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert(
      'sale_items',
      item.toMap(),
    );
  }

  static Future<List<SaleItem>> getSaleItems(int saleId) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'sale_items',
      where: 'saleId = ?',
      whereArgs: [saleId],
    );

    return result.map((e) => SaleItem.fromMap(e)).toList();
  }
}
