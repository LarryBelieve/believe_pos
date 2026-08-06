import '../database/database_helper.dart';
import '../models/customer.dart';

class CustomerService {
  static Future<int> addCustomer(Customer customer) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert(
      'customers',
      customer.toMap(),
    );
  }

  static Future<List<Customer>> getCustomers() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'customers',
      orderBy: 'name ASC',
    );

    return result.map((e) => Customer.fromMap(e)).toList();
  }

  static Future<int> updateCustomer(Customer customer) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  static Future<int> deleteCustomer(int id) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
