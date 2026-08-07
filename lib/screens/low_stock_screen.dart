import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class LowStockScreen extends StatefulWidget {
  const LowStockScreen({super.key});

  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  List<Product> lowStockProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLowStock();
  }

  Future<void> loadLowStock() async {
    try {
      final products = await ProductService.getLowStockProducts();

      if (!mounted) return;

      setState(() {
        lowStockProducts = products;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading low stock: $e"),
        ),
      );
    }
  }

  Widget buildProductCard(Product product) {
    final bool outOfStock = product.quantity <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 110,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Warning icon
              CircleAvatar(
                radius: 25,
                backgroundColor: outOfStock ? Colors.red : Colors.orange,
                child: Icon(
                  outOfStock ? Icons.remove_shopping_cart : Icons.warning_amber,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              // Product information
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Category: ${product.category}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Barcode: ${product.barcode}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Stock information
              SizedBox(
                width: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Stock",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.quantity.toString(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: outOfStock ? Colors.red : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Low Stock"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadLowStock,
              child: lowStockProducts.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 150),
                        Icon(
                          Icons.check_circle,
                          size: 80,
                          color: Colors.green,
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            "No low-stock products",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Text(
                            "All products have sufficient stock.",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: lowStockProducts.length,
                      itemBuilder: (context, index) {
                        return buildProductCard(
                          lowStockProducts[index],
                        );
                      },
                    ),
            ),
    );
  }
}
