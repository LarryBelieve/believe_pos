import '../database/database_helper.dart';
import '../models/stock_movement.dart';

class StockMovementService {
  /// Add a stock movement
  static Future<int> addMovement(
    StockMovement movement,
  ) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert(
      'stock_movements',
      movement.toMap(),
    );
  }

  /// Get all stock movements
  static Future<List<StockMovement>> getMovements() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'stock_movements',
      orderBy: 'movementDate DESC',
    );

    return result.map((e) => StockMovement.fromMap(e)).toList();
  }

  /// Get movements for a specific product
  static Future<List<StockMovement>> getMovementsForProduct(
    int productId,
  ) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'stock_movements',
      where: 'productId = ?',
      whereArgs: [productId],
      orderBy: 'movementDate DESC',
    );

    return result.map((e) => StockMovement.fromMap(e)).toList();
  }

  /// Get movements by type
  static Future<List<StockMovement>> getMovementsByType(
    String movementType,
  ) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'stock_movements',
      where: 'movementType = ?',
      whereArgs: [movementType],
      orderBy: 'movementDate DESC',
    );

    return result.map((e) => StockMovement.fromMap(e)).toList();
  }

  /// Delete a movement
  static Future<int> deleteMovement(int id) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'stock_movements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
