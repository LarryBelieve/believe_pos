import 'package:flutter/material.dart';
import 'checkout_screen.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import 'barcode_scanner_screen.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});
  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  List<Product> products = [];
  bool isLoading = true;
  String searchQuery = '';
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _scanBarcode() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const BarcodeScannerScreen(),
      ),
    );
    if (barcode == null) return;
    final Product? product = await ProductService.getProductByBarcode(barcode);
    if (!mounted) return;
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product not found."),
        ),
      );
      return;
    }
    final added = CartService.addToCart(product);
    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            product.quantity <= 0
                ? "${product.name} is out of stock."
                : "Not enough ${product.name} in stock.",
          ),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.name} added to cart."),
      ),
    );
  }

  Future<void> _loadProducts() async {
    final loadedProducts = await ProductService.getProducts();
    if (!mounted) return;
    setState(() {
      products = loadedProducts;
      isLoading = false;
    });
  }

  List<Product> get filteredProducts {
    if (searchQuery.isEmpty) {
      return products;
    }
    return products.where((product) {
      return product.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  void _addProductToCart(Product product) {
    final added = CartService.addToCart(product);
    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            product.quantity <= 0
                ? "${product.name} is out of stock."
                : "Not enough ${product.name} in stock.",
          ),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.name} added to cart."),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Sale"),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: "Scan Barcode",
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search Products",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Products",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredProducts.isEmpty
                    ? const Center(
                        child: Text("No products available"),
                      )
                    : ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Icon(
                                  product.quantity > 0
                                      ? Icons.shopping_bag
                                      : Icons.remove_shopping_cart,
                                ),
                              ),
                              title: Text(product.name),
                              subtitle: Text(
                                "R${product.price.toStringAsFixed(2)}"
                                " | Stock: ${product.quantity}",
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.add_circle,
                                  color: product.quantity > 0
                                      ? Colors.green
                                      : Colors.grey,
                                  size: 30,
                                ),
                                onPressed: product.quantity > 0
                                    ? () {
                                        _addProductToCart(product);
                                      }
                                    : () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "${product.name} is out of stock.",
                                            ),
                                          ),
                                        );
                                      },
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              border: Border(
                top: BorderSide(color: Colors.grey),
              ),
            ),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Shopping Cart",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 240,
                  child: ValueListenableBuilder<List<CartItem>>(
                    valueListenable: CartService.cartItems,
                    builder: (context, cartItems, _) {
                      final cartTotal = cartItems.fold<double>(
                        0,
                        (sum, item) => sum + item.total,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: cartItems.isEmpty
                                ? const Center(
                                    child: Text("Cart is empty"),
                                  )
                                : ListView.builder(
                                    itemCount: cartItems.length,
                                    itemBuilder: (context, index) {
                                      final item = cartItems[index];
                                      return ListTile(
                                        title: Text(item.product.name),
                                        subtitle: Text(
                                          "Qty: ${item.quantity}",
                                        ),
                                        trailing: Text(
                                          "R${item.total.toStringAsFixed(2)}",
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "R${cartTotal.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: cartItems.isEmpty
                                  ? null
                                  : () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const CheckoutScreen(),
                                        ),
                                      );
                                      // Reload stock after returning
                                      // from checkout.
                                      _loadProducts();
                                    },
                              child: const Text("Checkout"),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
