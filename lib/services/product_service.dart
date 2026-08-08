import '../database/database_helper.dart';
import '../models/product.dart';

class ProductService {
  // =========================
  // ADD PRODUCT
  // =========================
  static Future<int> addProduct(Product product) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert(
      'products',
      product.toMap(),
    );
  }

  // =========================
  // GET ALL PRODUCTS
  // =========================
  static Future<List<Product>> getProducts() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'products',
      orderBy: 'name ASC',
    );

    return result.map((e) => Product.fromMap(e)).toList();
  }

  // =========================
  // GET PRODUCT BY BARCODE
  // =========================
  static Future<Product?> getProductByBarcode(
    String barcode,
  ) async {
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

  // =========================
  // GET LOW STOCK PRODUCTS
  // =========================
  static Future<List<Product>> getLowStockProducts({
    int threshold = 5,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'products',
      where: 'quantity <= ?',
      whereArgs: [threshold],
      orderBy: 'quantity ASC',
    );

    return result.map((e) => Product.fromMap(e)).toList();
  }

  // =========================
  // DELETE PRODUCT
  // =========================
  static Future<int> deleteProduct(int id) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // UPDATE PRODUCT
  // =========================
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
