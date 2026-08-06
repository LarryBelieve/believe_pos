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

  static Future<double> getTodaySales() async {
    final sales = await getSales();

    final today = DateTime.now();

    double total = 0;

    for (final sale in sales) {
      final date = DateTime.parse(sale.saleDate);

      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        total += sale.total;
      }
    }

    return total;
  }

  static Future<int> getTodayTransactionCount() async {
    final sales = await getSales();

    final today = DateTime.now();

    int count = 0;

    for (final sale in sales) {
      final date = DateTime.parse(sale.saleDate);

      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        count++;
      }
    }

    return count;
  }

  static Future<double> getAverageSale() async {
    final sales = await getSales();

    if (sales.isEmpty) {
      return 0;
    }

    double total = 0;

    for (final sale in sales) {
      total += sale.total;
    }

    return total / sales.length;
  }
}
