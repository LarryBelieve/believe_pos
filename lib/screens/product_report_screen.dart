import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductReportScreen extends StatefulWidget {
  const ProductReportScreen({super.key});

  @override
  State<ProductReportScreen> createState() => _ProductReportScreenState();
}

class _ProductReportScreenState extends State<ProductReportScreen> {
  List<Product> products = [];

  bool isLoading = true;

  int totalProducts = 0;
  int totalUnits = 0;

  double totalCostValue = 0;
  double totalSellingValue = 0;
  double potentialProfit = 0;

  static const int lowStockLimit = 5;

  @override
  void initState() {
    super.initState();
    loadProductReport();
  }

  Future<void> loadProductReport() async {
    try {
      final loadedProducts = await ProductService.getProducts();

      int units = 0;

      double costValue = 0;
      double sellingValue = 0;

      for (final product in loadedProducts) {
        units += product.quantity;

        costValue += product.quantity * product.costPrice;

        sellingValue += product.quantity * product.price;
      }

      if (!mounted) return;

      setState(() {
        products = loadedProducts;

        totalProducts = loadedProducts.length;

        totalUnits = units;

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
            "Error loading product report: $e",
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
      margin: const EdgeInsets.only(bottom: 12),
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
                      fontSize: 23,
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

  Widget buildProductCard(Product product) {
    final bool outOfStock = product.quantity <= 0;

    final bool lowStock =
        product.quantity > 0 && product.quantity <= lowStockLimit;

    final double profitPerUnit = product.price - product.costPrice;

    final double stockCostValue = product.quantity * product.costPrice;

    final double stockSellingValue = product.quantity * product.price;

    final double stockProfit = stockSellingValue - stockCostValue;

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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.12),
                  child: Icon(
                    outOfStock ? Icons.remove_shopping_cart : Icons.inventory_2,
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
                          fontSize: 18,
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
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSmallInfo(
                    "Stock",
                    product.quantity.toString(),
                  ),
                ),
                Expanded(
                  child: _buildSmallInfo(
                    "Cost Price",
                    "R${product.costPrice.toStringAsFixed(2)}",
                  ),
                ),
                Expanded(
                  child: _buildSmallInfo(
                    "Selling Price",
                    "R${product.price.toStringAsFixed(2)}",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSmallInfo(
                    "Profit / Unit",
                    "R${profitPerUnit.toStringAsFixed(2)}",
                    valueColor: profitPerUnit >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildSmallInfo(
                    "Stock Cost",
                    "R${stockCostValue.toStringAsFixed(2)}",
                  ),
                ),
                Expanded(
                  child: _buildSmallInfo(
                    "Stock Profit",
                    "R${stockProfit.toStringAsFixed(2)}",
                    valueColor: stockProfit >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallInfo(
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Product Report",
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loadProductReport,
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
              onRefresh: loadProductReport,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    "Product Overview",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Review your products, pricing, stock and potential profit.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                        "Total Units",
                        totalUnits.toString(),
                        Icons.inventory_2,
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      buildSummaryCard(
                        "Cost Value",
                        "R${totalCostValue.toStringAsFixed(2)}",
                        Icons.account_balance_wallet,
                        Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      buildSummaryCard(
                        "Selling Value",
                        "R${totalSellingValue.toStringAsFixed(2)}",
                        Icons.sell,
                        Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      buildSummaryCard(
                        "Potential Profit",
                        "R${potentialProfit.toStringAsFixed(2)}",
                        Icons.trending_up,
                        potentialProfit >= 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 10),
                      buildSummaryCard(
                        "Low Stock",
                        products
                            .where(
                              (product) => product.quantity <= lowStockLimit,
                            )
                            .length
                            .toString(),
                        Icons.warning_amber,
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "All Products",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (products.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          30,
                        ),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.inventory_2,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No products available.",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...products.map(
                      buildProductCard,
                    ),
                ],
              ),
            ),
    );
  }
}
