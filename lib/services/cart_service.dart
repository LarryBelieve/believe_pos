import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  static final ValueNotifier<List<CartItem>> cartItems = ValueNotifier([]);
  static bool addToCart(Product product) {
    final items = List<CartItem>.from(cartItems.value);
    final index = items.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index >= 0) {
      // Check whether there is enough stock.
      if (items[index].quantity >= product.quantity) {
        return false;
      }
      items[index].quantity++;
    } else {
      // Product has no stock.
      if (product.quantity <= 0) {
        return false;
      }
      items.add(
        CartItem(
          product: product,
        ),
      );
    }
    cartItems.value = items;
    return true;
  }

  static double get total {
    return cartItems.value.fold(
      0,
      (sum, item) => sum + item.total,
    );
  }

  static void clearCart() {
    cartItems.value = [];
  }
}
