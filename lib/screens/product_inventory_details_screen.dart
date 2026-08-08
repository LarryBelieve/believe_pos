import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/supplier.dart';
import '../models/stock_movement.dart';

import '../services/supplier_service.dart';
import '../services/stock_movement_service.dart';

class ProductInventoryDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductInventoryDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductInventoryDetailsScreen> createState() =>
      _ProductInventoryDetailsScreenState();
}

class _ProductInventoryDetailsScreenState
    extends State<ProductInventoryDetailsScreen> {
  List<StockMovement> movements = [];
  Supplier? supplier;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final loadedMovements = await StockMovementService.getMovementsForProduct(
        widget.product.id!,
      );

      final suppliers = await SupplierService.getSuppliers();

      Supplier? loadedSupplier;

      for (final item in suppliers) {
        if (item.id == widget.product.supplierId) {
          loadedSupplier = item;
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        movements = loadedMovements;
        supplier = loadedSupplier;
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
            'Error loading inventory details: $e',
          ),
        ),
      );
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

  Widget buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
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

  Widget buildMovementCard(StockMovement movement) {
    final color = movementColor(movement.movementType);
    final icon = movementIcon(movement.movementType);

    final bool increased = movement.quantity >= 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(
                    icon,
                    color: color,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    movement.movementType,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                Text(
                  increased ? '+${movement.quantity}' : '${movement.quantity}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stock Before',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movement.stockBefore.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.grey,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Stock After',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movement.stockAfter.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    formatDate(movement.movementDate),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            if (movement.note != null && movement.note!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notes,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      movement.note!,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final double profit = product.price - product.costPrice;

    final double stockValue = product.quantity * product.costPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventory Details',
        ),
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // Product header
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 32,
                            child: Icon(
                              Icons.inventory_2,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  product.category,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Current stock
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const Text(
                            'CURRENT STOCK',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.quantity.toString(),
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: product.quantity <= 5
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'units available',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Inventory summary
                  Row(
                    children: [
                      buildSummaryCard(
                        'Cost Price',
                        'R${product.costPrice.toStringAsFixed(2)}',
                        Icons.payments,
                        Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      buildSummaryCard(
                        'Selling Price',
                        'R${product.price.toStringAsFixed(2)}',
                        Icons.sell,
                        Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      buildSummaryCard(
                        'Profit / Unit',
                        'R${profit.toStringAsFixed(2)}',
                        Icons.trending_up,
                        profit >= 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      buildSummaryCard(
                        'Stock Value',
                        'R${stockValue.toStringAsFixed(2)}',
                        Icons.account_balance_wallet,
                        Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Product information
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product Information',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.business),
                              const SizedBox(width: 10),
                              const Text(
                                'Supplier:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  supplier?.name ?? 'No supplier',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.qr_code),
                              const SizedBox(width: 10),
                              const Text(
                                'Barcode:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  product.barcode,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Stock Movement History',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  movements.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                children: const [
                                  Icon(
                                    Icons.history,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'No stock movements yet.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: movements.map(buildMovementCard).toList(),
                        ),
                ],
              ),
            ),
    );
  }
}
