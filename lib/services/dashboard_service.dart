import '../database/database_helper.dart';

class DashboardService {
  static Future<double> getTodaySales() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT SUM(total) AS totalSales
      FROM sales
    ''');

    if (result.isNotEmpty && result.first['totalSales'] != null) {
      return (result.first['totalSales'] as num).toDouble();
    }

    return 0.0;
  }

  static Future<int> getTotalTransactions() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT COUNT(*) AS total
      FROM sales
    ''');

    return (result.first['total'] as num).toInt();
  }

  static Future<double> getAverageSale() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT AVG(total) AS averageSale
      FROM sales
    ''');

    if (result.isNotEmpty && result.first['averageSale'] != null) {
      return (result.first['averageSale'] as num).toDouble();
    }

    return 0.0;
  }
}
