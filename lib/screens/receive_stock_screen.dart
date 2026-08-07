import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/supplier.dart';
import '../models/stock_receipt.dart';
import '../services/product_service.dart';
import '../services/supplier_service.dart';
import '../services/stock_receipt_service.dart';

class ReceiveStockScreen extends StatefulWidget {
  const ReceiveStockScreen({super.key});
  @override
  State<ReceiveStockScreen> createState() => _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends State<ReceiveStockScreen> {
  List<Product> products = [];
  List<Supplier> suppliers = [];
  Product? selectedProduct;
  Supplier? selectedSupplier;
  final quantityController = TextEditingController();
  final costPriceController = TextEditingController();
  bool isLoading = true;
  bool isSaving = false;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    quantityController.dispose();
    costPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
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
          content: Text("Error loading data: $e"),
        ),
      );
    }
  }

  Future<void> _receiveStock() async {
    if (selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a product."),
        ),
      );
      return;
    }
    if (selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a supplier."),
        ),
      );
      return;
    }
    final quantity = int.tryParse(
      quantityController.text.trim(),
    );
    final costPrice = double.tryParse(
      costPriceController.text.trim(),
    );
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid quantity."),
        ),
      );
      return;
    }
    if (costPrice == null || costPrice < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid cost price."),
        ),
      );
      return;
    }
    setState(() {
      isSaving = true;
    });
    try {
      final receipt = StockReceipt(
        productId: selectedProduct!.id!,
        supplierId: selectedSupplier!.id,
        quantity: quantity,
        costPrice: costPrice,
        receiptDate: DateTime.now().toIso8601String(),
      );
      await StockReceiptService.receiveStock(
        receipt: receipt,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Stock received successfully!",
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error receiving stock: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receive Stock"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const Text(
                    "Receive New Stock",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Product
                  DropdownButtonFormField<Product>(
                    value: selectedProduct,
                    decoration: const InputDecoration(
                      labelText: "Product",
                      border: OutlineInputBorder(),
                    ),
                    items: products.map((product) {
                      return DropdownMenuItem<Product>(
                        value: product,
                        child: Text(
                          "${product.name} "
                          "(Stock: ${product.quantity})",
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProduct = value;
                        if (value != null && value.costPrice > 0) {
                          costPriceController.text =
                              value.costPrice.toStringAsFixed(2);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  // Supplier
                  DropdownButtonFormField<Supplier>(
                    value: selectedSupplier,
                    decoration: const InputDecoration(
                      labelText: "Supplier",
                      border: OutlineInputBorder(),
                    ),
                    items: suppliers.map((supplier) {
                      return DropdownMenuItem<Supplier>(
                        value: supplier,
                        child: Text(supplier.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSupplier = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  // Quantity
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Quantity Received",
                      hintText: "e.g. 50",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Cost price
                  TextField(
                    controller: costPriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Cost Price",
                      hintText: "e.g. 8.50",
                      prefixText: "R ",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.inventory_2,
                            ),
                      label: Text(
                        isSaving ? "Saving..." : "Receive Stock",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      onPressed: isSaving ? null : _receiveStock,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
