import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/supplier.dart';
import '../services/product_service.dart';
import '../services/supplier_service.dart';

import 'product_inventory_details_screen.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> products = [];
  List<Supplier> suppliers = [];

  bool isLoading = true;

  static const int lowStockLimit = 5;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  // =========================
  // LOAD PRODUCTS
  // =========================

  Future<void> loadProducts() async {
    try {
      final loadedProducts = await ProductService.getProducts();

      final loadedSuppliers = await SupplierService.getSuppliers();

      if (!mounted) return;

      setState(() {
        products = loadedProducts;
        suppliers = loadedSuppliers;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error loading products: $e",
          ),
        ),
      );
    }
  }

  // =========================
  // GET SUPPLIER NAME
  // =========================

  String getSupplierName(int? supplierId) {
    if (supplierId == null) {
      return "No supplier";
    }

    try {
      final supplier = suppliers.firstWhere(
        (supplier) => supplier.id == supplierId,
      );

      return supplier.name;
    } catch (_) {
      return "No supplier";
    }
  }

  // =========================
  // DELETE PRODUCT
  // =========================

  Future<void> deleteProduct(int id) async {
    try {
      await ProductService.deleteProduct(id);

      await loadProducts();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Product deleted successfully",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error deleting product: $e",
          ),
        ),
      );
    }
  }

  // =========================
  // EDIT PRODUCT
  // =========================

  Future<void> editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProductScreen(
          product: product,
        ),
      ),
    );

    if (result == true) {
      await loadProducts();
    }
  }

  // =========================
  // ADD PRODUCT
  // =========================

  Future<void> addProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddProductScreen(),
      ),
    );

    await loadProducts();
  }

  // =========================
  // OPEN INVENTORY DETAILS
  // =========================

  Future<void> openInventoryDetails(Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductInventoryDetailsScreen(
          product: product,
        ),
      ),
    );

    // Refresh the product list when returning.
    await loadProducts();
  }

  // =========================
  // CONFIRM DELETE
  // =========================

  Future<void> confirmDelete(Product product) async {
    if (product.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Delete Product",
          ),
          content: Text(
            "Are you sure you want to delete ${product.name}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                "Cancel",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "Delete",
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await deleteProduct(product.id!);
    }
  }

  // =========================
  // PRODUCT CARD
  // =========================

  Widget buildProductCard(Product product) {
    final supplierName = getSupplierName(
      product.supplierId,
    );

    final double profit = product.price - product.costPrice;

    final bool isLowStock = product.quantity <= lowStockLimit;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          openInventoryDetails(product);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // PRODUCT NAME + STOCK STATUS
              // =========================

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    child: Icon(
                      Icons.inventory_2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.category,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLowStock)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "LOW STOCK",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              const Divider(),

              const SizedBox(height: 8),

              // =========================
              // STOCK
              // =========================

              Row(
                children: [
                  const Icon(
                    Icons.inventory,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Stock:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    product.quantity.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isLowStock ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // =========================
              // SUPPLIER
              // =========================

              Row(
                children: [
                  const Icon(
                    Icons.business,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Supplier:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      supplierName,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // =========================
              // BARCODE
              // =========================

              Row(
                children: [
                  const Icon(
                    Icons.qr_code,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Barcode:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      product.barcode,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // =========================
              // PRICES
              // =========================

              Row(
                children: [
                  // Cost Price
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Cost Price",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "R${product.costPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Selling Price
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selling Price",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "R${product.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Profit
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: profit >= 0
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Profit / Unit",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "R${profit.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: profit >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // =========================
// BUTTONS
// =========================

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      editProduct(product);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      confirmDelete(product);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    label: const Text("Delete"),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ],
              ),
              // =========================
              // TAP HINT
              // =========================

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 16,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Tap product to view inventory details",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // BUILD SCREEN
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Products",
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addProduct,
        child: const Icon(
          Icons.add,
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : products.isEmpty
              ? RefreshIndicator(
                  onRefresh: loadProducts,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 250),
                      Center(
                        child: Text(
                          "No products yet",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadProducts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return buildProductCard(
                        product,
                      );
                    },
                  ),
                ),
    );
  }
}
