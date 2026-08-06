import '../database/database_helper.dart';
import '../models/product.dart';

class ProductService {
  static Future<int> addProduct(Product product) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert(
      'products',
      product.toMap(),
    );
  }

  static Future<List<Product>> getProducts() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query('products');

    return result.map((e) => Product.fromMap(e)).toList();
  }

  static Future<Product?> getProductByBarcode(String barcode) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Product.fromMap(result.first);
  }

  static Future<int> deleteProduct(int id) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateProduct(Product product) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }
}
