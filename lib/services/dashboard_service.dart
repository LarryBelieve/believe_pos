import '../database/database_helper.dart';

class DashboardService {
  // =========================
  // TODAY'S DATE RANGE
  // =========================
  static List<String> _todayRange() {
    final now = DateTime.now();

    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final startOfTomorrow = startOfDay.add(
      const Duration(days: 1),
    );

    return [
      startOfDay.toIso8601String(),
      startOfTomorrow.toIso8601String(),
    ];
  }

  // =========================
  // TODAY'S SALES
  // =========================
  static Future<double> getTodaySales() async {
    final db = await DatabaseHelper.instance.database;

    final dates = _todayRange();

    final result = await db.rawQuery(
      '''
      SELECT SUM(total) AS totalSales
      FROM sales
      WHERE saleDate >= ?
      AND saleDate < ?
      ''',
      dates,
    );

    if (result.isNotEmpty && result.first['totalSales'] != null) {
      return (result.first['totalSales'] as num).toDouble();
    }

    return 0.0;
  }

  // =========================
  // TODAY'S TRANSACTIONS
  // =========================
  static Future<int> getTotalTransactions() async {
    final db = await DatabaseHelper.instance.database;

    final dates = _todayRange();

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM sales
      WHERE saleDate >= ?
      AND saleDate < ?
      ''',
      dates,
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toInt();
    }

    return 0;
  }

  // =========================
  // TODAY'S AVERAGE SALE
  // =========================
  static Future<double> getAverageSale() async {
    final db = await DatabaseHelper.instance.database;

    final dates = _todayRange();

    final result = await db.rawQuery(
      '''
      SELECT AVG(total) AS averageSale
      FROM sales
      WHERE saleDate >= ?
      AND saleDate < ?
      ''',
      dates,
    );

    if (result.isNotEmpty && result.first['averageSale'] != null) {
      return (result.first['averageSale'] as num).toDouble();
    }

    return 0.0;
  }

  // =========================
  // TODAY'S PROFIT
  // =========================
  static Future<double> getTodayProfit() async {
    final db = await DatabaseHelper.instance.database;

    final dates = _todayRange();

    final result = await db.rawQuery(
      '''
      SELECT
        SUM(
          (sale_items.price - products.costPrice)
          * sale_items.quantity
        ) AS totalProfit
      FROM sale_items
      INNER JOIN sales
        ON sales.id = sale_items.saleId
      INNER JOIN products
        ON products.id = sale_items.productId
      WHERE sales.saleDate >= ?
      AND sales.saleDate < ?
      ''',
      dates,
    );

    if (result.isNotEmpty && result.first['totalProfit'] != null) {
      return (result.first['totalProfit'] as num).toDouble();
    }

    return 0.0;
  }

  // =========================
  // TOTAL PRODUCTS
  // =========================
  static Future<int> getTotalProducts() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS totalProducts
      FROM products
      ''',
    );

    if (result.isNotEmpty && result.first['totalProducts'] != null) {
      return (result.first['totalProducts'] as num).toInt();
    }

    return 0;
  }

  // =========================
  // TOTAL STOCK VALUE
  // =========================
  static Future<double> getTotalStockValue() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery(
      '''
      SELECT SUM(quantity * costPrice) AS stockValue
      FROM products
      ''',
    );

    if (result.isNotEmpty && result.first['stockValue'] != null) {
      return (result.first['stockValue'] as num).toDouble();
    }

    return 0.0;
  }
}
