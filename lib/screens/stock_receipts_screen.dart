import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/supplier.dart';
import '../models/stock_movement.dart';
import '../services/product_service.dart';
import '../services/supplier_service.dart';
import '../services/stock_movement_service.dart';

class StockReceiptsScreen extends StatefulWidget {
  const StockReceiptsScreen({super.key});

  @override
  State<StockReceiptsScreen> createState() => _StockReceiptsScreenState();
}

class _StockReceiptsScreenState extends State<StockReceiptsScreen> {
  List<StockMovement> movements = [];
  List<Product> products = [];
  List<Supplier> suppliers = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final loadedMovements = await StockMovementService.getMovements();

      final loadedProducts = await ProductService.getProducts();

      final loadedSuppliers = await SupplierService.getSuppliers();

      if (!mounted) return;

      setState(() {
        movements = loadedMovements;
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
            "Error loading stock history: $e",
          ),
        ),
      );
    }
  }

  String getProductName(int productId) {
    try {
      final product = products.firstWhere(
        (product) => product.id == productId,
      );

      return product.name;
    } catch (_) {
      return "Unknown Product";
    }
  }

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);

      final day = parsedDate.day.toString().padLeft(2, '0');

      final month = parsedDate.month.toString().padLeft(2, '0');

      final year = parsedDate.year.toString();

      final hour = parsedDate.hour.toString().padLeft(2, '0');

      final minute = parsedDate.minute.toString().padLeft(2, '0');

      return "$day/$month/$year $hour:$minute";
    } catch (_) {
      return date;
    }
  }

  IconData getMovementIcon(String type) {
    switch (type.toUpperCase()) {
      case 'RECEIVED':
        return Icons.add_circle;

      case 'SALE':
        return Icons.remove_circle;

      case 'ADJUSTMENT':
        return Icons.edit;

      default:
        return Icons.inventory;
    }
  }

  Color getMovementColor(String type) {
    switch (type.toUpperCase()) {
      case 'RECEIVED':
        return Colors.green;

      case 'SALE':
        return Colors.red;

      case 'ADJUSTMENT':
        return Colors.orange;

      default:
        return Colors.blue;
    }
  }

  String getMovementTitle(String type) {
    switch (type.toUpperCase()) {
      case 'RECEIVED':
        return "Stock Received";

      case 'SALE':
        return "Stock Sold";

      case 'ADJUSTMENT':
        return "Stock Adjustment";

      default:
        return type;
    }
  }

  Widget buildMovementCard(
    StockMovement movement,
  ) {
    final productName = getProductName(movement.productId);

    final color = getMovementColor(movement.movementType);

    final icon = getMovementIcon(movement.movementType);

    final title = getMovementTitle(movement.movementType);

    final isIncrease = movement.quantity > 0;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatDate(
                      movement.movementDate,
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  if (movement.note != null &&
                      movement.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      movement.note!,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "${isIncrease ? '+' : ''}${movement.quantity}",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stock History",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : movements.isEmpty
              ? RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 180),
                      Icon(
                        Icons.history,
                        size: 70,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 15),
                      Center(
                        child: Text(
                          "No stock movements yet.",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: Text(
                          "Stock received and sales will appear here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: movements.length,
                    itemBuilder: (context, index) {
                      return buildMovementCard(
                        movements[index],
                      );
                    },
                  ),
                ),
    );
  }
}
