import '../database/database_helper.dart';
import '../models/supplier.dart';

class SupplierService {
  static Future<int> addSupplier(Supplier supplier) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert(
      'suppliers',
      supplier.toMap(),
    );
  }

  static Future<List<Supplier>> getSuppliers() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'suppliers',
      orderBy: 'name ASC',
    );

    return result.map((e) => Supplier.fromMap(e)).toList();
  }

  static Future<int> updateSupplier(Supplier supplier) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'suppliers',
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  static Future<int> deleteSupplier(int id) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'suppliers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
