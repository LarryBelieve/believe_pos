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
  // ============================================================
  // BELIEVE POS COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFF080D0F);
  static const Color cardColor = Color(0xFF11171A);
  static const Color cardBorderColor = Color(0xFF252D31);

  static const Color primaryGreen = Color(0xFF16A34A);
  static const Color darkGreen = Color(0xFF005C3B);
  static const Color lightGreen = Color(0xFF22C55E);

  static const Color textWhite = Color(0xFFF5F7F8);
  static const Color textGrey = Color(0xFF9CA6AD);

  // ============================================================
  // DATA
  // ============================================================

  List<Product> products = [];

  bool isLoading = true;

  String searchQuery = '';

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

  Future<void> _loadProducts() async {
    try {
      final loadedProducts = await ProductService.getProducts();

      if (!mounted) return;

      setState(() {
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
          backgroundColor: Colors.red.shade700,
          content: Text(
            "Error loading products: $e",
          ),
        ),
      );
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  List<Product> get filteredProducts {
    if (searchQuery.trim().isEmpty) {
      return products;
    }

    final query = searchQuery.toLowerCase();

    return products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.barcode.toLowerCase().contains(query);
    }).toList();
  }

  // ============================================================
  // BARCODE SCANNER
  // ============================================================

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
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: const Text(
            "Product not found.",
          ),
        ),
      );

      return;
    }

    _addProductToCart(product);
  }

  // ============================================================
  // ADD PRODUCT TO CART
  // ============================================================

  void _addProductToCart(Product product) {
    final added = CartService.addToCart(product);

    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
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
        backgroundColor: primaryGreen,
        duration: const Duration(seconds: 1),
        content: Text(
          "${product.name} added to cart.",
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget buildProductCard(Product product) {
    final bool inStock = product.quantity > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cardBorderColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            // PRODUCT ICON
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: darkGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                inStock
                    ? Icons.shopping_bag_outlined
                    : Icons.remove_shopping_cart_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // PRODUCT INFORMATION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Text(
                        "R${product.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: lightGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "•",
                        style: TextStyle(
                          color: textGrey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Stock: ${product.quantity}",
                        style: const TextStyle(
                          color: textGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ADD BUTTON
            GestureDetector(
              onTap: () {
                if (inStock) {
                  _addProductToCart(product);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red.shade700,
                      content: Text(
                        "${product.name} is out of stock.",
                      ),
                    ),
                  );
                }
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: inStock ? primaryGreen : Colors.grey.shade800,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  inStock ? Icons.add : Icons.remove,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CART SECTION
  // ============================================================

  Widget buildCartSection() {
    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: CartService.cartItems,
      builder: (context, cartItems, _) {
        final cartTotal = cartItems.fold<double>(
          0,
          (sum, item) => sum + item.total,
        );

        return Container(
          margin: const EdgeInsets.only(
            top: 16,
            bottom: 20,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cardBorderColor,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // CART HEADER
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: primaryGreen,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Shopping Cart",
                        style: TextStyle(
                          color: textWhite,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2226),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${cartItems.length} "
                        "${cartItems.length == 1 ? 'item' : 'items'}",
                        style: const TextStyle(
                          color: textGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // CART CONTENT
                SizedBox(
                  height: cartItems.isEmpty ? 290 : 280,
                  child: cartItems.isEmpty
                      ? buildEmptyCart()
                      : ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];

                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: 8,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF171E22),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: const TextStyle(
                                            color: textWhite,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "Qty: ${item.quantity}",
                                          style: const TextStyle(
                                            color: textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "R${item.total.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: lightGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                const Divider(
                  color: cardBorderColor,
                  height: 1,
                ),

                const SizedBox(height: 20),

                // TOTAL
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "R${cartTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: lightGreen,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // CHECKOUT BUTTON
                SizedBox(
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: cartItems.isEmpty
                        ? null
                        : () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CheckoutScreen(),
                              ),
                            );

                            await _loadProducts();
                          },
                    icon: const Icon(
                      Icons.credit_card,
                      size: 25,
                    ),
                    label: const Text(
                      "Checkout",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF20282C),
                      disabledForegroundColor: const Color(0xFF667078),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // EMPTY CART
  // ============================================================

  Widget buildEmptyCart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: const BoxDecoration(
            color: Color(0xFF1A2125),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shopping_cart_outlined,
            color: textGrey,
            size: 55,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Cart is empty",
          style: TextStyle(
            color: textWhite,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Add products to get started",
          style: TextStyle(
            color: textGrey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final displayedProducts = filteredProducts;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "New Sale",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.qr_code_scanner,
              size: 28,
            ),
            tooltip: "Scan Barcode",
            onPressed: _scanBarcode,
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            )
          : RefreshIndicator(
              color: primaryGreen,
              backgroundColor: cardColor,
              onRefresh: _loadProducts,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  22,
                  20,
                  22,
                  30,
                ),
                children: [
                  // ==================================================
                  // SEARCH BAR
                  // ==================================================

                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: cardBorderColor,
                      ),
                    ),
                    child: TextField(
                      style: const TextStyle(
                        color: textWhite,
                        fontSize: 16,
                      ),
                      cursorColor: primaryGreen,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "Search products by name or barcode...",
                        hintStyle: TextStyle(
                          color: textGrey,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 29,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // PRODUCTS HEADER
                  // ==================================================

                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Products",
                          style: TextStyle(
                            color: textWhite,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2226),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${displayedProducts.length}",
                          style: const TextStyle(
                            color: textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // PRODUCTS
                  // ==================================================

                  if (displayedProducts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: cardBorderColor,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: textGrey,
                            size: 55,
                          ),
                          SizedBox(height: 15),
                          Text(
                            "No products found",
                            style: TextStyle(
                              color: textWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...displayedProducts.map(
                      buildProductCard,
                    ),

                  // ==================================================
                  // SHOPPING CART
                  // ==================================================

                  buildCartSection(),
                ],
              ),
            ),
    );
  }
}
