import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class InventoryReportScreen extends StatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  List<Product> products = [];

  bool isLoading = true;

  int totalProducts = 0;
  int totalUnits = 0;
  int lowStockProducts = 0;
  int outOfStockProducts = 0;

  double totalCostValue = 0;
  double totalSellingValue = 0;
  double potentialProfit = 0;

  static const int lowStockLimit = 5;

  @override
  void initState() {
    super.initState();
    loadInventoryReport();
  }

  Future<void> loadInventoryReport() async {
    try {
      final loadedProducts = await ProductService.getProducts();

      int units = 0;
      int lowStock = 0;
      int outOfStock = 0;

      double costValue = 0;
      double sellingValue = 0;

      for (final product in loadedProducts) {
        units += product.quantity;

        costValue += product.quantity * product.costPrice;

        sellingValue += product.quantity * product.price;

        if (product.quantity <= 0) {
          outOfStock++;
        } else if (product.quantity <= lowStockLimit) {
          lowStock++;
        }
      }

      if (!mounted) return;

      setState(() {
        products = loadedProducts;

        totalProducts = loadedProducts.length;
        totalUnits = units;

        lowStockProducts = lowStock;
        outOfStockProducts = outOfStock;

        totalCostValue = costValue;
        totalSellingValue = sellingValue;

        potentialProfit = sellingValue - costValue;

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
            "Error loading inventory report: $e",
          ),
        ),
      );
    }
  }

  Widget buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildValueCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStockStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Stock Status",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.inventory_2,
                        size: 32,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        totalUnits.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Units in Stock",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        size: 32,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lowStockProducts.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Low Stock",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.remove_shopping_cart,
                        size: 32,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        outOfStockProducts.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Out of Stock",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProductList() {
    if (products.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: const [
              Icon(
                Icons.inventory_2,
                size: 60,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text(
                "No products available",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sortedProducts = List<Product>.from(products)
      ..sort(
        (a, b) => a.quantity.compareTo(b.quantity),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Inventory",
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...sortedProducts.map(
          (product) {
            final bool outOfStock = product.quantity <= 0;

            final bool lowStock =
                product.quantity > 0 && product.quantity <= lowStockLimit;

            Color statusColor;

            String statusText;

            if (outOfStock) {
              statusColor = Colors.red;
              statusText = "OUT OF STOCK";
            } else if (lowStock) {
              statusColor = Colors.orange;
              statusText = "LOW STOCK";
            } else {
              statusColor = Colors.green;
              statusText = "IN STOCK";
            }

            final double productValue = product.quantity * product.costPrice;

            return Card(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.12),
                      child: Icon(
                        outOfStock
                            ? Icons.remove_shopping_cart
                            : Icons.inventory_2,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.category,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Cost value: R${productValue.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.quantity.toString(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        Text(
                          "units",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Inventory Report",
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loadInventoryReport,
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadInventoryReport,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    "Inventory Overview",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "View your current stock levels and inventory value.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Product count + units
                  Row(
                    children: [
                      buildSummaryCard(
                        "Products",
                        totalProducts.toString(),
                        Icons.inventory,
                        Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      buildSummaryCard(
                        "Units",
                        totalUnits.toString(),
                        Icons.inventory_2,
                        Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Low stock + out of stock
                  Row(
                    children: [
                      buildSummaryCard(
                        "Low Stock",
                        lowStockProducts.toString(),
                        Icons.warning_amber,
                        Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      buildSummaryCard(
                        "Out of Stock",
                        outOfStockProducts.toString(),
                        Icons.remove_shopping_cart,
                        Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  buildValueCard(
                    "Inventory Cost Value",
                    "R${totalCostValue.toStringAsFixed(2)}",
                    Icons.account_balance_wallet,
                    Colors.orange,
                  ),

                  buildValueCard(
                    "Inventory Selling Value",
                    "R${totalSellingValue.toStringAsFixed(2)}",
                    Icons.sell,
                    Colors.blue,
                  ),

                  buildValueCard(
                    "Potential Gross Profit",
                    "R${potentialProfit.toStringAsFixed(2)}",
                    Icons.trending_up,
                    potentialProfit >= 0 ? Colors.green : Colors.red,
                  ),

                  const SizedBox(height: 6),

                  buildStockStatusCard(),

                  const SizedBox(height: 20),

                  buildProductList(),
                ],
              ),
            ),
    );
  }
}
