import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/supplier.dart';
import '../services/product_service.dart';
import '../services/supplier_service.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;
  const AddProductScreen({
    super.key,
    this.product,
  });
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _categoryController = TextEditingController();
  final _barcodeController = TextEditingController();
  List<Supplier> _suppliers = [];
  int? _selectedSupplierId;
  bool get isEditing => widget.product != null;
  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _costPriceController.text = widget.product!.costPrice.toStringAsFixed(2);
      _priceController.text = widget.product!.price.toStringAsFixed(2);
      _quantityController.text = widget.product!.quantity.toString();
      _categoryController.text = widget.product!.category;
      _barcodeController.text = widget.product!.barcode;
      _selectedSupplierId = widget.product!.supplierId;
    }
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    final suppliers = await SupplierService.getSuppliers();
    if (!mounted) return;
    setState(() {
      _suppliers = suppliers;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costPriceController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_nameController.text.trim().isEmpty ||
        _costPriceController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _quantityController.text.trim().isEmpty ||
        _categoryController.text.trim().isEmpty ||
        _barcodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields"),
        ),
      );
      return;
    }
    final costPrice = double.tryParse(_costPriceController.text.trim());
    final sellingPrice = double.tryParse(_priceController.text.trim());
    final quantity = int.tryParse(_quantityController.text.trim());
    if (costPrice == null || sellingPrice == null || quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter valid numbers for price and quantity",
          ),
        ),
      );
      return;
    }
    final product = Product(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      costPrice: costPrice,
      price: sellingPrice,
      quantity: quantity,
      category: _categoryController.text.trim(),
      barcode: _barcodeController.text.trim(),
      supplierId: _selectedSupplierId,
    );
    if (isEditing) {
      await ProductService.updateProduct(product);
    } else {
      await ProductService.addProduct(product);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? "Product updated successfully!"
              : "Product saved successfully!",
        ),
      ),
    );
    Navigator.pop(context, true);
  }

  Widget _buildTextField({
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit Product" : "Add Product",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildTextField(
              controller: _nameController,
              label: "Product Name",
            ),
            _buildTextField(
              controller: _costPriceController,
              label: "Cost Price",
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            _buildTextField(
              controller: _priceController,
              label: "Selling Price",
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            _buildTextField(
              controller: _quantityController,
              label: "Quantity",
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              controller: _barcodeController,
              label: "Barcode",
            ),
            _buildTextField(
              controller: _categoryController,
              label: "Category",
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<int>(
              value: _selectedSupplierId,
              decoration: const InputDecoration(
                labelText: "Supplier",
                border: OutlineInputBorder(),
              ),
              items: _suppliers.map((supplier) {
                return DropdownMenuItem<int>(
                  value: supplier.id,
                  child: Text(supplier.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSupplierId = value;
                });
              },
              hint: const Text("Select supplier"),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProduct,
                child: Text(
                  isEditing ? "Update Product" : "Save Product",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
