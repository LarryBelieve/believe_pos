import '../database/database_helper.dart';
import '../models/expense.dart';

class ExpenseService {
  // =========================
  // ADD EXPENSE
  // =========================

  static Future<int> addExpense(Expense expense) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert(
      'expenses',
      expense.toMap(),
    );
  }

  // =========================
  // GET ALL EXPENSES
  // =========================

  static Future<List<Expense>> getExpenses() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'expenses',
      orderBy: 'expenseDate DESC',
    );

    return result.map((e) => Expense.fromMap(e)).toList();
  }

  // =========================
  // GET EXPENSE BY ID
  // =========================

  static Future<Expense?> getExpense(int id) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Expense.fromMap(result.first);
  }

  // =========================
  // UPDATE EXPENSE
  // =========================

  static Future<int> updateExpense(Expense expense) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // =========================
  // DELETE EXPENSE
  // =========================

  static Future<int> deleteExpense(int id) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // GET TOTAL EXPENSES
  // =========================

  static Future<double> getTotalExpenses() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS totalExpenses
      FROM expenses
    ''');

    return (result.first['totalExpenses'] as num).toDouble();
  }

  // =========================
  // GET TODAY'S EXPENSES
  // =========================

  static Future<double> getTodayExpenses() async {
    final db = await DatabaseHelper.instance.database;

    final now = DateTime.now();

    final start = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final end = start.add(
      const Duration(days: 1),
    );

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS totalExpenses
      FROM expenses
      WHERE expenseDate >= ?
      AND expenseDate < ?
      ''',
      [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
    );

    return (result.first['totalExpenses'] as num).toDouble();
  }
}
