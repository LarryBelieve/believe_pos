import '../database/database_helper.dart';
import '../models/sale.dart';

class SalesHistoryService {
  static Future<List<Sale>> getSales() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'sales',
      orderBy: 'saleDate DESC',
    );

    return result.map((e) => Sale.fromMap(e)).toList();
  }
}
