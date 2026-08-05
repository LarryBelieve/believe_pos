import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  static final ValueNotifier<List<CartItem>> cartItems = ValueNotifier([]);

  static void addToCart(Product product) {
    final items = List<CartItem>.from(cartItems.value);
    final index = items.indexWhere(
      (item) => item.product.name == product.name,
    );

    if (index >= 0) {
      items[index].quantity++;
    } else {
      items.add(CartItem(product: product));
    }

    cartItems.value = items;
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
