import 'package:flutter/material.dart';
import '../services/product_service.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
            ),
          );

          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      body: ProductService.products.isEmpty
          ? const Center(
              child: Text(
                'No products yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              itemCount: ProductService.products.length,
              itemBuilder: (context, index) {
                final product = ProductService.products[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.inventory),
                    title: Text(product.name),
                    subtitle: Text(
                      'Category: ${product.category}\n'
                      'Price: R${product.price}\n'
                      'Quantity: ${product.quantity}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}