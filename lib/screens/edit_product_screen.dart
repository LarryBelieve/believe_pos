import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/supplier.dart';
import '../services/product_service.dart';
import '../services/supplier_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController costPriceController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  late TextEditingController categoryController;
  late TextEditingController barcodeController;

  List<Supplier> suppliers = [];
  int? selectedSupplierId;

  bool isLoadingSuppliers = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.product.name,
    );

    costPriceController = TextEditingController(
      text: widget.product.costPrice.toStringAsFixed(2),
    );

    priceController = TextEditingController(
      text: widget.product.price.toStringAsFixed(2),
    );

    quantityController = TextEditingController(
      text: widget.product.quantity.toString(),
    );

    categoryController = TextEditingController(
      text: widget.product.category,
    );

    barcodeController = TextEditingController(
      text: widget.product.barcode,
    );

    selectedSupplierId = widget.product.supplierId;

    loadSuppliers();
  }

  @override
  void dispose() {
    nameController.dispose();
    costPriceController.dispose();
    priceController.dispose();
    quantityController.dispose();
    categoryController.dispose();
    barcodeController.dispose();

    super.dispose();
  }

  Future<void> loadSuppliers() async {
    try {
      final loadedSuppliers = await SupplierService.getSuppliers();

      if (!mounted) return;

      setState(() {
        suppliers = loadedSuppliers;
        isLoadingSuppliers = false;

        // Make sure the old supplier still exists.
        if (selectedSupplierId != null &&
            !suppliers.any(
              (supplier) => supplier.id == selectedSupplierId,
            )) {
          selectedSupplierId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingSuppliers = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error loading suppliers: $e",
          ),
        ),
      );
    }
  }

  Future<void> saveProduct() async {
    final name = nameController.text.trim();
    final costPriceText = costPriceController.text.trim();
    final priceText = priceController.text.trim();
    final quantityText = quantityController.text.trim();
    final category = categoryController.text.trim();
    final barcode = barcodeController.text.trim();

    if (name.isEmpty ||
        costPriceText.isEmpty ||
        priceText.isEmpty ||
        quantityText.isEmpty ||
        category.isEmpty ||
        barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill in all product fields.",
          ),
        ),
      );
      return;
    }

    final double? costPrice = double.tryParse(costPriceText);

    final double? price = double.tryParse(priceText);

    final int? quantity = int.tryParse(quantityText);

    if (costPrice == null || costPrice < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter a valid cost price.",
          ),
        ),
      );
      return;
    }

    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter a valid selling price.",
          ),
        ),
      );
      return;
    }

    if (quantity == null || quantity < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter a valid quantity.",
          ),
        ),
      );
      return;
    }

    if (widget.product.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to update this product.",
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final updatedProduct = Product(
        id: widget.product.id,
        name: name,
        costPrice: costPrice,
        price: price,
        quantity: quantity,
        category: category,
        barcode: barcode,
        supplierId: selectedSupplierId,
      );

      await ProductService.updateProduct(
        updatedProduct,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Product updated successfully!",
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error updating product: $e",
          ),
        ),
      );
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double profit = widget.product.price - widget.product.costPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            buildTextField(
              controller: nameController,
              label: "Product Name",
            ),

            buildTextField(
              controller: costPriceController,
              label: "Cost Price",
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            buildTextField(
              controller: priceController,
              label: "Selling Price",
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            buildTextField(
              controller: quantityController,
              label: "Quantity",
              keyboardType: TextInputType.number,
            ),

            buildTextField(
              controller: categoryController,
              label: "Category",
            ),

            buildTextField(
              controller: barcodeController,
              label: "Barcode",
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 4),

            // Supplier
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
              ),
              child: isLoadingSuppliers
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : DropdownButtonFormField<int?>(
                      value: selectedSupplierId,
                      decoration: const InputDecoration(
                        labelText: "Supplier",
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text("No Supplier"),
                        ),
                        ...suppliers.map(
                          (supplier) {
                            return DropdownMenuItem<int?>(
                              value: supplier.id,
                              child: Text(
                                supplier.name,
                              ),
                            );
                          },
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedSupplierId = value;
                        });
                      },
                    ),
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Current Profit / Unit",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "R${profit.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: profit >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveProduct,
                icon: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.save,
                      ),
                label: Text(
                  isSaving ? "Saving..." : "Save Changes",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
