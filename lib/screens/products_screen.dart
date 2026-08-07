import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/supplier.dart';
import '../services/product_service.dart';
import '../services/supplier_service.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> products = [];
  List<Supplier> suppliers = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final loadedProducts = await ProductService.getProducts();
    final loadedSuppliers = await SupplierService.getSuppliers();
    if (!mounted) return;
    setState(() {
      products = loadedProducts;
      suppliers = loadedSuppliers;
      isLoading = false;
    });
  }

  Future<void> deleteProduct(int id) async {
    await ProductService.deleteProduct(id);
    loadData();
  }

  Future<void> editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductScreen(
          product: product,
        ),
      ),
    );
    if (result == true) {
      loadData();
    }
  }

  String getSupplierName(int? supplierId) {
    if (supplierId == null) {
      return "No supplier";
    }
    final supplier = suppliers.firstWhere(
      (supplier) => supplier.id == supplierId,
      orElse: () => Supplier(
        id: null,
        name: "Unknown supplier",
        phone: "",
        email: "",
        address: "",
      ),
    );
    return supplier.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductScreen(),
            ),
          );
          if (result == true) {
            loadData();
          }
        },
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : products.isEmpty
              ? const Center(
                  child: Text(
                    "No products yet",
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.inventory),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Category: ${product.category}\n"
                          "Stock: ${product.quantity}\n"
                          "Cost: R${product.costPrice.toStringAsFixed(2)}\n"
                          "Supplier: ${getSupplierName(product.supplierId)}",
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "R${product.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              tooltip: "Edit product",
                              onPressed: () {
                                editProduct(product);
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              tooltip: "Delete product",
                              onPressed: () {
                                if (product.id != null) {
                                  deleteProduct(product.id!);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
