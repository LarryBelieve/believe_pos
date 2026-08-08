import 'package:flutter/material.dart';

import '../models/stock_movement.dart';
import '../models/product.dart';
import '../services/stock_movement_service.dart';
import '../services/product_service.dart';

class StockMovementScreen extends StatefulWidget {
  const StockMovementScreen({super.key});

  @override
  State<StockMovementScreen> createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends State<StockMovementScreen> {
  List<StockMovement> movements = [];
  List<Product> products = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final loadedMovements = await StockMovementService.getMovements();

      final loadedProducts = await ProductService.getProducts();

      if (!mounted) return;

      setState(() {
        movements = loadedMovements;
        products = loadedProducts;
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
            'Error loading stock movements: $e',
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
      return 'Unknown Product';
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

      return '$day/$month/$year $hour:$minute';
    } catch (_) {
      return date;
    }
  }

  Color movementColor(String movementType) {
    final type = movementType.toLowerCase();

    if (type.contains('receive') ||
        type.contains('purchase') ||
        type.contains('add')) {
      return Colors.green;
    }

    if (type.contains('sale') || type.contains('remove')) {
      return Colors.red;
    }

    return Colors.blue;
  }

  IconData movementIcon(String movementType) {
    final type = movementType.toLowerCase();

    if (type.contains('receive') ||
        type.contains('purchase') ||
        type.contains('add')) {
      return Icons.add_box;
    }

    if (type.contains('sale') || type.contains('remove')) {
      return Icons.remove_shopping_cart;
    }

    return Icons.inventory_2;
  }

  Widget stockBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stock Movement History',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : movements.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 70,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'No stock movements yet.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Stock changes will appear here.',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: movements.length,
                    itemBuilder: (context, index) {
                      final movement = movements[index];

                      final productName = getProductName(
                        movement.productId,
                      );

                      final color = movementColor(
                        movement.movementType,
                      );

                      final icon = movementIcon(
                        movement.movementType,
                      );

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product header
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: color.withOpacity(
                                      0.15,
                                    ),
                                    child: Icon(
                                      icon,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    child: Text(
                                      productName,
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const Divider(
                                height: 25,
                              ),

                              // Movement type
                              Row(
                                children: [
                                  const Icon(
                                    Icons.swap_vert,
                                    size: 20,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  const Text(
                                    'Movement:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    movement.movementType,
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                              // Stock before/change/after
                              Row(
                                children: [
                                  stockBox(
                                    label: 'Stock Before',
                                    value: movement.stockBefore.toString(),
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  stockBox(
                                    label: 'Change',
                                    value: movement.quantity >= 0
                                        ? '+${movement.quantity}'
                                        : movement.quantity.toString(),
                                    color: color,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  stockBox(
                                    label: 'Stock After',
                                    value: movement.stockAfter.toString(),
                                    color: Colors.green,
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                              // Date
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  const Text(
                                    'Date:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Text(
                                      formatDate(
                                        movement.movementDate,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Note
                              if (movement.note != null &&
                                  movement.note!.trim().isNotEmpty) ...[
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.description,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        movement.note!,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
